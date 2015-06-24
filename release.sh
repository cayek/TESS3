#!/bin/bash
# TESS3 directory on my linux computer
myTESS3="/home/cayek/Projects/TESS3"
cd "$myTESS3"
ROUGE="\\033[1;31m"
VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
dir_TESS3=`pwd`

function test {
    echo "> test $@"
    res="$(eval "$@ 2>&1")"
    local status=$?
    if [ $status -ne 0 ]; then
        echo -e "$ROUGE" "error with $1 : " >&2
	echo "$res"
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

test "git checkout develop "
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
test "git push "

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
test "cmake -DCMAKE_BUILD_TYPE=release ../ "
test "make TESS3 "
cd ../
test "./setupRsrc.sh "
echo -e "$VERT" "OK"
fi
#############
# run tests #
#############
if [ -z "$TESTING" ]; then
echo -e "$NORMAL" "*** Testing :"

test "Rscript test/scriptR/Rtest.R  "

echo -e "$VERT" "OK"
fi
#################
# if ok release #
#################
if [ -z "$RELEASE" ]; then
echo -e "$NORMAL" "*** Release :"

test "git stash"
test "git checkout master"
git merge develop &> /dev/null

# start release #

# compile documentation
cd doc/src/
test "wget http://mirrors.ctan.org/macros/latex/contrib/lineno.zip  "
test "unzip lineno.zip "
test "mv lineno/lineno.sty . "
test "wget http://mirrors.ctan.org/macros/latex/contrib/ccaption.zip "
test "unzip ccaption.zip "
cd ccaption/
test "latex ccaption.ins"
test "mv ccaption.sty ../"
cd ..
test "pdflatex note.tex "
test "bibtex note "
test "pdflatex note.tex "
test "pdflatex note.tex "
test "rm -f ../documentation.pdf"
test "cp note.pdf ../documentation.pdf"
test "git add ../documentation.pdf"
cd ../../

# remove file which are not suppose to be in the release version
cat "$myTESS3/releaseRemove" | xargs -L 1 -d "\n" git rm &> /dev/null

DATE=`date +%Y-%m-%d`
test 'git commit -am "Release date: $DATE" '
test "git push "

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

