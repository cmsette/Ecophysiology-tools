#################################################################################################################################
# Dowmnloads microclim climate rasters (Kearney et al. 2014) for ecophysiology analyses
# Written by Carla M. Sette, PhD (12/1/2021)
#
# Description: Downloads microclim climate rasters (Kearney et al. 2014) for ecophysiology analyses. Code will download microclim zip files, extracts the data, and deletes all unnecessary raster layers. User can specify desired substrate types, % shade cover, and distances above the ground for downloaded microclim files. User can also choose whether to crop and replace raster files to a specified extent as well as to delete extracted zip files in order to save disk space.
#
# Usage
#	get_microclim(	microclim_path, extent=NA, sub_types=("rock","sand","soil"), shade_types=c(0,25,50,75,90,100), 
#					elev_types=c(0,3,5,10,15,20,30,50,100), time_out=360, rm_zip=T	)
#
# Arguments
#	microclim_path 	User-specified destination filepath for microclim downloads. 
#	extent 			Default is NA. User can specify raster extent c(r1, r2, c1, c2). 
#	sub_types 		Default downloads all substrate types, c("rock","sand","soil"). User can select specific types. 
#	shade_types 	Default downloads all shade scenarios, c(0,25,50,75,90,100) % shade. 
#	elev_types 		Default keeps all distances from the ground c(0,3,5,10,15,20,30,50,100) cm. User can select specific distances. 
#	time_out 		Default timeout is 360 seconds. If microclim download fils, try increasing time_out. 
#	rm_zip 			Default rm_zip=T, zip files are deleted after file extraction.
#################################################################################################################################

require(dplyr); require(raster)
get_microclim <- function(	microclim_path, 
							extent=NA, 
							sub_types=("rock","sand","soil"), 
							shade_types=c(0,25,50,75,90,100), 
							elev_types=c(0,3,5,10,15,20,30,50,100), 
							time_out=360, 
							rm_zip=T
){
	setwd(microclim_path)
	# Lists unwanted elevations for file removal
	all_elev <- c(0,3,5,10,15,20,30,50,100); rm_elev <- dplyr::setdiff(all_elev, elev_types)
	# Dataframe with Kearney et al. 2014 microclim file names and figshare.com filepaths
	micro_files <- data.frame(sub = c(rep("rock", 6), rep("soil", 6), rep("sand", 6)), shade = c(rep(c(0,25,50,75,90,100),3)),
		filename = c("substrate_temperature_degC_rock_0_shade.zip", "substrate_temperature_degC_rock_25_shade.zip", 			"substrate_temperature_degC_rock_50_shade.zip", "substrate_temperature_degC_rock_75_shade.zip", "substrate_temperature_degC_rock_90_shade.zip", 
			"substrate_temperature_degC_rock_100_shade.zip", "substrate_temperature_degC_sand_0_shade.zip", "substrate_temperature_degC_sand_25_shade.zip", 
			"substrate_temperature_degC_sand_50_shade.zip", "substrate_temperature_degC_sand_75_shade.zip", "substrate_temperature_degC_sand_90_shade.zip", 
			"substrate_temperature_degC_sand_100_shade.zip", "substrate_temperature_degC_soil_0_shade.zip", "substrate_temperature_degC_soil_25_shade.zip", 
			"substrate_temperature_degC_soil_50_shade.zip", "substrate_temperature_degC_soil_75_shade.zip", "substrate_temperature_degC_soil_90_shade.zip", 
			"substrate_temperature_degC_soil_100_shade.zip"),
		url = c("https://ndownloader.figstatic.com/files/3155891", "https://ndownloader.figstatic.com/files/3155858", 
			"https://ndownloader.figstatic.com/files/3155837", "https://ndownloader.figstatic.com/files/3155822", 
			"https://ndownloader.figstatic.com/files/3155975", "https://ndownloader.figstatic.com/files/3155978", 
			"https://ndownloader.figstatic.com/files/3155819", "https://ndownloader.figstatic.com/files/3155963", 
			"https://ndownloader.figstatic.com/files/3155969", "https://ndownloader.figstatic.com/files/3155966", 
			"https://ndownloader.figstatic.com/files/3155831", "https://ndownloader.figstatic.com/files/3155972", 
			"https://ndownloader.figstatic.com/files/3155828", "https://ndownloader.figstatic.com/files/3155834", 
			"https://ndownloader.figstatic.com/files/3155876", "https://ndownloader.figstatic.com/files/3155825", 
			"https://ndownloader.figstatic.com/files/3155843", "https://ndownloader.figstatic.com/files/3155849")		
	)
	# Downloads microclim zip files matching user-selected substrate and shade types
	micro_download <- dplyr::filter(micro_files, sub %in% sub_types, shade %in% shade_types)
	options(timeout=time_out); mapply(download.file, micro_download[,4], micro_download[,3], quiet=T)
	# Unzips each microclim zip file, deletes unwanted elevation files
	invisible(sapply(micro_download[,3], unzip_clean, microclim_path, rm_elev, elev_types, extent))

	#if(rm_zip == T){sapply(paste("*.zip",sep=""), function(x) invisible(file.remove(list.files(pattern=x))) )}
}
# Unzips microclim zip file, deletes unwanted elevation files (optional deletes .zip files)
unzip_clean <- function(microclim_zip, microclim_path, rm_elev, elev_types, extent){
	message(paste("Unzipping:", microclim_zip))
	unzip(microclim_zip, junkpaths=T)
	micro_list <- sapply(paste("D", elev_types,"cm_*",sep=""), function(x) list.files(pattern=x)); micro_list <- as.vector(micro_list)
	rm_list <- sapply(paste("D",rm_elev,"cm_*",sep=""), function(x) list.files(pattern=x))
	invisible(file.remove(rm_list))
	if(is.na(extent[1])==F){
		sapply(micro_list, micro_crop, extent)
	}
}
# Crops and overwrites raster files
micro_crop <- function(micro_file, extent){
	temp_raster <- crop(raster::raster(micro_file), extent)
	raster::writeRaster(temp_raster, micro_file, format="CDF", overwrite=T)
}


