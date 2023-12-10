#!/usr/bin/perl -w

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

use strict;
use warnings;

use Getopt::Std;

use List::Util qw( min max );

use Term::ANSIColor;

my %opts;
getopts("dm", \%opts) or die;

if ($#ARGV != 0) {
  die("ERROR: svn version argument is missing. Aborting.\n")
}

my $svn_revision = $ARGV[0];

if ($svn_revision !~ /^(r\d+|\d+)$/) {
  die("ERROR: Unexpected svn version format (r[0-9]+|[0-9]+) !~ $svn_revision. Aborting.\n")
}

$svn_revision =~ s/^r//g;

# ------------------------------
my $hash = "";
my $revision = "";
my $source = "";
my $revision_length = 0;

my %db = ();

if ($opts{m}) {
  my $dot_git_path=`git get-dot-git-path`;
  chomp $dot_git_path;
  my $db_filename="$dot_git_path/gvn/rev/db.list";

  open(FILE, "<$db_filename") or die "Couldn't open file $db_filename for reading, $!";
 
  my $linenr = 0; 
  my $nr = 0;
  while(my $line = <FILE>) {
    chomp $line;
    $linenr++;
    if($linenr == 1) {
      $revision_length = $line;
    } else {
      my @line = split(/ /, $line);
      my $hash = $line[0];
      my $revision = $line[1];
      $db{$revision} = $hash;
      if ($opts{d}) {
        warn ("$revision -> $hash\n");
      }
      $nr++;
    }
  }
  
  close(FILE);

  if ($opts{d}) {
    print("DEBUG: Read $nr hash->svn entries from $db_filename at length $revision_length.\n")
  }
  
} else {

  open(my $fh, '-|', 'git log --all --no-color') or die $!;
  my $nr = 0;
  while (my $line = <$fh>) {
    chomp $line;
  
    if($line =~ /^\s*commit\s+(\S+)(\s+|$)/) {
      $hash = $1;
    } elsif($line =~ /^\s+git-svn-id:\s+([^\@]+)\@(\d+)\s+/) {
      $source = $1;
      $revision = $2;
      if($hash ne "") {
        $db{$revision} = $hash;
        $revision_length = max(length($revision), $revision_length);
        $nr++;
        if($opts{d}) {
          warn ("$revision -> $hash\n");
        }
      } else {
        die("FATAL: undefined hash\n");
      }
    }
  }

  if ($opts{d}) {
    print("DEBUG: Decoded $nr hash->svn entries from git log at length $revision_length.\n")
  }
}

# ------------------------------
if(exists $db{$svn_revision}) {
  print("$db{$svn_revision}");
} else {
  die("ERROR: Could not find hash value to given svn revsion r$svn_revision. Aborting.\n")
}

