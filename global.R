
library(here)
library(tidyverse)
library(raster)
library(leaflet)
library(RColorBrewer)
library(leafem)
library(colorRamps)
library(colorspace)
library(rerddap)
library(sf)
library(htmlwidgets)

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


# 
raw_chloro <- as.data.frame(bind_rows(W_raw_chloro, E_raw_chloro)) %>% 
  group_by(time, latitude, longitude) %>% 
  mutate(chlorophyll = mean(chlorophyll))





so_cal_bath <- read_csv("so_cal_bath.csv")  


rm(E_raw_chloro, E_raw_sst, W_raw_sst, W_raw_chloro)
gc()

# Read in Shape Files

cha <- read_sf(here("shape", "channel_islands.shp")) %>% 
  mutate(geometry = st_transform(geometry, "+proj=longlat +ellps=WGS84 +datum=WGS84")) %>% 
  filter(!NAME=="San Clemente")

ca <- read_sf(here("s_11au16", "s_11au16.shp")) %>% 
  mutate(geometry = st_transform(geometry, "+proj=longlat +ellps=WGS84 +datum=WGS84")) %>% 
  filter(NAME == "California")

mpa <- read_sf(here("ds582", "ds582.shp")) %>%   
  mutate(geometry = st_transform(geometry, "+proj=longlat +ellps=WGS84 +datum=WGS84")) %>% 
  filter(Study_Regi == "SCSR")

smr <- read_sf(here("ds582", "ds582.shp")) %>%   
  mutate(geometry = st_transform(geometry, "+proj=longlat +ellps=WGS84 +datum=WGS84")) %>% 
  filter(Study_Regi == "SCSR") %>% 
  filter(Type %in% c("SMR", "FMR"))

smca <- read_sf(here("ds582", "ds582.shp")) %>%   
  mutate(geometry = st_transform(geometry, "+proj=longlat +ellps=WGS84 +datum=WGS84")) %>% 
  filter(Study_Regi == "SCSR") %>% 
  filter(Type == "SMCA")

no_take <- read_sf(here("ds582", "ds582.shp")) %>%   
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

chl_pal <- colorNumeric(palette =sequential_hcl(25,
                                                h = c(300, 75), c = c(35, 95), l = c(15, 90), power = c(0.8, 1.2)), domain = r_chl$chlorophyll)


rev <- rev(sequential_hcl(40,
  h = c(260, 220), c = c(74, 112, 39), l = c(17, 88), power = c(0, 1.3)))

 bath_pal <- colorNumeric(palette = rev, domain = so_cal_bath$layer)
 
 sst_pal <- colorNumeric(palette = matlab.like(25), domain = r_sst$sst)
 
 
 #Buoy Icon
 Buoy <-makeIcon('icons8-buoy-50.png', iconWidth = 30, iconHeight = 30)
 
 
 

sst_leaf <- leaflet(options = leafletOptions(minZoom = 8.5)) %>%
  addPolygons(data = cha, color = 'black', opacity = 1, weight = 2, fill = F) %>% 
  addPolygons(data = ca, color = 'black', opacity = 1, weight = 2, fill = F) %>% 
  addPolygons(data = smr, group = "MPA Status", color = "red", popup = ~NAME) %>%
  addPolygons(data = smca, group = "MPA Status", color = "blue", popup = ~NAME) %>% 
  addPolygons(data = no_take, group = "MPA Status", color = "purple", popup = ~NAME) %>% 
  addProviderTiles("Esri.OceanBasemap") %>%
  addRasterImage(x = final_re_samp_sst, colors = sst_pal, opacity = 0.7,
                 group = "Sea Surface Temp") %>%
  addRasterImage(x = re_samp_chl, colors = chl_pal, opacity = 0.7,
                 group = "Chlorophyll") %>%
  addRasterImage(x = re_samp_bath, colors = bath_pal, opacity = 0.7,
                  group = "Bathymetry") %>% 
  addMarkers(lng=-120.47, lat=34.273, 
             popup="<a href =https://www.ndbc.noaa.gov/station_page.php?station=46054>
                   West Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>% 
  addMarkers(lng=-119.839, lat=34.241, 
             popup="<a href = https://www.ndbc.noaa.gov/station_page.php?station=46053>
                   East Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>% 
  addMarkers(lng=-119.044, lat=33.758, 
             popup="<a href = https://www.ndbc.noaa.gov/station_page.php?station=46025>
                   Santa Monica Basin Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>%
  addMarkers(lng=-119.565, lat=33.769, 
             popup="<a href = https://www.ndbc.noaa.gov/station_page.php?station=46251>
                   Santa Cruz Basin Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>%
  addMarkers(lng=-120.213, lat=33.677, 
             popup="<a href =https://www.ndbc.noaa.gov/station_page.php?station=46069>
                   South Santa Rosa Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>%
  addMarkers(lng=-118.641, lat=33.860, 
             popup="<a href = https://www.ndbc.noaa.gov/station_page.php?station=46221>
                   Santa Monica Bay Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>%
  addMarkers(lng=-118.317, lat=33.618, 
             popup="<a href = https://www.ndbc.noaa.gov/station_page.php?station=46222>
                   San Pedro Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>%
  addMarkers(lng=-118.181, lat=33.576, 
             popup="<a href = https://www.ndbc.noaa.gov/station_page.php?station=46253>
                   San Pedro South Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>% 
  addMarkers(lng=-117.472, lat=33.178, 
             popup="<a href=https://www.ndbc.noaa.gov/station_page.php?station=46224>
                   Oceanside Offshore Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>%
  addMarkers(lng=-117.391, lat=32.933, 
             popup="<a href = https://www.ndbc.noaa.gov/station_page.php?station=46225>
                   Torrey Pines Outer Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>%
  addMarkers(lng=-117.501, lat=32.752, 
             popup="<a href=https://www.ndbc.noaa.gov/station_page.php?station=46258>
                   Mission Bay West Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>%
  addMarkers(lng=-117.425, lat=32.517, 
             popup="<a href =https://www.ndbc.noaa.gov/station_page.php?station=46232>
                   Point Loma South Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>%
  addMarkers(lng=-118.052, lat=32.499, 
             popup="<a href = https://www.ndbc.noaa.gov/station_page.php?station=46086>
                   San Clemente Basin Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy) %>%
  addMarkers(lng=-119.525, lat=32.388, 
             popup="<a href = https://www.ndbc.noaa.gov/station_page.php?station=46047>
                   Tanner Bank Buoy Data</a>", 
             group = "Buoys", 
             icon = Buoy,
             markerOptions(interactive = T, clickable = T, riseOnHover = T)) %>%
  addLegend(data = r_sst, pal = sst_pal, title = 'Sea Surface Temp', 
            position = "bottomright", values = ~sst, 
            opacity = 1, group = "Sea Surface Temp",
            bins = 8) %>% 
  addLegend(data = so_cal_bath, pal = bath_pal, title = 'Bathymetry', 
             position = "bottomright", 
             values = ~layer, opacity = 1, group = "Bathymetry") %>%
  addLegend(data = r_chl, pal = chl_pal, title = 'Chlorophyll', 
            position = "bottomright", 
            values = ~chlorophyll, opacity = 1, group = "Chlorophyll") %>% 
  addLayersControl(
    baseGroups = c("Sea Surface Temp", "Chlorophyll", "Bathymetry"),
    overlayGroups = c("Buoys", "MPA Status"),
    options = layersControlOptions(collapsed = FALSE)) %>% 
  onRender("
    function(el, x) {
      var updateLegend = function () {
          var selectedGroup = document.querySelectorAll('input:checked')[0].nextSibling.innerText.substr(1);

          document.querySelectorAll('.legend').forEach(a => a.hidden=true);
          document.querySelectorAll('.legend').forEach(l => {
            if (l.children[0].children[0].innerText == selectedGroup) l.hidden=false;
          });
      };
      updateLegend();
      this.on('baselayerchange', e => updateLegend());
    }") %>% 
  setView(lng = -119.200336, lat = 33.808464, zoom = 8.5) %>% 
  setMaxBounds(lng1 = -121.6,
               lat1 = 35.0,
               lng2 = -116.5,
               lat2 = 31.75) %>% 
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "feet",
    primaryAreaUnit = "sqfeet",
    activeColor = "#3D535D",
    completedColor = "#7D4479") %>% 
  addMouseCoordinates()


