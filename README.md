## Ice Radar Velocity converstion to netcdf tools

Provided here are some tools used to convert the UAF Sea Ice Radar data from matlab output format into a NetCDF container.  Provided are two files:

* `average_to_netcdf.mt` -	Simple script to generate average file.
* `template.nc` -	Template netcdf file used as a starting point for geo referencing

### Notes on the steps used to generate the tools.

Make netcdf template
```
gdal_translate  -a_srs '+proj=aeqd +lat_0=71.2925 +lon_0=-156.7883333333333 +x_0=0 +y_0=0 \
  +a=6358944.3 +b=6358944.3 +units=m +no_defs ' \
  -a_ullr -10553.6753809 10553.6753809 10553.6753809 -10553.6753809 \
  -sds 20140419_average.2.nc -of netcdf template.nc
```

Remove data items from template
```
ncks -x -v u,u template.nc template.nc
ncks -x -v v,v template.nc template.nc
```
Poplulate with octave / matlab

Set tags so georefering is applied: 
```
ncatted -O -a grid_mapping,u,c,c,"azimuthal_equidistant" x.nc
ncatted -O -a grid_mapping,v,c,c,"azimuthal_equidistant" x.nc
```
Clean up time arrays
