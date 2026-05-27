#!/usr/local/bin/perl

#--------------------------------------------------------------
# UTF-8対応 日本語表示可能な16進ダンプツール
#  ※※※曖昧幅全角(2文字)設定済みの端末エミュレータ専用※※※
#--------------------------------------------------------------

# Perl初期設定
use strict;

use utf8 ;
binmode STDOUT,":encoding(UTF-8)";

use FindBin;
use File::Spec;

# スクリプト初期設定
my $fn = "jhexdump" ;
my $conf = File::Spec->catfile($FindBin::Bin, "$fn.conf");

# 文字セット定義ファイルをハッシュに読み込む
my %unicode_table;

open(my $IN, '<', "$conf") or die "Cannot open $conf: $!";

while (my $line = <$IN>) {
	chomp $line;

	$line =~ s/#.*$//;			# コメント除去(行末コメントにも対応)
	$line =~ s/^\s+|\s+$//g;	# トリム(スペースなどを削除)
	next if $line eq '';		# 空行スキップ

	my ($code_hex, $width) = split /\s+/, $line;	# unicode, 表示幅 1=半角／2=全角(区切り文字はスペース)
	my $code = hex($code_hex);
	$unicode_table{$code} = $width;
}

close($IN);

# 引数チェック
my $filename = $ARGV[0];
if ($filename eq "") {
	print "usage: jhexdump.pl filename\n";
	exit;
}

# ファイルの読み込み
open(my $IN, "<:raw", $filename) or die "file open error.\n";

# ファイルサイズ取得
my $size = -s $IN;

# 16バイトごとに処理する
for (my $offset = 0; $offset < $size; $offset = $offset + 16) {

	seek($IN, $offset, 0);

	my $read_bytes = read($IN, my $buf, 19); # UTF-8対応のため19バイト分読み込む

	printf("%08x  ", $offset);

	my @bytes = unpack("C*", $buf);

	# 16進表示部分(左側)
	for (my $i = 0; $i < 16; $i++) {

		if ($i < $read_bytes) {
			printf("%02x ", $bytes[$i]);
		}
		else {
			print "   ";
		}

		if ($i == 7) {
			print " ";
		}
	}

	print " |";

	# 文字表示部分(右側)
	for (my $i = 0; $i < $read_bytes; $i++) {

		my $b = $bytes[$i];
		my $b1 = $bytes[$i+1];
		my $b2 = $bytes[$i+2];
		my $b3 = $bytes[$i+3];

		# ASCIIの場合(1バイト半角の場合)
		if ($b >= 0x20 && $b <= 0x7E) {
			print chr($b);
			if ($i >= 15) { last }
		}

		# 制御文字の場合
		elsif ($b <= 0x1F || $b == 0x7F) {
			print ".";
			if ($i >= 15) { last }
		}

		# UTF-8 2バイト文字の場合(文字セット定義ファイルにないものは〓とする)
		elsif ($b >= 0xC2 && $b <= 0xDF && $b1 >= 0x80 && $b1 <= 0xBF) {
			my $code = (($b & 0x1F) << 6) | ($b1 & 0x3F);
			if (is_use($code) == 2) { # 全角
				print chr($code) ;
			}
			elsif (is_use($code) == 1) { # 半角
				print chr($code) . "." ;
			}
			else {
				print "〓";
			}
			$i = $i + 1;
			if ($i >= 15) { last }
		}

		# UTF-8 3バイト文字の場合(文字セット定義ファイルにないものは〓とする)
		elsif ($b >= 0xE0 && $b <= 0xEF && $b1 >= 0x80 && $b1 <= 0xBF && $b2 >= 0x80 && $b2 <= 0xBF) {
			my $code = (($b & 0x0F) << 12) | (($b1 & 0x3F) << 6) | ($b2 & 0x3F);
			if (is_use($code) == 2) { # 全角
				if ($i >= 14) {
					print chr($code) ;
				}
				else {
					print chr($code) . ".";
				}
			}
			elsif (is_use($code) == 1) { # 半角カナなど
				if ($i >= 15) {
					print chr($code) ;
				}
				elsif ($i >= 14) {
					print chr($code) . ".";
				}
				else {
					print chr($code) . "..";
				}
			}
			else {
				if ($i >= 14) {
					print "〓";
				}
				else {
					print "〓.";
				}
			}
			$i = $i + 2;
			if ($i >= 15) { last }
		}

		# UTF-8 4バイト文字の場合(文字セット定義ファイルにないものは〓とする)
		elsif ($b >= 0xF0 && $b <= 0xF4 && $b1 >= 0x80 && $b1 <= 0xBF && $b2 >= 0x80 && $b2 <= 0xBF && $b3 >= 0x80 && $b3 <= 0xBF) {
			my $code = (($b & 0x07) << 18) | (($b1 & 0x3F) << 12) | (($b2 & 0x3F) << 6)  | ($b3 & 0x3F);
			if (is_use($code)) {
				if ($i >= 14) {
					print chr($code) ;
				}
				elsif ($i == 13) {
					print chr($code) . "." ;
				}
				else {
					print chr($code) . ".." ;
				}
			}
			else {
				if ($i >= 14) {
					print "〓" ;
				}
				elsif ($i == 13) {
					print "〓." ;
				}
				else {
					print "〓.." ;
				}
			}
			$i = $i + 3;
			if ($i >= 15) { last }
		}

		# その他の文字
		else {
			print ".";
			if ($i >= 15) { last }
		}
	}

	print "|\n";
}

close($IN);

exit;

#--------------------------------------------------------------
# サブルーチン：is_use 使用可能文字判定 兼 表示幅取得
#--------------------------------------------------------------
sub is_use {
	my ($code) = @_;
	return $unicode_table{$code};
}
