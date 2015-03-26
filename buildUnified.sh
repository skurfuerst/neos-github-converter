#!/bin/bash


DISTRIBUTION_DIRECTORY=`pwd`/../neosbase



function relocatePackage {
  PACKAGEKEY=$1

  cd $PACKAGEKEY
  git filter-branch --index-filter \
    'tab=$(printf "\t") && git ls-files -s | sed "s-$tab\"*-&'"$PACKAGEKEY"'/-" | GIT_INDEX_FILE=$GIT_INDEX_FILE.new git update-index --index-info && mv "$GIT_INDEX_FILE.new" "$GIT_INDEX_FILE"' \
    --tag-name-filter cat \
    -- --all
  cd ../
}


PACKAGE_DIRECTORY=$DISTRIBUTION_DIRECTORY/Packages


rm -Rf tmp
mkdir tmp
cd tmp

cp -R $PACKAGE_DIRECTORY/Application/TYPO3.TYPO3CR TYPO3.TYPO3CR
relocatePackage TYPO3.TYPO3CR

cp -R $PACKAGE_DIRECTORY/Application/TYPO3.Neos.NodeTypes TYPO3.Neos.NodeTypes
relocatePackage TYPO3.Neos.NodeTypes

#cp -R $PACKAGE_DIRECTORY/Application/TYPO3.Neos TYPO3.Neos
#relocatePackage TYPO3.Neos

mkdir FINAL
cd FINAL
git init
touch README.md
git add README.md
git commit -m "add readme"


# We want to "Preserve History for Paths"
#../../git-merge-repos/run.sh `pwd`/../TYPO3.TYPO3CR:. `pwd`/../TYPO3.Neos:.
../../git-merge-repos/run.sh `pwd`/../TYPO3.TYPO3CR:. `pwd`/../TYPO3.Neos.NodeTypes:.

#git subtree add --prefix=TYPO3.TYPO3CR --message="Adding TYPO3.TYPO3CR to shared repository" ../TYPO3.TYPO3CR master