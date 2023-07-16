#!python
#cython: language_level=3

from libc.math cimport sin, cos,atan2, pi,log,round, exp

cdef double MIN_LAT = -85.05112878
cdef double MAX_LAT = 85.05112878
cdef double MIN_LNG = -180
cdef double MAX_LNG = 180
cdef int EARTH_RADIUS = 6378137
cdef double EARTH_CIRCUMFERENCE = 2 * pi * EARTH_RADIUS
cdef long BASE_RESOLUTION = 1

cdef double verify_lat(double lat):
    return min(max(lat, MIN_LAT), MAX_LAT)

cdef double verify_lng(double lng):
    return min(max(lng, MIN_LNG), MAX_LNG)


cdef (double, double) verify_lat_lng( double lat, double lng):
    return verify_lat(lat), verify_lng(lng)

cdef double degrees_to_radians(double degrees):
    return degrees * pi / 180

cdef double radians_to_degrees(double radians):
    return radians * 180 / pi

cdef long map_width_in_pixels(int zoom):
    # at zoom of 1 its is 512 pixels for bing tiles vs 2 for indexing use cases
    return BASE_RESOLUTION << zoom

cdef double meters_per_pixel(double lat, int zoom):
    lat = verify_lat(lat)
    return (cos( degrees_to_radians(lat)) * EARTH_CIRCUMFERENCE) / map_width_in_pixels(zoom)

cdef (long,long) geo_to_tile(double lat, double lng, int zoom):
    cdef double lat_rad, lng_rad, Y, X, scale
    cdef long tile_X, tile_Y

    lat,lng = verify_lat_lng(lat, lng)
    lat_rad = degrees_to_radians(lat)

    X = ((lng/360) + 0.5) * map_width_in_pixels(zoom)
    Y = (0.5 - log ( (1 + sin(lat_rad))/(1 - sin(lat_rad)))/(4 * pi)) * map_width_in_pixels(zoom)

    tile_X, tile_Y = long( X ), long( Y  )

    tile_X = min(max(tile_X, 0), map_width_in_pixels(zoom) - 1 ) # minimum tile_X is 0 and maximum is map_width_in_pixels(zoom) - 1
    tile_Y = min(max(tile_Y, 0), map_width_in_pixels(zoom) - 1 )
    
    return tile_X, tile_Y

cdef (double, double) tile_to_geo(long tile_X, long tile_Y, int zoom):
    cdef double lat, lng
    cdef long map_width_in_pixels_at_zoom = map_width_in_pixels(zoom)
    lng = max( min(tile_X, map_width_in_pixels_at_zoom-1), 0)
    lat = max( min(tile_Y, map_width_in_pixels_at_zoom-1), 0)

    lng = (lng/map_width_in_pixels_at_zoom ) - 0.5
    lat = 0.5 - (lat/map_width_in_pixels_at_zoom)

    lng = round( 360 * lng * 1e12) / 1e12
    lat = round( (90 - 360 * atan2( exp( -lat * 2 * pi), 1) / pi) * 1e12) / 1e12
    return lat, lng

cdef str tile_to_quadkey(long X  ,long Y  ,int zoom ):
    cdef str quadkey = ""
    cdef long mask
    for i in range(zoom, 0, -1):
        mask = 1 << (i - 1)
        digit = 0
        if (X & mask) != 0:
            digit += 1
        if (Y & mask) != 0:
            digit += 2
        quadkey += str(digit)
    return quadkey[:zoom]

cdef str geo_to_quadkey(double lat, double lng, int zoom):
    cdef long X, Y
    X, Y = geo_to_tile(lat, lng, zoom)
    return tile_to_quadkey(X, Y, zoom)

cdef (long, long, int) quadkey_to_tile(str quadkey):
    cdef long X, Y, mask
    cdef int zoom 
    cdef long i
    X,Y = 0,0
    zoom = len(quadkey)

    for i in range(zoom):
        mask = 1 << (zoom -i - 1)
        if quadkey[i] == '1':
            X |= mask
        elif quadkey[i] == '2':
            Y |= mask
        elif quadkey[i] == '3':
            X |= mask
            Y |= mask
    return X, Y, zoom

cdef (double, double) tile_to_corner(long X ,long Y ,int zoom, int corner = 0):
    cdef double lat, lng 
    X = max( min(X, map_width_in_pixels(zoom)-1), 0)
    Y = max( min(Y, map_width_in_pixels(zoom)-1), 0)

    lng = (X/map_width_in_pixels(zoom) ) - 0.5
    lat = 0.5 - (Y/map_width_in_pixels(zoom))

    lng = round( 360 * lng * 1e12) / 1e12
    lat = round( (90 - 360 * atan2( exp( -lat * 2 * pi), 1) / pi) * 1e12) / 1e12
    if corner == 0:
        return lat, lng
    elif corner == 1:
        return lat, lng + 360 / map_width_in_pixels(zoom)
    elif corner == 2:
        return lat - 180 / map_width_in_pixels(zoom), lng
    elif corner == 3:
        return lat - 180 / map_width_in_pixels(zoom), lng + 360 / map_width_in_pixels(zoom)
    else:
        raise ValueError("corner must be 0, 1, 2, or 3")

cdef ((double, double), (double, double)) tile_to_bbox(long X, long Y, int zoom):
    return (tile_to_corner(X, Y, zoom, 0), tile_to_corner(X, Y, zoom, 3) )

#from https://github.com/joekarl/binary-quadkey and https://github.dev/muety/pyquadkey2
cpdef unsigned long long quadkey_to_quadint(str quadkey):
    cdef int zoom = len(quadkey)
    cdef int i
    cdef unsigned long long qi = 0
    cdef unsigned long bit_loc

    for i in range(zoom):
        bit_loc = (64 - ((i + 1) * 2))
        qi |= int(quadkey[i]) << bit_loc
    qi |= zoom
    return qi

cdef str quadint_to_quadkey(unsigned long long quadint):
    cdef int zoom = quadint & 0x1F
    cdef int i
    cdef unsigned long long mask = 0x8000000000000000
    cdef str quad
    for i in range(zoom):
        if quadint & mask:
            quad += '1'
        else:
            quad += '0'
        mask >>= 1
    return quad

cdef (double, double) quadkey_to_geo(str quadkey, int corner = 0):
    cdef long X, Y
    cdef int zoom
    X, Y, zoom = quadkey_to_tile(quadkey)
    return tile_to_corner(X, Y, zoom, corner)

cdef ((double, double), (double, double)) quadkey_to_bbox(str quadkey):
    cdef long X, Y
    cdef int zoom
    X, Y, zoom = quadkey_to_tile(quadkey)
    return tile_to_bbox(X, Y, zoom)

cdef (long, long, int) get_tile_parent(long X, long Y, int zoom, int parent_zoom):
    cdef long parent_X, parent_Y
    parent_X = X >> (zoom - parent_zoom)
    parent_Y = Y >> (zoom - parent_zoom)
    return parent_X, parent_Y, parent_zoom

cdef int get_tile_childrens_2(long X, long Y, int zoom, int child_zoom):
    # cdef long child_X, child_Y
    # cdef int i
    # cdef ((double,double)[]) children = []
    # for i in range(4):
    #     child_X = X << (child_zoom - zoom) + (i % 2)
    #     child_Y = Y << (child_zoom - zoom) + (i // 2)
    #     children.append(tile_to_corner(child_X, child_Y, child_zoom, 0))
    return 1

###Python Interface###
def verify_lat_lng_py(lat, lng):
    return verify_lat_lng(lat, lng)

def geo_to_tile_py(lat, lng, zoom):
    """
    Converts lat, lng to web tileor tile
    Args:
        lat: latitude
        lng: longitude
        zoom: zoom level
    Returns:
        (x, y) tuple of web tileor tile
    """
    return geo_to_tile(lat, lng, zoom)

def geo_to_quadkey_py(lat, lng, zoom):
    """
    Converts lat, lng to quadkey
    Args:
        lat: latitude
        lng: longitude
        zoom: zoom level
    Returns:
        quadkey : str
    """
    return geo_to_quadkey(lat, lng, zoom)

def geo_to_quadint_py(lat, lng, zoom):
    """
    Converts lat, lng to quadint
    Args:
        lat: latitude
        lng: longitude
        zoom: zoom level
    Returns:
        quadint : int
    """
    return quadkey_to_quadint(geo_to_quadkey(lat, lng, zoom))

def tile_to_geo_py(x, y, zoom):
    """
    Converts web tileor tile to lat, lng
    Args:
        x: x coordinate
        y: y coordinate
        zoom: zoom level
    Returns:
        (lat, lng) tuple of lat, lng
    """
    return tile_to_geo(x, y, zoom)

def tile_to_quadkey_py(x, y, zoom):
    """
    Converts web tileor tile to quadkey
    Args:
        x: x coordinate
        y: y coordinate
        zoom: zoom level
    Returns:
        quadkey : str
    """
    return tile_to_quadkey(x, y, zoom)


def tile_to_corner_py(x, y, zoom, corner = 0):
    """
    Converts web tileor tile to corner lat, lng
    Args:
        x: x coordinate
        y: y coordinate
        zoom: zoom level
        corner: corner number (top left = 0, top right = 1, bottom left = 2, bottom right = 3)
    Returns:
        (lat, lng) tuple of lat, lng
    """
    return tile_to_corner(x, y, zoom, corner)

def tile_to_bbox_py(x, y, zoom):
    """
    Converts web tileor tile to bbox
    Args:
        x: x coordinate
        y: y coordinate
        zoom: zoom level
    Returns:
        ((lat, lng), (lat, lng)) tuple of bbox (top left, bottom right)
    """
    return tile_to_bbox(x, y, zoom)

def quadkey_to_tile_py(quadkey):
    """
    Converts quadkey to web tileor tile
    Args:
        quadkey: quadkey
    Returns:
        (x, y, zoom) tuple of web tileor tile
    """
    return quadkey_to_tile(quadkey)


def quadkey_to_quadint_py(quadkey):
    """
    Converts quadkey to quadint
    Args:
        quadkey: quadkey
    Returns:
        quadint : int
    """
    return quadkey_to_quadint(quadkey)

def quadint_to_quadkey_py(quadint):
    """
    Converts quadint to quadkey
    Args:
        quadint: quadint
    Returns:
        quadkey : str
    """
    return quadint_to_quadkey(quadint)

def quadkey_to_geo_py(quadkey, corner = 0):
    """
    Converts quadkey to lat, lng
    Args:
        quadkey: quadkey
        corner: corner number (top left = 0, top right = 1, bottom left = 2, bottom right = 3)
    Returns:
        (lat, lng) tuple of lat, lng
    """ 
    return quadkey_to_geo(quadkey, corner)

def quadkey_to_parent_py(quadkey, parent_zoom=-1):
    """
    Gets top parent quadkey
    Args:
        quadkey: quadkey
    Returns:
        quadkey : str
    """
    if parent_zoom == -1:
        parent_zoom = len(quadkey) - 1
    elif parent_zoom > len(quadkey):
        raise ValueError("parent_zoom must be less than or equal to len(quadkey)")
    return quadkey[:parent_zoom]

def quadint_to_geo_py(quadint, corner = 0):
    """
    Converts quadint to lat, lng
    Args:
        quadint: quadint
        corner: corner number (top left = 0, top right = 1, bottom left = 2, bottom right = 3)
    Returns:
        (lat, lng) tuple of lat, lng
    """ 
    return quadkey_to_geo(quadint_to_quadkey(quadint), corner)

def quadint_to_bbox_py(quadint):
    """
    Converts quadint to bbox
    Args:
        quadint: quadint
    Returns:
        ((lat, lng), (lat, lng)) tuple of bbox (top left, bottom right)
    """
    return quadkey_to_bbox(quadint_to_quadkey(quadint))

def quadkey_to_bbox_py(quadkey):
    """
    Converts quadkey to bbox
    Args:
        quadkey: quadkey
    Returns:
        ((lat, lng), (lat, lng)) tuple of bbox (top left, bottom right)
    
    """
    return quadkey_to_bbox(quadkey)

def get_tile_parent_py(x, y, zoom, parent_zoom=-1):
    """
    Gets parent web tileor tile
    Args:
        x: x coordinate
        y: y coordinate
        zoom: zoom level
        parent_zoom: parent zoom level
    Returns:
        (x, y, zoom) tuple of web tileor tile
    """
    if parent_zoom == -1:
        parent_zoom = zoom - 1
    return get_tile_parent(x, y, zoom, parent_zoom)

def get_tile_childrens_py(x, y, zoom, child_zoom=-1):
    """
    Gets children web tileor tiles
    Args:
        x: x coordinate
        y: y coordinate
        zoom: zoom level
        child_zoom: child zoom levelFc
    Returns:
        [(x, y, zoom), (x, y, zoom), (x, y, zoom), (x, y, zoom)] list of web tileor tiles
    """
    if child_zoom == -1:
        child_zoom = zoom + 1
    return get_tile_childrens_2(x, y, zoom, child_zoom)
