# Script for extraction of intersections between data L-est function curve and upper envelope of random-generated pattern L-est function
# = distance between points indicating start of clustering (and) end of clustering


####### ####### ####### ####### ####### ####### ####### ####### #######
# Step: loading necessary libraries 
####### ####### ####### ####### ####### ####### ####### ####### #######

library(spatstat)
library(maptools)
library(tiff)
library(ggplot2)

####### ####### ####### ####### ####### ####### ####### ####### #######
####### Step: loading files - specify correct paths to folders ####### 
####### ####### ####### ####### ####### ####### ####### ####### #######

# mask image files (tiffs) for loading of image dimensions 
dimfiles <- list.files("D:/Users data/Margarita/2022-05-23_STED_Analysis_mask", 
                       pattern="*mask.tif", 
                       full.names=TRUE, recursive = TRUE)
# mask matrix (csv) files for loading of mask coordinates 
maskfiles <- list.files("D:/Users data/Margarita/2022-05-23_STED_Analysis_masks", 
                        pattern="*mask.csv", 
                        full.names=TRUE, recursive = TRUE)
# points matrix (csv) files for loading of points coordinates 
xyfiles <- list.files("D:/Users data/Margarita/2022-05-23_STED_Analysis_points", 
                      pattern="*xy.csv", 
                      full.names=TRUE, recursive = TRUE)

####### ####### ####### ####### ####### ####### ####### ####### #######
####### Step: processing of loaded files ####### 
####### ####### ####### ####### ####### ####### ####### ####### #######

ddf <- lapply(dimfiles, readTIFF)
idf <- lapply(ddf, dim)
my_list <- list()
for (i in 1:length(dimfiles)){
  tempstr = gsub(".*Margarita/(.+)_GFP.*", "\\1", dimfiles[i])
  stri = gsub(".*/(.+).*", "\\1", tempstr)
  my_list[[length(my_list) + 1]] <- stri
  assign(paste(stri,sep=""), c(idf[[i]][1], idf[[i]][2]))
}

for (i in 1:length(dimfiles))
  assign(paste("ms", i,sep=""), c(idf[[i]][1], idf[[i]][2]))

ldf <- lapply(maskfiles, read.csv, header = TRUE)
for (i in 1:length(maskfiles))
  assign(paste("msk", i,sep=""), ldf[[i]])

tdf <- lapply(xyfiles, read.csv, header = TRUE)
for (i in 1:length(xyfiles))
  assign(paste("m", i,sep=""), tdf[[i]])


for (i in 1:length(dimfiles))
  assign(paste("mswin", i,sep=""),
         owin(c(0, get(paste("ms", i,sep=""))[1]-1), 
              c(0, get(paste("ms", i,sep=""))[2]-1), 
              mask=get(paste("msk", i,sep=""))[,c(1,2)]))

for (i in 1:length(dimfiles))
  assign(paste("p", i,sep=""), 
         ppp(get(paste("m", i,sep=""))[,2], 
             get(paste("m", i,sep=""))[,3], 
             get(paste("mswin", i,sep=""))))

for (i in 1:length(dimfiles)) {
  assign(paste("p", i,sep=""),rescale(get(paste("p", i,sep="")), 50))
}

for (i in 1:length(dimfiles))
  X <- get(paste("p", i,sep=""))
unitname(X) <- c("micron", "microns")


patlist <- list()
for (i in 1:length(dimfiles))
  patlist[[i]] <- (get(paste("p", i,sep="")))
names(patlist) <- my_list
print(patlist)


hf <- hyperframe(patterns=patlist,
                 name = names(patlist), 
                 group = gsub(".*CHO(.+)_sem.*", "\\1", names(patlist)))

# checkpoint - dataframe 
head(hf)

####### ####### ####### ####### ####### ####### ####### ####### #######
####### Step: intersection table ####### 
####### ####### ####### ####### ####### ####### ####### ####### #######

# Specify folder path for saving intersection table (folder Intersections)
folder_path = "D:/Users data/Cockova/margarita/intersections_test/"

minv = 1
maxv = length(dimfiles)
for (s in minv:maxv){
  number = s
  lft <- envelope(get(paste("p", number,sep="")), Lest, nlarge = 13000, correction = "best", nsim = 100, verbose = FALSE)
  dflft <- as.data.frame(lft)
  isdf <- c()
  a = 1
  for (i in seq_along(dflft$r)){
    if (!(is.na(dflft$obs[i]))){
      if (round(dflft$obs[i],2) - round(dflft$hi[i],2) < 0.01){
        dn <- round(dflft$obs[i],3) - round(dflft$hi[i],3)
        tempo <- paste(i,dflft$r[i],dflft$obs[i], round(dflft$obs[i],3),round(dflft$hi[i],3), abs(round(dn, 5)), hf[number]$name, sep = "\t")
        print(tempo)
        isdf[a] <- tempo
        a=a+1
      }
    }
  }
  isdf <- as.data.frame(isdf)
  colnames(isdf) <- "id\tx\tdata_y\tdata_y_rounded\thigh_random_y_rounded\ty_diff\tdataset"
  
  write.csv(isdf, file = paste(folder_path, hf[number]$name, ".csv", sep =""))
}




