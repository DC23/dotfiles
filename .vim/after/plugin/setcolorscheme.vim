if has('gui_running')
    color solarized
elseif has('win32') || has('win64')
    "xoriadark looks terrible in a DOS shell
    color default
else
    set background=dark
    color solarized
endif
