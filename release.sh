#!/bin/bash
# TESS3 directory on my linux computer
cd /home/cayek/Projects/TESS3
ROUGE="\\033[1;31m"
VERT="\\033[1;32m"
dir_TESS3=`pwd`

function test {
    eval "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo -e "$ROUGE" "error with $1" >&2
	exit 1
    fi
    return $status
}


###############################
# push all changes to develop #
###############################
echo "*** Push changes :"

git checkout develop
# check if there are not commited file
status=`git status 2>&1 | tee`
dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`

if [ "${dirty}" == "0" ] || [ "${newfile}" == "0" ] || [ "${renamed}" == "0" ] || [ "${deleted}" == "0" ]; then
echo -e "$ROUGE" "commit in develop branch before release"
exit 1
fi

#git push
git push

echo -e "$VERT" "OK"
#################
# try to deploy #
#################
echo "*** Deployment testing :"

cd ~/Téléchargements/

rm -rf TESS3_testdeploy
git clone ssh://cayek@patator.imag.fr/home/cayek/noBackup/TESS3.git TESS3_testdeploy &> /dev/null
cd TESS3_testdeploy/
git checkout develop &> /dev/null

mkdir build
cd build
test "cmake -DCMAKE_BUILD_TYPE=release ../ &> /dev/null"
test "make TESS3 &> /dev/null"
cd ../
test "./setupRsrc.sh &> /dev/null"

echo -e "$VERT" "OK"
#############
# run tests #
#############

echo "*** Testing :"

test "Rscript test/scriptR/Rtest.R  &> /dev/null"

echo -e "$VERT" "OK"

#################
# if ok release #
#################
echo "*** Release :"

git stash &> /dev/null
git checkout master &> /dev/null
git merge develop &> /dev/null

# start release #

# compile documentation
cd doc/src/
wget http://mirrors.ctan.org/macros/latex/contrib/lineno.zip  &> /dev/null
unzip lineno.zip &> /dev/null
mv lineno/lineno.sty
wget http://mirrors.ctan.org/macros/latex/contrib/ccaption.zip &> /dev/null
unzip ccaption.zip &> /dev/null
cd ccaption/
latex ccaption.ins &> /dev/null
mv ccaption.sty ../
cd ..
test "latex note.tex &> /dev/null"
test "bibtex note &> /dev/null"
test "latex note.tex &> /dev/null"
test "latex note.tex &> /dev/null"
test "dvipdf note.dvi &> /dev/null"
rm -f ../documentation.pdf
cp note.pdf ../documentation.pdf 
git add ../documentation.pdf
cd ../../

# remove file which are not suppose to be in the release version
cat releaseRemove | xargs git rm  

DATE=`date +%Y-%m-%d`
git commit -am "Release date: $DATE"
git push

#push on github
ssh cayek@patator.imag.fr <<EOF
cd noBackup/TESS3.git
git push 
logout
EOF

cd ~/Téléchargements/
rm -rf TESS3_testdeploy

echo -e "$VERT" "OK"
