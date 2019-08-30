library(leaflet)

# Add a marker for the "Population Health Facility" on the UW campus.
leaflet() %>% addTiles() %>%
  addMarkers(lat = 47.65401, lng = -122.3117, 
             popup = "Population Health Facility,<br>University of Washington")
