# Ecophysiology-tools

#get_microclim
#Description
Downloads microclim climate rasters (Kearney et al. 2014) for ecophysiology analyses. Code will download microclim zip files, extracts the data, and deletes all unnecessary raster layers. User can specify desired substrate types, % shade cover, and distances above the ground for downloaded microclim files. User can also choose whether to crop and replace raster files to a specified extent as well as to delete extracted zip files in order to save disk space.

#Usage
  get_microclim(microclim_path, extent=NA, sub_types=("rock","sand","soil"), shade_types=c(0,25,50,75,90,100),
  elev_types=c(0,3,5,10,15,20,30,50,100), time_out=360, rm_zip=T)
  
#Arguments
  microclim_path    User-specified destination filepath for microclim downloads.
	extent            Default is NA. User can specify raster extent c(r1, r2, c1, c2).
	sub_types         Default downloads all substrate types, c("rock","sand","soil"). User can select specific types.
	shade_types       Default downloads all shade scenarios, c(0,25,50,75,90,100) % shade.
	elev_types        Default keeps all distances from the ground c(0,3,5,10,15,20,30,50,100) cm. User can select specific distances.
	time_out          Default timeout is 360 seconds. If microclim download fils, try increasing time_out.
	rm_zip            Default rm_zip=T, .zip files are deleted after file extraction.
