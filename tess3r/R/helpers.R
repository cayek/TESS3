test_character <- function(name, param, default)
{
  if(missing(param)) {
    if(is.null(default)) {
      p = paste("'",name,"' argument is missing.", sep="");
      stop(p)
    } else
      return(default);
  } else {
    if(!is.character(param)) {
      p = paste("'",name,"' argument has to be of type character.",
                sep="");
      stop(p);
    }
  }
  return(param);
}

test_double <- function(name, param, default)
{
  if(missing(param)) {
    if(is.null(default)) {
      p = paste("'",name,"' argument is missing.", sep="");
      stop(p)
    } else
      return(default);
  } else {
    if(is.integer(param))
      param = as.double(param)

    if(!is.double(param)) {
      p = paste("'",name,"' argument has to be of type double.", sep="");
      stop(p);
    }
  }
  return(param);
}


test_extension <- function(name, extension)
{
  # obtain the extension of name
  ext = getExtension(basename(name))

  # if not the correct extension, stop
  if (ext != extension) {
    p = paste("'input_file' format and extension have to be \".",
              extension, "\" (not \".",ext,"\").", sep="")
    stop(p)
  }

  return(ext);
}

test_input_file <- function(name, extension)
{
  # list of possible extension
  l = c("geno", "lfmm", "vcf", "ancestrymap", "ped")

  # obtain the extension of name
  ext = getExtension(basename(name))

  # init input_file
  input_file = name;
  # check if the exstension is known
  if (!(ext %in% l)) {
    p = paste("The extension (.", ext,") is unknown (file \"",name,"\").\n",
              "Please, use one of the following format extension: .geno,",
              " .lfmm, .vcf, .ancestrymap, .ped.", sep="")
    stop(p);
    # if not the correct format, convert
  } else if (ext != extension) {
    input_file = setExtension(name, paste(".", extension, sep=""))
    print("*********************************************************");
    print(paste(" Conversion from the ", ext," format to the ", extension,
                " format", sep = ""));
    print("*********************************************************");

    if (extension == "lfmm") {
      if(ext == "geno") {
        input_file = geno2lfmm(name, force = FALSE)
      } else if (ext == "ancestrymap") {
        input_file = ancestrymap2lfmm(name, force = FALSE)
      } else if (ext == "vcf") {
        input_file = vcf2lfmm(name, force = FALSE)
      } else if (ext == "ped") {
        input_file = ped2lfmm(name, force = FALSE)
      }
    } else if (extension == "geno") {
      if(ext == "lfmm") {
        input_file = lfmm2geno(name, force = FALSE)
      } else if (ext == "ancestrymap") {
        input_file = ancestrymap2geno(name, force = FALSE)
      } else if (ext == "vcf") {
        input_file = vcf2geno(name, force = FALSE)
      } else if (ext == "ped") {
        input_file = ped2geno(name, force = FALSE)
      }
    }
  }

  return(input_file);
}

test_integer <- function(name, param, default)
{
  if(missing(param)) {
    if(is.null(default)) {
      p = paste("'",name,"' argument is missing.", sep="");
      stop(p)
    } else
      return(default);
  } else {
    if(is.double(param))
      param = as.integer(param)

    if(!is.integer(param)) {
      p = paste("'",name,"' argument has to be of type integer.", sep="");
      stop(p);
    }
  }
  return(param);
}

test_logical <- function(name, param, default)
{
  if(missing(param)) {
    if(is.null(default)) {
      p = paste("'",name,"' argument is missing.", sep="");
      stop(p)
    } else
      return(default);
  } else {
    if(!is.logical(param)) {
      p = paste("'",name,"' argument has to be of type logical.", sep="");
      stop(p);
    }
  }
  return(param);
}

projectTess3Load <- function(input.file, project)
{

  projectName = setExtension(paste(dirname(normalizePath(input.file)), "/",
                                   basename(input.file), sep=""), ".tess3Project")
  # load the project
  if (!project == "new" && file.exists(projectName)) {
    proj = load.tess3Project(projectName)
    # file input file not modified since the start of the project
    if (proj@creationTime >= file.info(input.file)$mtime
        || project == "force") {
      return(proj)
    } else {
      stop("The input file has been modified since the creation of the",
           " project.\nIf the input file is different, the results ",
           "concatenating all runs can be false.\nTo remove the current",
           " project and start a new one, add the option 'project = ",
           "new'.\nTo continue with the same project, add the option ",
           "'project = force'.")
    }
    # create a new project
  } else {
    if (file.exists(projectName)) {
      remove.tess3Project(projectName);
    }
    proj = new("tess3Project")
    proj@creationTime = Sys.time()
    # files
    proj@input.file = normalizePath(input.file)
    # directory
    proj@directory = setExtension(paste(dirname(normalizePath(input.file)),
                                        "/", basename(input.file), sep=""), ".tess3/")
    unlink(proj@directory, recursive = TRUE)
    dir.create(proj@directory, showWarnings = FALSE)
    # tess3Project.file
    proj@tess3Project.file = projectName
    # masked
    dir.create(paste(proj@directory, "masked/", sep=""),
               showWarnings = FALSE)
    save.tess3Project(proj)

    return(proj)
  }
}


getExtension <- function(file)
{
  l = strsplit(file, "\\.")[[1]]
  return(l[length(l)])
}

setExtension <- function(file, ext)
{
  out = dirname(file)
  l = strsplit(basename(file), "\\.")[[1]]
  if (length(l) >= 2) {
    out = paste(out, l[1], sep="/")
    if (length(l) >= 3) {
      for (i in 2:(length(l)-1))
        out = paste(out, l[i], sep=".")
    }
    out = paste(out, ext, sep="")
  } else if (length(l) == 1) {
    out = paste(out, l[1], sep="/")
    out = paste(out, ext, sep="")
  } else {
    out = NULL
  }

  return(out)
}

currentDir <- function(file)
{
  substr(file, nchar(getwd())+2, nchar(file))
}

