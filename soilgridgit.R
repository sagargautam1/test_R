#Download soil grid latest data for global scale
#function download the soilgrids data for different depth and create aggregated data for 1m depth
#main source for the code idea: https://git.wur.nl/isric/soilgrids/soilgrids.notebooks/-/blob/master/markdown/webdav_from_R.md
#please refer to SOILGRID website for more detail on data https://files.isric.org/soilgrids/latest/data/
#@parm  downloadfolder:location to download data
#@parm  variable: variable of interest from soilgrids (soc/clay/sadnd/silt/cec etc etc)
#@library rgdal, gdalUtils, raster, parallel

getsoilgrid<-function(downloadfolder,variable,res){
if(!dir.exists(downloadfolder)){
  stop('Need target for download files.')
}
dir.create(paste0(downloadfolder,variable), showWarnings = FALSE)
setwd(paste0(downloadfolder,variable,"/"))

gdalwarp(t_srs="EPSG:4326", multi=TRUE, wm=200, 
         co=c("BIGTIFF=YES", "COMPRESS=DEFLATE", "TILED=TRUE"),
         tr=c(rep(res,2)), 
         paste0("/vsicurl/https://files.isric.org/soilgrids/latest/data/",variable,"/",variable,"_0-5cm_mean.vrt"), # Input VRT
         paste0(variable,"_0-5cm_SoilGrids2.tif")) 

gdalwarp(t_srs="EPSG:4326", multi=TRUE, wm=200, 
         co=c("BIGTIFF=YES", "COMPRESS=DEFLATE", "TILED=TRUE"),
         tr=c(rep(res,2)), # Desired output resolution #25/10000 resolution=0.0025
         paste0("/vsicurl/https://files.isric.org/soilgrids/latest/data/",variable,"/",variable,"_5-15cm_mean.vrt"), # Input VRT
         paste0(variable,"_5-15cm_SoilGrids2.tif")) 

gdalwarp(t_srs="EPSG:4326", multi=TRUE, wm=200, 
         co=c("BIGTIFF=YES", "COMPRESS=DEFLATE", "TILED=TRUE"),
         tr=c(rep(res,2)), 
         paste0("/vsicurl/https://files.isric.org/soilgrids/latest/data/",variable,"/",variable,"_15-30cm_mean.vrt"), # Input VRT
         paste0(variable,"_15-30cm_SoilGrids2.tif")) 

gdalwarp(t_srs="EPSG:4326", multi=TRUE, wm=200, 
         co=c("BIGTIFF=YES", "COMPRESS=DEFLATE", "TILED=TRUE"),
         tr=c(rep(res,2)), 
         paste0("/vsicurl/https://files.isric.org/soilgrids/latest/data/",variable,"/",variable,"_30-60cm_mean.vrt"), # Input VRT
         paste0(variable,"_30-60cm_SoilGrids2.tif")) 

gdalwarp(t_srs="EPSG:4326", multi=TRUE, wm=200, 
         co=c("BIGTIFF=YES", "COMPRESS=DEFLATE", "TILED=TRUE"),
         tr=c(rep(res,2)), 
         paste0("/vsicurl/https://files.isric.org/soilgrids/latest/data/",variable,"/",variable,"_60-100cm_mean.vrt"), # Input VRT
         paste0(variable,"_60-100cm_SoilGrids2.tif"))

all=list.files(getwd(),pattern="*Grids2.tif", full.names = TRUE)
out1m=raster::stack(all[1],all[2],all[3],all[4],all[5])
beginCluster()
mean1m <- clusterR(out1m, mean, args=list(na.rm=TRUE))
endCluster()
writeRaster(mean1m,paste0(variable,"_0_1m.tif"))
}

#example to run the function

library(rgdal)
library(gdalUtils)
library(raster)
library(parallel)
variable="soc"
downloadfolder="/Users/SGautam/Desktop/Soildata/"
res=0.25 #this is for around 25 km/ 0.25 degree resolution
getsoilgrid(downloadfolder,variable,res)
