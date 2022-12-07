library(dplyr)
library(readr)

areaperil<-read.csv("./data/stochastic/BD/files/eventset.oasis_areaperil_dict.csv",)

areaperils_to_keep<-areaperil%>%filter(lat1<=27.5&lat1>=18.5&lon1<=94&lon1>=86.5)
areaperils_to_keep<-as.vector(areaperils_to_keep$areaperil_id)

footprint<-read.csv("./stochastic/BD/footprint/footprint.csv",
                      colClasses = c(rep("integer",3),"NULL"))


footprint<-footprint%>%filter(areaperil_id %in% areaperils_to_keep)
  
write.csv(footprint,"./data/stochastic/BD/footprint/footprint.csv",row.names = FALSE)
