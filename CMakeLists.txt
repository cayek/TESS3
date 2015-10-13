cmake_minimum_required (VERSION 2.8)

project(TESS3)

if (UNIX)
  message(status "Setting GCC flags")
  SET(CMAKE_C_FLAGS_DEBUG "-lm -lpthread -g -Wall -Wextra")
  SET(CMAKE_C_FLAGS_RELEASE "-lm -lpthread -g -O3 -Wall -Wextra")
  SET(CMAKE_C_COMPILER "gcc")
endif()


#set(CMAKE_RUNTIME_OUTPUT_DIRECTORY  ${PROJECT_SOURCE_DIR}/bin/${CMAKE_BUILD_TYPE})
#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib/${CMAKE_BUILD_TYPE})
#set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib/${CMAKE_BUILD_TYPE})

if(CMAKE_SIZEOF_VOID_P EQUAL 8) 
    set(arch_64 TRUE) 
	add_definitions(-D__x86_64__)
	message("64 bits detected")
else() 
    set(arch_64 FALSE) 
	add_definitions(-D__i386__)
	message("32 bit detected")
endif() 

set(SRC_DIRECTORY "tess3r/src/")

#include directoriy
include_directories("${SRC_DIRECTORY}")

#add lapack
file(GLOB lapack_SRC
    "${SRC_DIRECTORY}/external/lapack/*.h"
    "${SRC_DIRECTORY}/external/lapack/*.c"
)

add_library(lapack STATIC ${lapack_SRC})
SET_TARGET_PROPERTIES( lapack PROPERTIES LINKER_LANGUAGE C)


#add sNMF
file(GLOB sNMF_SRC
    "${SRC_DIRECTORY}/sNMF/*.h"
    "${SRC_DIRECTORY}/sNMF/*.c"
)

#include_directories("src/lapack/" )
#link_directories(lib/${CMAKE_BUILD_TYPE})
add_library(sNMFlib STATIC ${sNMF_SRC})
SET_TARGET_PROPERTIES( sNMFlib PROPERTIES LINKER_LANGUAGE C)

#add crossEntropy
file(GLOB crossEntropy_SRC
    "${SRC_DIRECTORY}/crossEntropy/*.h"
    "${SRC_DIRECTORY}/crossEntropy/*.c"
)

add_library(crossEntropylib STATIC ${crossEntropy_SRC})
SET_TARGET_PROPERTIES( crossEntropylib PROPERTIES LINKER_LANGUAGE C)

#add createDataSet
file(GLOB createDataSet_SRC
    "${SRC_DIRECTORY}/createDataSet/*.h"
    "${SRC_DIRECTORY}/createDataSet/*.c"
)

add_library(createDataSetlib STATIC ${createDataSet_SRC})
SET_TARGET_PROPERTIES( createDataSetlib PROPERTIES LINKER_LANGUAGE C)

#add bituint
file(GLOB bituint_SRC
    "${SRC_DIRECTORY}/bituint/*.h"
    "${SRC_DIRECTORY}/bituint/*.c"
)

add_library(bituintlib STATIC ${bituint_SRC})
SET_TARGET_PROPERTIES( bituintlib PROPERTIES LINKER_LANGUAGE C)


#add nnlsm
file(GLOB nnlsm_SRC
    "${SRC_DIRECTORY}/nnlsm/*.h"
    "${SRC_DIRECTORY}/nnlsm/*.c"
)

add_library(nnlsmlib STATIC ${nnlsm_SRC})
SET_TARGET_PROPERTIES( nnlsmlib PROPERTIES LINKER_LANGUAGE C)


#add io
file(GLOB io_SRC
    "${SRC_DIRECTORY}/io/*.h"
    "${SRC_DIRECTORY}/io/*.c"
)

add_library(iolib STATIC ${io_SRC})
SET_TARGET_PROPERTIES( iolib PROPERTIES LINKER_LANGUAGE C)


#add stats
file(GLOB stats_SRC
    "${SRC_DIRECTORY}/stats/*.h"
    "${SRC_DIRECTORY}/stats/*.c"
)

add_library(statslib STATIC ${stats_SRC})
SET_TARGET_PROPERTIES( statslib PROPERTIES LINKER_LANGUAGE C)


#add matrix
file(GLOB matrix_SRC
    "${SRC_DIRECTORY}/matrix/*.h"
    "${SRC_DIRECTORY}/matrix/*.c"
)

add_library(matrixlib STATIC ${matrix_SRC})
SET_TARGET_PROPERTIES( matrixlib PROPERTIES LINKER_LANGUAGE C)
target_link_libraries (matrixlib statslib lapack )

#add spatialRegularizationTools
file(GLOB spatialRegularizationTools_SRC
    "${SRC_DIRECTORY}/spatialRegularizationTools/*.h"
    "${SRC_DIRECTORY}/spatialRegularizationTools/*.cpp"
)

add_library(spatialRegularizationToolslib STATIC ${spatialRegularizationTools_SRC})
SET_TARGET_PROPERTIES( spatialRegularizationToolslib PROPERTIES LINKER_LANGUAGE CXX)

#add Fst
file(GLOB Fst_SRC
    "${SRC_DIRECTORY}/Fst/*.h"
    "${SRC_DIRECTORY}/Fst/*.cpp"
)

add_library(Fstlib STATIC ${Fst_SRC})
SET_TARGET_PROPERTIES( Fstlib PROPERTIES LINKER_LANGUAGE CXX)


#add sNMF main
add_executable(TESS3  "${SRC_DIRECTORY}/main/main_sNMF.c" )
SET_TARGET_PROPERTIES(TESS3 PROPERTIES LINKER_LANGUAGE C)
target_link_libraries (TESS3 sNMFlib lapack createDataSetlib crossEntropylib iolib nnlsmlib bituintlib statslib matrixlib spatialRegularizationToolslib Fstlib)
