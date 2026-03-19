---
title: An R Markdown document converted from "/home/zuzka/Desktop/sobol_2022/Sobol2022_curves.ipynb"
output: html_document

library(spatstat)
library(maptools)
library(tiff)
#library(spatstat.core)
library(ggplot2)

dimfiles <- list.files("D:/Users data/Margarita/2022-05-23_STED_Analysis_images", pattern="*mask.tif", full.names=TRUE, recursive = TRUE)
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

maskfiles <- list.files("D:/Users data/Margarita/2022-05-23_STED_Analysis_masks", pattern="*mask.csv", full.names=TRUE, recursive = TRUE)
ldf <- lapply(maskfiles, read.csv, header = TRUE)
for (i in 1:length(maskfiles))
  assign(paste("msk", i,sep=""), ldf[[i]])

xyfiles <- list.files("D:/Users data/Margarita/2022-05-23_STED_Analysis_points", pattern="*xy.csv", full.names=TRUE, recursive = TRUE)
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


plot(allstats(get(paste("p",1, sep=""))), main = hf[1]$name)
plot(allstats(get(paste("p",2, sep=""))), main = hf[2]$name)

pdf(file="D:/Users data/Margarita/allplots.pdf",width=8,height=8)
for (i in 1:length(dimfiles)){
    plot(allstats(get(paste("p",i, sep=""))), main = hf[i]$name)
}
dev.off()


lft <- envelope(p1, Lest, correction = "best", nsim = 10, verbose = FALSE)
plot(lft, main = hf[1]$name)
plot(lft, . - r ~ r)
dflft <- as.data.frame(lft)
head(dflft)
plot(dflft$r,(dflft$obs), type="l")
lines(dflft$r,(dflft$hi),col="green")

fit1<-smooth.spline(dflft$r,(dflft$obs),cv = TRUE)
fit2<-smooth.spline(dflft$r,(dflft$hi),cv = TRUE)
plot(dflft$r,(dflft$obs), type="l")
lines(fit1,lwd=2,col="green")
lines(fit2,lwd=2,col="purple")

install.packages("remotes")
remotes::install_github("andrewheiss/reconPlots")
library(reconPlots)

curve_intersect(curve(fit1), curve(fit2))

linear_model1 <- lm(dflft$obs~poly(dflft$r,4,raw=TRUE), data=dflft)
plot(dflft$r,(dflft$obs))
lines(dflft$r, predict(linear_model1, data.frame(x=dflft$r)), col='green')
summary(linear_model1)$adj.r.squared

f1 <- function(x)  10 * x * log(x)^2
f2  <- function(x) 100 * x * log(x)



curve(f1,from=1e-3,to=1e8,log="xy")
curve(f2,add=TRUE,col=2)
uniroot(function(x) f1(x)-f2(x),c(10,1e8))$root

                 

min(lft$obs-lft$r)


dflft <- as.data.frame(lft)
dflft$obsr <- lft$obs-lft$r
head(dflft)

dflft[dflft$obsr == min(dflft$obsr),"r"]

lft <- envelope(p1, Lest, correction = "best", nsim = 10, verbose = FALSE)
plot(lft, main = hf[1]$name)
plot(lft, . - r ~ r)


pdf(file="D:/Users data/Margarita/L_functions.pdf",width=8,height=8)
for (i in 1:length(dimfiles)){
    lft <- envelope(get(paste("p",i,sep="")), Lest, correction = "trans", nsim = 10, verbose = FALSE)
    plot(lft, main = hf[i]$name) 
    plot(lft, . - r ~ r, main = hf[i]$name)
}
dev.off()

```{r}
minr <- c()
for (i in 1:length(dimfiles)){
    lft <- envelope(get(paste("p",i,sep="")), Lest, correction = "trans", nsim = 10, verbose = FALSE)
    dflft <- as.data.frame(lft)
    dflft$obsr <- lft$obs-lft$r
    min <- dflft[dflft$obsr == min(dflft$obsr),"r"]
    minr[i] = min
}
```
minr
```{r}
names <- hf$name
names <- as.data.frame(names)
names$minr <- minr
names
```
write.csv(names, file = "D:/Users data/Margarita/minr_table.csv")


for (i in 14:length(dimfiles)){
  lft <- envelope(get(paste("p",i,sep="")), Lest, correction = "trans", nsim = 100, verbose = FALSE)
  dflft <- as.data.frame(lft)
  write.csv(dflft, file = paste("D:/Users data/Margarita/function_tables/", hf[i]$name, ".csv", sep =""))
}

