#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use POSIX;

my ( $basedir, $pattern, $age, $amount );
GetOptions("basedir=s" => \$basedir,
           "pattern=s" => \$pattern,
           "age=i"     => \$age,
           "amount=i"  => \$amount)
or die "Error in command line arguments";

die '$basedir should be defined' if !defined $basedir;
die '$pattern should be defined' if !defined $pattern;
die '$age should be defined'     if !defined $age;
die '$amount should be defined'  if !defined $amount;

die "Basedir '$basedir' doesn't exists or not a directory" if !-d $basedir;

pipe my $reader, my $writer;
my $pid = fork;

die "Fork failed: $!" if !defined $pid;
if ( $pid == 0 ) {
    close $reader;
    POSIX::close(1);
    POSIX::dup2(fileno($writer), 1);
    my $mtime = $age < 0 ? $age : -1 * $age;
    exec 'find', $basedir, -name => $pattern, -mtime => $mtime;
}
else {
    close $writer;
    my @files = <$reader>;
    my ( $code, $status ) = @files >= $amount
      ? ( 0, 'OK' )
      : ( 1, 'WARNING' );

    printf "%s: %d files found (expect %d)\n", $status, scalar @files, $amount;
    print join "", @files;
    exit $code;
}
