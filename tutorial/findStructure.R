Tess3wrapper.directory <- "/home/cayek/Projects/TESS3/src/Rwrapper/TESS3.R"
Athaliana.directory <- "/home/cayek/Projects/TESS3/data/simulated/Athaliana"
source( Tess3wrapper.directory )

setwd( Athaliana.directory )
###########################################################################
# Run TESS3 on a data set simualted from an Arabidopsis Athalina data set #
###########################################################################

#read data
spatialData = read.coord("Athaliana.coord")
n = nrow(spatialData)

project = TESS3( genotype = "Athaliana.geno", 
                 coordinates = "Athaliana.coord", 
                 K = 1:5, 
                 ploidy = 1, 
                 rep = 1, 
                 maskedProportion = 0.2)


###########################################
# Chose of K with cross-entropy criterion #
###########################################

plot( 1:5, cross.entropy( project ), main  = "Cross Entropy",type="b", xlab = "K", ylab = "cross entropy" )

################################
# Plot result on map for K = 3 #
################################

# pops R script 
source("../../../src/popsRScripts/POPSutilities.r") # WARNING : this script may require to be sourced 2 times !

asciiFile="/lowResEurope.asc"
grid=createGridFromAsciiRaster(asciiFile)
# To display only altitudes above 0:
constraints=getConstraintsFromAsciiRaster(asciiFile,cell_value_min=0)

maps(matrix = qmatrix( project, K = 3 )$Q,
     coord = spatialData,
     grid=grid,constraints=constraints,method="max",main="ancestry coefficient with K = 3")
