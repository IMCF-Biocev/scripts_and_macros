
library(spatstat)
library(maptools)
library(tiff)
library(ggplot2)

dimfiles <- list.files("I:/Users data/Margarita/STED/2022-05-23_STED_Analysis_images", pattern="*mask.tif", full.names=TRUE, recursive = TRUE)
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

maskfiles <- list.files("I:/Users data/Margarita/STED/2022-05-23_STED_Analysis_masks", pattern="*mask.csv", full.names=TRUE, recursive = TRUE)
ldf <- lapply(maskfiles, read.csv, header = TRUE)
for (i in 1:length(maskfiles))
  assign(paste("msk", i,sep=""), ldf[[i]])

xyfiles <- list.files("I:/Users data/Margarita/STED/2022-05-23_STED_Analysis_points", pattern="*xy.csv", full.names=TRUE, recursive = TRUE)
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
head(hf)

################## testing #################################################################


test <- Lest(p1)
test2 <- Lest(p2)

ks.test(test$border, test2$border)


plot(test$r,(test$border), type="l", lwd = 1, col = "red")
for (i in 2:length(dimfiles)){
  tempL <- Lest(get(paste("p", i,sep="")))
  if (hf[i]$group == "mut"){
    lines(tempL$r,(tempL$border),lwd=1,col="red")
  } else {
  lines(tempL$r,(tempL$border),lwd=1,col="blue")
}}

###################################################################################

################################ new code ######################################
test <- Lest(p1)

max(test$r)
maxr <- c(max(test$r))
for (i in 1:length(dimfiles)){
  tempL <- Lest(get(paste("p", i,sep="")))
  maxr[[i]] <- max(tempL$r)
  maxmax = max(maxr)
  minmax = min(maxr)
}
maxmax
minmax
hist(maxr, breaks = 30)
rs <- seq(from =0, to= 4.835, by =0.005)
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
  new <- c(tempL$border, rep(NaN, (length(dataMUT$r) - length(tempL$border))))           # Create new column
  new2 <- c(tempL$trans, rep(NaN, (length(dataMUT$r) - length(tempL$trans)))) 
  if (hf[i]$group == "mut"){
    dataMUT[ , ncol(dataMUT) + 1] <- new                  # Append new column
    colnames(dataMUT)[ncol(dataMUT)] <- paste0(hf[i]$name)  # Rename column name
    dataMUTtr[ , ncol(dataMUTtr) + 1] <- new2                  # Append new column
    colnames(dataMUTtr)[ncol(dataMUTtr)] <- paste0(hf[i]$name)    
  } else {
    dataWT[ , ncol(dataWT) + 1] <- new                  # Append new column
    colnames(dataWT)[ncol(dataWT)] <- paste0(hf[i]$name)  # Rename column name
    dataWTtr[ , ncol(dataWTtr) + 1] <- new2                  # Append new column
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

mutsub <- subset(dataMUTtr, r < 1 & r > 0.06)
wtsub <- subset(dataWTtr, r < 1 & r > 0.06)

plot(mutsub$r,(mutsub$avg), type="l", lwd = 1, col = "red")
lines(wtsub$r,(wtsub$avg),lwd=1,col="blue")

plot(mutsub$r,(mutsub$avg-mutsub$r), type="l", lwd = 1, col = "red")
lines(wtsub$r,(wtsub$avg-wtsub$r),lwd=1,col="blue")

ks.test(dataMUT$avg, dataWT$avg)
ks.test(dataMUTtr$avg, dataWTtr$avg)
ks.test(mutsub$avg, wtsub$avg)


###################################################################################
# every dataset has a number, chose numbers from 1 to 94
number = 1
lft <- envelope(get(paste("p", number,sep="")), Lest, correction = "best", nsim = 5, verbose = FALSE)
plot(lft, main = hf[number]$name)
#plot(lft, . - r ~ r)
dflft <- as.data.frame(lft)
#head(dflft)
#plot(dflft$r,(dflft$obs), type="l")
#lines(dflft$r,(dflft$hi),col="green")
head(dflft)
fit1<-smooth.spline(dflft$r,(dflft$obs),cv = TRUE)
fit2<-smooth.spline(dflft$r,(dflft$hi),cv = TRUE)
fit3<-smooth.spline(dflft$r,(dflft$theo),cv = TRUE)
fit4<-smooth.spline(dflft$r,(dflft$lo),cv = TRUE)

plot(dflft$r,(dflft$obs), type="l")
lines(fit1,lwd=2,col="green")
lines(fit2,lwd=2,col="purple")
lines(fit3,lwd=1,col="black")
lines(fit4,lwd=1,col="purple")

isdf <- c()
tt <- c()
dt <- c()
a = 1
for (i in seq_along(fit1$x)){
  if (round(fit1$y[i],2) == round(fit2$y[i],2)){
    dn <- round(fit1$y[i],3) - round(fit2$y[i],3)
    tt[a] <- i
    dt[a] <- abs(round(dn, 5))
    tempo <- paste(i,fit1$x[i], round(fit1$y[i],3),round(fit2$y[i],3), abs(round(dn, 5)), hf[number]$name, sep = "\t")
    print(tempo)
    isdf[a] <- tempo
    a=a+1
  }
}

isdf <- as.data.frame(isdf)
colnames(isdf) <- "id\tx\tdata_y\thigh_random_y\ty_diff\tdataset"
isdf
write.csv(isdf, file = paste("I:/Users data/Margarita/STED/intersections/", hf[number]$name, ".csv", sep =""))

# choose new number



#### automatic ######################  new code #################################
minv = 38
maxv = length(dimfiles)
for (s in minv:maxv){
  number = s
  lft <- envelope(get(paste("p", number,sep="")), Lest, correction = "best", nsim = 100, verbose = FALSE)
  dflft <- as.data.frame(lft)
  isdf <- c()
  a = 1
  for (i in seq_along(dflft$r)){
    if (round(dflft$obs[i],2) == round(dflft$hi[i],2)){
      dn <- round(dflft$obs[i],3) - round(dflft$hi[i],3)
      tempo <- paste(i,dflft$obs[i], round(dflft$obs[i],3),round(dflft$hi[i],3), abs(round(dn, 5)), hf[number]$name, sep = "\t")
      print(tempo)
      isdf[a] <- tempo
      a=a+1
    }
  }
  isdf <- as.data.frame(isdf)
  colnames(isdf) <- "id\tx\tdata_y\thigh_random_y\ty_diff\tdataset"
  
  write.csv(isdf, file = paste("I:/Users data/Margarita/STED/intersections/", hf[number]$name, ".csv", sep =""))
}

#################################################################################

#### automatic ######################  new code #################################
minv = 38
maxv = length(dimfiles)
for (s in minv:maxv){
  number = s
  lft <- envelope(get(paste("p", number,sep="")), Lest, correction = "best", nsim = 100, verbose = FALSE)
  dflft <- as.data.frame(lft)
  isdf <- c()
  a = 1
  for (i in seq_along(dflft$r)){
    if (round(dflft$obs[i],2) == round(dflft$hi[i],2)){
      dn <- round(dflft$obs[i],3) - round(dflft$hi[i],3)
      tempo <- paste(i,dflft$obs[i], round(dflft$obs[i],3),round(dflft$hi[i],3), abs(round(dn, 5)), hf[number]$name, sep = "\t")
      print(tempo)
      isdf[a] <- tempo
      a=a+1
    }
  }
  isdf <- as.data.frame(isdf)
  colnames(isdf) <- "id\tx\tdata_y\thigh_random_y\ty_diff\tdataset"
  
  write.csv(isdf, file = paste("I:/Users data/Margarita/STED/intersections/", hf[number]$name, ".csv", sep =""))
}

#################################################################################