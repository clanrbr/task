package config;

use strict;
#use warnings;

BEGIN
{
use Exporter ();
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = qw( );
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions
@EXPORT_OK   = qw( $host $dbname $port $dbuser $dbpass %restrictions $uselibs  );
}
our @EXPORT_OK;

our $host         = "localhost";
our $dbname       = "imot";
our $port         = 15432;
our $dbuser       = "imot";
our $dbpass       = "imotwww19d";

our @types=('A','B');
our %restrictions= ('A'=>100,'B'=>200);
our $uselibs = "../task/classes";