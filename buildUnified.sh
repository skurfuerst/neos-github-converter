#!/bin/bash
set -e


DISTRIBUTION_DIRECTORY=`pwd`/tmp-old-neos

rm -Rf $DISTRIBUTION_DIRECTORY
git clone git://git.typo3.org/Neos/Distributions/Base.git tmp-old-neos
cd tmp-old-neos
composer install
cd ../



function copyPackageIfNotExistsAndEnterTempDirectory {
  PACKAGEPATH=$1
  PACKAGEKEY=`basename $PACKAGEPATH`

  if [ ! -d "$PACKAGEKEY" ]; then
    cp -R $PACKAGEPATH .
  fi

  cd $PACKAGEKEY
}

function relocatePackage {
  PACKAGEPATH=$1

  copyPackageIfNotExistsAndEnterTempDirectory $PACKAGEPATH

  git filter-branch -f --index-filter \
    'tab=$(printf "\t") && git ls-files -s | sed "s-$tab\"*-&'"$PACKAGEKEY"'/-" | GIT_INDEX_FILE=$GIT_INDEX_FILE.new git update-index --index-info && mv "$GIT_INDEX_FILE.new" "$GIT_INDEX_FILE"' \
    --tag-name-filter cat \
    -- --all


  # transfer BRANCHES -> TAGS (because they are kept for the migration)
  for BRANCH in `git branch --all | grep origin | grep -v HEAD | grep -v composer | grep -v flow-cms | grep -v GSoC2009| grep -v l10n | grep -v trunk | grep -v master`
  do
    git tag --force branch-`basename $BRANCH` $BRANCH
  done
  cd ..
}



# This function does not only skip the given commit hash, but also records the original commit hash.
function skipCommitHash {
  PACKAGEPATH=$1
  HASH_TO_SKIP=$2

  copyPackageIfNotExistsAndEnterTempDirectory $PACKAGEPATH

  # note: the "nl" below looks very ugly (breaking indentation etc); but that's the only
  # way I could get this to work.

  git filter-branch --commit-filter '
nl="
"
    COMMIT_MESSAGE=`cat /dev/stdin`;
    COMMIT_MESSAGE="$COMMIT_MESSAGE${nl}Original-Commit-Hash: $GIT_COMMIT";

    if [ "$GIT_COMMIT" = '"$HASH_TO_SKIP"' ];
    then
        skip_commit "$@";
    else
        git commit-tree "$@" -m "$COMMIT_MESSAGE";
    fi' \
    --tag-name-filter cat \
    -- --all

  cd ..
}

function recreateBranches {
  cd merged-repo
  for tagBranch in `git tag | grep branch`; do
    git branch ${tagBranch:7} $tagBranch
    git tag -d $tagBranch
  done

  cd ..
}

PACKAGE_DIRECTORY=$DISTRIBUTION_DIRECTORY/Packages


rm -Rf tmp
mkdir tmp
cd tmp


# we manually need to skip empty commits in Kickstart / Fluid (the first commit is empty!)
skipCommitHash $PACKAGE_DIRECTORY/Framework/TYPO3.Kickstart cc6a1089d6beacde049fb435c7fc8feb6177945e
relocatePackage $PACKAGE_DIRECTORY/Framework/TYPO3.Kickstart

skipCommitHash $PACKAGE_DIRECTORY/Framework/TYPO3.Fluid a06f6e4be4cd49671f6265889543b6ff13decce1
relocatePackage $PACKAGE_DIRECTORY/Framework/TYPO3.Fluid

skipCommitHash $PACKAGE_DIRECTORY/Framework/TYPO3.Eel 000000000
relocatePackage $PACKAGE_DIRECTORY/Framework/TYPO3.Eel

skipCommitHash $PACKAGE_DIRECTORY/Framework/TYPO3.Flow 000000000
relocatePackage $PACKAGE_DIRECTORY/Framework/TYPO3.Flow
#skipCommitHash $PACKAGE_DIRECTORY/Application/TYPO3.Party d63e2db37bcb7f2fa0137e7a6fb13b26a7e1da40
#relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Party

../git-merge-repos/run.sh \
  `pwd`/TYPO3.Eel:. \
  `pwd`/TYPO3.Flow:. \
  `pwd`/TYPO3.Fluid:. \
  `pwd`/TYPO3.Kickstart:.
#  `pwd`/TYPO3.Party:.

recreateBranches

mv merged-repo FINAL-Flow

# TYPO3.Form has different versions
#relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Form
# TYPO3.Imagine has different versions
# relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Imagine

skipCommitHash $PACKAGE_DIRECTORY/Application/TYPO3.Media 000000000
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Media

skipCommitHash $PACKAGE_DIRECTORY/Application/TYPO3.Neos 000000000
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Neos

skipCommitHash $PACKAGE_DIRECTORY/Application/TYPO3.Neos.Kickstarter 000000000
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Neos.Kickstarter

skipCommitHash $PACKAGE_DIRECTORY/Application/TYPO3.Neos.NodeTypes 000000000
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Neos.NodeTypes
# neos-SEO has different package versions
#relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Neos.Seo
#relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Setup
# different versioning scheme
#relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Twitter.Bootstrap

skipCommitHash $PACKAGE_DIRECTORY/Application/TYPO3.TYPO3CR 000000000
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.TYPO3CR
cd TYPO3.TYPO3CR
git tag -d 0.5.0-alpha1
git tag -d 0.5.0-alpha2
git tag -d 0.5.0-alpha3
git tag -d 0.5.0-alpha4
git tag -d 0.5.0-alpha5
git tag -d 0.5.0-alpha6
git tag -d 0.5.0-alpha7
cd ..

skipCommitHash $PACKAGE_DIRECTORY/Application/TYPO3.TypoScript 000000000
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.TypoScript



# We want to "Preserve History for Paths"
../git-merge-repos/run.sh \
  `pwd`/TYPO3.Media:. \
  `pwd`/TYPO3.Neos:. \
  `pwd`/TYPO3.Neos.Kickstarter:. \
  `pwd`/TYPO3.Neos.NodeTypes:. \
  `pwd`/TYPO3.TYPO3CR:. \
  `pwd`/TYPO3.TypoScript:.
  #`pwd`/TYPO3.Setup:. \
#  `pwd`/TYPO3.Twitter.Bootstrap:.
#    `pwd`/TYPO3.Imagine:. \
#`pwd`/TYPO3.Neos.Seo:. \
#`pwd`/TYPO3.Form:. \

recreateBranches
mv merged-repo FINAL-Neos
