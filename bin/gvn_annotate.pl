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
      $db{$line[0]} = $line[1];
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
        $db{$hash} = $revision;
        $revision_length = max(length($revision), $revision_length);
        $nr++;
        if($opts{d}) {
          warn ("$hash -> $revision\n");
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

my $color_svn_revision=`git config gvn.all.color-svn-revision || true`;

# ------------------------------
while(my $line = <>) {
  if($line =~ /(\<hash\>([^\<]+)\<\/hash\>)/) {
    my $hash_replace = $1;
    my $hash = $2;
    my $replacement = "";
    if(exists $db{$hash}) {
      my $revision_length_print = $revision_length + 1;
      $replacement = colored(sprintf("%-${revision_length_print}s", "r$db{$hash}"), $color_svn_revision);
    } else {
      my $replacement_rev = "r";
      for (my $i=0; $i < $revision_length; $i++) {
        $replacement_rev .= "?";
      }
      $replacement = colored($replacement_rev, $color_svn_revision);
    }
    $line =~ s/$hash_replace/$replacement/g;
  }
  print $line;
}
print "\n";
