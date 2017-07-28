#!/usr/bin/env octave
#simple script to create "average" ice velocity netcdf files from matlab files

pkg load octcdf netcdf;

#command line processing
arg_list = argv();
template = arg_list{1}
infile = arg_list{2};
outfile = arg_list{3};
omask = arg_list{4};
rmask = arg_list{5};

#print some info
printf("Converting %s to %s using %s as a template\n", infile, outfile,template);

#load data
load(infile);
load(omask);
load(rmask);

#mask data
u_dims = size(u);
v_dims = size(v);
rmask = repmat(rmask, 1,1,u_dims(3));
omask = repmat(omask, 1,1,u_dims(3));
u(rmask & omask) = NaN;
v(rmask & omask) = NaN;

#copy template
system(sprintf("cp %s %s", template, outfile));

#populate netcdf file
nccreate(outfile, 'u', 'Dimensions',{'r',u_dims(1),'c',u_dims(2),'v',u_dims(3)}, 'Format', 'netcdf4_classic');
nccreate(outfile, 'v', 'Dimensions',{'r',v_dims(1),'c',v_dims(2),'v',v_dims(3)}, 'Format', 'netcdf4_classic');
ncwrite(outfile,'u',flipud(u));
ncwrite(outfile,'v',flipud(v));

#write out times to a txt file
fd = fopen(sprintf("%s.times.txt", outfile), "w");
for i=1:size(infiles)(1)
	fprintf(fd,"%s %s\n", infiles{i,1}, infiles{i,2})
end
fclose(fd);


#set gelocation values
system(sprintf("ncatted -O -a grid_mapping,u,c,c,\"azimuthal_equidistant\" %s", outfile));
system(sprintf("ncatted -O -a grid_mapping,v,c,c,\"azimuthal_equidistant\" %s", outfile));

#generate overview
system(sprintf("gdal_translate -of png -scale -0.001 0.001 1 255 -ot byte -b 1 NETCDF:\"%s\":u  %s.png", outfile, outfile));
