use v6.c;
use btcproto;

sub MAIN ( Str $host ) {
  say "connecting $host";
  my $conn = IO::Socket::INET.new(host => $host, port => 8333);
  say "connected!";
  
  my $hello = push("hello", Buf.new());
  $conn.write($hello);
  say "hello sent";
  say $hello;
  
  say $conn.read(1);
  say "read";
  
  $conn.close;
}
