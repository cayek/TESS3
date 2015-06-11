TESS3
=====
TESS3 is a fast and efficient program for estimating spatial population structure based on geographically constrained non-negative matrix factorization and population genetics.

TESS3 can be used on Mac, Linux or Windows trough the command-line interface or in R software environment thanks to the R wrapper function. 

Organization
------------
The repository is organized as follows:

* src: code source of the program.

* external: external libraries.

* test: scripts to test the program (for developers only).

* examples: some examples of use of TESS3 program.

* doc: program documentation.

* data: simulated data sets provided for examples.

Program documentation
---------------------

The program documentation is available `here<>`_

Installation
------------

The first step is to generate compilation build environment to compile source code using `cmake<http://www.cmake.org/download/>`_. 

* On Linux or Mac OS, in TESS3 directory use these bash commands to generate makefile: 

```bash
    mkdir build/
	cmake -DCMAKE_BUILD_TYPE=release ../
```
	
* On windows, ...
```
```

Then, you can build the program.

* On Linux or Mac OS, in TESS3 directory: 

```bash
    cd build/
	make TESS3
```
	
Finally, if you want to use the R wrapper function and execute R script examples (see `program documentation<>`_) you need to set the absolute path of TESS3 command-line program in `src/Rwrapper/TESS3.R<>`_:

```
TESS3_cmd <- "TESS3_directory/build/TESS3"
```


