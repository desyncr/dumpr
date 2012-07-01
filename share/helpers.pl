#!/usr/bin/perl -w
# Version: ${version.number}
# Build: @BUILDTIMESTAMP@
use strict;
use warnings;
use URI::Escape;
use Data::Dumper;

my $operation=$ARGV[0] || &usage;
my $param=$ARGV[1] || &usage;
my $param2=$ARGV[2] || '';
my $filename="";

$param =~ s/\/\//\//g;
$param =~ s/\:/\:\//g;

$param2 =~ s/\/\//\//g;
$param2 =~ s/\:/\:\//g;

if ($operation =~ "filename") {
    my @uri = split("/", $param);
    print $uri[-1];

}elsif ($operation =~ "relative-path") {
    my @base = split("/", $param); # base address
    my @relative = split("/", $param2); # to make relative

    my $rel='';
    for (my $i=$#base+1; $i<$#relative; $i++)
    {
        $rel .= $relative[$i] . '/';
    }
    print $rel;

}elsif ($operation =~ "decode") {
    $filename = uri_unescape($param);
    print $filename;

}elsif ($operation =~ "list") {
    my @urls = `cat $param` =~ /<a href\="(.*)">.*<\/a>/g;
    print join("\n", @urls);;
}

sub usage{
    exit 1;
}