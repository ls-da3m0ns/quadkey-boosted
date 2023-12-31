## QuadKey Boosted Python Library

The QuadKey Python library provides functionalities to convert between geographic coordinates and QuadKeys. It also provides the much needed functionalities of getting boundary of quadkeys in wkt format. QuadKeys are a geospatial indexing system used to represent and address tiles on a map, commonly used in mapping services like Bing Maps.

### What is a QuadKey?

A QuadKey is a string representation of a tile's location in a quadtree hierarchy. It is used to index and address tiles at different levels of detail (zoom levels). The QuadKey system is based on dividing the Earth's surface into quadrants using a quadtree structure.

### Mathematics Behind QuadKeys

The mathematics behind QuadKeys involve the conversion between geographic coordinates (latitude and longitude) and QuadKeys. The conversion can be divided into the following steps:

1. Determining the tile at the desired level of detail:
   - Convert the latitude and longitude coordinates to tile coordinates using a mapping function.
   - Map the tile coordinates to the desired level of detail (zoom level).

2. Constructing the QuadKey:
   - Iterate over each level of detail, starting from the highest level.
   - Determine the quadrant that contains the tile using the tile coordinates.
   - Append the corresponding digit (0, 1, 2, or 3) to the QuadKey string.

To convert QuadKeys back to geographic coordinates, the process is reversed:
1. Start with the QuadKey and its length (number of characters).
2. Iterate over each digit in the QuadKey, starting from the highest level of detail.
3. Divide the current tile into quadrants and determine the quadrant corresponding to the current digit.
4. Update the tile coordinates based on the quadrant.
5. Convert the tile coordinates back to latitude and longitude using a reverse mapping function.


steps to getting quadkey from lat/lon 
get mercator tile from lat/lon
    * pixel width of 256 is to be used
get quadkey from mercator tile
for boundary
    * get tile from quadkey
    * get top and bottom lat/lon from tile
    * create polygon from (top, bottom) coords
things to take care of all computations to be done in c
