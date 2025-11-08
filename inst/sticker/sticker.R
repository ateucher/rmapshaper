library(rnaturalearth)
library(sf)
library(rmapshaper)
library(geojsonsf)
library(dplyr)
library(hexSticker)
library(showtext)
library(ggplot2)
## Loading Google fonts (http://www.google.com/fonts)
font_add_google("Nova Mono", "novamono")
## Automatically use showtext to render text for future devices
showtext_auto()

## Seed for colours (dummyval)
set.seed(32)

world <- ne_countries(returnclass = "sf")
world_simp <- world |>
  mutate(dummyval = runif(nrow(world))) |>
  select(iso_a3, dummyval) |>
  st_transform("ESRI:54030") |>
  ms_simplify(keep = 0.1)


world_centroid <- st_coordinates(st_centroid(ms_dissolve(world_simp)))

poly_centroids <- st_coordinates(st_centroid(world_simp))

xdiff <- poly_centroids[, "X"] - world_centroid[, "X"]
ydiff <- poly_centroids[, "Y"] - world_centroid[, "Y"]

## Percentage shift from world centroid
xshift <- 0.1
yshift <- 0.1

## Seed for rotation
set.seed(36)
rotate <- runif(length(xdiff), -60, 60)

affine_shift_cmd <-
  glue::glue(
    "-affine shift={xdiff * xshift},{ydiff * yshift} rotate={rotate} where='iso_a3 == \"{world_simp$iso_a3}\"'"
  ) |>
  Filter(\(x) !grepl("ATA", x), x = _) |>
  glue::glue_collapse(sep = " ")


crazy_map <- sf_geojson(world_simp) |>
  apply_mapshaper_commands(affine_shift_cmd) |>
  geojson_sf(
    input = st_crs(world_simp)$input,
    wkt = st_crs(world_simp)$wkt
  ) |>
  select(iso_a3, dummyval)

p <- ggplot() +
  geom_sf(
    data = crazy_map,
    aes(fill = dummyval),
    linewidth = 0.1,
    show.legend = FALSE
  ) +
  scale_fill_distiller(palette = "Greens") +
  theme_void()

## hex sticker

write_sticker <- function(p, format, plot_dim) {
  sticker(
    p,
    package = "rmapshaper",
    p_size = 15, # This seems to behave very differently on a Mac vs PC
    p_y = 0.45,
    p_color = "#c2e4a5",
    p_family = "novamono",
    p_fontface = "bold",
    s_x = 1.0,
    s_y = 1.04,
    s_width = plot_dim,
    s_height = plot_dim,
    h_color = "#c2e4a5",
    filename = file.path(paste0("inst/sticker/rmapshaper.", format))
  )
}

(write_sticker(p, "png", 1.85))
# write_sticker(p, "svg")

usethis::use_logo("inst/sticker/rmapshaper.png")
