#!/usr/bin/perl
use strict;
use CGI;
use config;
use lib ("$config::uselibs");
use LockActions;

my ($result,$lockAction);
my @resultText=("FAIL","OK");

my $req = new CGI;

if ( $req )
  {
    my $url=$ENV{'REQUEST_URI'};  $url=~s/\?.*$//;
    my $index=0; $index=2 if ( $ENV{"SERVER_NAME"}=~m/perl/);
    my @vals=split(/\//,$url);

    #Config global
    if ( ($vals[3+$index] eq "obtain_execution_lock") and ($vals[4+$index]=~m/A|B/) )
      {
        $lockAction = new LockActions('type',$vals[4+$index]);
        $result=$resultText[$lockAction->obtain_execution_lock()];
      }
    elsif (  ($vals[3+$index] eq "release_execution_lock") and ($vals[4+$index]=~m/A|B/) )
      {
        $lockAction = new LockActions('type',$vals[4+$index]);
        $result=$resultText[$lockAction->release_execution_lock()];
      }
    else
      {
        $result=$resultText[0];
      }
  }

print "Content-type: text/plain; charset=utf-8;\n\n";
print $result;