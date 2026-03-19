---
title: An R Markdown document converted from "/home/zuzka/Desktop/sobol_2022/Sobol2022_NND.ipynb"
output: html_document
---

```{r}
library(spatstat)
library(maptools)
library(tiff)
#library(spatstat.core)
library(ggplot2)
```
#install.packages("ggplot2")

```{r}
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

######################  new code #################################
points <- c()
for (i in 1:length(dimfiles)){
  points[i] <- get(paste("p",i,sep=""))$n
  if (points[i] > 9000){
    print(i)
    print(points[i])
  }}

semiran_nns <- c()
#########Margarita testing
# deleted if (points[i] < 10000){ / and changed rMaternII za rMaternI
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

for (i in length(semiran_nns):length(dimfiles)-1){
  semiran_nns[i] <- NA
}  
df <- data.frame(names(patlist), semiran_nns)
df$group <- gsub(".*CHO(.+)_sem.*", "\\1", names(patlist))
write.csv(df, file = "I:/Users data/Margarita/STED/new_random_nnd_table_v2.csv")

######################  
###potom toto ###################  
mean_nns <- c()
for (i in 1:length(dimfiles))
  mean_nns[i] <- mean(nndist(get(paste("p", i, sep=""))))

dff <- data.frame(names(patlist), mean_nns, semiran_nns)
dff$ratio_nns <- mean_nns/semiran_nns
dff$group <- gsub(".*CHO(.+)_sem.*", "\\1", names(patlist))

write.csv(dff, file = "I:/Users data/Margarita/STED/new_updated_random_nnd_table_v2.csv")

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

######################  
semiran_nns <- c()
for (i in 1:30){
  if (points[i] < 9000){
    resc_mswin <- rescale(get(paste("mswin",i,sep="")), 50)
    intensity_pp <- intensity(get(paste("p",i,sep="")))
    min_r <- min(nndist(get(paste("p",i,sep=""))))
    rnn <- c()
    a <- 1
  
    for(a in 1:10) {
      semiran_nn <- mean(nndist(rMaternII(kappa = intensity_pp, r = min_r, win = resc_mswin)))
      rnn[a] <- semiran_nn
    }
    semiran_nns[i] <- (mean(rnn))
  }}

for (i in 30:60){
  if (points[i] < 9000){
    resc_mswin <- rescale(get(paste("mswin",i,sep="")), 50)
    intensity_pp <- intensity(get(paste("p",i,sep="")))
    min_r <- min(nndist(get(paste("p",i,sep=""))))
    rnn <- c()
    a <- 1
    
    for(a in 1:10) {
      semiran_nn <- mean(nndist(rMaternII(kappa = intensity_pp, r = min_r, win = resc_mswin)))
      rnn[a] <- semiran_nn
    }
    semiran_nns[i] <- (mean(rnn))
  }}

for (i in 60:length(dimfiles)){
  if (points[i] < 9000){
    resc_mswin <- rescale(get(paste("mswin",i,sep="")), 50)
    intensity_pp <- intensity(get(paste("p",i,sep="")))
    min_r <- min(nndist(get(paste("p",i,sep=""))))
    rnn <- c()
    a <- 1
    
    for(a in 1:10) {
      semiran_nn <- mean(nndist(rMaternII(kappa = intensity_pp, r = min_r, win = resc_mswin)))
      rnn[a] <- semiran_nn
    }
    semiran_nns[i] <- (mean(rnn))
  }}

semiran_nns

reduced_patlist <- c()
mean_nns <- c()
for (i in 1:length(dimfiles))
  mean_nns[i] <- mean(nndist(get(paste("p", i, sep=""))))

df <- data.frame(names(patlist), mean_nns, semiran_nns)
df$ratio_nns <- mean_nns/semiran_nns
df$group <- gsub(".*CHO(.+)_sem.*", "\\1", names(patlist))
head(df)


write.csv(df, file = "D:/Users data/Margarita/new_nnd_table.csv")

lo <- c("wt", "mut")
ggplot(df, aes(x = factor(group, level = lo), y = mean_nns, color = group)) + 
  geom_boxplot(outlier.shape = NA) + 
  geom_jitter()

ggplot(df, aes(x = factor(group, level = lo), y = ratio_nns, color = group)) + 
  geom_boxplot() + 
  geom_jitter()

# saving plot for corrected controls
pdf(file="D:/Users data/Margarita/controlplots.pdf",width=10,height=10)
for (i in 1:length(dimfiles)){
  resc_mswin <- rescale(get(paste("mswin",i,sep="")), 50)
  intensity_pp <- intensity(get(paste("p",i,sep="")))
  min_r <- min(nndist(get(paste("p",i,sep=""))))
  tempdata <- rMaternII(kappa = intensity_pp, r = min_r, win = resc_mswin)
  plot(Lest(tempdata), main = hf[i]$name)
}
dev.off()

##################################################################
rnn <- c()
for(a in 1:100) {
  ran_nn <- mean(nndist(runifpoint(get(paste("p",i,sep=""))$n, win = resc_mswin)))
  rnn[a] <- ran_nn
}
rnn
mean(nndist(get(paste("p", 1, sep=""))))
hist(nndist(get(paste("p", 1, sep=""))), xlim=c(0,1))
plot(p1)
rm <- rescale(get(paste("mswin",1,sep="")), 50)
rand <- runifpoint(get(paste("p",1,sep=""))$n, win = rm)
plot(rand)
hist(nndist(rand), xlim=c(0,1))

x <- as.data.frame(nndist(get(paste("p", i, sep=""))))
x$source <- "data"
colnames(x) <- c("nnd", "source")
head(x)

y <- as.data.frame(nndist(rand))
y$source <- "random"
colnames(y) <- c("nnd", "source")
combinedDf <- rbind(x, y)
ggplot(data = combinedDf, aes(x = factor(source), y = nnd, color = source) ) + 
  geom_boxplot() + theme_bw()

ggplot(combinedDf, aes(x = nnd, color = source)) +
  geom_histogram(fill="white", alpha=0.5, position="identity", binwidth=500)


ran_nns <- c()

for (i in 1:length(dimfiles)){
    resc_mswin <- rescale(get(paste("mswin",i,sep="")), 50)
    rnn <- c()
    a <- 1
    for(a in 1:100) {
        ran_nn <- mean(nndist(runifpoint(get(paste("p",i,sep=""))$n, win = resc_mswin)))
        rnn[a] <- ran_nn
    }
    ran_nns[i] <- (mean(rnn))
}

#print(ran_nns)

mean_nns <- c()
for (i in 1:length(dimfiles))
    mean_nns[i] <- mean(nndist(get(paste("p", i, sep=""))))
#print(mean_nns)      
#print(names(patlist))
points <- c()
for (i in 1:length(dimfiles))
    points[i] <- get(paste("p",i,sep=""))$n
points

```{r}
df <- data.frame(names(patlist), mean_nns, ran_nns)
df$ratio_nns <- mean_nns/ran_nns
df$group <- gsub(".*CHO(.+)_sem.*", "\\1", names(patlist))
head(df)
```

```{r}
write.csv(df, file = "D:/Users data/Margarita/nnd_table.csv")
```

```{r}
lo <- c("wt", "mut")
ggplot(df, aes(x = factor(group, level = lo), y = mean_nns, color = group)) + 
    geom_boxplot(outlier.shape = NA) + 
    geom_jitter()
```

```{r}
ggplot(df, aes(x = factor(group, level = lo), y = ratio_nns, color = group)) + 
    geom_boxplot() + 
    geom_jitter()
```
help("geom_boxplot")


##### test
resc_mswin <- rescale(mswin15, 50)
resc_mswin
ints <- intensity(p15)
ints
min_r <- min(nndist(p15))
min_r
test <- Lest(p15, nlarge = 12000)
plot(test)
plot(p15)
x <- rMaternI(kappa = ints, r = min_r, win = resc_mswin)
x
plot(x)

na_list <- list(15,20,22,26,81,93,94)

semiran_nns <- c()
for (i in na_list){
  resc_mswin <- rescale(get(paste("mswin",i,sep="")), 50)
  intensity_pp <- intensity(get(paste("p",i,sep="")))
  min_r <- min(nndist(get(paste("p",i,sep=""))))
  rnn <- c()
  a <- 1
    
  for(a in 1:10) {
    x <- rMaternI(kappa = intensity_pp, r = min_r, win = resc_mswin)
    semiran_nn <- mean(nndist(x))
    print(x)
    rnn[a] <- semiran_nn
    }
  semiran_nns[i] <- (mean(rnn))
}

semiran_nns

