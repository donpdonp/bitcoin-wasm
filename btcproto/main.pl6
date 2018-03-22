use v6.c;
use btcproto;

sub MAIN ( Str $host =  "seed.bitcoin.sipa.be" ) {
  say "connecting $host";

  my $supplier = Supplier.new;
  my $supply = $supplier.Supply;
  my $socket_tube = Channel.new;

  IO::Socket::Async.connect($host, 8333).then( -> $promise {
    my $socket = $promise.result;
    $socket_tube.send($socket);
    $supplier.emit(['connect', Buf.new]);
    $socket.Supply(:bin).tap( -> $buf { 
      my $payload_len = decodeHeader($buf);
    });
  });

  $supply.tap( -> $inmsg {
    say "state tap {$inmsg}";
    my $protoversion = 100004;
    my $useragent = "/perl6:0.0.1/";
    my $msg = version($protoversion, $useragent, 500000);
    say "send version {$protoversion} {$useragent} payload {$msg.elems-24}";
    my $socket = $socket_tube.receive;
    $socket.write($msg);
    #verack
    #getinfo
  });

  Channel.new.receive; # wait
}
