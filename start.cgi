#!/usr/bin/perl
use strict;
use CGI;
use config;
use lib ("$config::uselibs");
use LockActions;
use StatsActions;

my ($result,$lockAction,$statsActions);
my @resultText=("FAIL","OK");

my $req = new CGI;

if ( $req )
  {
    my $url=$ENV{'REQUEST_URI'};  $url=~s/\?.*$//;
    my $method=$ENV{'REQUEST_METHOD'};
    my $index=0; $index=2 if ( $ENV{"SERVER_NAME"}=~m/perl/);
    my @vals=split(/\//,$url);

    #Config global
    if ( ($vals[3+$index] eq "obtain_execution_lock") and ($vals[4+$index]=~m/A|B/) and ($method eq "GET") )
      {
        $lockAction = new LockActions('type',$vals[4+$index]);
        my $response=$lockAction->obtain_execution_lock();
        $result=$resultText[$response];

        if ( $response==0 )
          {
            $statsActions = new StatsActions();
            $statsActions->track_failed_querries($vals[4+$index]);
          }
      }
    elsif (  ($vals[3+$index] eq "release_execution_lock") and ($vals[4+$index]=~m/A|B/) and ($method eq "GET") )
      {
        $lockAction = new LockActions('type',$vals[4+$index]);
        my $response=$lockAction->release_execution_lock();
        $result=$resultText[$response];

        if ( $response==0 )
          {
            $statsActions = new StatsActions();
            $statsActions->track_failed_querries($vals[4+$index]);
          }
      }
    else
      {
        $result=$resultText[0];
      }
  }

print "Content-type: text/plain; charset=utf-8;\n\n";
print $result;