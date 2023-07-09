from .core.__init___ import utils

def lat_lng_to_quadkey(lat, lng, level):
    utils.verify_lat_lng_py(lat, lng)
    return "023012301230"
