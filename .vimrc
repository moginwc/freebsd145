set tabstop=4
set ambiwidth=double
set ignorecase
set ruler
syntax on
set clipboard=unnamedplus

"augroup Mouse
"  autocmd!
"  autocmd BufReadPost * if &readonly | set mouse=n | map <2-RightMouse> :q<CR> | endif
"augroup END

"if &diff
"    highlight DiffAdd ctermbg=195
"    highlight DiffDelete ctermbg=224 ctermfg=224
"    highlight DiffChange ctermbg=194
"    highlight DiffText cterm=NONE ctermbg=121 ctermfg=16 
"    highlight Folded cterm=NONE ctermfg=246 ctermbg=255
"    highlight FoldColumn cterm=NONE ctermfg=246 ctermbg=255
"endif
