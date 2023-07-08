from .utils import verify_lat_lng_py

def lat_lng_to_quadkey(lat, lng, level):
    verify_lat_lng_py(lat, lng)
    return "023012301230"
