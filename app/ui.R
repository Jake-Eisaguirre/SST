
shinyUI(
  fluidPage(
    
    titlePanel("So-Cal Fish Bite"),
    
    leafletOutput("sst_leaf", height = 700, width = "100%")
    
  )
)
