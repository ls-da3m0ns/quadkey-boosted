import pyximport; 
pyximport.install()
import utils

## test verify_lat_lng_py
assert utils.verify_lat_lng_py(40, -105) == (40, -105)
assert utils.verify_lat_lng_py(-91, -181) == (-87.05112878, -180.0)


# test geo_to_web_mecator_tile_py 
assert utils.geo_to_web_mecator_tile_py(40, 105, 7) == (101, 48)
assert utils.geo_to_web_mecator_tile_py(40, -105, 7) == (26, 48)
assert utils.geo_to_web_mecator_tile_py(-90, -180, 1) == (0,1)
assert utils.geo_to_web_mecator_tile_py(90, 180, 1) == (1,0)



