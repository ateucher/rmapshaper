download.file("https://github.com/ateucher/rmapshaper/files/1911058/statsnzregional-council-2018-clipped-generalised-GPKG.zip",
              destfile = "statsnzregional-council-2018-clipped-generalised-GPKG.zip")

library(sf)
unzip("statsnzregional-council-2018-clipped-generalised-GPKG.zip")
nz_full = st_read("regional-council-2018-clipped-generalised.gpkg")
nz_simp1 = rmapshaper::ms_simplify(nz_full, keep = 0.001, sys = FALSE)
nz_simp2 = rmapshaper::ms_simplify(nz_full, keep = 0.001, sys = TRUE)

cat("original:") 
print(object.size(nz_full), units = "Kb")
cat("sys-false: ")
print(object.size(nz_simp1), units = "Kb")
cat("sys-true: ")
print(object.size(nz_simp2), units = "Kb")

