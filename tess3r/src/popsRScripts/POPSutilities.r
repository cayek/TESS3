### List of available functions: ###

#correlation = function(matrix1,matrix2,plot=TRUE,colors=defaultPalette)
#correlationFromPops = function(file1,file2,nind,nskip1=2,nskip2=2,plot=TRUE,colors=defaultPalette)
#barplotCoeff = function(matrix,colors=defaultPalette,...)
#barplotFromPops = function(file1,nind,nskip1=2,colors=defaultPalette,...)

loadPkg = function(pkgName,extraComment="") 
{
  print(paste("Loading",pkgName))
  if (!require(pkgName,character.only=T)){
    print(paste("Warning: Projections on maps require package",pkgName,"Trying to install",pkgName))
    print(extraComment)
    install.packages(pkgName)
    require(pkgName)
  }
}

# Load required packages, install them if absent
loadPkg(pkgName="fields")
loadPkg(pkgName="RColorBrewer",
      extraComment="Package RColorBrewer is optional if you choose your own palettes for color gradients (option colorGradientsList in MAPS Utilities functions)"
      )

### Global variables ###

defaultPalette = c(
"#ff3333" ,"#33ff33" ,"#6666ff" ,"#ffff00",
"#ff66ff" ,"#99ffff" ,"#ffcc33" ,"#cccccc",
"#cc9999" ,"#339966" ,"#999900" ,"#cc3300",
"#669999" ,"#993333" ,"#006600" ,"#990099",
"#ff9966" ,"#99ff99" ,"#9999ff" ,"#cc6600",
"#33cc33" ,"#cc99ff" ,"#ff6666" ,"#99cc66",
"#009999" ,"#cc3333" ,"#9933ff" ,"#ff0000",
"#0000ff" ,"#00ff00" ,"#ffcc99" ,"#999999")

# plot(1:length(defaultPalette),rep(1,length(defaultPalette)),col=defaultPalette,pch=19,cex=4)

lColorGradients = list( 
	c("gray95",brewer.pal(9,"Reds")),
	c("gray95",brewer.pal(9,"Greens")),
	c("gray95",brewer.pal(9,"Blues")),
	c("gray95",brewer.pal(9,"YlOrBr")),
	c("gray95",brewer.pal(9,"RdPu")),
	c("gray95",brewer.pal(9,"Greys"))
)
# Use display.brewer.all() to display color gradients provided by RColorBrewer


helpPops = function()

{
options(warning.length=3000)
warning(paste("Available functions:",
"\n\n",
"HELP:",
"\n","  * helpPops()",
"\n\n",
"\n","SHOW EXAMPLE:",
"\n","  * Open the R script scriptExample.r",
"\n\n",
"\n","CORRELATION UTILITIES:",
"\n Compute correlation between matrix of membership/admixture coefficients (from matrix or from POPS outputs)",
"\n","  * correlation(matrix1,matrix2,plot=TRUE,colors=defaultPalette)",
"\n","  * correlationFromPops(file1,file2,nind,nskip1=2,nskip2=2,plot=TRUE,colors=defaultPalette)",
"\n\n",
"\n","BARPLOT UTILITIES:",
"\n Display barplot of membership/admixture coefficients (from matrix or from POPS output)",
"\n","* barplotCoeff(matrix,colors=defaultPalette,...)",
"\n","* barplotFromPops(file1,nind,nskip1=2,colors=defaultPalette,...)",
"\n\n",
"\n","MAPS UTILITIES:",
"\n Display maps of membership/admixture coefficients (from matrix or from POPS output)",
"\n","  * maps(matrix,coord,grid,constraints=NULL,method=\"treshold\",colorGradientsList=lColorGradients,onemap=T,onepage=T,...)",
"\n","  * mapsFromPops(file,nind,nskip=2,coord,grid,constraints=NULL,method=\"treshold\",colorGradientsList=lColorGradients,onemap=T,onepage=T,...)",
"\n Create grid on which coefficients will be displayed",
"\n","  * createGrid(min_long,max_long,min_lat,max_lat,npixels_long,npixels_lat)",
"\n","  * createGridFromAsciiRaster(file)",
"\n","  * getConstraintsFromAsciiRaster(file,cell_value_min=NULL,cell_value_max=NULL)",
"\n Legend for maps",
"\n","  * displayLegend(K=NULL,colorGradientsList=lColorGradients)",
"\n\n"
))
}



### Functions definitions ###


### CORRELATION ###

correlation = function(matrix1,matrix2,plot=TRUE,colors=defaultPalette)

# Calculate correlation between 2 matrix of membership/admixture coefficients
# Clusters should be stored in the same order 
# ex. green cluster corresponds to the 2nd column in both matrix

{
	matrix1=as.matrix(matrix1)
	matrix2=as.matrix(matrix2)
	if ( (nrow(matrix1)!=nrow(matrix2)) | (ncol(matrix1)!=ncol(matrix2)) )
	{
		stop("matrix1 and matrix2 should have the same dimensions")
	}
	cor=cor(c(matrix1),c(matrix2))
	if (plot)
	{
		  op <- par(mfrow = c(2, 1), oma=c(0,0,3,0))
	    plotFig = try(
		  barplot(t(matrix1),col=defaultPalette)
      )
   
    if (class(plotFig)!="try-error") {
      title(paste("Correlation between these 2 matrix:",cor))
      barplot(t(matrix2),col=defaultPalette)
    }else {
      warning("The figure is too large: \n
        * solution 1: we are trying to plot the figure over two windows instead, \n
        * solution 2: use x11() or dev.new() and enlarge manually the R plotting area before executing the function, \n
        * solution 3: if you need the correlation value only, use the option plot=FALSE")
      par(mfrow = c(1, 1))
      barplot(t(matrix1),col=defaultPalette,main=paste("Matrix 1, correlation between the 2 matrix:",cor))
		  cat ("Press [enter] to continue and plot matrix 2")
		  line <- readline()
		  barplot(t(matrix2),col=defaultPalette,main=paste("Matrix 2, correlation between the 2 matrix:",cor))
    } 
    
    
	}
	return( cor )

}


correlationFromPops = function(file1,file2,nind,nskip1=2,nskip2=2,plot=TRUE,colors=defaultPalette)

# Load matrix of membership/admixture coefficients from POPS' output files
# Calculate correlation between the 2 extracted matrix
# Clusters should be stored in the same order 
# ex. green cluster corresponds to the 2nd column in both matrix

{
	matrix1=read.table(file1,skip=nskip1,nrows=nind)
	matrix1=matrix1[,-c(1,ncol(matrix1))]
	matrix2=read.table(file2,skip=nskip2,nrows=nind)
	matrix2=matrix2[,-c(1,ncol(matrix2))]
	K=ncol(matrix1)
	if (ncol(matrix2)!=K) {
		stop(paste("different number of clusters detected in",file1,"and",file2))
	}
	print(paste(K,"clusters detected"))
	return(correlation(matrix1,matrix2,plot=plot,colors=colors))

}
 

### BARPLOT ###

barplotCoeff = function(matrix,colors=defaultPalette,...)

## Plot membership/admixture in a bar chart, from a matrix or a POPS' output file

{
	barplot(t(as.matrix(matrix)),col=colors,...)
}

barplotFromPops = function(file1,nind,nskip1=2,colors=defaultPalette,...)
{
	matrix1=read.table(file1,skip=nskip1,nrows=nind)
	matrix1=matrix1[,-c(1,ncol(matrix1))]
	barplotCoeff(matrix1,colors=colors,...)
}


### MAPS ###

# function called by function maps, do NOT call it directly
mapsMethodMax = function(matrix,coord,grid,constraints,colorGradientsList,...)

{
	K=ncol(matrix)
	if (length(colorGradientsList)<K) 
	{
		stop(paste(K,"clusters detected but only",length(colorGradientsList),"color gradient(s) defined.", 
				"You should complete colorGradientsList to have as many gradients as clusters."))
	}

	listOutClusters=NULL
	matrixOfVectors =NULL
	for (k in 1:K)
	{
		clust=NULL
		clust= Krig(coord, matrix[,k], theta = 10)  
		look<- predict(clust,grid) # evaluate on a grid of points
		out<- as.surface( grid, look)
		listOutClusters[[k]] = out[[8]]	
		matrixOfVectors = cbind(matrixOfVectors,c(out[[8]]))	
	}
	long = out[[1]]
	lat = out[[2]]

	whichmax = matrix(apply(matrixOfVectors ,MARGIN=1,FUN=which.max),nrow=length(long))

	for (k in 1:K)
	{
		ncolors=length(colorGradientsList[[k]])
		if (class(constraints)!= "NULL") { listOutClusters[[k]][ !constraints ] = NA }
		listOutClusters[[k]][ whichmax != k ] = NA
		image(long,lat,listOutClusters[[k]],add=(k>1),col=colorGradientsList[[k]][(ncolors-9):ncolors],breaks=c(-200,.1,seq(.2,.9,.1),+200),...)
	}
	points(coord,pch=19)
}


maps = function(matrix,coord,grid,constraints=NULL,method="treshold",colorGradientsList=lColorGradients,onemap=T,onepage=T,...)

# project membership/admixture coefficients on a grid using Krig
# gradients in coefficients are represented by gradients in colors 
# if onemap=T & method="treshold" only coefficients > 0.5 are plotted
# if onemap=T & method="max" at each point the cluster for which the coefficient is maximal is plotted (even if the value is less than 0.5) 
# if onemap=F all values are plotted (since there is one cluster represented on each map, there is no overlap problem)

{

	require(fields)
	if ( (method != "treshold") & (method != "max")) {stop(paste("Unknown method",method))}
	if (class(constraints)!= "NULL") {
	   if ( nrow(grid) != nrow(constraints)*ncol(constraints) ) {
	      stop(paste("Argument grid assumes", nrow(grid), "pixels, but argument constaints assumes", nrow(constraints)*ncol(constraints),"pixels"))
	   }
	}

	if (onemap & method=="max") {
		mapsMethodMax(matrix=matrix,coord=coord,grid=grid,constraints=constraints,colorGradientsList=colorGradientsList,...)

	} else {
	K=ncol(matrix)
	if (length(colorGradientsList)<K) 
	{
		stop(paste(K,"clusters detected but only",length(colorGradientsList),"color gradient(s) defined.", 
				"You should complete colorGradientsList to have as many gradients as clusters."))
	}

	if (!onemap & onepage) {KK = as.integer(K/2); par(mfrow = c(2,KK+1)) }

	for (k in 1:K)
	{
		clust=NULL
		clust= Krig(coord, matrix[,k], theta = 10)  
		look<- predict(clust,grid) # evaluate on a grid of points
		out<- as.surface( grid, look)

		if (class(constraints)!= "NULL") { out[[8]][ !constraints ] = NA }

		ncolors=length(colorGradientsList[[k]])
		if (onemap) 
		{
			out[[8]][ out[[8]] < .5 ] = NA
			image(out,add=(k>1),col=colorGradientsList[[k]][(ncolors-4):ncolors],breaks=c(seq(.5,.9,.1),+200),...)
		} else {
			image(out,col=colorGradientsList[[k]][(ncolors-9):ncolors],breaks=c(-200,.1,seq(.2,.9,.1),+200),...)
			points(coord,pch=19)
		}
	}

	if (onemap) { points(coord,pch=19) }
	}

}


mapsFromPops = function(file,nind,nskip=2,...)
# load the file in a matrix and call maps(matrix,...)
{

	matrix=read.table(file,skip=nskip,nrows=nind)
	matrix=matrix[,-c(1,ncol(matrix))]
	maps(matrix,...)

}




displayLegend=function(K=NULL,colorGradientsList=lColorGradients){
	if (class(K)=="NULL")  { K=length(colorGradientsList) }
	KK = as.integer(K/2); par(mfrow = c(2,KK+1)) 
	for (k in 1:K) {
		ncolors=length(colorGradientsList[[k]])
		barplot(matrix(rep(1/10,10)),col=colorGradientsList[[k]][(ncolors-9):ncolors],main=paste("Cluster",k))
	}
}

createGrid = function(min_long,max_long,min_lat,max_lat,npixels_long,npixels_lat)

# return a grid on which clusters could be project using 'map' function

{
	long.pix=seq(from=min_long,to=max_long, length=npixels_long)
	lat.pix=seq(from=min_lat,to=max_lat, length=npixels_lat)
	grid=make.surface.grid( list( long.pix,lat.pix))
	return(grid)
}


createGridFromAsciiRaster = function(file)

# return a grid to use to project clusters on a map
# the grid is computed from an ascii raster file

{
	info=read.table(file,nrows=6)
	grid.info=info[,2]
	names(grid.info)=info[,1]
	lat.pix=seq(from=grid.info["YLLCENTER"],by=grid.info["CELLSIZE"],length=grid.info["NROWS"])
	long.pix=seq(from=grid.info["XLLCENTER"],by=grid.info["CELLSIZE"],length=grid.info["NCOLS"])
	grid=make.surface.grid( list( long.pix,lat.pix))

	return(grid)
}

getConstraintsFromAsciiRaster = function(file,cell_value_min=NULL,cell_value_max=NULL)

# return a matrix with boolean cells
# cell is set to TRUE if user wants to project on this map's cell
# cell is set to FALSE otherwise
# if needed user is invited to add/remove constraints by modifying the function

{
	map=read.table(file,skip=6)
	map=t(map)[,nrow(map):1]
	
	# 3 suggested constraints that you can remove if needed:

	map_constraints=!is.na(map) 	
	
	if (!is.null(cell_value_min)) {
		map_constraints[map<cell_value_min]=FALSE
	}
	
	if (!is.null(cell_value_max)) {
		map_constraints[map>cell_value_max]=FALSE
	}

	# you can add constraints here, example:
	# map_constraints["condition where you do not want to project clusters"]=FALSE	

	return(map_constraints)
}

helpPops()


