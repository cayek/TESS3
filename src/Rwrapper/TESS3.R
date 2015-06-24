##########################################################################
####################Wrapper script for TESS3 in R#########################
##########################################################################


#TESS3 executable location : absolute_path/TESS3
TESS3.cmd <- "/home/cayek/Projects/TESS3/build/TESS3"

##########################################################################

TESS3 <- function( genotype,  coordinates, K, ploidy=1, seed=-1, rep = 1, maskedProportion = 0.0, alpha = 0.001 ) {
  
  #test if we can found sNMF
  if (!(class(TESS3.cmd)=="character")) {
    stop("Can not read or execute TESS3. Please check in TESS3.R if TESS3.cmd=absolute_path/TESS3")
  }
   if (file.access( TESS3.cmd, mode = 1 )) {
     stop("Can not read or execute TESS3. Please check in TESS3.R if TESS3.cmd=absolute_path/TESS3 and if TESS3 program was generated and can be executed")
     
   }
  
  res = vector("list",length=length(K))
  
  #creating TESS3 working directory
  if ( !file.exists(file = "TESS3_workingDirectory") ) {
    dir.create("TESS3_workingDirectory")
  }
  TESS3_workingDirectory = paste( getwd(), "/TESS3_workingDirectory/", sep="" )
  
  if( class( genotype ) == "matrix" ) {
    
    #cat("---------------------WRITTING GENOTYPE-----------------------\n")
    #write genotype and spatial data into file
    genotype_file  = paste( TESS3_workingDirectory, "/genotype.geno", sep="" )
    write.table(file = genotype_file,
                t(genotype), row.names = F, col.names = F, quote = F, sep = "")
    
  } else if( class( genotype ) == "character" ) {
    
    genotype_file = genotype
    attr(res,"genotype" ) = genotype_file
    
  }
  
  if( class( spatialData ) == "matrix" ) {
    
    #cat("---------------------WRITTING GENOTYPE-----------------------\n")
    #write genotype and spatial data into file
    spatialData_file  = paste( TESS3_workingDirectory, "/coordinate.coord", sep="" )
    write.table(file = spatialData_file,
                spatialData, row.names = F, col.names = F, quote = F, sep = " ")
    
  } else if( class( spatialData ) == "character" ) {
    
    spatialData_file  = spatialData
    attr(res,"spatialData" ) = spatialData_file
  }
  
  #optionnal arg
  optionalArg = ""
  if( seed > 0 ) {
    
    optionalArg = paste( optionalArg, "-s", seed )
    
  }
  if( maskedProportion > 0.0 ) {
    
    optionalArg = paste( optionalArg, "-c", maskedProportion )
    
  }
  
  
  attr(res,"K") = K
  attr(res,"alpha") = alpha
  attr(res,"rep" ) = rep
  attr(res,"proportion of masked data" ) = maskedProportion
  attr(res,"ploidy" ) = ploidy
  
  for( k in 1:length(K)) {
    
    res[[k]]$Q = vector("list",length=rep) 
    res[[k]]$G = vector("list",length=rep) 
    res[[k]]$Fst = vector("list",length=rep)
    res[[k]]$error = 1:rep
    res[[k]]$all.ce = 1:rep
    res[[k]]$masked.ce = 1:rep

    output_Q = paste( TESS3_workingDirectory,"/genotype" ,".",K[k],".Q",sep="")
    output_G = paste( TESS3_workingDirectory,"/genotype" ,".",K[k],".G",sep="")
    output_Fst = paste( TESS3_workingDirectory,"/genotype" ,".",K[k],".Fst",sep="")
    output_summary = paste( TESS3_workingDirectory,"/genotype" ,".",K[k],".sum",sep="")
    
    for( r in 1:rep) {
      
      #launch TESS3 
      cat("---------------------RUNNING TESS3-----------------------\n")
      system( paste( TESS3.cmd, 
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
  
  #create an object of type TESS3
  class(res) = "tess3"
  return(res)
  
}

summary.tess3 <- function( obj ) {
  K = attr(obj,"K")
  cat(paste("Number of ancestral populations from",K[1],'to',K[length(K)],"\n"))
  cat(paste("Number of repetition:",attr(obj,"rep"),"\n"))
  cat(paste("Regularization parameter:",attr(obj,"alpha"),"\n"))
  cat(paste("Proportion of masked data:",attr(obj,"proportion of masked data"),"\n"))
  cat(paste("Ploidy:",attr(obj,"ploidy"),"\n"))
  
  if( !is.null( attr(obj,"genotype") ) ) {
    
    cat(paste("Genotype file:",attr(obj,"genotype"),"\n"))
    
  }
  
  if( !is.null( attr(obj,"spatialData") ) ) {
    
    cat(paste("Coordinate file:",attr(obj,"spatialData"),"\n"))
    
  }
  
}

plot.tess3 <- function( obj ) {
  
  
  
}

print.tess3 <- function( obj ) {
  
  print.default( obj )
  
}


##########################################################################
##########################Result Getter###################################
##########################################################################

qmatrix <- function( project, K, run = "best" ) {
  
  if( class(project) != "tess3" ) {
    
    stop( "Project should be an object of class tess3" )
    
  }
  
  k = which(attr(project, "K") == K )
  
  if( length(k) == 0 ) {
    
    stop(paste("There is no run for K =",K,"!"))
    
  } else {
    k=k[1]
    if (class(run) == "numeric") {
      
      res = list( Q = project[[k]]$Q[[run]], K = K )
      class(res) = "qmatrix"
      return( res )
      
    } else if( run  == "best"  ) {
      
      best = which.min( project[[k]]$error )
      
      res = list( Q = project[[k]]$Q[[ best ]], K = K )
      class(res) = "qmatrix"
      return( res )
      
    }
  }
}

plot.qmatrix <- function(obj) {
  
  barplot( t( obj$Q ), col = 1:obj$K )
  
}


gmatrix <- function( project, K, run = "best" ) {
  
  if( class(project) != "tess3" ) {
    
    stop( "Project should be an object of class tess3" )
    
  }
  
  k = which(attr(project, "K") == K )
  
  if( length(k) == 0 ) {
    
    stop(paste("There is no run for K =",K,"!"))
    
  } else {
    k=k[1]
    if (class(run) == "numeric") {
      
      res = list( G = project[[k]]$G[[run]], K = K )
      class(res) = "gmatrix"
      return( res )
      
    } else if( run  == "best"  ) {
      
      best = which.min( project[[k]]$error )
      
      res = list( G = project[[k]]$G[[ best ]], K = K )
      class(res) = "gmatrix"
      return( res )
      
    }
    
  }
}

fst <- function( project, K, run = "best" ) {
  
  if( class(project) != "tess3" ) {
    
    stop( "Project should be an object of class tess3" )
    
  }
  
  k = which(attr(project, "K") == K )
  
  if( length(k) == 0 ) {
    
    stop(paste("There is no run for K =",K,"!"))
    
  } else {
    k=k[1]
    if (class(run) == "numeric") {
      
      res = list( Fst = project[[k]]$Fst[[run]], K = K )
      class(res) = "fstmatrix"
      return( res )
      
    } else if( run  == "best"  ) {
      
      best = which.min( project[[k]]$error )
      
      res = list( Fst = project[[k]]$Fst[[ best ]], K = K )
      class(res) = "fstmatrix"
      return( res )
      
    }
  }
}

cross.entropy <- function( project, FUNCTION = mean  ) {
  
  if( class(project) != "tess3" ) {
    
    stop( "Project should be an object of class tess3" )
    
  }
  
  res = c()
  
  for( k in 1:length(project) ) {
    
    res = c(res, FUNCTION( project[[k]]$masked.ce ) ) 
    
  }
  
  return(res)
  
}

residual.error <- function( project, FUNCTION = mean  ) {
  
  if( class(project) != "tess3" ) {
    
    stop( "Project should be an object of class tess3" )
    
  }
  
  res = c()
  
  for( k in 1:length(project) ) {
    
    res = c(res, FUNCTION( project[[k]]$error ) ) 
    
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

tess2tess3 = function( file = "data.tess" ){
  
  library(LEA)
  
  # read data for 2 diploid organisms and 10 multiallelic markers 
  # diploid individuals encoded using two rows of data
  # data in the "TESS" format
  # Missing data are coded as "-9" ("-1" works as well)
  
  
  dat = read.table(file)
  
  n = dim(dat)[1]
  coord = dat[seq(1,n,by = 2), 1:2]
  
  dat = dat[,-(1:2)]
  
  # Convert allelic data into absence/presence data at each locus
  # Results are stored in the "dat.binary" object 
  
  L = dim(dat)[2]
  dat.binary = NULL
  for (j in 1:L){
    allele = unique(dat[,j])
    for (i in allele[allele > 0]) dat.binary=cbind(dat.binary, dat[,j]==i)
    LL = dim(dat.binary)[2]
    ind = which(allele < 0)
    if (length(ind) != 0){dat.binary[ind, (LL - length(allele) + 2):LL] = -9}
  } 
  
  # Compute a genotype for each allele (0,1,2 or 9 for a missing value)
  # results are stored in the "genotype" object (2 rows, 26 columns)
  
  n = dim(dat.binary)[1]/2
  genotype = matrix(NA,nrow=n,ncol=dim(dat.binary)[2])
  for(i in 1:n){
    genotype[i,]= dat.binary[2*i-1,]+dat.binary[2*i,]
    genotype[i, (genotype[i,] < 0)] = 9
  }
  
  
  
  # Export genotypes in an external file in the "geno" format
  write.table(file="genotype.geno",t(genotype),row.names=F,col.names=F,quote=F, sep = "")
  
  # Export spatial coordinates in an external file in the "coord" format
  write.table(file="coordinates.coord",coord,row.names=F,col.names=F,quote=F)
  
}

