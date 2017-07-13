#!/usr/bin/env octave
#simple script to create "average" ice velocity netcdf files from matlab files

pkg load octcdf netcdf;

#command line processing
arg_list = argv();
template = arg_list{1}
infile = arg_list{2};
outfile = arg_list{3};

#print some info
printf("Converting %s to %s using %s as a template\n", infile, outfile,template);

#load data
load(infile);

#copy template
system(sprintf("cp %s %s", template, outfile));

#populate netcdf file
nccreate(outfile, 'u', 'Dimensions',{'r',47,'c',47,'v',1}, 'Format', 'netcdf4_classic');
nccreate(outfile, 'v', 'Dimensions',{'r',47,'c',47,'v',1}, 'Format', 'netcdf4_classic');
ncwrite(outfile,'v',-flipud(v));
ncwrite(outfile,'u',flipud(u));

#set gelocation values
system(sprintf("ncatted -O -a grid_mapping,u,c,c,\"azimuthal_equidistant\" %s", outfile));
system(sprintf("ncatted -O -a grid_mapping,v,c,c,\"azimuthal_equidistant\" %s", outfile));

#generate overview png
system(sprintf("gdal_translate -of png -scale -0.001 0.001 1 255 -ot byte NETCDF:\"%s\":u  %s.png", outfile, outfile));
