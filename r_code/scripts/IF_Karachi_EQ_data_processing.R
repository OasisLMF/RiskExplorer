library(dplyr)
library(tidyr)

setwd("C:/Users/starf/Develop/data/stochastic/supporting_data/PK-KA")

hazard_grid<-read.csv("./supporting_data/Hazard_GridResolution_Cresta-Karachi-Pakistan.csv")%>%mutate(Intensity=Intensity*100)%>%
  dplyr::rename(event_id=Event_ID,lon1=Longitude,lat1=Latitude,intensity=Intensity,
                grid_id=GridID)

event_frequency<-read.csv("./supporting_data/Event_Frequency.csv")%>%lapply(as.numeric)%>%
                  as.data.frame()%>%drop_na()

colnames(event_frequency)<-tolower(colnames(event_frequency))

areaperil<-unique(hazard_grid%>%select(lon1,lat1)%>%mutate(lon1=lon1/1000000,
                                                                    lat1=lat1/1000000))%>%
            dplyr::arrange(lat1,lon1)

areaperil<-cbind(areaperil_id=1:nrow(areaperil),areaperil%>%select(lon1,lat1))

write.csv(areaperil,file="areaperil_dict.csv")

intensity_bin<-data.frame(intensity_bin_id=1:170,
           bin_from=seq(0.5,85,by=0.5),
           bin_to=seq(0.5,85,by=0.5))%>%mutate(interpolate=(bin_from+bin_to)/2)

write.csv(intensity_bin,file="intensity_bin_dict.csv")

events<-unique(hazard_grid$event_id)

event_occurrence<-data.frame(event_id=integer(0),period_no=integer(0),occ_year=integer(0))

for (i in 1:100000){

  sims<-event_frequency%>%cbind(sim_value=runif(nrow(event_frequency)))%>%
    mutate(include=ifelse(event_freq>=sim_value,1,0))%>%filter(include==1)
  
  event_occurrence<-rbind(event_occurrence,data.frame(event_id=sims$event_id,
                                                      period_no=rep(i,nrow(sims)),
                                                      occ_year=rep(i,nrow(sims))))
  
  
}

write.csv(event_occurrence,file="occurrence_lt.csv")

footprint<-hazard_grid%>%select(event_id,lon1,lat1,intensity)%>%merge(intensity_bin,
                                                                      by.x="intensity",by.y="bin_from")%>%
          select(event_id,lon1,lat1,intensity_bin_id)%>%
          mutate(lon1=lon1/1000000,lat1=lat1/1000000)%>%
          merge(areaperil,by=c("lon1","lat1"))%>%select(event_id,areaperil_id,intensity_bin_id)%>%
          arrange(event_id)


write.csv(footprint,file="./footprint/footprint.csv",row.names = FALSE)
