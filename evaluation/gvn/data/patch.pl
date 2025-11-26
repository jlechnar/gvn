#!/usr/bin/perl -w

use strict;
use warnings;

$/ = "@";

while(my $line = <>) {
  $line =~ s/\n/@/g;
  if($line =~ /^(@|)(.+)#(.+)@(.+)#(.+)@\s*$/) {
    my $a = $1;
    my $b = $2;
    my $c = $3;
    my $d = $4;
    my $e = $5;
    my $l = sprintf("%s%-5s%s@%s", $b, $c, $e, (($d =~ /[\\\/]/) ? "$d@" : ""));
    $l =~ s/@/\n/g;
    print("$l");
  } elsif($line =~ /^(@|)(.+)#(.*)#(.+)@\s*$/) {
    my $a = $1;
    my $b = $2;
    my $d = $3;
    my $e = $4;
    my $l = sprintf("%s%-5s%s@%s", $b, "r???", $e, (($d =~ /[\\\/]/) ? "$d@" : ""));
    $l =~ s/@/\n/g;
    print("$l");
  }

}
