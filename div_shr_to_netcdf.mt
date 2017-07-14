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
div3d_dims = size(div3d);
shr3d_dims = size(shr3d);
infile_dims = size(infiles);
nccreate(outfile, 'div3d', 'Dimensions',{'r',div3d_dims(1),'c',div3d_dims(2),'v',div3d_dims(3)}, 'Format', 'netcdf4_classic');
nccreate(outfile, 'shr3d', 'Dimensions',{'r',shr3d_dims(1),'c',shr3d_dims(2),'v',shr3d_dims(3)}, 'Format', 'netcdf4_classic');
ncwrite(outfile,'div3d',flipud(div3d));
ncwrite(outfile,'shr3d',flipud(shr3d));

#write out times to a txt file
fd = fopen(sprintf("%s.times.txt", outfile), "w");
for i=1:size(infiles)(1)
	fprintf(fd,"%s %s\n", infiles{i,1}, infiles{i,2})
end
fclose(fd);


#set gelocation values
system(sprintf("ncatted -O -a grid_mapping,div3d,c,c,\"azimuthal_equidistant\" %s", outfile));
system(sprintf("ncatted -O -a grid_mapping,shr3d,c,c,\"azimuthal_equidistant\" %s", outfile));

#generate overview png
system(sprintf("gdal_translate -of png -scale -0.001 0.001 1 255 -ot byte -b 1 NETCDF:\"%s\":shr3d  %s.png", outfile, outfile));

