##########################################################################
####################Wrapper script for TESS3 in R#########################
##########################################################################


#TESS3 executable location : absolute_path/TESS3
TESS3_cmd <- "TESS3_directory/build/TESS3"

##########################################################################

TESS3 <- function( genotype,  spatialData, K, ploidy=1, seed=-1, rep = 1, maskedProportion = 0.0, alpha = 0.001 ) {
  
  #test if we can found sNMF
  if (!(class(TESS3_cmd)=="character")) {
    stop("Can not read or execute TESS3. Please check in TESS3.R if TESS3_cmd=absolute_path/TESS3")
  }
  if (file.access( TESS3_cmd, mode = 1 )) {
    stop("Can not read or execute TESS3. Please check in TESS3.R if TESS3_cmd=absolute_path/TESS3 and if TESS3 program was generated and can be executed")
    
  }
  
  #creating TESS3 working directory
  if ( !file.exists(file = "TESS3_workingDirectory") ) {
    dir.create("TESS3_workingDirectory")
  }
  TESS3_workingDirectory = paste( getwd(), "/TESS3_workingDirectory/", sep="" )
  
  if( class( genotype ) == "matrix" ) {
    
    #cat("---------------------WRITTING GENOTYPE-----------------------\n")
    #write genotype and spatial data into file
    genotype_file  = paste( TESS3_workingDirectory, "/aux.geno", sep="" )
    write.table(file = genotype_file,
                t(genotype), row.names = F, col.names = F, quote = F, sep = "")
    
  } else if( class( genotype ) == "character" ) {
    
    genotype_file = genotype
    
  }
  
  if( class( spatialData ) == "matrix" ) {
    
    #cat("---------------------WRITTING GENOTYPE-----------------------\n")
    #write genotype and spatial data into file
    spatialData_file  = paste( TESS3_workingDirectory, "/aux.coord", sep="" )
    write.table(file = spatialData_file,
                spatialData, row.names = F, col.names = F, quote = F, sep = " ")
    
  } else if( class( spatialData ) == "character" ) {
    
    spatialData_file  = spatialData
    
  }
  
  #optionnal arg
  optionalArg = ""
  if( seed > 0 ) {
    
    optionalArg = paste( optionalArg, "-s", seed )
    
  }
  if( maskedProportion > 0.0 ) {
    
    optionalArg = paste( optionalArg, "-c", maskedProportion )
    
  }
  
  res = vector("list",length=length(K))
  attr(res,"K") = K
  
  for( k in 1:length(K)) {
    
    res[[k]]$Q = vector("list",length=rep) 
    res[[k]]$G = vector("list",length=rep) 
    res[[k]]$Fst = vector("list",length=rep)
    res[[k]]$error = 1:rep
    res[[k]]$all.ce = 1:rep
    res[[k]]$masked.ce = 1:rep

    output_Q = paste( TESS3_workingDirectory,"/aux" ,".",K[k],".Q",sep="")
    output_G = paste( TESS3_workingDirectory,"/aux" ,".",K[k],".G",sep="")
    output_Fst = paste( TESS3_workingDirectory,"/aux" ,".",K[k],".Fst",sep="")
    output_summary = paste( TESS3_workingDirectory,"/aux" ,".",K[k],".sum",sep="")
    
    for( r in 1:rep) {
      
      #launch TESS3 
      cat("---------------------RUNNING TESS3-----------------------\n")
      system( paste( TESS3_cmd, 
                     "-x", genotype_file,
                     "-r", spatialData_file,
                     "-K", K[k],
                     "-m", ploidy,
                     "-I",#to init Q with a sample of locus
                     "-q",output_Q,
                     "-g",output_G,
                     "-f",output_Fst,
                     "-y",output_summary,
                     "-a", alpha,
                     optionalArg,
                     sep= " " ) )
      
      
      #read result
      cat("---------------------READING RESULTS-----------------------\n")
      res[[k]]$Q[[r]] = as.matrix(read.table(file = output_Q))
      res[[k]]$G[[r]] = as.matrix(read.table(file = output_G))
      res[[k]]$Fst[[r]] = as.matrix(read.table(file = output_Fst))
      aux = readLines(output_summary)
      res[[k]]$error[r] = as.numeric( sub( ".*: ","", aux[1] ) )
      res[[k]]$all.ce[r] = as.numeric( sub( ".*: ","", aux[2] ) )
      res[[k]]$masked.ce[r] = as.numeric( sub( ".*: ","", aux[3] ) )
    }
    
    
  }
  
  
  return(res)
  
}


##########################################################################
##########################Result Getter###################################
##########################################################################

getQ <- function( project, K, run = "best" ) {
  
  k = which(attr(project, "K") == K )
  
  if( length(k) == 0 ) {
    
    stop(paste("There is no run for K =",K,"!"))
    
  } else {
    k=k[1]
    if (class(run) == "numeric") {
      
      return( project[[k]]$Q[[run]] )
      
    } else if( run  == "best"  ) {
      
      best = which.min( project[[k]]$error )
      
      return( project[[k]]$Q[[ best ]] )
      
    }
  }
}

getG <- function( project, K, run = "best" ) {
  
  k = which(attr(project, "K") == K )
  
  if( length(k) == 0 ) {
    
    stop(paste("There is no run for K =",K,"!"))
    
  } else {
    k=k[1]
    if (class(run) == "numeric") {
      
      return( project[[k]]$G[[run]] )
      
    } else if( run  == "best"  ) {
      
      best = which.min( project[[k]]$error )
      
      return( project[[k]]$G[[ best ]] )
      
    }
  }
}

getFst <- function( project, K, run = "best" ) {
  
  k = which(attr(project, "K") == K )
  
  if( length(k) == 0 ) {
    
    stop(paste("There is no run for K =",K,"!"))
    
  } else {
    k=k[1]
    if (class(run) == "numeric") {
      
      return( project[[k]]$Fst[[run]] )
      
    } else if( run  == "best"  ) {
      
      best = which.min( project[[k]]$error )
      
      return( project[[k]]$Fst[[ best ]] )
      
    }
  }
}

getCrossEntropy <- function( project, func = mean  ) {
  
  res = c()
  
  for( k in 1:length(project) ) {
    
    res = c(res, func( project[[k]]$masked.ce ) ) 
    
  }
  
  return(res)
  
}

getLeastSquared <- function( project, func = mean  ) {
  
  res = c()
  
  for( k in 1:length(project) ) {
    
    res = c(res, func( project[[k]]$error ) ) 
    
  }
  
  return(res)
  
}

##########################################################################
################################Reader####################################
##########################################################################

read.coord <- function( file ) {
  
  if (file.exists( file = file )) {
    
    return(as.matrix(read.table( file = file )))
    
  } else {
    
    stop(paste("Can not find the file:", file))
  }
  
}

read.tess <- function( file ) {
  
  
  if (file.exists( file = file )) {
    
    return(as.matrix(read.table( file = file )))
    
  } else {
    
    stop(paste("Can not find the file:", file))
  }
  
  
}

