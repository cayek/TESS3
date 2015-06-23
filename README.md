TESS3
=====
TESS3 is a fast and efficient program for estimating spatial population structure based on geographically constrained non-negative matrix factorization and population genetics.

TESS3 can be used on Mac, Linux or Windows through the command-line interface or in R software environment thanks to the R wrapper function. 

Organization
------------
The repository is organized as follows:

* src: code source of the program.

* external: external libraries.

* test: scripts to test the program (for developers only).

* tutorial: some examples of use of TESS3 program.

* doc: program documentation.

* data: simulated data sets provided for examples.

Program documentation
---------------------

The program documentation is available [here](https://github.com/cayek/TESS3/blob/master/doc/documentation.pdf).

Installation
------------
You need to download the master source directory [here](https://github.com/cayek/TESS3/archive/master.zip).

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


Finally, if you want to use the R wrapper function and execute R script examples (see the section Tutorial of the [program documentation](https://github.com/cayek/TESS3/blob/master/doc/documentation.pdf)) you need to set the absolute path in src/Rwrapper/[TESS3.R](https://github.com/cayek/TESS3/blob/master/src/Rwrapper/TESS3.R) and [examples](https://github.com/cayek/TESS3/blob/master/examples). On Unix systems, you can run the following command in TESS3 directory:

```bash
./setupRsrc.sh -t TESS3_program
```

