if has('gui_running')
    if hostname() == 'belkar'
        call Enbiggen()
    else
        set lines=67
        set columns=165
    endif
endif
