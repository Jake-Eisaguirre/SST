
```{r}

# chloro_plot <- ggplot() +
#   geom_raster(data = final_chloro, aes(y=latitude, x=longitude, fill = chlorophyll),
#               show.legend = T,
#               interpolate = T,
#               hjust = 1,
#               vjust = 1) +
#   scale_fill_viridis_c(option = "turbo") +
#   theme_light() +
#   labs(x = "Longitude",
#        y = "",
#        fill = "Chlorophyll
# (mg m^-3)") +
#   theme(panel.grid = element_line(F),
#         panel.background = element_rect(fill = "grey70"),
#         legend.position = "bottom",
#         axis.text.x = element_text(angle = 45, vjust = 1, hjust=1),
#         axis.title.y=element_blank(),
#         axis.text.y=element_blank(),
#         axis.ticks.y=element_blank(),
#         plot.margin = unit(c(0,0.8,0,0), "inches")) +
#   scale_x_continuous(breaks = c(-120.5, -120.25, -120, -119.75, -119.5, -119.25, -119),
#                      expand = c(0,0)) +
#   scale_y_continuous(breaks = c(33.25, 33.5, 33.75, 34, 34.25, 34.5),
#                                 expand = c(0,0),
#                      position = "right") +
#   geom_sf(data = cha, color = "black", fill = "grey60") +
#   geom_sf(data = ca, color = "black", fill = "grey60") +
#   coord_sf(xlim = c(-120.69999999999999, -118.75), ylim = c(33.1125, 34.9), expand = FALSE)







# grid.arrange(sst_plot, chloro_plot, ncol=2)

```  
```{r}
# sst_plot <- ggplot() +
#   geom_raster(data = final_sst, aes(y=latitude, x=longitude, fill = sst),
#               show.legend = T,
#               interpolate = T,
#               hjust = 1,
#               vjust = 1) +
#   scale_fill_viridis_c(option = "plasma", begin = 0) +
#   theme_light() +
#   labs(x = "Longitude",
#        y = "Latitude",
#        #title = "3 Day Composite",
#        fill = "Sea Surface
# Temperature (F)") +
#   theme(panel.grid = element_line(F),
#         legend.position = "bottom",
#         panel.background = element_rect(fill = "grey70"),
#         axis.text.x = element_text(angle = 45, vjust = 1, hjust=1),
#         plot.margin = unit(c(0,0,0,0), "inches")) +
#   scale_x_continuous(breaks = c(-120.5, -120.25, -120, -119.75, -119.5, -119.25, -119),
#                      expand = c(0,0)) +
#   scale_y_continuous(breaks = c(33.25, 33.5, 33.75, 34, 34.25, 34.5),
#                                         expand = c(0,0)) +
#   geom_sf(data = cha, color = "black", fill = "grey60") +
#   geom_sf(data = ca, color = "black", fill = "grey60") +
#   coord_sf(xlim = c(-120.69999999999999, -118.75), ylim = c(33.1125, 34.9), expand = FALSE)
# 
# 
#   

```