#!/usr/bin/perl -w

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

# ------------------------------
while(my $line = <>) {
  if($line =~ /(\<hash\>([^\<]+)\<\/hash\>)/) {
    my $hash_replace = $1;
    my $hash = $2;
    my $replacement = "";
    if(exists $db{$hash}) {
      $replacement = colored(sprintf("r%${revision_length}d", $db{$hash}), 'bold blue');
    } else {
      $replacement = sprintf(" %${revision_length}s", "");
    }
    $line =~ s/$hash_replace/$replacement/g;
  }
  print $line;
}
print "\n";
