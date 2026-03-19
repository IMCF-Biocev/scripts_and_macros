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
dimfiles <- list.files("D:/Users data/Margarita/2022-05-23_STED_Analysis_masks", 
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
#names(patlist) <- substr(maskfiles, 29, 35)
names(patlist) <- my_list
print(patlist)


hf <- hyperframe(patterns=patlist,
                 name = names(patlist), 
                 group = gsub(".*CHO(.+)_sem.*", "\\1", names(patlist)))

# checkpoint - dataframe 
head(hf)

####### ####### ####### ####### ####### ####### ####### ####### #######
####### Step: Saving distribution function plots ####### 
####### ####### ####### ####### ####### ####### ####### ####### #######

# Specify correct path of folder for saving plots (folder Plots)
pdf(file="D:/Users data/Margarita/allplots.pdf",
    width=100,height=100)
for (i in 1:length(dimfiles))
  plot(allstats(get(paste("p",i, sep=""))), main = hf[i]$name)
dev.off()

# Specify correct path of folder for saving plots
pdf(file="D:/Users data/Margarita/L_functions.pdf",
    width=8,height=8)
for (i in 1:length(dimfiles)){
  lft <- envelope(get(paste("p",i,sep="")), Lest, correction = "best", nsim = 50, verbose = FALSE)
  plot(lft, main = hf[i]$name, cex = 100)
  plot(lft, . - r ~ r, main = hf[i]$name)
  
}
dev.off()

####### ####### ####### ####### ####### ####### ####### ####### #######
####### Step: Kolmogorov-smirnov statistics ####### #parameters needs to be optimized
####### ####### ####### ####### ####### ####### ####### ####### #######

initial_step <- Lest(p1)
maxr <- c(max(initial_step$r))
for (i in 1:length(dimfiles)){
  tempL <- Lest(get(paste("p", i,sep="")))
  maxr[[i]] <- max(tempL$r)
  maxmax = max(maxr)
  minmax = min(maxr)
}
maxmax
minmax
hist(maxr, breaks = 30)
rs <- seq(from =0, to= 4.835, by =0.005) #maxmax rounded to 3rd position to 0 or 5

dataMUT <- data.frame(
  r = rs
)
dataMUTtr<- data.frame(
  r = rs
)
dataWT <- data.frame(
  r = rs
)
dataWTtr <- data.frame(
  r = rs
)

for (i in 1:length(dimfiles)){
  tempL <- Lest(get(paste("p", i,sep="")))
  new <- c(tempL$border, rep(NaN, (length(dataMUT$r) - length(tempL$border))))           
  new2 <- c(tempL$trans, rep(NaN, (length(dataMUT$r) - length(tempL$trans)))) 
  if (hf[i]$group == "mut"){
    dataMUT[ , ncol(dataMUT) + 1] <- new                  
    colnames(dataMUT)[ncol(dataMUT)] <- paste0(hf[i]$name)  
    dataMUTtr[ , ncol(dataMUTtr) + 1] <- new2                  
    colnames(dataMUTtr)[ncol(dataMUTtr)] <- paste0(hf[i]$name)    
  } else {
    dataWT[ , ncol(dataWT) + 1] <- new                  
    colnames(dataWT)[ncol(dataWT)] <- paste0(hf[i]$name)  
    dataWTtr[ , ncol(dataWTtr) + 1] <- new2                  
    colnames(dataWTtr)[ncol(dataWTtr)] <- paste0(hf[i]$name)
  }}
dataMUT
dataMUT$avg <- rowMeans(dataMUT[,-which(names(dataMUT) == "r")], na.rm=TRUE)
dataMUTtr$avg <- rowMeans(dataMUTtr[,-which(names(dataMUTtr) == "r")], na.rm=TRUE)
head(dataMUT, n=20)
head(dataMUTtr, n=20)
dataWT$avg <- rowMeans(dataWT[,-which(names(dataWT) == "r")], na.rm=TRUE)
dataWTtr$avg <- rowMeans(dataWTtr[,-which(names(dataWTtr) == "r")], na.rm=TRUE)

plot(dataMUT$r,(dataMUT$avg), type="l", lwd = 1, col = "red")
lines(dataWT$r,(dataWT$avg),lwd=1,col="blue")

plot(dataMUT$r,(dataMUT$avg-dataMUT$r), type="l", lwd = 1, col = "red")
lines(dataWT$r,(dataWT$avg-dataWT$r),lwd=1,col="blue")

plot(dataMUTtr$r,(dataMUTtr$avg), type="l", lwd = 1, col = "red")
lines(dataWTtr$r,(dataWTtr$avg),lwd=1,col="blue")
lines(dataWTtr$r,(dataWTtr$r),lwd=1,col="black")

# selection of range of distances r
mutsub <- subset(dataMUTtr, r < 1 & r > 0.06)
wtsub <- subset(dataWTtr, r < 1 & r > 0.06)

plot(mutsub$r,(mutsub$avg), type="l", lwd = 1, col = "red")
lines(wtsub$r,(wtsub$avg),lwd=1,col="blue")

plot(mutsub$r,(mutsub$avg-mutsub$r), type="l", lwd = 1, col = "red")
lines(wtsub$r,(wtsub$avg-wtsub$r),lwd=1,col="blue")

# whole model
ks.test(dataMUT$avg, dataWT$avg)
# whole model - border correction
ks.test(dataMUTtr$avg, dataWTtr$avg)

# reduced model for selected range of distances
ks.test(mutsub$avg, wtsub$avg)

