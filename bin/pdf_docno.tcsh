#!/bin/tcsh

set strings = "技26-001"

# 文書番号のみのPDFファイルを作成する
gs -q -dBATCH -dNOPAUSE -sDEVICE=pdfwrite \
   -sPAPERSIZE=a4 \
   -sOutputFile=docno.pdf - << EOF

  2.834645669 2.834645669 scale %単位をmmにする
  /IPAGothic-UniJIS-UTF8-H findfont 6.35 scalefont setfont

  10 283 moveto
  ($strings) show

  showpage
EOF

# 元のPDFファイルと、文書番号のPDFファイルを合成する
qpdf in.pdf --overlay docno.pdf -- out.pdf
