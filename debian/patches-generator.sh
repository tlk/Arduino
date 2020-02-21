#!/bin/bash
#
# Goals:
#   Interface nicely with the existing Debian eco-system
#   Make it easy to maintain debian-patches with git branches
#   Keep debian-patches small


# The debian-patches git branches are branched off $UPSTREAM_BRANCH.
UPSTREAM_BRANCH=master

# Naming convention for debian-patches branches:
#   debian-patches/01-build-xml, debian-patches/02-macosx, etc.
PATCHES="01-build-xml 02-macosx 03-wrapper-script"


# Git branch with debian/rules, this script, etc.
PACKAGE_BRANCH=pkg-debian

# Automatic rebase may work because debian-patches are kept small.
rebase() {
    echo "Rebase $UPSTREAM_BRANCH debian-patches/*"
    echo ""
    for name in $PATCHES ; do
        git rebase $UPSTREAM_BRANCH "debian-patches/$name"
        if [ $? ]; then
            echo "  debian-patches/$name rebased"
        else
            echo "!Failed to rebase"
            git rebase --abort
            exit 1
        fi
    done
    git checkout $PACKAGE_BRANCH
    echo ""
    echo "Done!"
}


# Debian patches are maintained in debian-patches branches.
# One branch turns into one patch file.
# The patches/series file is automatically updated.
refresh() {
    echo "Deleting old patch files"
    rm -f patches/*

    echo "Creating new patch files from git branches (debian-patches)"
    mkdir -p patches

    for name in $PATCHES ; do
        filename="$name.patch"
        git diff $UPSTREAM_BRANCH..debian-patches/$name > patches/$filename
        echo $filename >> patches/series
        echo "  patches/$filename"
    done

    echo "Done!"
}


if [ "$1" == "refresh" ] ; then
    refresh
elif [ "$1" == "rebase" ] ; then
    rebase
else
    echo "Usage: patches-generator.sh refresh"
fi

