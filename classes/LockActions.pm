package LockActions;
use strict;
use Carp;
use DBI;
use config;

my $jobCategory;

sub new
{
  my $class= shift @_;
  my $self={@_};
  bless ($self, $class);
  $self->_init;
  return $self;
}

sub _init
{
  my $self=shift;
  $jobCategory=$self->{'type'};
}

sub obtain_execution_lock
{
  my $self = shift;
  unless (ref $self)
    {
      croak "Should call obtain_execution_lock() with an object, not a class";
    }

  my $result=0;

  my ($dbh);
  eval { $dbh = DBI->connect("dbi:Pg:dbname=$config::dbname;host=$config::host;port=$config::port", $config::dbuser, $config::dbpass, {AutoCommit => 0}); };
  if ( $dbh )
    {
      my $sth=$dbh->prepare("UPDATE task SET number_of_jobs=number_of_jobs+1 WHERE (type_of_job=?) AND (number_of_jobs<?)");
      if ( $sth->execute("$jobCategory","$config::restrictions{\"$jobCategory\"}") )
        {
          $result=1 if ( $sth->rows()==1 );
        }
      $sth->finish;

      $dbh->commit() if ( $result==1 );
      $dbh->disconnect();
    }
  return $result;
}

sub release_execution_lock
{
  my $self = shift;
  unless (ref $self)
    {
      croak "Should call release_execution_lock() with an object, not a class";
    }

  my $result=0;

  my ($dbh);
  eval { $dbh = DBI->connect("dbi:Pg:dbname=$config::dbname;host=$config::host;port=$config::port", $config::dbuser, $config::dbpass, {AutoCommit => 0}); };
  if ( $dbh )
    {
      my $sth=$dbh->prepare("UPDATE task SET number_of_jobs=number_of_jobs-1 WHERE (type_of_job=?) AND (number_of_jobs>0)");
      if ( $sth->execute("$jobCategory") )
        {
          $result=1 if ( $sth->rows()==1 );
        }
      $sth->finish;

      $dbh->commit() if ( $result==1 );
      $dbh->disconnect();
    }
  return $result;
}

1;