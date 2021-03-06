
## Ice Radar Velocity converstion to netcdf tools

Goal: Convert the matlab formatted radar data and convert to a NetCDF for long term archiving and use by modelers.

_Developer caveat note: Scripts written in matlab because it seemed simplest way to read matlab files.  For others more familiar with matlab programming and data formats there are likely easier ways to do this conversion._

There are three types of data to be converted into respective NetCDF:
* average data set - u and v velocity vector
  * data time comes from matlab filename
* divergence and sheer - contains (todo: insert short summary here)
  * data includes a time component  (todo: not handled correctly yet - coming soon)
* flow - u and v vector 
  *  data includes a time component (todo: not handled correctly yet - comming soon)

Tools used to convert the UAF Sea Ice Radar data from matlab output format into a NetCDF container.  Provided are two files:

* `average_to_netcdf.mt` -	Simple script to generate average file.
* `template.nc` -	Template netcdf file used as a starting point for geo referencing
* `div_shr_to_netcdf.mt` - simple script to generate div/shear file  
* `flow_to_netcdf.mt` - simple script to generate flow file

### Usage

Run them like this:

```
./ice_radar_velocity_netcdf_tools/flow_to_netcdf.mt ice_radar_velocity_netcdf_tools/template.nc flow_20140419_10_20_1_10_phys_filt_med.mat test2/flow_20140419_10_20_1_10_phys_filt_med.nc
./ice_radar_velocity_netcdf_tools/div_shr_to_netcdf.mt ice_radar_velocity_netcdf_tools/template.nc  20140419_div_shr.mat test2/20140419_div_shr.nc
./ice_radar_velocity_netcdf_tools/average_to_netcdf.mt ice_radar_velocity_netcdf_tools/template.nc 20140419_average.mat test2/20140419_average.nc
```

### Notes from process followed when developing the tools above:

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

## License

Open source MIT license : _use at your own risk_

## Authors

* Jay Cable <jay@gina.alaska.edu> - Lead Developer
* Dayne Broderson <dayne@alaska.edu> - Documentation and santiy maker
