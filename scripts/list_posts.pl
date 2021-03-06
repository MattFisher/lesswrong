#!/usr/bin/perl -w
# Description: This scripts sends a mt.getRecentPostTitles request
#              to TypePad

use strict;
use warnings;
use utf8;

use Data::Dumper;
use XMLRPC::Lite;
use IO::File;
use English;
use YAML::Syck;

my $username = "";
my $password = "";
my $blogid   = "";
my $proxyurl = 'http://www.typepad.com/t/api';

# http://www.typepad.com/site/blogs/6a00d8341c6a2c53ef00d8341c6a3053ef/dashboard

my $posts = XMLRPC::Lite
    ->proxy($proxyurl)
    ->call('mt.getRecentPostTitles', $blogid, $username, $password, 2000)
    ->result;

unless (defined ($posts)) {
    print "failed: $!";
}

my $ofile = IO::File->new('posts2.yml', 'w');
unless($ofile) {
    die "Can't open output file";
}
my $log = IO::File->new('log2.txt', 'w');
unless($log) {
    die "Unable to open log file";
}

# Download all the posts....
my @fullposts;
foreach my $post (@$posts) {
    my $postid = $post->{'postid'};
    
    print $log "$post->{'title'}\n";
    print "$post->{'title'}\n";
    
    my $full_post = eval {
         return XMLRPC::Lite 
            ->proxy($proxyurl) 
            ->call('blogger.getPost', '20f354f288cb1bf9d6c7f13726dfb402',$postid, $username, $password) 
            ->result;
    };
    if($EVAL_ERROR) {
        print $log "*** Error retrieving post $post->{title}:\n$EVAL_ERROR\n";
        next;
    }
    
    push @fullposts, $full_post;
}

DumpFile($ofile, \@fullposts);
$ofile->close();
$log->close();