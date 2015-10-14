TESS3
=====
TESS3 is a fast and efficient program for estimating spatial population structure based on geographically constrained non-negative matrix factorization and population genetics.

TESS3 can be used on Mac, Linux or Windows through the command-line interface or in R software environment thanks to the R wrapper function. 

# Installation

## R packaged software

You can install the R package directly from the github repository thanks to the package devtools. If you don't already have devtools R package you can install it from CRAN:

```R
install.packages("devtools")
```

Then, you can install the package:

```R
devtools::install_github("cayek/TESS3/tess3r")
```

## Command-line interface software

If you prefer working with command-line interface we also provide cmake file to compile the code. You need to download the master source directory [here](https://github.com/cayek/TESS3/archive/master.zip).

The first step is to generate compilation build environment to compile source code using cmake (can be install [here](<http://www.cmake.org/download/>)). 

* On Linux or Mac OS, in TESS3 directory use these bash commands to generate makefile: 

```bash
    mkdir build/
	cd build
	cmake -DCMAKE_BUILD_TYPE=release ../
```
	
* On windows, you can use cmake to generate visual studio project or MinGW Makefiles (GNU compilers and make can be install using [MinGW installer](<http://www.mingw.org/wiki/Getting_Started>))


Then, you can build the program.

* On Linux or Mac OS, in TESS3 directory: 

```bash
    cd build/
	make TESS3
```

# Program documentation

The Command-line program documentation is available [here](https://github.com/cayek/TESS3/blob/master/doc/documentation.pdf).

Find out more complete with the R package [here](todo).

# Organization

The repository is organized as follows:

* tess3r: code source of the program.

* external: external libraries.

* test: scripts to test the program (for developers only).

* tutorial: some examples of use of TESS3 program.

* doc: program documentation.

* data: simulated data sets provided for examples.
