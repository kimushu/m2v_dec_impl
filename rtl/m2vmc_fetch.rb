#!/usr/bin/env ruby
#================================================================================
# MC用Fetchメモリ初期化ファイル生成スクリプト(すべて0)
# $Id$
#================================================================================

puts(<<EOD)
DEPTH = 128;
WIDTH = 8;
ADDRESS_RADIX = HEX;
DATA_RADIX = BIN;
CONTENT
BEGIN
EOD
128.times {|a| puts("%02X : 00000000;" % a) }
puts("END;")

