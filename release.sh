#!/bin/bash
# TESS3 directory on my linux computer
myTESS3="/home/cayek/Projects/TESS3"
cd "$myTESS3"
ROUGE="\\033[1;31m"
VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
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

###################
# parse arguments #
###################
RELEASE=""
DEPLOY=""
TESTING=""
while [[ $# > 0 ]]
do
key="$1"

case $key in
    -nr|--notrelease)
    RELEASE="0"
    ;;
    -nd|--notdeploy)
    DEPLOY="0"
    ;;
    -nt|--nottesting)
    TESTING="0"
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done
###############################
# push all changes to develop #
###############################
echo -e "$NORMAL" "*** Push changes :"

test "git checkout develop &> /dev/null"
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
test "git push &> /dev/null"

echo -e "$VERT" "OK"
#################
# try to deploy #
#################
cd ~/Téléchargements/

rm -rf TESS3_testdeploy
git clone ssh://cayek@patator.imag.fr/home/cayek/noBackup/TESS3.git TESS3_testdeploy &> /dev/null
cd TESS3_testdeploy/
git checkout develop &> /dev/null

if [ -z "$DEPLOY" ]; then
echo -e "$NORMAL" "*** Deployment testing :"
mkdir build
cd build
test "cmake -DCMAKE_BUILD_TYPE=release ../ &> /dev/null"
test "make TESS3 &> /dev/null"
cd ../
test "./setupRsrc.sh &> /dev/null"
echo -e "$VERT" "OK"
fi
#############
# run tests #
#############
if [ -z "$TESTING" ]; then
echo -e "$NORMAL" "*** Testing :"

test "Rscript test/scriptR/Rtest.R  &> /dev/null"

echo -e "$VERT" "OK"
fi
#################
# if ok release #
#################
if [ -z "$RELEASE" ]; then
echo -e "$NORMAL" "*** Release :"

git stash &> /dev/null
git checkout master &> /dev/null
git merge develop &> /dev/null

# start release #

# compile documentation
cd doc/src/
test "wget http://mirrors.ctan.org/macros/latex/contrib/lineno.zip  &> /dev/null"
test "unzip lineno.zip &> /dev/null"
test "mv lineno/lineno.sty . &> /dev/null"
test "wget http://mirrors.ctan.org/macros/latex/contrib/ccaption.zip &> /dev/null"
test "unzip ccaption.zip &> /dev/null"
test "cd ccaption/"
test "latex ccaption.ins &> /dev/null"
test "mv ccaption.sty ../"
cd ..
test "latex note.tex &> /dev/null"
test "bibtex note &> /dev/null"
test "latex note.tex &> /dev/null"
test "latex note.tex &> /dev/null"
test "dvipdf note.dvi &> /dev/null"
test "rm -f ../documentation.pdf"
test "cp note.pdf ../documentation.pdf"
test "git add ../documentation.pdf"
cd ../../

# remove file which are not suppose to be in the release version
cat "$myTESS3/releaseRemove" | xargs git rm  

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
fi

