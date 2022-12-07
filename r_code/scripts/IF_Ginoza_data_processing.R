library(dplyr)

setwd("C:/Users/starf/OneDrive/Documents/Cat_Model_Project/Repo/data/stochastic/JP-GZ/supporting_data")

hazard_grid<-read.csv("./Hazard_GridResolution_Municipality-Ginoza-Okinawa-Japan.csv")
event_frequency<-read.csv("./Event_Frequency.csv")%>%rename(event_id=ï..event_id)

areaperil<-unique(hazard_grid%>%select(lon1,lat1)%>%mutate(lon1=lon1/1000000,
                                                                    lat1=lat1/1000000))%>%
            dplyr::arrange(lat1,lon1)

areaperil<-cbind(areaperil_id=1:nrow(areaperil),areaperil%>%select(lon1,lat1))

write.csv(areaperil,file="areaperil_dict.csv")

intensity_bin<-data.frame(bin_index=1:200,
           bin_from=seq(0,99.5,by=0.5)*3.6,
           bin_to=seq(0.5,100,by=0.5)*3.6)%>%mutate(interpolate=(bin_from+bin_to)/2)


write.csv(intensity_bin,file="intensity_bin_dict.csv")

events<-unique(hazard_grid$event_id)

event_occurrence<-data.frame(event_id=integer(0),period_no=integer(0),occ_year=integer(0))

for (i in 1:10000){

  sims<-event_frequency%>%cbind(sim_value=runif(nrow(event_frequency)))%>%
    mutate(include=ifelse(event_freq>=sim_value,1,0))%>%filter(include==1)
  
  event_occurrence<-rbind(event_occurrence,data.frame(event_id=sims$event_id,
                                                      period_no=rep(i,nrow(sims)),
                                                      occ_year=rep(i,nrow(sims))))
  
  
}

write.csv(event_occurrence,file="occurrence_lt.csv")

# footprint<-unique(hazard_grid%>%select(event_id,grid_id,intensity_bin_index)%>%rename(areaperil_id=grid_id))

footprint<-hazard_grid%>%select(event_id,lon1,lat1,intensity_bin_index)%>%mutate(lon1=lon1/1000000,
                                         lat1=lat1/1000000)%>%
              merge(areaperil,by=c("lon1","lat1"))%>%select(event_id,areaperil_id,intensity_bin_index)%>%
              rename(intensity_bin_id=intensity_bin_index)%>%arrange(event_id)



write.csv(footprint,file="footprint.csv")

#Cat 1 or above

cat1_hazard<-hazard_grid%>%filter(intensity_bin_index>67)%>%merge(event_frequency,by="event_id")%>%
  group_by(event_id)%>%summarise(max_intensity=max(intensity_bin_index),freq=max(event_freq))

