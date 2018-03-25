use v6;
use btcproto;

module btcproto::net {

our sub dispatch($inmsg, $socket, $payload_tube) {
    if $inmsg eq "connect" {
      my $protoversion = 100004;
      my $useragent = "/perl6:0.0.1/";
      my $msg = version($protoversion, $useragent, 500000);
      say "send version {$protoversion} {$useragent} payload {$msg.elems-24}";
      $socket.write($msg);
    }

    if $inmsg eq "version" {
      my $payload = $payload_tube.receive;
      my $v = btcproto::version::Version.new;
      $v.fromBuf($payload);
      say "Connected to: {$v.user_agent} #{$v.block_height}";

      my $msg = verack;
      say "send verack";
      $socket.write($msg);
    }

    if $inmsg eq "verack" {
      my $msg = getinfo;
      say "send getinfo";
      $socket.write($msg);
    }
}

our sub read_loop(IO::Socket::Async $socket, Supplier $supplier, Channel $payload_tube) {
    my $msgbuf = Buf.new;
    my $gotHeader = False;
    my $verb = "";
    my $payload_len = 0;
    $socket.Supply(:bin).tap( -> $buf {
      $msgbuf.append($buf);
      if !$gotHeader {
        if $msgbuf.elems >= 24 {
          my $header = bufTrim($msgbuf, 24);
          my @header = btcproto::decodeHeader($header);
          $verb = @header[0];
          $payload_len = @header[1];
          $gotHeader = True;
          say "Verb: {$verb}  Payload size: {$payload_len}";
        }
      }
      if $msgbuf.elems >= $payload_len {
        my $payload = bufTrim($msgbuf, $payload_len);
          say "Payload length {$payload.elems}/{$payload_len}";
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

}