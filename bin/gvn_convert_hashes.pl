#!/usr/bin/perl -w

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

use strict;
use warnings;

use Getopt::Long;
#use Getopt::Std;

use List::Util qw( min max );

use Term::ANSIColor;

# warn(join(' ', @ARGV));

my %opts;
Getopt::Long::Configure("pass_through");
GetOptions ("c:s" => \$opts{c}, # command
            "d" => \$opts{d}, # debug
            "m" => \$opts{m}) # use database or direct convert
or die("Error in command line arguments\n");
#getopts("dm", \%opts) or die;

my $max_revision_positions=5;

# ------------------------------
my $data = join(' ', @ARGV);

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
      $db{$line[1]} = $line[0];
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
    } elsif($line =~ /^\s+git-svn-id:\s+([^\@]+)\@(\d{1,$max_revision_positions})\s+/) {
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
# multi matches
while($data =~ /(^| )(-r|r)((\d{1,$max_revision_positions}):(r|)(\d{1,$max_revision_positions}))( |$)/) {
  my $svn_revision_before = $1;
  my $svn_revision_rev_prefix = $2;
  my $svn_revision_block = $3;
  my $svn_revision1 = $4;
  my $svn_revision2 = $6;
  my $svn_revision_after = $7;

  if(not exists $db{$svn_revision1}) {
    die("ERROR: Could not find hash value to given svn revsion $svn_revision1. Aborting.\n")
  }
  if(not exists $db{$svn_revision2}) {
    die("ERROR: Could not find hash value to given svn revsion $svn_revision2. Aborting.\n")
  }

  my $svn_revision1_postfix = "\^";
  my $svn_revision2_postfix = "";
  my $svn_revision_before_postfix = "";
  if($svn_revision2 >= $svn_revision1) {
  } else {
    if($opts{c} =~ /^lg/) {
      die("ERROR: Reverse mapping of versions not supported for command $opts{c}. Aborting.\n")
    }
    $svn_revision_before_postfix = " --reverse ";
    my $svn_revision1_tmp = $svn_revision1;
    $svn_revision1 = $svn_revision2;
    $svn_revision2 = $svn_revision1_tmp;
  }

  $data =~ s/${svn_revision_before}${svn_revision_rev_prefix}${svn_revision_block}${svn_revision_after}/${svn_revision_before}${svn_revision_before_postfix}$db{$svn_revision1}${svn_revision1_postfix}..$db{$svn_revision2}${svn_revision2_postfix}${svn_revision_after}/g;

  if($opts{d}) {
    warn "$data\n";
  }
}

# ------------------------------
# single matches
while($data =~ /(^| |-|\.\.\.|\.\.)r(\d{1,$max_revision_positions})(\.\.| |$)/) {
  my $svn_revision_before = $1;
  my $svn_revision = $2;
  my $svn_revision_after = $3;

  if(exists $db{$svn_revision}) {
    if($svn_revision_before eq "-") {
      $data =~ s/${svn_revision_before}r${svn_revision}${svn_revision_after}/$db{$svn_revision}${svn_revision_after}/g;
    } elsif($svn_revision_before eq ":") {
      $data =~ s/${svn_revision_before}r${svn_revision}${svn_revision_after}/\^\.\.$db{$svn_revision}${svn_revision_after}/g;
    } else {
      $data =~ s/${svn_revision_before}r${svn_revision}${svn_revision_after}/${svn_revision_before}$db{$svn_revision}${svn_revision_after}/g;
    }
  } else {
    die("ERROR: Could not find hash value to given svn revsion $svn_revision. Aborting.\n")
  }
  if($opts{d}) {
    warn "$data\n";
  }
}

# ------------------------------
print("$data");

