use v6.c;
use Digest::SHA;

sub push($verb, $payload) is export {
  my $hello = Buf.new(0xf9, 0xbe, 0xb4, 0xd9); # Bitcoin Mainnet
  say "hello ", $hello;
  my $command = strPad($verb);
  say "command ", $command;
  my $payload_length = Buf.new(0x00, 0x00, 0x00, 0x00); #length
  say "payload_length ", $payload_length;
  say "payload ", $payload;
  

  my $payload_checksum = sha256(sha256($payload)).subbuf(0,4);
  say "payload_checksum ", $payload_checksum;

  my $msg = Buf.new();
  $msg.append($hello.reverse);
  $msg.append($command);
  $msg.append($payload_length.reverse);
  $msg.append($payload_checksum.reverse);
}

sub strPad(Str $s) {
  Buf.new($s.encode('ISO-8859-1')).reallocate(12);
}

