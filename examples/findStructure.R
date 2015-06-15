Tess3wrapper.dirrectory <- "/home/cayek/Projects/TESS3/src/Rwrapper/TESS3.R"
Athaliana.dirrectory <- "/home/cayek/Projects/TESS3/data/simulated/Athaliana"
source( Tess3wrapper.dirrectory )
library(LEA)

setwd( Athaliana.dirrectory )
>>>>>>> 358aaf4aa4fd30b32cd147a540dc8e02d77dca5c
###########################################################################
# Run TESS3 on a data set simualted from an Arabidopsis Athalina data set #
###########################################################################

#read data
spatialData = read.coord("Athaliana.coord")
n = nrow(spatialData)

project = TESS3( genotype = "Athaliana.geno", 
                 spatialData = "Athaliana.coord", 
                 K = 1:5, 
                 ploidy = 1, 
                 rep = 1, 
                 maskedProportion = 0.2)


###########################################
# Chose of K with cross-entropy criterion #
###########################################

plot( 1:5, crossEntropy( project ), main  = "Cross entropy",type="b", xlab = "K", ylab = "corss entropy" )

################################
# Plot result on map for K = 3 #
################################

# R script available on http://membres-timc.imag.fr/Olivier.Francois/pops.html
source("POPS_directory/R/POPSutilities.r")

asciiFile="/home/cayek/Projects/TESS3/data/simulated/Athaliana/down_etopo1.asc"
grid=createGridFromAsciiRaster(asciiFile)
# To display only altitudes above 0:
constraints=getConstraintsFromAsciiRaster(asciiFile,cell_value_min=0)

maps(matrix = qmatrix( project, K = 3 )$Q,
     coord = spatialData,
     grid=grid,constraints=constraints,method="max",main="ancestry coefficient with K = 3")
