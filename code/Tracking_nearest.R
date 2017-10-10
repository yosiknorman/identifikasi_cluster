
# ========================== BUTUH ===========================
# data koordinat cluster beserta luas

pos = titik_cluster
new.pos = titik_cluster[1,]-1.5
# Compute distance to points and select nearest index
jarakmin = min(abs(colSums((t(pos) - new.pos))))
# nearest.idx <- which.min(colSums((t(pos) - new.pos)) )
# nearest.idx <- which(abs(colSums((t(pos) - new.pos))) < (jarakmin+0.01))
# nearest.idx
# pos[nearest.idx, ]

cari_terdekat = function(new.pos){
  nearest.idx <- which(abs(colSums((t(pos) - new.pos))) < (jarakmin+0.01))
  nearest.idx
  pos[nearest.idx, ]
  hasil = list(nearest.idx,pos[nearest.idx, ])
  return(hasil)
}

cari_terdekat(new.pos = new.pos)

hasil=cari_terdekat(new.pos = new.pos)
if(length(hasil[[1]]) == 0){
  print("kagak Ada")
}else{
  print(hasil[[2]])
}