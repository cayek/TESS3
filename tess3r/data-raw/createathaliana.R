library(LEA)
# Athaliana data
geno = read.geno("../data/simulated/Athaliana/Athaliana.geno")
coord = as.matrix( read.table( "../data/simulated/Athaliana/Athaliana.coord" ))
athaliana = cbind(coord,geno)
devtools::use_data(athaliana)


