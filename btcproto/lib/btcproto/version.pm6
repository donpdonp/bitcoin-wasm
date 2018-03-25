use Numeric::Pack :ints;
use experimental :pack;

module btcproto::version {
  class Version {
    has Str $.addr_recv;
    has Str $.addr_from;
    has Str $.user_agent;
    has Int $.block_height;

    method fromBuf(Buf $b) {
      $!addr_recv = $b.subbuf(20, 26).perl;
      $!addr_from = $b.subbuf(46, 26).perl;
      my $strlen = $b[80];
      $!user_agent = btcproto::bufToStr($b.subbuf(81, $strlen));
      my $block_height_buf = $b.subbuf(81+$strlen, 4);
      $!block_height = $block_height_buf.unpack("L")
    }
  }
}
