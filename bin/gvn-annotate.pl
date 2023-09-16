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
getopts("d", \%opts) or die;

# ------------------------------
my $hash = "";
my $revision = "";
my $source = "";
my $revision_length = 0;

my %db = ();

open(my $fh, '-|', 'git log --all --no-color') or die $!;
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
        if($opts{d}) {
          warn ("$hash -> $revision\n");
	}
      } else {
	die("FATAL: undefined hash\n");
      }
    }
}

$revision_length += 1;

# ------------------------------
while(my $line = <>) {
  if($line =~ /(\<hash\>([^\<]+)\<\/hash\>)/) {
    my $hash_replace = $1;
    my $hash = $2;
    my $replacement = "";
    if(exists $db{$hash}) {
      $replacement = colored(sprintf("%-${revision_length}s", "r$db{$hash}"), 'bold blue');
    } else {
      $replacement = sprintf(" %${revision_length}s", "");
    }
    $line =~ s/$hash_replace/$replacement/g;
  }
  print $line;
}
print "\n";
