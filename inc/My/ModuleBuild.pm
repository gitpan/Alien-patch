package My::ModuleBuild;

use strict;
use warnings;
use base qw( Alien::Base::ModuleBuild );
use Capture::Tiny qw( capture );
use Alien::Base::PkgConfig;
use File::Spec;
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

sub alien_load_pkgconfig
{
  my($self) = @_;

  my $version = do {
    local $CWD = $self->config_data('working_directory');
    $CWD[-1] =~ /^patch-(.*)$/ ? $1 : 'unknown';
  };

  my $pc_name = File::Spec->catfile(qw( inc pkgconfig patch.pc ));
  open my $fh, '>', $pc_name;
  print $fh <<EOF;
Name: patch
Description: patch
Version: $version
Libs: 
Cflags: 
EOF
  close $fh;
  
  my %pc;
  $pc{patch} = Alien::Base::PkgConfig->new($pc_name);
  \%pc;
}

1;
