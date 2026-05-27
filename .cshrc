#
# .cshrc - csh resource script, read at beginning of execution by each shell
#
# see also csh(1), environ(7).
# more examples available at /usr/share/examples/csh/
#

alias h		history 25
alias j		jobs -l
alias la	ls -aF
alias lf	ls -FA
alias ll	ls -lAF

alias l		'ls -l | more -e'
alias ll	'ls -la | more -e'
alias vi	vim
alias rm	'rm -i'

# wineサンプル
#wine#alias bz       'wine ~/wine_bin/Bz/Bz64.exe'
#wine#alias hidemaru 'wine ~/.wine/drive_c/Program\ Files/Hidemaru/Hidemaru.exe'
#wine#alias winmerge 'wine ~/.wine/drive_c/Program\ Files/WinMerge/WinMergeU.exe'
#wine#alias cd32     'cd ~/.wine/drive_c/Program\ Files\ \(x86\)'
#wine#alias cd64     'cd ~/.wine/drive_c/Program\ Files'

# These are normally set through /etc/login.conf.  You may override them here
# if wanted.
set path = (/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin $HOME/bin)
# A righteous umask
umask 27

setenv	EDITOR	vi
setenv	PAGER	less

if ($?prompt) then
	# An interactive shell -- set some stuff up
	set prompt = "%N@%m:%~ %# "
	set promptchars = "%#"

	set filec
	set history = 1000
	set savehist = (1000 merge)
	set autolist = ambiguous
	# Use history to aid expansion
	set autoexpand
	set autorehash
	set mail = (/var/mail/$USER)
	if ( $?tcsh ) then
		bindkey "^W" backward-delete-word
		bindkey -k up history-search-backward
		bindkey -k down history-search-forward
	endif

endif
