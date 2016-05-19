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

test_that("test main", {
  data("data.for.test", package = "tess3rOldExperiment")
  file.geno <- paste0(tempfile(),".geno")
  LEA::write.geno(data.for.test$X, file.geno)
  file.coord <- paste0(tempfile(),".coord")
  write.table(data.for.test$coord, row.names = FALSE, col.names = FALSE, file = file.coord)
  W <- ComputeHeatKernelWeight(data.for.test$coord, 2)
  file.W <- paste0(tempfile(),".W")
  write.table(W, row.names = FALSE, col.names = FALSE, file = file.W)
  tess3.old.run <- TESS3(input.file = file.geno,
                         input.coord = file.coord,
                         K = 2,
                         project = "new",
                         repetitions = 1,
                         alpha = 0.001,
                         tolerance = 1e-05,
                         entropy = FALSE,
                         percentage = 0.05,
                         I = 0,
                         iterations = 200,
                         ploidy = 1,
                         seed = -1,
                         CPU = 1,
                         Q.input.file = "",
                         W.input.file = file.W)
})
