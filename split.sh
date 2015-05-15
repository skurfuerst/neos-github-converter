#!/bin/bash

set -e


GITHUB_USER=YOUR_GITHUB_USER_HERE

NEOS_PACKAGES="TYPO3.Form TYPO3.Media TYPO3.Neos.Kickstarter TYPO3.Neos.Seo TYPO3.Setup TYPO3.TypoScript TYPO3.Imagine TYPO3.Neos TYPO3.Neos.NodeTypes TYPO3.Party TYPO3.TYPO3CR TYPO3.Eel TYPO3.Flow TYPO3.Fluid TYPO3.Kickstart"
for i in `echo $NEOS_PACKAGES | tr " " "\n"`; do
    curl -u "$GITHUB_USER:YOUR_PERSONAL_GITHUB_ACCESS_TOKEN_HERE" https://api.github.com/orgs/Neos-GitHub-Test-ReadOnlyPackages/repos -d "{\"name\":\"$i\"}"
done


mkdir -p tmp-split-neos
cd tmp-split-neos

../git-subsplit/git-subsplit.sh init git@github.com:Neos-GitHub-Test/Neos.git
../git-subsplit/git-subsplit.sh update

../git-subsplit/git-subsplit.sh publish "
    TYPO3.Form:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Form.git
    TYPO3.Media:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Media.git
    TYPO3.Neos.Kickstarter:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Neos.Kickstarter.git
    TYPO3.Neos.Seo:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Neos.Seo.git
    TYPO3.Setup:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Setup.git
    TYPO3.TypoScript:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.TypoScript.git
    TYPO3.Imagine:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Imagine.git
    TYPO3.Neos:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Neos.git
    TYPO3.Neos.NodeTypes:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Neos.NodeTypes.git
    TYPO3.Party:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Party.git
    TYPO3.TYPO3CR:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.TYPO3CR.git
"
cd ..

mkdir -p tmp-split-flow
cd tmp-split-flow

../git-subsplit/git-subsplit.sh init git@github.com:Neos-GitHub-Test/Flow.git
../git-subsplit/git-subsplit.sh update

../git-subsplit/git-subsplit.sh publish "
    TYPO3.Flow:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Flow.git
    TYPO3.Fluid:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Fluid.git
    TYPO3.Eel:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Eel.git
    TYPO3.Kickstart:git@github.com:Neos-GitHub-Test-ReadOnlyPackages/TYPO3.Kickstart.git
"
cd ..