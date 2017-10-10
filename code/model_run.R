library(raster)
library(maps)

rm(list = ls())
setwd("~/SatelitPusat/data/model/postprd/")
load("../../../dependent/topograp.rda")
f = dir()
r=list()
mr = list()

for(i in 1:length(f)){
  r[[i]] <- raster(f[i])
  mr[[i]] =matrix(r[[i]] ,nrow = 279)
  # mr[[i]][ mr[[i]] >= 0 ]=NA
  mr[[i]] = t(apply(mr[[i]],c(1),rev))
}

lon=seq(90,150,length=dim(mr[[1]])[1])
lat=seq(-15,15,length=dim(mr[[1]])[2])

warna = colorRampPalette(c("darkred","green","blue","white"))


filled.contour(lon,lat, mr[[1]],col = warna(25), plot.axes = {
  map("world", fill=F, col="black", bg=NULL, xlim=c(90,150), ylim=c(-15, 15), 
      mar=c(0,0,0,0),resolution = 0.0000001,add=T) ;
      axis(1,at=seq(90,150,10),labels = sprintf("%sE",as.integer(seq(90,150,10)))  ) ;
  axis(2,at=seq(-15,15,length=7),labels = c(sprintf("%sS",c(-15,10,5) ),  0,sprintf("%sN",c(5,10,15) )))
  # image(topograp$xnya,topograp$ynya,topograp$el,col=terrain.colors(10,alpha=0.2),add=T)
})

