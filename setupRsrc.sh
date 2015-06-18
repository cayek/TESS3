#!/bin/sh

usage(){
	echo "Usage: $0 [-t | --tess3 TESS3_program] "
	exit 1
}

while [[ $# > 0 ]]
do
key="$1"

case $key in
    -t|--tess3)
    tess3="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

#tess3 project directory
dir=`pwd`

#tess3 cmd line 
if [ -z "$tess3" ]; then 
    tess3="./build/TESS3"
fi

#convert relative path into absolute path
f=`dirname $tess3`
tess3_absolute=`cd $f; pwd`"/"`basename $tess3`

#check if tess3 program exist
if [ ! -e "$tess3_absolute" ]; then 
    echo "Can not find TESS3 program : $tess3_absolute file do not exist !" 1>&2
    usage
fi

#check if tess3 program can be executed
if [ ! -x "$tess3" ]; then 
    echo "Can not execute TESS3 program : $tess3_absolute is not executable" 1>&2
    usage
fi

#find Rwrapper and example 
Rwrapper_path="$dir/src/Rwrapper/TESS3.R"
findSelection_path="$dir/examples/findSelection.R"
findStructure_path="$dir/examples/findStructure.R"
Athalina_path="$dir/data/simulated/Athaliana"
admixedPopDiploid_path="$dir/data/simulated/admixedPopDiploid"
testR_path="$dir/test/scriptR/Rtest.R"
if [ ! -e "$Athalina_path" ] || [ ! -e "$Rwrapper_path" ] || [ ! -e "$findSelection_path" ] || [ ! -e "$findStructure_path" ]; then 
    echo "Can not find find R sources !" 1>&2
    echo "Be sure that you run `basename $0` in the TESS3 project directory" 1>&2
fi

# findSelection
sed -i "s|^[ ]*Tess3wrapper.dirrectory[ ]*<-.*|Tess3wrapper.directory <- \"$Rwrapper_path\"|g" $findSelection_path
sed -i "s|^[ ]*Athaliana.dirrectory[ ]*<-.*|Athaliana.directory <- \"$Athalina_path\"|g" $findSelection_path

# findStructure
sed -i "s|^[ ]*Tess3wrapper.dirrectory[ ]*<-.*|Tess3wrapper.directory <- \"$Rwrapper_path\"|g" $findStructure_path
sed -i "s|^[ ]*Athaliana.dirrectory[ ]*<-.*|Athaliana.directory <- \"$Athalina_path\"|g" $findStructure_path

# Rwrapper
sed -i "s|^[ ]*TESS3.cmd[ ]*<-.*|TESS3.cmd <- \"$tess3_absolute\"|g" $Rwrapper_path

# Rtest
sed -i "s|^[ ]*Tess3wrapper.dirrectory[ ]*<-.*|Tess3wrapper.directory <- \"$Rwrapper_path\"|g" $testR_path
sed -i "s|^[ ]*Athaliana.dirrectory[ ]*<-.*|Athaliana.directory <- \"$Athalina_path\"|g" $testR_path
sed -i "s|^[ ]*admixedPopDiploid.dirrectory[ ]*<-.*|admixedPopDiploid.directory <- \"$admixedPopDiploid_path\"|g" $testR_path
sed -i "s|^[ ]*findSelection.dirrectory[ ]*<-.*|findSelection.directory <- \"$findSelection_path\"|g" $testR_path
sed -i "s|^[ ]*findStructure.dirrectory[ ]*<-.*|findStructure.directory <- \"$findStructure_path\"|g" $testR_path
