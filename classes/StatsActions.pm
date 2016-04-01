package StatsActions;
use strict;
use Carp;
use DBI;
use config;

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
}

sub recording
{
  my $self = shift;
  unless (ref $self)
    {
      croak "Should call obtain_execution_lock() with an object, not a class";
    }

  my ($action)=@_;
  my $result=0;
  
  my $dbh;
  eval { $dbh = DBI->connect("dbi:$config::databaseDriver:dbname=$config::dbname;host=$config::host;port=$config::port", $config::dbuser, $config::dbpass, {AutoCommit => 0}); };

  if ( $dbh )
    {
      my $sth=$dbh->prepare("UPDATE task_monitor SET flag=?");
      if ( $sth->execute("$action") )
        {
          $result=1 if ( $sth->rows()==1 );
        }
      $sth->finish;

      $dbh->commit() if ( $result==1 );
      $dbh->disconnect();
    }
  return $result;
}

sub clear_records
{
  my $self = shift;
  unless (ref $self)
    {
      croak "Should call obtain_execution_lock() with an object, not a class";
    }
  my $result=0;
  
  my $dbh;
  eval { $dbh = DBI->connect("dbi:$config::databaseDriver:dbname=$config::dbname;host=$config::host;port=$config::port", $config::dbuser, $config::dbpass, {AutoCommit => 0}); };

  if ( $dbh )
    {
      my $sth=$dbh->prepare("DELETE FROM task_metrics");
      if ( $sth->execute() )
        {
          $result=1;
        }
      $sth->finish;

      $dbh->commit() if ( $result==1 );
      $dbh->disconnect();
    }
  return $result;
}

sub get_records
{
  my $self = shift;
  unless (ref $self)
    {
      croak "Should call obtain_execution_lock() with an object, not a class";
    }
  my %result;
  
  my $dbh;
  eval { $dbh = DBI->connect("dbi:$config::databaseDriver:dbname=$config::dbname;host=$config::host;port=$config::port", $config::dbuser, $config::dbpass, {AutoCommit => 0}); };

  if ( $dbh )
    {
      my $sth=$dbh->prepare("SELECT type_of_job, action FROM task_metrics");
      if ( $sth->execute() )
        {
          while ( my @row=$sth->fetchrow_array() )
            {
              my @temp=(0,0,0);
              $result{"$row[0]"}=\@temp if (!exists $result{"$row[0]"});
              $result{"$row[0]"}[$row[1]]++;
            }
        }
      $sth->finish;
      $dbh->disconnect();
    }
  return %result;
}

sub track_failed_querries
{
  my $self = shift;
  unless (ref $self)
    {
      croak "Should call obtain_execution_lock() with an object, not a class";
    }

  my ($type_of_job)=@_;

  my $result=0;
  my $dbh;
  eval { $dbh = DBI->connect("dbi:$config::databaseDriver:dbname=$config::dbname;host=$config::host;port=$config::port", $config::dbuser, $config::dbpass, {AutoCommit => 0}); };

  if ( $dbh )
    {
      my $flag=0;
      my $sths=$dbh->prepare("SELECT flag FROM task_monitor LIMIT 1");
      if ( $sths->execute() )
        {
          $flag=($sths->fetchrow_array())[0] if ( $sths->rows()==1 );
        }
      $sths->finish();

      if ( $flag==1 )
        {
          my $sth=$dbh->prepare("INSERT INTO task_metrics (type_of_job,action) VALUES (?,2)");
          if ( $sth->execute("$type_of_job") )
            {
              $result=1 if ($sth->rows()==1);
            }
          $sth->finish;
        }

      $dbh->commit() if ($result==1);
      $dbh->disconnect();
    }
  return $result;
}

sub get_active_jobs
{
  my $self = shift;
  unless (ref $self)
    {
      croak "Should call obtain_execution_lock() with an object, not a class";
    }
  my %result;
  
  my $dbh;
  eval { $dbh = DBI->connect("dbi:$config::databaseDriver:dbname=$config::dbname;host=$config::host;port=$config::port", $config::dbuser, $config::dbpass, {AutoCommit => 0}); };
  if ( $dbh )
    {
      my $sth=$dbh->prepare("SELECT number_of_jobs, type_of_job FROM task");
      if ( $sth->execute() )
        {
          while ( my @row=$sth->fetchrow_array() )
            {
              $result{"$row[1]"}=$row[0];
            }
        }
      $sth->finish;
      $dbh->disconnect();
    }
  return %result;
}

1;