# AIM: Create an interactive map of Melbourne council areas, coloured by median income. Also allow interactive hover to reveal exact values, using ggiraph package (successor of plotly)

#install.packages(c('sf','ggiraph','remotes')
#remotes::install_github("runapp-aus/strayr")

library(sf)
library(ggiraph)


# read map data via API ---------------------------------------------------



mapdata1 <- strayr::read_absmap("sa32021")


# read income data via url ------------------------------------------------

income <- read_csv("https://raw.githubusercontent.com/wfmackey/absmapsdata/master/img/data/median_income_sa3.csv")



# join data ---------------------------------------------------------------



combined_data <- left_join(income, 
                           mapdata1, 
                           by = c("sa3_name_2016"='sa3_name_2021')
)

# create plot -------------------------------------------------------------



mapdata1 %>%
  filter(gcc_name_2021 == "Greater Melbourne") %>%    
  ggplot() +
  geom_sf(aes(geometry = geometry,  # use the geometry variable
              fill = areasqkm_2021),     # fill by area size
          lwd = 0,                  # remove borders
          show.legend = FALSE) +    # remove legend
  geom_point(aes(cent_long,
                 cent_lat),        # use the centroid long (x) and lats (y)
             colour = "white") +    # make the points white
  theme_void() +                    # clears other plot elements
  coord_sf()




map_plt <- combined_data %>%
  filter(gcc_name_2021 == "Greater Melbourne") %>%   # let's just look Melbourne
  ggplot() +
  geom_sf(aes(geometry = geometry,   # use the geometry variable
              fill = median_income), # fill by unemployment rate
          lwd = 0) +                 # remove borders
  theme_void() +                     # clears other plot elements
  labs(fill = "Median income"); map_plt

# ggiraph -----------------------------------------------------------------


plot_data <- combined_data %>%
  filter(gcc_name_2021 == "Greater Melbourne")

# Create interactive plot
girafe_plt <- ggplot() +
  geom_sf_interactive(
    data = plot_data,
    aes(
      geometry = geometry,
      fill = median_income,
      tooltip = paste0(sa3_name_2016,'\n',
                       "Median income: $", median_income) # Hover text
    ),
    lwd = 0,colour='lightgrey'
  ) +
  theme_void() +
  labs(fill = "Median income") + scale_fill_viridis_c(end=0.9) +
  ggtitle('Melbourne Metro Median Income in 2016')


# Render with ggiraph
girafe(ggobj = girafe_plt)
