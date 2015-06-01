##########################################################################
####################Wrapper script for TESS3 in R#########################
##########################################################################


#TESS3 executable location : absolute_path/TESS3
TESS3_cmd <- "/home/cayek/Projects/TESS3/build/TESS3"

##########################################################################

TESS3 <- function( genotype,  spatialData, K, ploidy=1, seed=0 ) {
  
  #test if we can found sNMF
  if (!(class(TESS3_cmd)=="character")) {
    stop("Can not read or execute TESS3. Please check in TESS3.R if TESS3_cmd=absolute_path/TESS3")
  }
  if (file.access( TESS3_cmd, mode = 1 )) {
    stop("Can not read or execute TESS3. Please check in TESS3.R if TESS3_cmd=absolute_path/TESS3")
    
  }
  
  #creating TESS3 working directory
  if ( !file.exists(file = "TESS3_workingDirectory") ) {
    dir.create("TESS3_workingDirectory")
  }
  TESS3_workingDirectory = paste( getwd(), "/TESS3_workingDirectory/", sep="" )
  
  cat("---------------------WRITTING DATA-----------------------\n")
  #write genotype and spatial data into file
  genotype_file  = paste( TESS3_workingDirectory, "/aux.geno", sep="" )
  write.table(file = genotype_file,
              t(genotype), row.names = F, col.names = F, quote = F, sep = "")
  spatialData_file  = paste( TESS3_workingDirectory, "/aux.coord", sep="" )
  write.table(file = spatialData_file,
              spatialData, row.names = F, col.names = F, quote = F, sep = " ")
  
  #launch TESS3 
  cat("---------------------RUNNING TESS3-----------------------\n")
  system( paste( TESS3_cmd, 
                 "-x", genotype_file,
                 "-r", spatialData_file,
                 "-K", K,
                 "-m", ploidy,
                 "-s", seed,
                 "-I",#to init Q with a sample of locus
                 sep= " " ) )
  
  
  #read result
  cat("---------------------READING RESULTS-----------------------\n")
  res = list()
  res$Q = as.matrix(read.table(file = paste( TESS3_workingDirectory,"/aux" ,".",K,".Q",sep="")))
  res$G = as.matrix(read.table(file = paste( TESS3_workingDirectory,"/aux" ,".",K,".Q",sep="")))
  
  return(res)
  
}