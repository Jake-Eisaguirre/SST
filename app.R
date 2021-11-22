# shiny app

source("global.R")

library(htmlwidgets)
library(shiny)
library(leaflet)
ui <- fluidPage(
  
  titlePanel("So-Cal Fish Bite"),
  
  leafletOutput("sst_leaf", height = 700, width = "100%"),
  
  
  
)

server <- function(input, output, session){
  
  #Reactive
  sst_reactive <- reactive({
    final_re_samp_sst
  })
  
  
  
  
  #Map
  output$sst_leaf <- renderLeaflet({
    
    leaflet(options = leafletOptions(minZoom = 8.5)) %>%
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
        completedColor = "#7D4479")
    
    
    
    
  })
  
}

shinyApp(ui = ui, server = server)