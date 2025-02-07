#!/usr/bin/perl

use v5.14;
use warnings;

use Test2::V0;

use IO::Socket::IP;

use IO::Socket::INET;
use Socket qw( SOCK_STREAM unpack_sockaddr_in getaddrinfo );

{
   my $testserver = IO::Socket::INET->new(
      Listen    => 1,
      LocalHost => "127.0.0.1",
      Type      => SOCK_STREAM,
   ) or die "Cannot listen on PF_INET - $IO::Socket::errstr";

   my ( $err, @peeraddrinfo ) = getaddrinfo( "127.0.0.1", $testserver->sockport, { socktype => SOCK_STREAM } );
   $err and die "Cannot getaddrinfo 127.0.0.1 - $err";

   my $socket = IO::Socket::IP->new(
      PeerAddrInfo => \@peeraddrinfo,
   );

   ok( defined $socket, 'IO::Socket::IP->new( PeerAddrInfo => ... ) constructs a new socket' ) or
      diag( "  error was $IO::Socket::errstr" );

   is( [ unpack_sockaddr_in $socket->peername ],
       [ unpack_sockaddr_in $testserver->sockname ],
       '$socket->peername' );
}

{
   my ( $err, @localaddrinfo ) = getaddrinfo( "127.0.0.1", 0, { socktype => SOCK_STREAM } );
   $err and die "Cannot getaddrinfo 127.0.0.1 - $err";

   my $socket = IO::Socket::IP->new(
      Listen => 1,
      LocalAddrInfo => \@localaddrinfo,
   );

   ok( defined $socket, 'IO::Socket::IP->new( LocalAddrInfo => ... ) constructs a new socket' ) or
      diag( "  error was $IO::Socket::errstr" );

   my $testclient = IO::Socket::INET->new(
      PeerHost => "127.0.0.1",
      PeerPort => $socket->sockport,
   ) or die "Cannot connect to localhost - $IO::Socket::errstr";

   is( [ unpack_sockaddr_in $socket->sockname ],
       [ unpack_sockaddr_in $testclient->peername ],
       '$socket->sockname' );
}

done_testing;
