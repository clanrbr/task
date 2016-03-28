package LockActions;
use strict;
use Carp;
use DBI;

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
  my $self= shift;
  my ($inbox,$sfields,$limit,$offset)=@_;
  unless (ref $self)
    {
      croak "Should call GetMessages() with an object, not a class";
    }

  my ($query_limit, $query_offset)=('','');

  my ($dbh,@return);
  eval { $dbh = DBI->connect("dbi:Pg:dbname=$imotconf::dbname;host=$imotconf::host;port=$imotconf::port", $imotconf::dbuser, $imotconf::dbpass, {AutoCommit => 0}); };
  if ( $dbh )
    {
      my $sth=$dbh->prepare("SELECT FROM UPDATE");
      if ( $sth->execute(@vls) )
        {
          while ( my @row=$sth->fetchrow_array() )
            {
              push(@return,\@row);
            }
        }
      $sth->finish;

      $dbh->disconnect();
    }
  return @return;
}