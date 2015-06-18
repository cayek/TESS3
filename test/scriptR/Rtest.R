Tess3wrapper.directory <- "/home/cayek/Projects/TESS3/src/Rwrapper/TESS3.R"
Athaliana.directory <- "/home/cayek/Projects/TESS3/data/simulated/Athaliana"
admixedPopDiploid.directory <- "/home/cayek/Projects/TESS3/data/simulated/admixedPopDiploid"
findSelection.directory <- "/home/cayek/Projects/TESS3/tutorial/findSelection.R"
findStructure.directory <- "/home/cayek/Projects/TESS3/tutorial/findStructure.R"
cat("******************************************************\n")
cat("**************TESTS of TESS3 cmd line R***************\n")
cat("******************************************************\n")

source(Tess3wrapper.directory)

ok <- function(res) {	
  
  if(res) {
    
    stop( "scriptR error !!" )
      
  }
  
}


################################################################
####################BLACK BOX TESTING###########################
################################################################

nonRegressionTesting <- function( directory, genoDataFile, coordDataFile, K, ploidy, resName, maskedProportion = 0.0, alpha = 0.001, rep = 1 ) {
  
  cat(paste("----->nonRegressionTesting TEST :", directory, "\n"))
  
  setwd( directory )
  
  genotype = genoDataFile
  spatialData = as.matrix(read.table( file = coordDataFile ))
  tess3 = TESS3( genotype, spatialData, K = K, ploidy = ploidy, seed = 1, maskedProportion = maskedProportion, alpha = alpha, rep = rep )
  res = list( Q = qmatrix( tess3, K )$Q, 
              G = gmatrix( tess3, K )$G, 
              Fst = fst( tess3, K )$Fst,
              CrossEntropy = crossEntropy( tess3), 
              LeastSquared = leastSquared( tess3) )
  if(!file.exists(file = resName) ) {
    resOld=res
    save(resOld,file = resName)
    cat("-->RESULT : First Time\n")
    return(-1)
  } else {
    load(resName)
    diff = sum((resOld$Q - res$Q)^2) + 
      sum((resOld$G - res$G)^2) + 
      sum((resOld$Fst - res$Fst)^2) + 
      sum((resOld$CrossEntropy - res$CrossEntropy)^2) + 
                        sum((resOld$LeastSquared - res$LeastSquared)^2 ) 
    cat(paste("-->RESULT :", diff, "\n" ))
    return( diff )
  }
}


################################################################

ok( nonRegressionTesting( "/home/cayek/Projects/TESS3/data/simulated/admixedPopDiploid/",
                          "admixedPopDiploid.geno", 
                          "admixedPopDiploid.coord",
                          2,
                          2,
                          alpha = 0.1,
                          "6.res")
)



ok( nonRegressionTesting( Athaliana.directory,
                      "Athaliana.geno", 
                      "Athaliana.coord",
                      2,
                      1,
                      "1.res")
)

ok( nonRegressionTesting( Athaliana.directory,
                          "Athaliana.geno", 
                          "Athaliana.coord",
                          2,
                          1,
                          "2.res", 
                          maskedProportion = 0.1)
)

ok( nonRegressionTesting( Athaliana.directory,
                          "Athaliana.geno", 
                          "Athaliana.coord",
                          2,
                          1,
                          "3.res", 
                          alpha = 0.2)
)


ok( nonRegressionTesting( Athaliana.directory,
                          "Athaliana.geno", 
                          "Athaliana.coord",
                          2,
                          1,
                          "4.res", 
                          rep = 2)
)


ok( nonRegressionTesting( Athaliana.directory,
                          "Athaliana.geno", 
                          "Athaliana.coord",
                          5,
                          1,
                          "5.res")
)




source(findSelection.directory)
source(findStructure.directory)


