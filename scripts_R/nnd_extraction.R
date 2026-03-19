# Script for statistical testing if two functions come from the same distribution
# and saving plots of distribution functions


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
xyfiles <- list.files("D:/Users data/Margarita/2022-05-23_STED_Analysis_xy", 
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
#names(patlist) <- substr(maskfiles, 29, 35)
names(patlist) <- my_list
print(patlist)


hf <- hyperframe(patterns=patlist,
                 name = names(patlist), 
                 group = gsub(".*CHO(.+)_sem.*", "\\1", names(patlist)))

# checkpoint - dataframe 
head(hf)

####### ####### ####### ####### ####### ####### ####### ####### #######
####### Step: NND analysis  ####### 
####### ####### ####### ####### ####### ####### ####### ####### #######

# Specify folder path for saving nnd table
nnd_table_folder = "D:/Users data/Margarita/nnd_table.csv"

points <- c()
for (i in 1:length(dimfiles)){
  points[i] <- get(paste("p",i,sep=""))$n
}

semiran_nns <- c()
min_i = 1
for (i in min_i:length(dimfiles)){
  resc_mswin <- rescale(get(paste("mswin",i,sep="")), 50)
  intensity_pp <- intensity(get(paste("p",i,sep="")))
  min_r <- min(nndist(get(paste("p",i,sep=""))))
  rnn <- c()
  a <- 1
  
  for(a in 1:100) {
    semiran_nn <- mean(nndist(rMaternI(kappa = intensity_pp, r = min_r, win = resc_mswin)))
    rnn[a] <- semiran_nn
  }
  semiran_nns[i] <- (mean(rnn))
}
semiran_nns

mean_nns <- c()
for (i in 1:length(dimfiles))
  mean_nns[i] <- mean(nndist(get(paste("p", i, sep=""))))

dff <- data.frame(names(patlist), mean_nns, semiran_nns)
dff$ratio_nns <- mean_nns/semiran_nns
dff$group <- gsub(".*CHO(.+)_sem.*", "\\1", names(patlist))

write.csv(dff, file = nnd_table_folder)

# plots
lo <- c("wt", "mut")
ggplot(dff, aes(x = factor(group, level = lo), y = mean_nns, color = group)) + 
  geom_boxplot(outlier.shape = NA) + 
  geom_jitter()

ggplot(dff, aes(x = factor(group, level = lo), y = semiran_nns, color = group)) + 
  geom_boxplot() + 
  geom_jitter()

ggplot(dff, aes(x = factor(group, level = lo), y = ratio_nns, color = group)) + 
  geom_boxplot() + 
  geom_jitter()
