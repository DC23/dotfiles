if has('gui_running')
    color xoriadark
elseif has('win32') || has('win64')
    "xoriadark looks terrible in a DOS shell
    color default
else
    color xoriadark
endif
