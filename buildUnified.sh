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
  for BRANCH in `git branch --all | grep origin | grep -v HEAD | grep -v master`
  do
    git tag --force branch-`basename $BRANCH` $BRANCH
  done
  cd ..
}

function skipCommitHash {
  PACKAGEPATH=$1
  HASH_TO_SKIP=$2

  copyPackageIfNotExistsAndEnterTempDirectory $PACKAGEPATH

  git filter-branch --commit-filter '
    if [ "$GIT_COMMIT" = '"$HASH_TO_SKIP"' ];
    then
        skip_commit "$@";
    else
        git commit-tree "$@";
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
relocatePackage $PACKAGE_DIRECTORY/Framework/TYPO3.Eel
relocatePackage $PACKAGE_DIRECTORY/Framework/TYPO3.Flow


../git-merge-repos/run.sh \
  `pwd`/TYPO3.Eel:. \
  `pwd`/TYPO3.Flow:. \
  `pwd`/TYPO3.Fluid:. \
  `pwd`/TYPO3.Kickstart:.

recreateBranches

mv merged-repo FINAL-Flow

relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Form
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Imagine
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Media
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Neos
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Neos.Kickstarter
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Neos.NodeTypes
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Neos.Seo
skipCommitHash $PACKAGE_DIRECTORY/Application/TYPO3.Party d63e2db37bcb7f2fa0137e7a6fb13b26a7e1da40
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Party
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Setup
# TYPO3.Twitter.Bootstrap missing
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.TYPO3CR
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.TypoScript



# We want to "Preserve History for Paths"
../git-merge-repos/run.sh \
  `pwd`/TYPO3.Form:. \
  `pwd`/TYPO3.Imagine:. \
  `pwd`/TYPO3.Media:. \
  `pwd`/TYPO3.Neos:. \
  `pwd`/TYPO3.Neos.Kickstarter:. \
  `pwd`/TYPO3.Neos.NodeTypes:. \
  `pwd`/TYPO3.Neos.Seo:. \
  `pwd`/TYPO3.Party:. \
  `pwd`/TYPO3.Setup:. \
  `pwd`/TYPO3.TYPO3CR:. \
  `pwd`/TYPO3.TypoScript:.

recreateBranches
mv merged-repo FINAL-Neos

