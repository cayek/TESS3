#' Estimates individual ancestry coefficients, ancestral allele frequencies and an ancestral allele frequency differentiation statistic.
#'
#' \code{\link{TESS3}} estimates admixture coefficients using a graph based Non-Negative
#' Matrix Factorization algorithms, and provide STRUCTURE-like outputs. \code{\link{TESS3}} also computes
#' an ancestral allele frequency differentiation statistic
#'
#' @param input.file A character string containing a the path to the input genotype file,
#' a genotypic matrix in the \code{\link[LEA]{geno}} format.
#' @param input.coord A character string containing a the path to the input coordinate file,
#' a coordinate matrix in the \code{\link{coord}} format.
#' @param K An integer vector corresponding to the number of ancestral populations for
#' which the TESS3 algorithm estimates have to be calculated.
#' @param project A character string among "continue", "new", and "force". If "continue",
#' the results are stored in the current project. If "new", the current
#' project is removed and a new one is created to store the result. If
#' "force", the results are stored in the current project even if the input
#' file has been modified since the creation of the project.
#' @param repetitions An integer corresponding with the number of repetitions for each value of \code{K}.
#' @param alpha A numeric value corresponding to the TESS3 regularization parameter.
#' The results depend on the value of this parameter.
#' @param tolerance A numeric value for the tolerance error.
#' @param entropy A boolean value. If true, the cross-entropy criterion is calculated.
#' @param percentage A numeric value between 0 and 1 containing the percentage of
#' masked genotypes when computing the cross-entropy
#' criterion. This option applies only if \code{entropy == TRUE}.
#' @param I The number of SNPs to initialize the algorithm. It starts the algorithm
#' with a run of snmf using a subset of nb.SNPs random SNPs. If this option
#' is set with nb.SNPs, the number of randomly chosen SNPs is the minimum
#' between 10000 and 10 \% of all SNPs. This option can considerably speeds
#' up snmf estimation for very large data sets.
#' @param iterations An integer for the maximum number of iterations in algorithm.
#' @param ploidy 1 if haploid, 2 if diploid, n if n-ploid.
#' @param seed A seed to initialize the random number generator. By default, the seed is randomly chosen.
#' @param CPU A number of CPUs to run the parallel version of the algorithm. By default, the number of CPUs is 1.
#' @param Q.input.file A character string containing a path to an initialization file for Q, the individual admixture coefficient matrix.
#'
#' @return \code{TESS3} returns an object of class \code{tess3Project}.
#' The following methods can be applied to the object of class {tess3Project}:
#' \item{plot}{
#'   Plot the minimal cross-entropy in function of K.
#' }
#' \item{show}{
#'   Display information about the analyses.
#' }
#' \item{summary}{
#'   Summarize the analyses.
#' }
#' \item{Q}{
#'   Return the admixture coefficient matrix for the chosen run with K
#'   ancestral populations.
#' }
#' \item{G}{
#'   Return the ancestral allele frequency matrix for the chosen run with K
#'   ancestral populations.
#' }
#' \item{FST}{
#'   Return ancestral allele frequency differentiation statistic matrix for the chosen run with K
#'   ancestral populations.
#' }
#' \item{cross.entropy}{
#'   Return the cross-entropy criterion for the chosen runs with K
#'   ancestral populations.
#' }
#' \item{load.snmfProject(file.tess3Project)}{
#'   Load the file containing an tess3Project objet and return the tess3Project
#'   object.
#' }
#' \item{remove.snmfProject(file.tess3Project)}{
#'   Erase a \code{tess3Project} object. Caution: All the files associated with
#'   the object will be removed.
#' }
#'
#' @examples
#' ### Example of analyses using snmf ###
#' # dataset simulated from the plant species Arabidopsis thaliana
#' # It contains 26943 SNPs for 170 individuals.
#' athaliana.genofile <- system.file("extdata/Athaliana","Athaliana.geno",package = "tess3r")
#' athaliana.coord <- system.file("extdata/Athaliana","Athaliana.coord",package = "tess3r")
#'
#' #################
#' # runs of TESS3 #
#' #################
#'
#' # main options, K: (the number of ancestral populations),
#' #        entropy: calculate the cross-entropy criterion,
#'
#' # Runs with K between 1 and 5 with cross-entropy and 2 repetitions.
#' project <- TESS3( athaliana.genofile, athaliana.coord, K=1:5, entropy = TRUE, repetitions = 2,
#'                   project = "new")
#'
#' # plot cross-entropy criterion of all runs of the project
#' plot(project, lwd = 5, col = "red", pch=1)
#'
#' # get the cross-entropy of each run for K = 4
#' ce = cross.entropy(project, K = 4)
#'
#' # select the run with the lowest cross-entropy
#' best = which.min(ce)
#'
#' # plot the best run for K = 3 (ancestry coefficients).
#' barplot(t(Q(project, K = 3, run = best)), col = c(2:4) )
#'
#'
#' @aliases Q G FST cross.entropy load.snmfProject remove.snmfProject
#'
#' @useDynLib tess3r wrapper_tess3
#' @export
TESS3 <- function(input.file,
                  input.coord,
                  K,
                  project = "continue",
                  repetitions = 1,
                  alpha = 0.001,
                  tolerance = 0.00001,
                  entropy = FALSE,
                  percentage = 0.05,
                  I = 0,
                  iterations = 200,
                  ploidy = 1,
                  seed = -1,
                  CPU = 1,
                  Q.input.file = "")
{

  ###########################
  # test arguments and init #
  ###########################

  # input file
  ## geno
  if( class( input.file ) == "matrix" ) {
    project = "new"
    if ( !file.exists(file = "tess3r_workingDirectory") ) {
      dir.create("tess3r_workingDirectory")
    }
    TESS3_workingDirectory = paste( getwd(), "/tess3r_workingDirectory/", sep="" )
    #cat("---------------------WRITTING GENOTYPE-----------------------\n")
    #write genotype and spatial data into file
    genotype_file  = paste( TESS3_workingDirectory, "/genotype.geno", sep="" )
    write.table(file = genotype_file,
                t(input.file), row.names = F, col.names = F, quote = F, sep = "")
    input.file = genotype_file
  }
  input.file = test_character("input.file", input.file, NULL)
  # check extension and convert if necessary
  input.file = test_input_file(input.file, "geno")
  input.file = normalizePath(input.file)
  ## coord
  if( class( input.coord ) == "matrix" ) {
    project = "new"
    if ( !file.exists(file = "tess3r_workingDirectory") ) {
      dir.create("tess3r_workingDirectory")
    }
    TESS3_workingDirectory = paste( getwd(), "/tess3r_workingDirectory/", sep="" )
    #cat("---------------------WRITTING GENOTYPE-----------------------\n")
    #write genotype and spatial data into file
    coordinates_file  = paste( TESS3_workingDirectory, "/coordinate.coord", sep="" )
    write.table(file = coordinates_file,
                input.coord, row.names = F, col.names = F, quote = F, sep = " ")
    input.coord = coordinates_file
  }
  input.coord = test_character("input.coord", input.coord, NULL)
  input.coord = normalizePath(input.coord)


  # K
  for (k in 1:length(K)) {
    K[k] = test_integer("K", K[k], NULL)
    if (K[k] <= 0)
      stop("'K' argument has to be positive.")
  }
  # alpha
  alpha = test_double("alpha", alpha, 10)
  if (alpha < 0)
    alpha = 0
  # tolerance
  tolerance = test_double("tolerance", tolerance, 0.0001)
  if (tolerance <= 0)
    tolerance = 0.0001
  # entropy
  entropy = test_logical("entropy", entropy, FALSE)
  # percentage
  percentage = test_double("percentage", percentage, 0)
  if (entropy && (percentage < 0 || percentage >= 1))
    percentage = 0.05
  else if (!entropy)
    percentage = 0
  # iterations
  iterations = test_integer("iterations", iterations, 200)
  if (iterations <= 0)
    iterations = 200;
  # ploidy
  ploidy = test_integer("ploidy", ploidy, 0)
  if (ploidy <= 0)
    ploidy = 0;
  # CPU
  CPU = test_integer("CPU", CPU, 1)
  if (CPU <= 0)
    CPU = 1;
  if(Sys.info()['sysname'] == "Windows")
    CPU = 1;
  # input Q
  Q.input.file = test_character("Q.input.file", Q.input.file, "")
  # test extension
  if (Q.input.file != "")
    test_extension(Q.input.file, "Q")
  # I
  I = test_integer("I", I, 0)
  if (I < 0)
    stop("'I' argument has to be of type positive.")
  # repetitions
  repetitions = test_integer("repetitions", repetitions, 1)
  # project
  if (missing(project))
    project = "continue"
  else if (!(project %in% c("continue", "new", "force")))
    stop("A project argument can be 'continue', 'new' or 'force'.");

  ####################
  # call the project #
  ####################

  proj = projectTess3Load(input.file, project)

  ################################
  # launch each run sequentially #
  ################################

  for (r in 1:repetitions) {
    # set the seed
    if (is.na(seed[r]))
      s = -1
    else
      s = seed[r]
    s = test_integer("seed", s, as.integer(runif(1)*.Machine$integer.max))
    if (s == -1)
      s = as.integer(runif(1)*.Machine$integer.max)
    set.seed(s) # init seed

    # create.dataset
    if (entropy) {
      masked.file = setExtension((paste(proj@directory, "masked/",
                                        basename(input.file), sep="")), "_I.geno")
      masked.file = create.dataset(input.file, masked.file, s,
                                   percentage);
    } else {
      masked.file = input.file
    }
    for (k in K) {
      print("*************************************");
      p = paste("* TESS3 K =",k," repetition",r,"     *");
      print(p);
      print("*************************************");

      re = length(which(proj@K == k)) + 1

      # create a directory for the run
      tmp  = basename(setExtension(basename(input.file), ""))
      dir = paste(proj@directory, "K", k, "/run", re, "/", sep="")
      dir.create(dir, showWarnings = FALSE, recursive = TRUE)

      # Q file
      Q.output.file = paste(dir, tmp, "_r", re ,".",k, ".Q", sep="")
      # G file
      G.output.file = paste(dir, tmp, "_r", re ,".",k, ".G", sep="")
      # Fst file
      FST.output.file = paste(dir, tmp, "_r", re ,".",k, ".Fst", sep="")
      # sum file
      sum.output.file = paste(dir, tmp, "_r", re ,".",k, ".sum", sep="")

      # TODO on peut aussi tester que le fichier n est pas déjà
      # existant
      tess3Class.file = paste(dir, tmp, "_r", re ,".",k, ".tess3Class",
                             sep="")

      all.ce = 0;
      masked.ce = 0;
      n = 0;
      L = 0;
      resC = .C("wrapper_tess3",
                as.character(masked.file),
                as.character(input.coord),
                as.integer(k),
                as.double(alpha),
                as.double(tolerance),
                as.double(0.0),
                as.integer(iterations),
                s = as.integer(s),
                as.integer(ploidy),
                as.integer(CPU),
                as.character(Q.input.file),
                as.character(Q.output.file),
                as.character(G.output.file),
                as.character(FST.output.file),
                as.character(sum.output.file),
                as.integer(I),
                all.ce = as.double(all.ce),
                masked.ce = as.double(masked.ce),
                n = as.integer(n),
                L = as.integer(L)
      );

      # calculate crossEntropy
      if (entropy) {
        ce = cross.entropy.estimation(input.file, k, masked.file,
                                      Q.output.file, G.output.file, ploidy)
        all.ce = ce$all.ce
        masked.ce = ce$masked.ce
      }

      # creation of the res file
      res = new("tess3Class")
      res@directory = dir

      # file tess3Class
      res@tess3Class.file  = tess3Class.file;
      res@K = as.integer(k);
      res@run = as.integer(re);
      res@CPU = as.integer(CPU);
      res@seed = resC$s;
      res@alpha = alpha;
      res@percentage = percentage;
      res@I = as.integer(I);
      res@iterations = as.integer(iterations);
      res@entropy = entropy;
      res@tolerance = tolerance;
      res@crossEntropy = masked.ce;
      res@ploidy = as.integer(ploidy);
      res@Q.input.file = Q.input.file;
      res@Q.output.file = normalizePath(Q.output.file);
      res@G.output.file = normalizePath(G.output.file);
      res@FST.output.file = normalizePath(FST.output.file);
      save.tess3Class(res, res@tess3Class.file)

      proj@n = resC$n;
      proj@L = resC$L;
      proj = addRun.tess3Project(proj, res);
      save.tess3Project(proj)
    }
  }

  return(proj);
}

#' tess3r : An R Package for Population Genetics Study
#'
#' This R package implements the TESS3 program and tools useful to plot program outputs.
#'
#' @docType package
#'
#' @name tess3r
#'
NULL



