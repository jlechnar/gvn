# gvn
gvn = Git sVN = git configuration for easier usage of git-svn

## Installation under Linux
* Place bin/* to e.g. ~/bin folder or any other folder that is in executable search path
* Copy relevant parts (gvn-) OR more OR all from .gitconfig to ~/.gitconfig OR to local git-svn repository

## Usage
gvn <command> <options>

e.g.
gvn ucs // stash update commit unstash
gvn us // stash update unstash
gvn lgs // show oneline graphical colored log with svn numbers

## Requirements
* git with svn extension
** e.g. git 2.37 and svn 1.14.
