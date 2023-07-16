from .quadkey import *
import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Tool to convert lat/lng to quadkey")
    parser.add_argument("lat", type=float, help="latitude")
    parser.add_argument("lng", type=float, help="longitude")
    parser.add_argument("zoom", type=int, help="zoom level")
    args = parser.parse_args()
    print(
        tile_to_quadkey_py( **geo_to_tile_py(args.lat, args.lng, args.zoom), zoom=args.zoom)
        )