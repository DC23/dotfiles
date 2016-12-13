if has('gui_running')
    set background=dark
    color Tomorrow-Night
elseif has('win32') || has('win64')
    "xoriadark looks terrible in a DOS shell
    color default
else
    set background=dark
    color Tomorrow-Night
endif
