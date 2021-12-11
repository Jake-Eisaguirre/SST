
library(tidyverse)
library(raster)
library(leaflet)
library(sf)
library(RColorBrewer)
library(leafem)
library(colorRamps)
library(colorspace)
library(rerddap)
library(htmlwidgets)
library(shiny)

date <- as.Date(Sys.time()) %>% 
  paste0("T12:00:00Z") 

past_date <- as.Date(date) -8

past_date <- as.Date(past_date) %>% 
  paste0("T12:00:00Z") 


# W_raw_sst_3 <- griddap('erdMWsstd3day_LonPM180',
#  time = c(past_date,'last'),
#  latitude = c(35.0, 31.75),
#  longitude = c(-121.5, -119),
#  fmt = "csv")
# 
# 
# E_raw_sst_3 <- griddap('erdMWsstd3day_LonPM180',
#  time = c(past_date,'last'),
#  latitude = c(35.0, 31.75),
#  longitude = c(-119, -116.5),
#  fmt = "csv")

W_raw_sst <- griddap('erdMWsstd8day_LonPM180',
                     time = c(past_date,'last'),
                     latitude = c(35.0, 31.75),
                     longitude = c(-121.5, -119),
                     fmt = "csv")


E_raw_sst <- griddap('erdMWsstd8day_LonPM180',
                     time = c(past_date,'last'),
                     latitude = c(35.0, 31.75),
                     longitude = c(-119, -116.5),
                     fmt = "csv")

raw_sst <- as.data.frame(bind_rows(W_raw_sst, E_raw_sst)) %>% 
  group_by(time, latitude, longitude) %>% 
  mutate(sst = mean(sst))



# W_raw_chlor_3 <- griddap('erdMWchla3day_LonPM180',
#  time = c(past_date,'last'),
#  latitude = c(35.0, 31.75),
#  longitude = c(-121.5, -119),
#  fmt = "csv")
# 
# E_raw_chlor_3 <- griddap('erdMWchla3day_LonPM180',
#  time = c(past_date,'last'),
#  latitude = c(35.0, 31.75),
#  longitude = c(-119, -116.5),
#  fmt = "csv")

W_raw_chloro <- griddap('erdMWchla8day_LonPM180',
                        time = c(past_date,'last'),
                        latitude = c(31.75, 35.0),
                        longitude = c(-121.5, -119),
                        fmt = "csv")

E_raw_chloro <- griddap('erdMWchla8day_LonPM180',
                        time = c(past_date,'last'),
                        latitude = c(31.75, 35.0),
                        longitude = c(-119, -116.5),
                        fmt = "csv")



raw_chloro <- as.data.frame(bind_rows(W_raw_chloro, E_raw_chloro)) %>% 
  group_by(time, latitude, longitude) %>% 
  mutate(chlorophyll = mean(chlorophyll))





so_cal_bath <- read_csv("data/so_cal_bath.csv")


rm(E_raw_chloro, E_raw_sst, W_raw_sst, W_raw_chloro)
gc()

# Read in Shape Files

cha <- read_sf("data/CHIS/channel_islands.shp") %>% 
  mutate(geometry = st_transform(geometry, "+proj=longlat +ellps=WGS84 +datum=WGS84")) %>% 
  filter(!NAME=="San Clemente")

ca <- read_sf("data/California/california.shp") %>% 
  mutate(geometry = st_transform(geometry, "+proj=longlat +ellps=WGS84 +datum=WGS84")) %>% 
  filter(NAME == "California")

mpa <- read_sf("data/MPA/MPA.shp") %>%   
  mutate(geometry = st_transform(geometry, "+proj=longlat +ellps=WGS84 +datum=WGS84")) %>% 
  filter(Study_Regi == "SCSR")

smr <- read_sf("data/MPA/MPA.shp") %>%   
  mutate(geometry = st_transform(geometry, "+proj=longlat +ellps=WGS84 +datum=WGS84")) %>% 
  filter(Study_Regi == "SCSR") %>% 
  filter(Type %in% c("SMR", "FMR"))

smca <- read_sf("data/MPA/MPA.shp") %>%   
  mutate(geometry = st_transform(geometry, "+proj=longlat +ellps=WGS84 +datum=WGS84")) %>% 
  filter(Study_Regi == "SCSR") %>% 
  filter(Type == "SMCA")

no_take <- read_sf("data/MPA/MPA.shp") %>%   
  mutate(geometry = st_transform(geometry, "+proj=longlat +ellps=WGS84 +datum=WGS84")) %>% 
  filter(Study_Regi == "SCSR") %>% 
  filter(Type == "SMCA (No-Take)")


merged_shapes_mask <- bind_rows(ca, cha)


# Clean SST Data

clean_sst <- raw_sst[-c(2)] 

# mut_sst <- clean_sst %>% 
#   mutate(data.frame(longitude = as.numeric(clean_sst$longitude))) %>% 
#   mutate(data.frame(latitude = as.numeric(clean_sst$latitude))) %>% 
#   mutate(data.frame(sst = as.numeric(clean_sst$sst))) %>% 
#   na.omit()

final_sst <- raw_sst %>% #final clean SST data frame
  mutate(sst = (sst * (9/5) + 32 )) %>% 
  mutate(sst = (sst - 5)) %>% 
  na.omit()



rm(raw_sst, clean_sst)
gc()


# Clean Chloro Data

final_chloro <- raw_chloro[-c(2)] 

# final_chloro <- clean_chloro %>% #final clean chloro data frame
#   mutate(data.frame(longitude = as.numeric(clean_chloro$longitude))) %>% 
#   mutate(data.frame(latitude = as.numeric(clean_chloro$latitude))) %>% 
#   mutate(data.frame(chlorophyll = as.numeric(clean_chloro$chlorophyll))) %>% 
#   na.omit() %>% 
#   as_data_frame()

final_chloro$chlorophyll <- abs(log(final_chloro$chlorophyll))

final_chloro <- final_chloro %>% 
  na.omit()

rm(raw_chloro)
gc()

#sst raster
r_sst <- final_sst[-c(1)]

r_sst <- as.data.frame(r_sst)

r_sst <- r_sst[c('longitude', 'latitude', 'sst')]

ras_sst <- rasterFromXYZ(r_sst, crs =4326)


new_ras_sst <- raster(xmn = -121.5,
                      xmx = -116.5,
                      ymn = 31.0,
                      ymx = 35.0,
                      res = c(0.002, 0.002))


re_samp_sst <- resample(ras_sst, new_ras_sst, method = "bilinear")


cropped_sst <- mask(re_samp_sst, merged_shapes_mask, inverse = T)


final_re_samp_sst <- projectRaster(cropped_sst, crs = 4326) #final re-sammpled SST raster

rm(new_ras_sst, re_samp_sst, cropped_sst, ras_sst)
gc()



# Chloro Raster
r_chl <- final_chloro[-c(1)]

r_chl <- as.data.frame(r_chl)

r_chl <- r_chl[c('longitude', 'latitude', 'chlorophyll')]

ras_chl <- rasterFromXYZ(r_chl, crs = 4326 )

new_ras_chl <- raster(xmn = -121.5,
                      xmx = -116.5,
                      ymn = 31.0,
                      ymx = 35.0,
                      res = c(0.002, 0.002))

re_samp_chl <- resample(ras_chl, new_ras_chl, method = "bilinear")

cropped_chl <- mask(re_samp_chl, merged_shapes_mask, inverse = T)

re_samp_chl <- projectRaster(cropped_chl, crs = 4326) #final re-sampled Chloro raster

rm(ras_chl, new_ras_chl, cropped_chl)
gc()


# bath Raster


bath_ras <- rasterFromXYZ(so_cal_bath, crs = 4326)

new_ras_bath <- raster(xmn = -121.5,
                       xmx = -116.5,
                       ymn = 31.0,
                       ymx = 35.0,
                       res = c(0.002, 0.002))


re_samp_bath <- resample(bath_ras, new_ras_bath, method = "bilinear") #final re-sampled Bathy raster

cropped_bath <- mask(re_samp_bath, merged_shapes_mask, inverse = T)

re_samp_bath <- projectRaster(cropped_bath, crs = 4326) #final re-sampled Chloro raster

rm(bath_ras, new_ras_bath, cropped_bath)
gc()

# Color pals for rasters
#sst_pal <- colorNumeric(palette = sequential_hcl(5,
#h = c(-110, 82), c = c(61, 100), l = c(13, 100), power = c(2.45, 0.9)), domain = r_sst$sst)

chl_pal <- colorNumeric(
  palette =sequential_hcl(
    25,h = c(300, 75), c = c(35, 95), l = c(15, 90),
    power = c(0.8, 1.2)), domain = r_chl$chlorophyll)


rev <- rev(sequential_hcl(40,
  h = c(260, 220), c = c(74, 112, 39), l = c(17, 88), power = c(0, 1.3)))

 bath_pal <- colorNumeric(palette = rev, domain = so_cal_bath$layer)
 
 sst_pal <- colorNumeric(palette = matlab.like(25), domain = r_sst$sst)
 
 
 #Buoy Icon
 Buoy <-makeIcon('icons8-buoy-50.png', iconWidth = 30, iconHeight = 30)
 
 



