library(tess3r)
context("tess3Project methods")

test_that("FST method and others :-D", {

  projet = TESS3(input.file = athaliana[,-(1:2)], athaliana[,1:2], 1:3, entropy = TRUE)
  fst = FST(projet, 3, 1)
  expect_is(fst,"matrix")
  plot(projet)
  show(projet)
  summary(projet)
  q = Q(projet, 1, 1)
  g = G(projet, 2,1)
  ce = cross.entropy(projet, 3, 1)

  projet_loaded = load.tess3Project("tess3r_workingDirectory/genotype.tess3Project")
  remove.tess3Project( "tess3r_workingDirectory/genotype.tess3Project" )
})
