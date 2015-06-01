cat("******************************************************\n")
cat("**************TESTS of TESS3 cmd line R***************\n")
cat("******************************************************\n")

source("/home/cayek/Projects/TESS3/src/Rwrapper/TESS3.R")



################################################################
####################BLACK BOX TESTING###########################
################################################################

nonRegressionTesting <- function( directory, genoDataFile, coordDataFile, K, ploidy ) {
  
  cat(paste("----->nonRegressionTesting TEST :", directory, "\n"))
  
  setwd( directory )
  
  genotype = as.matrix(read.table( file = genoDataFile ))
  spatialData = as.matrix(read.table( file = coordDataFile ))
  
  res = TESS3( genotype, spatialData, K, ploidy=ploidy, seed=0 )
  if(!file.exists(file = "nonRegressionTesting.res") ) {
    resOld=res
    save(resOld,file = "nonRegressionTesting.res")
    cat("-->RESULT : First Time\n")
    return(-1)
  } else {
    load("nonRegressionTesting.res")
    diff = sum((resOld$Q - res$Q)^2) + sum((resOld$G - res$G)^2)
    cat(paste("-->RESULT :", diff, "\n" ))
    return( diff )
  }
}


################################################################

nonRegressionTesting( "/home/cayek/Projects/TESS3/data/simulated/adMixture_K2_Nm1_n200_L2000_d1_k1.9_OnlyXFALSE",
                      "adMixture_K2_Nm1_n200_L2000_d1_k1.9_OnlyXFALSE.mat", 
                      "adMixture_K2_Nm1_n200_L2000_d1_k1.9_OnlyXFALSE.coord",
                      2,
                      1)



