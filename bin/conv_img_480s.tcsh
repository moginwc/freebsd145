#!/bin/tcsh

# 長辺を480pxにリサイズする。画像をシャープネスする。

foreach fn ($argv)
    magick "${fn}" \
		-resize 480x480\> \
		-unsharp 1.5x1.0+0.1 \
		~/work/`basename ${fn}`
end
