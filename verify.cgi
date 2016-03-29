#!/usr/bin/perl
use strict;
use CGI;
use config;
use LWP::UserAgent;
use HTTP::Request::Common;

my $req = new CGI;
my ($result,$lockAction);
if ( $req )
  {
    # Test for wrong type of job
    $result.=&testCaseForWrongTypeOfJob();
    # Test for obtaining and releasing the job 'A'
    $result.=&testCaseForRightTypeOfSingleJob('A');
    # Test for obtaining and releasing the job 'B'
    $result.=&testCaseForRightTypeOfSingleJob('B');
    # Test for obtaining and releasing maximum + 1 active jobs of type 'A'
    $result.=&testCaseForMaxRecordsOfType('A',$config::restrictions{'A'});
    # Test for obtaining and releasing maximum + 1 active jobs of type 'B'
    $result.=&testCaseForMaxRecordsOfType('B',$config::restrictions{'B'});
  }

sub testCaseForWrongTypeOfJob() 
  {
    my $response="";
    # Test for wrong type of job
    my $urlObtain="http://perl2.hazart.eu/cgi/imot/task/start.cgi/obtain_execution_lock/C";
    my $urlRelease="http://perl2.hazart.eu/cgi/imot/task/start.cgi/release_execution_lock/C";
    my $browser=LWP::UserAgent->new;
    $browser->max_size(1048576);
    $browser->timeout(5);
    my $req=HTTP::Request->new("GET",$urlObtain);
    my $resp=$browser->request($req);
    if ( $resp->is_success )
      {
        $response.="Test for obtaining wrong type of job: ".$resp->content."\n";
      }

    my $reqRelease=HTTP::Request->new("GET",$urlRelease);
    my $respRelease=$browser->request($reqRelease);
    if ( $respRelease->is_success )
      {
        $response.="Test for releasing wrong type of job: ".$respRelease->content."\n";
      }

    return $response;
  }

sub testCaseForRightTypeOfSingleJob() 
  { 
    my ($typeOfJob)=@_;

    my $response="";
    # Test for wrong type of job
    my $urlObtain="http://perl2.hazart.eu/cgi/imot/task/start.cgi/obtain_execution_lock/".$typeOfJob;
    my $urlRelease="http://perl2.hazart.eu/cgi/imot/task/start.cgi/release_execution_lock/".$typeOfJob;
    my $browser=LWP::UserAgent->new;
    $browser->max_size(1048576);
    $browser->timeout(5);
    my $req=HTTP::Request->new("GET",$urlObtain);
    my $resp=$browser->request($req);
    if ( $resp->is_success )
      {
        $response.="Test for obtaining right type of job '$typeOfJob': ".$resp->content."\n";
      }

    my $reqRelease=HTTP::Request->new("GET",$urlRelease);
    my $respRelease=$browser->request($reqRelease);
    if ( $respRelease->is_success )
      {
        $response.="Test for releasing right type of job '$typeOfJob': ".$respRelease->content."\n";
      }

    return $response;
  }

sub testCaseForMaxRecordsOfType() 
  {
    my ($typeOfJob,$max)=@_;

    my $i=0;
    my $response.="Test for obtaining more than '$max' active jobs of type '$typeOfJob': \n";
    while ( $i<$max+1 ) 
      {
        # Test for wrong type of job
        my $urlObtain="http://perl2.hazart.eu/cgi/imot/task/start.cgi/obtain_execution_lock/".$typeOfJob;
        my $browser=LWP::UserAgent->new;
        $browser->max_size(1048576);
        $browser->timeout(5);
        my $req=HTTP::Request->new("GET",$urlObtain);
        my $resp=$browser->request($req);
        if ( $resp->is_success )
          {
            $response.=($i+1)." : ".$resp->content."\n";
          }
        $i++;
      }

    $response.="Test for releasing more than '$max' active jobs of type '$typeOfJob': \n";
    while ($i>0)
      {
        my $urlRelease="http://perl2.hazart.eu/cgi/imot/task/start.cgi/release_execution_lock/".$typeOfJob;
        my $browser=LWP::UserAgent->new;
        $browser->max_size(1048576);
        $browser->timeout(5);
        my $reqRelease=HTTP::Request->new("GET",$urlRelease);
        my $respRelease=$browser->request($reqRelease);
        if ( $respRelease->is_success )
          {
            $response.=($max+2-$i)." : ".$respRelease->content."\n";
          }
        $i--;
      }

    return $response;
  }

print "Content-type: text/plain; charset=utf-8;\n\n";
print $result;
