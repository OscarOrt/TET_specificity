#######Calculate demethylation kinetics for each of 256 motifs for Decitabine experiment#########

###########################################################################################################

#load dplyr package to allow select function
library(dplyr)

setwd("~/Dropbox/DemethylationKinetics_Scripts/Oscar/Datasets/")

#remove any "*_DemethVeloc.txt" output files from the last run (as this will cause errors)
unlink("*_DemethVeloc.txt", recursive = FALSE)

#Loop for all raw files
input.files <- list.files(pattern="^V65_Dec_non_CGI_meth", full.names=TRUE, recursive=FALSE)
for(i in 1:length(input.files)){
  data <- read.csv(input.files[i])
  #remove summary line from input file)  
  data <- data[-257,]

###start a new dataframe with slope in it
#Make dummy data
Demeth.veloc<-data.frame(0.5,1)
#NameColumns
names(Demeth.veloc)<-c("Motif","slope")
#RemoveDummyData
Demeth.veloc <- Demeth.veloc[-1,]

#extract time pointsof interest
zero.h <- t(select(data, matches("V65_Dec_0h_")))
six.h <- t(select(data, matches("V65_Dec_6h_")))
twelve.h <- t(select(data, matches("V65_Dec_12h_")))
eighteen.h <- t(select(data, matches("V65_Dec_18h_")))
twenty4.h <- t(select(data, matches("V65_Dec_24h_")))
thirty.h <- t(select(data, matches("V65_Dec_30h_")))
thirty6.h <- t(select(data, matches("V65_Dec_36h_")))
forty2.h <- t(select(data, matches("V65_Dec_42h_")))
forty8.h <- t(select(data, matches("V65_Dec_48h_")))


###this is the Demethy veloc motif loop. Makes a table for each Motif and each timepoint during linear demehtylation (i.e. over 30 h)
for (Motif.col in 1:256){
  #Make new dataframe ("Motif1") which holds the methylation values for each motif at the timepoints of interest....
  #Needs to be updated for each dataset
  command.a <- paste("Motif1 <- zero.h[,",Motif.col,"]", sep="")
  eval(parse(text=command.a))
  command.a <- paste("Motif1 <- cbind(Motif1, six.h[,",Motif.col,"])", sep="")
  eval(parse(text=command.a))
  command.a <- paste("Motif1 <- cbind(Motif1, twelve.h[,",Motif.col,"])", sep="")
  eval(parse(text=command.a))
  command.a <- paste("Motif1 <- cbind(Motif1, eighteen.h[,",Motif.col,"])", sep="")
  eval(parse(text=command.a))
  command.a <- paste("Motif1 <- cbind(Motif1, twenty4.h[,",Motif.col,"])", sep="")
  eval(parse(text=command.a))
  command.a <- paste("Motif1 <- cbind(Motif1, thirty.h[,",Motif.col,"])", sep="")
  eval(parse(text=command.a))
  
  #Add colnames to Motif 1, make new vector with hr
  colnames(Motif1)<- c("0 h", "6 h", "12 h", "18 h", "24 h", "30 h")
  hr <- c(0,6,12,18,24,30)
  
  #Convert the table from factors to characters to numbers
  Motif1 <- as.data.frame(Motif1, stringsAsFactors = FALSE)
  Motif1 <- as.data.frame(sapply(Motif1, as.numeric))
  
  ##plot methylation change over time, calculate slope (lm) over linear range
  #mean.data is to get y-axis limit defined
  Loss.pp <- Motif1 - mean(Motif1$`0 h`) 
  mean.data = colMeans(Loss.pp, na.rm=T)
  par(new=TRUE)
  plot(x=hr, y=mean.data, las=1, frame.plot=F, ylim = c(-30,5), ylab = "CG methylation (%)")
  abline(lm(mean.data~hr), col="red") # regression line (y~x) 
  slope <- coef(lm(mean.data~hr))[2] #slope is the kinetic for demethylation at each motif (pp/h)
  
  #Add new value to summary table "Demeth.veloc1"
  Demeth.veloc1 <-  data.frame(Motif.col,slope)
  colnames(Demeth.veloc1)<-c("Motif","slope")
  Demeth.veloc <- rbind(Demeth.veloc,Demeth.veloc1)
  
} #End of Motif DemethVelocy loop


##Add Demethy.velocity to data file()
data$slope <- Demeth.veloc$slope

#write files according to input file
file.prefix <- basename(input.files[i])
output.filename <- paste(file.prefix,"_DemethVeloc.txt", sep = "")
write.table(data, file=output.filename, sep = "\t", row.names = T)

}

 data <- data[order(data$slope),]
data$slope <- data$slope*-1
row.names(data) <- data$kmer

#plot the slope data
layout(matrix(c(1,2,1,3), nrow = 2, ncol = 2, byrow = TRUE))

plot(y=data$slope, x=1:256, pch=20, las=1, frame.plot = F, ylab = "Demethylation velocity (-mC/h)", xlab="Rank", ylim = c(1.2,1.8))



