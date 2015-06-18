Tess3wrapper.directory <- "/home/cayek/Projects/TESS3/src/Rwrapper/TESS3.R"
Athaliana.directory <- "/home/cayek/Projects/TESS3/data/simulated/Athaliana"
source( Tess3wrapper.dirrectory )
library(LEA)

setwd( Athaliana.dirrectory )
###########################################################################
# Run TESS3 on a data set simualted from an Arabidopsis Athalina data set #
###########################################################################

#read data
spatialData = read.coord("Athaliana.coord")
genotype = read.geno("Athaliana.geno")
n = nrow(spatialData)

project = TESS3( genotype = genotype, 
                 spatialData = spatialData, 
                 K = 3, 
                 ploidy = 1, 
                 rep = 5 )


#############################
# Genome scan for selection #
#############################

#### Fst with TESS3 
Fst = fst( project, K = 3 )$Fst
Fst[Fst < 0.0] = 0.0

#### Convert Fst into t score
squared.t.scores = Fst*(n-2)/(1-Fst)

#### recalibrated p-values
gif = 25
adj.p.values = pf( squared.t.scores/gif , df1 = 2, df2 = n-3, lower = FALSE )

hist(adj.p.values,prob=TRUE)

#### Benjamini Hochberg procedure
alpha = 1e-10
L = length(adj.p.values)
# return a list of candidates with an expected FDR of alpha.
w = which(sort(adj.p.values) < alpha * (1:L) / L)
candidates = order(adj.p.values)[w]
limite = max(adj.p.values[candidates])

#### Manhattan plot 
plot( 1:length(adj.p.values),-log10(adj.p.values) , 
      main = "Manhattan Plot" , 
      xlab = "indices", 
      ylab="- Log P-value", 
      pch=19, cex = .5) 
#add limite
abline( -log10(limite), 0, col = "green", lty = 6, lwd = 3 )
