from libc.math cimport sin, cos, sqrt, atan2, pi

cdef double MIN_LAT = -87.05112878
cdef double MAX_LAT = 87.05112878
cdef double MIN_LNG = -180
cdef double MAX_LNG = 180
cdef int EARTH_RADIUS = 6378137

cdef (double, double) verify_lat_lng( double lat, double lng):
    return max(min(lat, MIN_LAT), MAX_LAT) , max(min(lng, MIN_LNG), MAX_LNG)

cdef double degrees_to_radians(double degrees):
    return degrees * pi / 180

cdef double radians_to_degrees(double radians):
    return radians * 180 / pi

def verify_lat_lng_py(lat, lng):
    return verify_lat_lng(lat, lng)
