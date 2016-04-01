#!/usr/bin/perl
use strict;
use CGI;
use config;
use lib ("$config::uselibs");
use StatsActions;
use Time::HiRes qw ( setitimer ITIMER_VIRTUAL ITIMER_REAL  time );
use Sys::MemInfo qw(totalmem freemem totalswap);

my ($result,$statsActions,$statsActions);
my $req = new CGI;
my $twoMinutesInSeconds=2*60; # 2 minutes
if ( $req )
  {
    my $beginTime=time();
    my $statsActions = new StatsActions();

    $result.="RAM total memory: ".(&totalmem / 1024)."\n";
    $result.="RAM free memory:  ".(&freemem / 1024)."\n";

    #CPU load

    #clear old data
    $statsActions->clear_records();

    #start collecting data;
    $statsActions->recording(1);

    #get current active jobs
    my %activeJobs=$statsActions->get_active_jobs();
    $result.="FROM START JOB A: $activeJobs{'A'}\n";
    $result.="FROM START JOB B: $activeJobs{'B'}\n";

    #sleep for the rest
    my $nowTime=time();
    if ( $nowTime-$beginTime<$twoMinutesInSeconds )
      {
        my $timeToSleep=$twoMinutesInSeconds-($nowTime-$beginTime);
        sleep($timeToSleep);
      }

    #stop collecting data
    $statsActions->recording(0);

    #get jobs queried during 2 minutes
    my %getRecords=$statsActions->get_records();
    foreach (keys %getRecords) 
      {
        my $key=$_;
        $result.="ACTIVE jobs during those two minutes of type '$key': $getRecords{$key}[0] obtained calls, $getRecords{$key}[1] released calls , $getRecords{$key}[2] failed calls\n";
      }
  }

print "Content-type: text/plain; charset=utf-8;\n\n";
print $result;
