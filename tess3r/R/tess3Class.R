# create cl TESS3
setClass("tess3Class",
         slots = c(directory="character",
                   tess3Class.file ="character",
                   K="integer", run = "integer",
                   CPU = "integer", seed="numeric", alpha = "numeric",
                   percentage = "numeric",
                   I = "integer", iterations = "integer",
                   entropy = "logical", tolerance = "numeric",
                   crossEntropy = "numeric", ploidy = "integer",
                   Q.input.file="character", Q.output.file = "character",
                   G.output.file="character",FST.output.file="character")
)

# listMethods

#listMethods_tess3Class <- function()
#{
#c(    "Qvalues",
#    "Gvalues"
#);
#}

# listSlots

#listSlots_tess3Class <- function()
#{
#c(    "directory", "K", "CPU", "seed", "alpha", "missing.data",
#    "tess3Class.file", "percentage ", "I", "iterations",
#    "entropy", "error", "crossEntropy", "ploidy", "Q.input.file",
#   "Q.output.file",
#    "G.output.file")
#}

# .DollarNames.tess3Class <- function(x, pattern) c(listSlots_tess3Class(),
# listMethods_tess3Class())

# $

#setMethod("$", "tess3Class",
#           function(x, name) {
#             if (!(name %in% listMethods_tess3Class() ||
#                name %in% listSlots_tess3Class())) {
#               stop("no $ method for object without attributes")
#         } else if (name %in% listMethods_tess3Class()) {
#        do.call(name, list(x));
#         } else {
#        slot(x, name)
#         }
#           }
#)

# Qvalues

setGeneric("Qvalues", function(object) matrix);
setMethod("Qvalues", "tess3Class",
          function(object) {
            R = as.matrix(read.table(object@Q.output.file));
          }
)

# Gvalues

setGeneric("Gvalues", function(object) matrix);
setMethod("Gvalues", "tess3Class",
          function(object) {
            R = as.matrix(read.table(object@G.output.file));
          }
)

# FSTvalues

setGeneric("FSTvalues", function(object) matrix);
setMethod("FSTvalues", "tess3Class",
          function(object) {
            R = as.matrix(read.table(object@FST.output.file));
          }
)

setGeneric("getCrossEntropy", function(object="tess3Class") vector);
setMethod("getCrossEntropy", "tess3Class",
          function(object) {
            if (object@entropy)
              object@crossEntropy
            else
              NULL
          }
)
# plot

# display lambda for a value of d, and a Manhattan plot for a value of K.
#setMethod("plot", "tess3Class",
#          function(x, y, ...){
#        # todo colors
#        barplot(t(x$Qvalues), main="Admixture coefficient plot", ...)
#          }
#)

# show

setMethod("show", "tess3Class",
          function(object) {
            cat("tess3 class\n\n")
            cat("file directory:                  ", object@directory, "\n")
            cat("Q output file:                   ",
                basename(object@Q.output.file), "\n")
            cat("G output file:                   ",
                basename(object@G.output.file), "\n")
            cat("FST output file:                   ",
                basename(object@FST.output.file), "\n")
            cat("tess3Class file:                  ",
                basename(object@tess3Class.file), "\n")
            cat("number of ancestral populations: ", object@K, "\n")
            cat("run number:                      ", object@run, "\n")
            cat("regularization parameter:        ", object@alpha, "\n")
            cat("number of CPUs:                  ", object@CPU, "\n")
            cat("seed:                            ", object@seed, "\n")
            cat("maximal number of iterations:    ", object@iterations, "\n")
            cat("tolerance error:                 ", object@tolerance, "\n")
            cat("Q input file:                    ", object@Q.input.file, "\n")
            if (object@entropy)
              cat("cross-Entropy:                   ", object@crossEntropy,"\n")
            else
              cat("cross-Entropy:                   ", object@entropy,"\n")
          }
)

# summary

#setGeneric("summary", function(object) NULL)
#setMethod("summary", "tess3Class",
#    function(object) {
#        show(object)
#    }
#)

# load

setGeneric("load.tess3Class", function(file="character") attributes("tess3Class"))
setMethod("load.tess3Class", "character",
          function(file) {
            return(dget(file));
          }
)

# save

setGeneric("save.tess3Class", function(x="tess3Class", file="character")NULL)
setMethod("save.tess3Class", signature(x="tess3Class", file="character"),
          function(x, file) {
            dput(x, file)
          }
)

# remove

setGeneric("remove.tess3Class", function(file="character")NULL)
setMethod("remove.tess3Class", signature(file="character"),
          function(file) {
            cl = load.tess3Class(file)
            file.remove(cl@G.output.file)
            file.remove(cl@Q.output.file)
            file.remove(file)
          }
)
