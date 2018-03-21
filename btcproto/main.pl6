use v6.c;
use btcproto;

sub MAIN ( Str $host ) {
  say "connecting $host";
  my $conn = IO::Socket::INET.new(host => $host, port => 8333);
  
  my Buf $msg;
  my $protoversion = 100004;
  my $useragent = "/perl6:0.0.1/";
  $msg = version($protoversion, $useragent, 500000);
  say "send version {$protoversion} {$useragent} payload ", $msg.elems-24;
  $conn.write($msg);
  
  say "read";
  my $len =  decodeHeader($conn.read(24));
  my $recv = $conn.read($len);
  say "client name: ", decodeVersion($recv);

  $msg = verack();
  say "verack";
  $conn.write($msg);
  say "read";
  $len =  decodeHeader($conn.read(24));

  $msg = getinfo();
  say "getinfo";
  $conn.write($msg);
  say "read";
  $len =  decodeHeader($conn.read(24));
  if $len > 1 {
    $recv = $conn.read($len);
    say $recv.decode('ISO-8859-1');
  }
  
  $conn.close;
}
