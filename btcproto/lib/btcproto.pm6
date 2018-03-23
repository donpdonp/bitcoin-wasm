use v6.c;
use Digest::SHA256::Native;
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

sub decodeVersion($b) is export {
  my $s = $b.subbuf(81, $b[80]);
  bufToStr($s);
}

sub verack is export {
  my $payload = Buf.new();
  push("verack", $payload);
}

sub version($version, $user_agent, $blockheight) is export {
  my $payload = Buf.new();
  $payload.append(int32Buf($version)); #version
  $payload.append(int64Buf(7)); #services
  $payload.append(int64Buf(DateTime.now.posix)); #timestamp
  $payload.append(netAddress(1)); #Recipient
  $payload.append(netAddress(2)); #Sender
  $payload.append(int64Buf(1521609933)); #nodeID/nonce
  $payload.append(strToBuf($user_agent)); #client version string
  $payload.append(int32Buf($blockheight)); #blockheight
  push("version", $payload);
}

sub getinfo is export {
  push("getinfo", Buf.new());
}

sub networkName(Buf $id) {
  "Bitcoin" if $id == Buf.new(0xf9, 0xbe, 0xb4, 0xd9);
}

sub bufToStr($buf) {
  join "", $buf.map: { last when 0; $_.chr  }
}

our sub decodeHeader(Buf $buf) {
  #unpack-uint32 $buf.subbuf(16,4), :byte-order(little-endian);
  my $rlen = $buf[16].Int;
  my $command = bufToStr($buf.subbuf(4,12));
  say "[{networkName($buf.subbuf(0,4))}] Command: {$command} PayloadLen: {$rlen}";
  [$command, $rlen]
}

}
