fname = "use-cases.Rmd"

f.in = file.path("vignettes-raw", fname)
f.out = file.path("vignettes", fname)

unlink(f.out)
knitr::knit(input = f.in, output = f.out)
file.edit(f.out)

# Spark cleanup
Sys.sleep(3)
source("vignettes-raw/1-spark-cleanup.R")
