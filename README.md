# SmartMet Server

SmartMet Server is a data and product server for MetOcean data. It provides a high capacity and high availability data and product server for MetOcean data. The server is written in C++, since 2008 it has been in operational use by the Finnish Meteorological Institute FMI.

The server can read input data from various sources:
* GRIB (1 and 2)
* NetCDF
* SQL database

The server provides several output interfaces:
* WMS 1.3.0
* WFS 2.0
* Several custom interface and several output formats:
* JSON
* XML
* ASCII
* HTML
* SERIAL
* GRIB1
* GRIB2
* NetCDF
* Raster images

The server is INSPIRE compliant. It is used for FMI data services and product generation. It's been operative since 2008 and used for FMI Open Data Portal since 2013.

The server is especially good for extracting weather data and generating products based on gridded data (GRIB and NetCDF). The data is extracted and products generating always on-demand.

