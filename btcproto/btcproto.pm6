use v6.c;
use Digest::SHA;
use Numeric::Pack :ALL;

sub push($verb, $payload) {
  my $hello = Buf.new(0xf9, 0xbe, 0xb4, 0xd9); # Bitcoin Mainnet
  say "hello ", $hello;
  my $command = strPad($verb);
  say "command ", $command;
  my $payload_length = int32Buf($payload.elems);
  say "payload_length ", $payload_length;
  say "payload ", $payload;
  

  my $payload_checksum = sha256(sha256($payload)).subbuf(0,4);
  say "payload_checksum ", $payload_checksum;

  my $msg = Buf.new();
  $msg.append($hello);
  $msg.append($command);
  $msg.append($payload_length);
  $msg.append($payload_checksum);
  $msg.append($payload);
}

sub strPad(Str $s) {
  Buf.new($s.encode('ISO-8859-1')).reallocate(12);
}

sub int32Buf($int) {
  pack-int32 $int, :byte-order(little-endian);;
}

sub int64Buf($int) {
  pack-int64 $int, :byte-order(little-endian);;
}

sub strToBuf($s) {
  my $buf = Buf.new();
  $buf.append($s.chars);
  $buf.append($s.encode('ISO-8859-1'));
  $buf;
}


sub netAddress($addr) {
  Buf.new(0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
}

sub version is export {
  my $payload = Buf.new();
  #$payload.append(int32Buf(70004)); #version
  $payload.append(int32Buf(60002)); #version
  $payload.append(int64Buf(1)); #services
  #$payload.append(int64Buf(1521609933)); #timestamp
  $payload.append(Buf.new(0x11, 0xB2, 0xD0, 0x50, 0, 0, 0, 0)); #timestamp
  $payload.append(netAddress("127.0.0.1")); #Recipient
  $payload.append(netAddress("127.0.0.1")); #Sender
  #$payload.append(int64Buf(1521609933)); #nodeID/nonce
  $payload.append(Buf.new(0x3B, 0x2E, 0xB3, 0x5D, 0x8C, 0xE6, 0x17, 0x65)); #nodeID/nonce
  $payload.append(strToBuf("/Satoshi:0.7.2/")); #client version string
  $payload.append(int32Buf(212672)); #blockheight
  push("version", $payload);
}

sub getinfo is export {
  push("getinfo", Buf.new());
}
