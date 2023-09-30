# gvn
GVN = Git sVN = git configuration for easier usage of git-svn

## Installation under Linux
* Basic setup
  - Link bin_gvn folder to ~/bin folder
  - Link gvn to ~/bin
* link gvn to any folder that is in executable search path and adapt paths in .gitconfig.* accordingly
* Copy relevant parts (gvn-) OR more OR all from .gitconfig.* to ~/.gitconfig.* OR to local git-svn repository config

## Usage
gvn \<command\> (\<options\>)

e.g.
* gvn ucs // stash update commit unstash
* gvn us // stash update unstash
* gvn lgs // show oneline graphical colored log with svn numbers
* gvn bs <file> // colored blaming of file including svn revision numbers per line

## Requirements
* git with svn extension (git-svn)
  - e.g. git 2.37 and svn 1.14.
* python3 for svn revision annotation and colored blaming + following additional packages:
  - inquirer
  - pygments
