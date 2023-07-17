
# quadkey-boosted
[![License](https://img.shields.io/badge/License-Apache_2.0-green.svg)](https://opensource.org/licenses/Apache-2.0)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![C](https://img.shields.io/badge/c-%2300599C.svg?style=for-the-badge&logo=c&logoColor=white)
## Description
quadkey-boosted is a high-performance Python library that provides a powerful set of tools and functions for working with quadkeys, enabling seamless integration of tile-based mapping systems into your Python applications. Built on top of a blazing-fast C implementation, quadkey-boosted offers lightning-fast calculations, ensuring optimal performance even with large-scale datasets.

## Key Features
 * Available API's
   * Conversion
      * lat lng to QuadKey
      * QuadKey to lat lng
      * QuadKey to BingTile
      * BingTile to QuadKey
      * Polygon to quadQuadKeykeys
      * QuadKey to Multipolygon
   * Operations
      * get parent
      * get childrens
      * get K neighbours
   * Metadata
      * get average tile size
      * get zoom level
      * get tile distance between two tiles
      * WKT, GeoJson, WKB representation of quadkey
 * C based backend for fast calculations
 * Can handle various types of projections

## License

[![License](https://img.shields.io/badge/License-Apache_2.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

## Project Status
 * ✅ Add Basic convertion API
 * ❎ Implement advance geospatial apis
 * ❎ Add support for projections

### What is a QuadKey?

A QuadKey is a string representation of a tile's location in a quadtree hierarchy. It is used to index and address tiles at different levels of detail (zoom levels). The QuadKey system is based on dividing the Earth's surface into quadrants using a quadtree structure.

For more details on the concept, please refer to
the [Microsoft Article About this](https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system).

## Installation
### Requirements
   This library requires **Python 3.6** or higher. To compile it from source, Cython is required in addition.

### using pip
```bash
pip install quadkey-boosted
```
### From source
#### Prerequisites (`Linux`)
* `gcc`
    * Fedora: `dnf install @development-tools`
    * Ubuntu / Debian: `apt install build-essential`
* `python3-devel`
    * Fedora: `dnf install python3-devel`
    * Ubuntu / Debian: `apt install python3-dev`

#### Prerequisites (`Windows`)
* Visual C++ Build Tools 2015 (with Windows 10 SDK) (see [here](https://devblogs.microsoft.com/python/unable-to-find-vcvarsall-bat/#i-need-a-package-that-has-no-wheel-what-can-i-do))
#### Build from source
```bash
# Clone  repo
git clone https://github.com/ls-da3m0ns/quadkey-boosted

# Create Virtual Environment
python -m venv ./venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Compile 
python setup.py sdist bdist_wheel

# Install 
pip install dist/quadkey-0.0.1-cp38-cp38-linux_x86_64.whl
```
# Usage
## Basic Usage
```python
import quadkey
lat = 47.641268
lng = -122.125679
zoom = 15

# Convert lat lng to quadkey
qk = quadkey.geo_to_quadkey(lat, lng, zoom)

# Convert quadkey to lat lng
## get top left corner
lat, lng = quadkey.quadkey_to_geo(qk, corner=0)
## get bottom right corner
lat, lng = quadkey.quadkey_to_geo(qk, corner=2)

# Convert quadkey to bbox
bbox = quadkey.quadkey_to_bbox(qk)

# Convert quadkey to Tile
tl = quadkey.quadkey_to_tile(qk)

# Conver quadkey to quadint
qi = quadkey.quadkey_to_quadint(qk)

# Convert lat lng to quadint
qi = quadkey.geo_to_quadint(lat, lng, zoom)

# get parent quadkey
parent = quadkey.get_parent(qk)
```

## References

I would like to acknowledge the following repositories that served as references during the development of this project:
 - [pyquadkey2](https://github.com/muety/pyquadkey2)
