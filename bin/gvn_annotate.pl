#!/usr/bin/perl -w

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

use strict;
use warnings;

# use Getopt::Std;
use Getopt::Long;

use List::Util qw( min max );

use Term::ANSIColor;

my %opts;
# m ... use gvn db.list file for decode
# d ... debug
# r ... use revmap db file for decode
# b ... filter empty lines and ^...$ (both)
# f ... filter ^...$
# c ... color for svn revision
# e ... extend end with empty line
#getopts("dmr:fFc:", \%opts) or die;

my @rs = ();
my @cs = ();
GetOptions('d' => \$opts{d},
           'm' => \$opts{m},
           'r=s@' => \@rs,
           'b' => \$opts{b},
           'f' => \$opts{f},
           'e' => \$opts{e},
           'c=s@' => \@cs);

$opts{c} = join(' ', @cs);
if($#rs!= -1) {
  $opts{r} = 1;
}

# ------------------------------
my $hash = "";
my $revision = "";
my $source = "";
my $revision_length = 0;

my %db = ();

if ($opts{r}) {
  my $nr = 0;

  foreach my $filename (@rs) {
    if ($opts{d}) {
      warn ("Processing $filename ...\n");
    }

    open(my $fh, '<:raw', "$filename") or die "Couldn't open file $filename for reading, $!";

    my $nr_bytes_read = 0;
    my $buffer = '';
    my $nr_bytes_to_read = 0;
    my $abort = 0;
    my $svn_revision;
    my $git_revision;

    while ($abort == 0) {
      $buffer = '';
      $nr_bytes_to_read = 4;
      $nr_bytes_read = read($fh, $buffer, $nr_bytes_to_read);

      #print("$nr_bytes_read\n");
      if ($nr_bytes_read != $nr_bytes_to_read) {
        $abort = 1;
      } else {

        #my $svn_revision = ; # dec
        #push @values, unpack('N', $buffer);  # Assuming 4-byte unsigned integer
        $svn_revision = unpack( 'NL*', $buffer );
      }

      if ($abort == 0) {
        $buffer = '';
        $nr_bytes_to_read = 20;
        $nr_bytes_read = read($fh, $buffer, $nr_bytes_to_read);

        #print("$nr_bytes_read\n");

        if ($nr_bytes_read != $nr_bytes_to_read) {
          $abort = 1;
        } else {

          $git_revision = unpack( 'H*', $buffer );
          #print("$git_revision => $svn_revision\n");
          #my $git_revision = ; # hash as hex string
          $db{$git_revision} = $svn_revision;
          $revision_length = max(length($svn_revision), $revision_length);
          $nr++;
          if ($opts{d}) {
            warn ("$git_revision -> $svn_revision\n");
          }
        }
      }
    }

    # Check for end of file
    # vs. !defined $nr_bytes_read ??? FIXME
    if (($nr_bytes_read == 0) && ($nr_bytes_to_read == 4)) {
      #warn("EOD reached");
      #    } elsif($nr_bytes_read != $nr_bytes_to_read) {
      #      die("ERROR: Reading revision information from $filename failed due to unexpected read data size ($nr_bytes_read != $nr_bytes_to_read). Seems that the file is corrupted")
    } else {
      die("ERROR: Reading revision information from $filename failed due to unexpected read data size ($nr_bytes_read != $nr_bytes_to_read).")
    }


    if (!defined $buffer) {
      if ($! == 0) {            # No error means EOF reached
        print "End of file reached.\n";
      } else {
        die "Error reading binary data: $!";
      }
    }

    close($fh);
  }

  if ($opts{d}) {
    print("DEBUG: Decoded $nr hash->svn entries from $opts{r} at length $revision_length.\n")
  }

} elsif ($opts{m}) {
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

# ------------------------------
while(my $line = <>) {
  chomp($line);
  if($opts{b}) {
    next if($line =~ /^\.\.\.$/);
    next if($line =~ /^\s*$/);
  }
  if($opts{f}) {
    next if($line =~ /^\.\.\.$/);
  }

  if($line =~ /((\<hash\>|#)([^\<]+)(\<\/hash\>|#))/) {
    my $hash_replace = $1;
    my $hash = $3;
    my $replacement = "";
    if(exists $db{$hash}) {
      my $revision_length_print = $revision_length + 1;
      if($opts{c}) {
        $replacement = colored(sprintf("%-${revision_length_print}s", "r$db{$hash}"), $opts{c});
      } else {
        $replacement = sprintf("%-${revision_length_print}s", "r$db{$hash}");
      }
    } else {
      my $replacement_rev = "r";
      for (my $i=0; $i < $revision_length; $i++) {
        $replacement_rev .= "?";
      }
      if($opts{c}) {
        $replacement = colored($replacement_rev, $opts{c});
      } else {
        $replacement = $replacement_rev;
      }
    }
    $line =~ s/$hash_replace/$replacement/g;
  }
  print "$line\n";
}

if($opts{e}) {
  print "\n";
}
