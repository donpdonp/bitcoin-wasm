use v6.c;
use Digest::SHA;
use Numeric::Pack :ints;

module btcproto {

sub push($verb, $payload) {
  my $hello = Buf.new(0xf9, 0xbe, 0xb4, 0xd9); # Bitcoin Mainnet
  my $command = strPad($verb);
  my $payload_length = int32Buf($payload.elems);

  my $payload_checksum = sha256(sha256($payload)).subbuf(0,4);

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
  pack-uint32 $int, :byte-order(little-endian);;
}

sub int64Buf($int) {
  pack-uint64 $int, :byte-order(little-endian);;
}

sub strToBuf($s) {
  my $buf = Buf.new();
  $buf.append($s.chars);
  $buf.append($s.encode('ISO-8859-1'));
  $buf;
}


sub netAddress($addr) {
  Buf.new(0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 
          0x0a, 0x00, 0x00, $addr, 0x20, 0x8D)
}

sub version is export {
  my $payload = Buf.new();
  $payload.append(int32Buf(70004)); #version
  $payload.append(int64Buf(7)); #services
  $payload.append(int64Buf(1521609933)); #timestamp
  $payload.append(netAddress(1)); #Recipient
  $payload.append(netAddress(2)); #Sender
  #$payload.append(int64Buf(1521609933)); #nodeID/nonce
  $payload.append(Buf.new(0x3B, 0x2E, 0xB3, 0x5D, 0x8C, 0xE6, 0x17, 0x65)); #nodeID/nonce
  $payload.append(strToBuf("/Satoshi:0.7.2/")); #client version string
  $payload.append(int32Buf(212672)); #blockheight
  push("version", $payload);
}

sub getinfo is export {
  push("getinfo", Buf.new());
}

sub networkName(Buf $id) {
  "Bitcoin mainnet" if $id == Buf.new(0xf9, 0xbe, 0xb4, 0xd9);
}

sub command($strZ) {
  $strZ.decode('ISO-8859-1')
}

sub decodeHeader(Buf $buf) is export {
  say "Response:", $buf;
  #unpack-uint32 $buf.subbuf(16,4), :byte-order(little-endian);
  my $rlen = $buf[16].Int;
  say networkName($buf.subbuf(0,4)), " Command:", command($buf.subbuf(4,12)), " Len:", $rlen;
  $rlen
}

}
