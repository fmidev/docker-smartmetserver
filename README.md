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

### This image includes following packages:

#### Libraries
* [smartmet-library-gis](https://github.com/fmidev/smartmet-library-gis)
* [smartmet-library-giza](https://github.com/fmidev/smartmet-library-giza)
* [smartmet-library-locus](https://github.com/fmidev/smartmet-library-locus)
* [smartmet-library-macgyver](https://github.com/fmidev/smartmet-library-macgyver)
* [smartmet-library-newbase](https://github.com/fmidev/smartmet-library-newbase)
* [smartmet-library-spine](https://github.com/fmidev/smartmet-library-spine)

#### Engines
* [smartmet-engine-contour](https://github.com/fmidev/smartmet-engine-contour)
* [smartmet-engine-geonames](https://github.com/fmidev/smartmet-engine-geonames)
* [smartmet-engine-gis](https://github.com/fmidev/smartmet-engine-gis)
* [smartmet-engine-observation](https://github.com/fmidev/smartmet-engine-observation)
* [smartmet-engine-querydata](https://github.com/fmidev/smartmet-engine-querydata)
* [smartmet-engine-sputnik](https://github.com/fmidev/smartmet-engine-querydata)

#### Plugins
* [smartmet-plugin-admin](https://github.com/fmidev/smartmet-plugin-admin)
* [smartmet-plugin-autocomplete](https://github.com/fmidev/smartmet-plugin-autocomplete)
* [smartmet-plugin-download](https://github.com/fmidev/smartmet-plugin-download) [[Guide](https://github.com/fmidev/smartmet-plugin-download/wiki/SmartMet-plugin-download)]
* [smartmet-plugin-timeseries](https://github.com/fmidev/smartmet-plugin-timeseries)  [[Guide](https://github.com/fmidev/smartmet-plugin-timeseries/wiki/SmartMet-plugin-TimeSeries)]
* [smartmet-plugin-wfs](https://github.com/fmidev/smartmet-plugin-wfs) [[Guide](https://github.com/fmidev/smartmet-plugin-wfs/wiki/SmartMet-plugin-WFS)]
* [smartmet-plugin-wms](https://github.com/fmidev/smartmet-plugin-wms) [[Guide](https://github.com/fmidev/smartmet-plugin-wms/wiki/SmartMet-plugin-WMS-%28Dali-%26-WMS%29)]
* [smartmet-server](https://github.com/fmidev/smartmet-server)

### Usage
#### Run container
```
docker run -d --restart=always --name smartmetserver -v $HOME/data:/smartmet/data \
-p 8080:8080 fmidev/smartmetserver
```
#### Get data to play with
```
mkdir -p $HOME/data/meps/surface
wget -O $HOME/data/meps/surface/$(date -u +%Y%m%d0000)_meps_northeurope_surface.sqd \ 
-S "https://opendata.fmi.fi/download?param=Temperature,TotalCloudCover,Precipitation1h,WindSpeedMS,Humidity,
Pressure,WeatherSymbol3&format=qd&producer=harmonie_scandinavia_surface&origintime=$(date -u +%Y-%m-%dT00Z)&timestep=data"
```

#### Access timeseries plugin
http://localhost:8080/timeseries?producer=meps&lonlat=24.94,60.17&param=time,temperature,pressure

#### Access WMS Capabilities
http://localhost:8080/wms?service=wms&version=1.3.0&request=GetCapabilities

#### Access data inventory
http://localhost:8080/admin?what=qengine

Get more help for timeseries usage from github [wiki page](https://github.com/fmidev/smartmet-plugin-timeseries/wiki/SmartMet-plugin-TimeSeries).


### Build custom container
```
FROM fmidev/smartmetserver:latest
USER root
COPY smartmetconf /etc/smartmet
COPY wms /smartmet/share/wms
USER 101010
```
