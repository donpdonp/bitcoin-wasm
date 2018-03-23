use v6.c;
use btcproto;

sub MAIN ( Str $host =  "seed.bitcoin.sipa.be" ) {
  say "connecting $host";

  my $supplier = Supplier.new;
  my $supply = $supplier.Supply;
  my $payload_tube = Channel.new;
  my $socket;

  IO::Socket::Async.connect($host, 8333).then( -> $promise {
    CATCH { default { say .^name, ': ', .Str } };
    $socket = $promise.result;
    $supplier.emit('connect');
    read_loop($socket, $supplier, $payload_tube);
  });

  $supply.tap( -> $inmsg {
    say "state receive {$inmsg.perl}";
    if $inmsg eq "connect" {
      my $protoversion = 100004;
      my $useragent = "/perl6:0.0.1/";
      my $msg = version($protoversion, $useragent, 500000);
      say "send version {$protoversion} {$useragent} payload {$msg.elems-24}";
      $socket.write($msg);
    }

    if $inmsg eq "version\0\0\0\0\0" {
      my $msg = verack;
      say "send verack";
      $socket.write($msg);
    }

    if $inmsg eq "verack\0\0\0\0\0\0" {
      my $msg = getinfo;
      say "send getinfo";
      $socket.write($msg);
    }
  });

  Channel.new.receive; # wait
}

sub read_loop(IO::Socket::Async $socket, Supplier $supplier, Channel $payload_tube) {
    my $msgbuf = Buf.new;
    my $gotHeader = False;
    my $verb = "";
    my $payload_len = 0;
    $socket.Supply(:bin).tap( -> $buf {
      $msgbuf.append($buf);
      if !$gotHeader {
        if $msgbuf.elems >= 24 {
          my $header = bufTrim($msgbuf, 24);
          my @header = decodeHeader($header);
          $verb = @header[0];
          $payload_len = @header[1];
          $gotHeader = True;
          say "Verb: {$verb}  Payload size: {$payload_len}";
        }
      }
      if $msgbuf.elems >= $payload_len {
        my $payload = bufTrim($msgbuf, $payload_len);
          say "Payload actual: {$payload.elems}  Payloa expected: {$payload_len}";
        $gotHeader = False;
        #payload processing
        $payload_tube.send($payload);
        $supplier.emit($verb);
      }
    });
}

sub bufTrim($msgbuf, $payload_len) {
  my $payload = $msgbuf.subbuf(0, $payload_len);
  subbuf-rw($msgbuf, 0, $payload_len) = Buf.new;
  $payload
}
