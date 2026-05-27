#!/bin/tcsh

# 元のPDFファイルの総ページ数を把握する
set total = `qpdf --show-npages in.pdf`

# ページ番号のみのPDFファイルを作成する
gs -q -dBATCH -dNOPAUSE -sDEVICE=pdfwrite \
   -sPAPERSIZE=a4 \
   -sOutputFile=pageno.pdf - << EOF

1 1 $total {
  2.834645669 2.834645669 scale
  /Times-Roman findfont 3.5 scalefont setfont

  /pageno exch def
  200 287 moveto
  pageno 3 string cvs show

  showpage
} for
EOF

# 元のPDFファイルと、ページ番号のみのPDFファイルを合成する
qpdf in.pdf --overlay pageno.pdf -- out.pdf
