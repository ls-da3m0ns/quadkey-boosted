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

cdef (long,long) geo_to_web_mecator_tile(double lat, double lng, int zoom):
    cdef double lat_rad, lng_rad, Y, X, scale
    cdef long mercat_X, mercat_Y

    lat,lng = verify_lat_lng(lat, lng)
    lat_rad = degrees_to_radians(lat)

    X = ((lng/360) + 0.5) * map_width_in_pixels(zoom)
    Y = (0.5 - log ( (1 + sin(lat_rad))/(1 - sin(lat_rad)))/(4 * pi)) * map_width_in_pixels(zoom)

    mercat_X, mercat_Y = long( X ), long( Y  )

    mercat_X = min(max(mercat_X, 0), map_width_in_pixels(zoom) - 1 ) # minimum mercat_X is 0 and maximum is map_width_in_pixels(zoom) - 1
    mercat_Y = min(max(mercat_Y, 0), map_width_in_pixels(zoom) - 1 )
    
    return mercat_X, mercat_Y

cdef (double, double) web_mecator_tile_to_geo(long mercat_X, long mercat_Y, int zoom):
    cdef double lat, lng
    cdef long map_width_in_pixels_at_zoom = map_width_in_pixels(zoom)
    lng = max( min(mercat_X, map_width_in_pixels_at_zoom-1), 0)
    lat = max( min(mercat_Y, map_width_in_pixels_at_zoom-1), 0)

    lng = (lng/map_width_in_pixels_at_zoom ) - 0.5
    lat = 0.5 - (lat/map_width_in_pixels_at_zoom)

    lng = round( 360 * lng * 1e12) / 1e12
    lat = round( 90 - 360 * atan2( exp( -lat * 2 * pi), 1) / pi * 1e12) / 1e12
    return lat, lng

cdef str web_mercator_tile_to_quadkey(long X  ,long Y  ,int zoom ):
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

###Python Interface###
def verify_lat_lng_py(lat, lng):
    return verify_lat_lng(lat, lng)

def geo_to_web_mecator_tile_py(lat, lng, zoom):
    """
    Converts lat, lng to web mercator tile
    Args:
        lat: latitude
        lng: longitude
        zoom: zoom level
    Returns:
        (x, y) tuple of web mercator tile
    """
    return geo_to_web_mecator_tile(lat, lng, zoom)

def web_mecator_tile_to_geo_py(x, y, zoom):
    """
    Converts web mercator tile to lat, lng
    Args:
        x: x coordinate
        y: y coordinate
        zoom: zoom level
    Returns:
        (lat, lng) tuple of lat, lng
    """
    return web_mecator_tile_to_geo(x, y, zoom)

def web_mercator_tile_to_quadkey_py(x, y, zoom):
    """
    Converts web mercator tile to quadkey
    Args:
        x: x coordinate
        y: y coordinate
        zoom: zoom level
    Returns:
        quadkey : str
    """
    return web_mercator_tile_to_quadkey(x, y, zoom)