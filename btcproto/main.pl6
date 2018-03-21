use v6.c;
use btcproto;

sub MAIN ( Str $host ) {
  say "connecting $host";
  my $conn = IO::Socket::INET.new(host => $host, port => 8333);
  
  my $version = version();
  say "send version payload ", $version.elems-24;
  $conn.write($version);
  
  say "read";
  my $len =  decodeHeader($conn.read(24));
  say "received ", $len;
  my $recv = $conn.read($len);
  say $recv;
  say $recv.decode('ISO-8859-1');
  
  $conn.close;
}
