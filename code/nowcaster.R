#!//usr/bin/Rscript
library(ncdf4)
library(maps)
library(EBImage)
library(ggmap)
library(matlab)
library(leaflet)
library(raster)
library(htmlwidgets)

rm(list = ls())
setwd("~/SatelitPusat/code/")
PAT <-  "../data/recent"
dir(PAT)
REC <- Sys.time()
f <- dir(PAT)
f <- f[length(f)]


nowcaster<- function(f){
  
  #========================= OPEN DATA ===========================
  nc <- nc_open(sprintf("%s/%s",PAT,f))
  CTT <- ncvar_get(nc,"CO")
  dim(CTT)
  lon <- ncvar_get(nc,"longitude")
  lat <- ncvar_get(nc,"latitude")
  
  ix = which(lon >= 90 & lon <= 150)
  iy = which(lat >= -15 & lat <= 15)
  lon = lon[ix]
  lat = lat[iy]
  CTT=CTT[ix,iy]
  #======================== CHECK IMAGE ==========================
  
  # x11(height = 6,width = 7)
  # wrn = colorRampPalette(c("darkblue","white","grey"))
  # image(lon,lat,CTT,col=wrn(100), font.lab=2,font.axis=2)
  # 
  # map("world", fill=F, col="black", lwd=1, bg=NULL, xlim=c(90,150), ylim=c(-15, 15),
  #     mar=c(0,0,0,0),resolution = 0.0000001,add=T)
  # grid()
  
  # image(lon,lat,var)
  #========================= CHECK AREA ==========================
  TBB = CTT  
  TBB[TBB >= 220]=0    # == Selimut ==
  
  dis = lat[length(lat)] - lat[1]
  degree = dis/length(lat)
  const = 111.699
  km2 = 10000
  jumlah_grid = as.integer(km2/(degree*const))
  Area <- bwlabel(TBB)
  
  A=Area
  A[A == 0] = NA
  Atable <- table(A)
  AreaThreshold = jumlah_grid # jumlah grid
  Adelete <- which(Atable < AreaThreshold) #delete those
  simpan_luas <- which(Atable >= AreaThreshold) #delete those
  
  for (i in Adelete){
    TBB[A == i ]<- NA
    A[A == i ] <- NA
  }
  
  
  min(TBB[!is.na(TBB)])
  TBB[TBB == 0 ]=NA
  TBB[is.na(TBB) ] = 299
  
  xy = meshgrid(1:length(lat),1:length(lon))
  
  
  dd = list()
  cx = c()
  cy = c()
  
  for(i in 1:length(simpan_luas)){
    dd[[i]] = TBB
    dd[[i]][A != simpan_luas[i] ] = 300
    if(min(dd[[i]]) < 217 ){
      cy[i] =  xy$x[dd[[i]] == min(dd[[i]])]
      cx[i] = xy$y[dd[[i]] == min(dd[[i]])]
    }
  }
  
  cx = lon[cx]
  cy = lat[cy]
  
  # ================ CARI KOORDINAT CORE ====================
  
  png(filename = sprintf("../hasil/TBB_monitor/%s.png",substr(f,1,30)),height = 700,width = 1200)
  wrn = colorRampPalette(c("darkred","white","grey"))
  image(lon,lat,CTT,col=wrn(70), font.lab=2,font.axis=2)
  map("world", fill=F, col="black", lwd=1, bg=NULL, xlim=c(90,150), ylim=c(-15, 15),
      mar=c(0,0,0,0),resolution = 0.0000001,add=T)
  points(cx,cy,pch=4, cex = 1)
  grid()
  box()
  dev.off()
  # ================ CARI NAMA LOKASI -- ONLINE ====================
  coords <- data.frame(cx,cy)
  cx = cx[!is.na(cx)]
  cy = cy[!is.na(cy)]
  
  names(coords) <- c("lon","lat")
  nama_lokasi = c()
  for(i in 1:length(cx)){
    nama_lokasi[i] = revgeocode(c(cx[i],cy[i]))
  }
  
  nama_lokasi = unlist(nama_lokasi)
  
  library(raster)
  TBB[TBB >= 280] = NA
  
  dr = raster(apply(TBB,c(1),rev))
  crs(dr) <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
  extent(dr) <- c(xmin = lon[1],xmax= lon[length(lon)],ymin = lat[1],ymax = lat[length(lat)])
  
  
  # =============== LEAFLET ================
  
  cx = round(cx,digits = 4)
  cy = round(cy,digits = 4)
  
  pal <- colorNumeric(c( "darkred","red","darkblue", "NA"), values(dr),
                      na.color = "transparent")
  
  lef = leaflet() %>% addTiles() %>%
    addRasterImage(dr, colors = pal, opacity = 0.7) %>%
    addLegend(pal = pal, values = values(dr),
              title = "Cloud Top Temp (K)") %>%
    
    addMarkers( lng=cx, lat=cy, popup=sprintf("Monitoring Kluster Awan Konvektif;  
                                              pusat lokasi lon,lat : (%s,%s) %s",cx,cy,nama_lokasi))
  
  
  
  saveWidget(lef, '../html_leaf/let.html', selfcontained = F) 
  
  computeFeatures.shape(TBB)
  gt = TBB
  
  gt[is.na(gt)] = 0
  ss = bwlabel(gt)
  w=table(ss)
  
  
  ac = computeFeatures.shape(ss)
  xyc = computeFeatures.moment(ss)
  
  cl = colorRampPalette(c("black","blue","red","yellow"))
  
  titik_cluster= data.frame(lon[xyc[,1]],lat[xyc[,2]])
  names(titik_cluster) = c("lon","lat")
  # ================ PLOT LEAFLET PUSAT KLUSTER ====================
  
  center_lokasi = c()
  for(i in 1:length(titik_cluster$lon)){
    center_lokasi[i] = revgeocode(c(titik_cluster$lon[i],titik_cluster$lat[i]))
  }
  
  center_lokasi = unlist(center_lokasi)
  
  pal <- colorNumeric(c( "darkred","red","darkblue", "NA"), values(dr),
                      na.color = "transparent")
  clok = leaflet() %>% addTiles() %>%
    addRasterImage(dr, colors = pal, opacity = 0.7) %>%
    addLegend(pal = pal, values = values(dr),
              title = "Cloud Top Temp (K)") %>%
    
    addMarkers( lng=titik_cluster$lon, lat=titik_cluster$lat, popup=sprintf("Monitoring Kluster Awan Konvektif;  
                                                                            pusat lokasi lon,lat : (%s,%s) %s",cx,cy,center_lokasi))
  
  
  
  saveWidget(clok,'../html_leaf/clok.html', selfcontained = F) 
  
  tabel = w
  A[is.na(A)] = 0 
  image(A)
  # A[A ==0] =NA
  B = A
  B[B != 0] = 1
  A_tabel = list(A,B,tabel,titik_cluster)
  
  names(A_tabel) = c("LuasanMatrix","Luas_biner","tabel","titik_cluster")
  nf = substr(f,19,30)
  save( file = sprintf("../dependent/A_tabel%s.rda",nf),A_tabel)
}

nowcaster(f=f)