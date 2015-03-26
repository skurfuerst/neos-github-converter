#!/bin/bash


DISTRIBUTION_DIRECTORY=`pwd`/../neosbase



function relocatePackage {
  PACKAGEPATH=$1

  cp -R $PACKAGEPATH .

  PACKAGEKEY=`basename $PACKAGEPATH`

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

relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.TYPO3CR
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Neos.NodeTypes
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.TypoScript
relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Neos.Kickstarter
# relocatePackage $PACKAGE_DIRECTORY/Application/TYPO3.Neos

mkdir FINAL
cd FINAL
git init
touch README.md
git add README.md
git commit -m "add readme"


# We want to "Preserve History for Paths"
#../../git-merge-repos/run.sh `pwd`/../TYPO3.TYPO3CR:. `pwd`/../TYPO3.Neos:.
../../git-merge-repos/run.sh \
  `pwd`/../TYPO3.TYPO3CR:. \
  `pwd`/../TYPO3.Neos.NodeTypes:. \
  `pwd`/../TYPO3.Neos.TypoScript:. \
  `pwd`/../TYPO3.Neos.Kickstarter:.

#git subtree add --prefix=TYPO3.TYPO3CR --message="Adding TYPO3.TYPO3CR to shared repository" ../TYPO3.TYPO3CR master