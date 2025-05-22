unlink("derby.log")
unlink("logs", recursive = TRUE, force = TRUE)

unlink(file.path("vignettes-raw", "derby.log"))
unlink(file.path("vignettes-raw", "logs"), recursive = TRUE, force = TRUE)
