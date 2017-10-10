library(EBImage)
setwd("~/SatelitPusat/code/")

rm(list = ls())
PAT = "../dependent/"

fn = dir(PAT,pattern = "A_tabel")
data_full = list()
for(i in 1:length(fn)){
  load(file = sprintf("../dependent/%s",fn[i]))
  data_full[[i]] = A_tabel
}
names(data_full) = fn

x11()
par(mfrow = c(1,3))
image(data_full[[1]]$Luas_biner)
image(data_full[[2]]$Luas_biner)

toNA = data_full[[1]]$Luas_biner
data_full[[1]]$tabel == data_full[[2]]$tabel
# dim(data_full[[1]]$Luas_biner)[1]*dim(data_full[[1]]$Luas_biner)[2]
toNA[toNA == 0] = NA

ovlp = toNA %in% data_full[[2]]$Luas_biner
ovlp[ovlp == TRUE] = 1
ovlp = matrix(ovlp,dim(toNA)[1],dim(toNA)[2])

data_full[[1]]$Luas_biner == ovlp
data_full[[2]]$Luas_biner == ovlp

lon = seq(90,150,length=dim(bwovlp)[1])
lat = seq(-15,15,length=dim(bwovlp)[2])

bwovlp = bwlabel(ovlp)
image(lon,lat,bwovlp)
cfm = computeFeatures.moment(bwovlp)
tabel_ovlp = data.frame(lon[cfm[,1]],lat[cfm[,2]])
names(tabel_ovlp) = c("lon","lat")

points(tabel_ovlp)
points(data_full[[1]]$tabel,col="blue",pch = 3)
data_full[[1]]$tabel == tabel_ovlp
