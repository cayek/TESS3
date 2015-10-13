library(tess3r)
context("tess3utils")

test_that("createGridFromAsciiRaster", {
  asciiFile=system.file("extdata/","lowResEurope.asc",package = "tess3r")
  grid=createGridFromAsciiRaster(asciiFile)
})


test_that("getConstraintsFromAsciiRaster", {
  asciiFile=system.file("extdata/","lowResEurope.asc",package = "tess3r")
  grid=getConstraintsFromAsciiRaster(asciiFile)
})


test_that("maps", {

  project = tess3(input.file = athaliana[,-(1:2)], athaliana[,1:2], 3)

  asciiFile=system.file("extdata/","lowResEurope.asc",package = "tess3r")
  grid=createGridFromAsciiRaster(asciiFile)
  # To display only altitudes above 0:
  constraints=getConstraintsFromAsciiRaster(asciiFile,cell_value_min=0)

  maps(matrix = Q( project, K = 3, run = 1 ),
       coord = athaliana[,1:2],
       grid=grid,constraints=constraints,method="max",main="ancestry coefficient with K = 3")
})