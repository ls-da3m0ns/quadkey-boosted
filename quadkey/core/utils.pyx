#!python
#cython: language_level=3

from libc.math cimport sin, cos, sqrt, atan2, pi, log, tan, ceil

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
