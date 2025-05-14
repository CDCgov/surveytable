fname = "use-cases.Rmd"

file.remove(file.path("vignettes", fname))
knitr::knit(input = file.path("vignettes-raw", fname)
            , output = file.path("vignettes", fname))

# Spark cleanup
Sys.sleep(3)
unlink(file.path("vignettes-raw", "derby.log"))
unlink(file.path("vignettes-raw", "logs")
      , recursive = TRUE, force = TRUE)
