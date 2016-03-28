#!/usr/bin/perl
use strict;
use CGI;
use LockActions;

my ($result,$status_code);
my @resultText=("FAIL","OK");

my $req = new CGI;
my %controller_call =('home' => \&Home,'search' => \&SearchResultsMobile, 'details' => \&Details, , 'dictionary' => \&Dictionary,
                      'users' => \&Users, 'notepad' => \&Notepad, 'filters' => \&Filters, 'sendquestion' => \&AskQuestion, 'notifications'=> \&Notifications);

if ( $req )
  {
    my $url=$ENV{'REQUEST_URI'};  $url=~s/\?.*$//;
    my $index=0; $index=1 if ( $ENV{"SERVER_NAME"}=~m/perl/);
    my @vals=split(/\//,$url);

    #Config global
    if ( ($vals[3+$index] eq "obtain_execution_lock") and ($vals[4+$index]=~m/A|B/) )
      {
        $req->param(-name=>'obtain_execution_lock',-value=>$vals[4+$index]);
      }
    elsif (  ($vals[3+$index] eq "release_execution_lock") and ($vals[4+$index]=~m/A|B/) )
      {
        $req->param(-name=>'release_execution_lock',-value=>$vals[3+$index]);
      }
    else
      {
        $result.=$resultText[0];
      }

    if (exists $controller_call{$vals[3+$index]})
      {
        # ($result, $status_code) = $controller_call{$vals[2+$index]}->($req);
      }
  }

print "Access-Control-Allow-Credentials: true\n";
print "Access-Control-Allow-Origin: http://m.imot.bg\n";
print "Status: $status_code\n";
print "Content-type: text/plain; charset=utf-8;\n\n";
print $result;