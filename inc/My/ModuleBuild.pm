package My::ModuleBuild;

use strict;
use warnings;
use base qw( Alien::Base::ModuleBuild );
use Capture::Tiny qw( capture );
use Config;
use File::Temp qw( tempdir );
use File::chdir;

sub new
{
  my($class, %args) = @_;
  
  $args{alien_name} = 'patch';
  $args{alien_repository} = {
    protocol => 'http',
    host     => 'ftp.gnu.org',
    location => "/gnu/patch/",
    pattern  => qr{^patch-.*\.tar\.gz$},
  };
  
  my $self = $class->SUPER::new(%args);
  
  $self;
}

sub alien_check_installed_version
{
  my($self) = @_;
  my($stdout, $stderr, $ret) = capture { system 'patch', '--version'; $? };
  return if $ret;
  return $1 if $stdout =~ /patch ([0-9.]+)/i;
  return $1 if $stdout =~ /patch version ([0-9.])/i;
  return 'unknwon';
}

sub alien_check_built_version
{
  $CWD[-1] =~ /^patch-(.*)$/ ? $1 : 'unknown';
}

1;
