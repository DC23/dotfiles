"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Daniel Collins
" Vim configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Utility Functions:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! Enbiggen()
    set columns=200
    set lines=78
endfunction

function! EnsureExists(path)
    if !isdirectory(expand(a:path))
        call mkdir(expand(a:path))
    endif
endfunction

function! VisualSelection(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

function! Preserve(command) "{{{
    " preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    execute a:command
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction "}}}

function! StripTrailingWhitespace() "{{{
    call Preserve("%s/\\s\\+$//e")
endfunction "}}}

function! CloseWindowOrKillBuffer() "{{{
    let number_of_windows_to_this_buffer = len(filter(range(1, winnr('$')), "winbufnr(v:val) == bufnr('%')"))

    " never bdelete a nerd tree
    if matchstr(expand("%"), 'NERD') == 'NERD'
        wincmd c
        return
    endif

    if number_of_windows_to_this_buffer > 1
        wincmd c
    else
        bdelete
    endif
endfunction

" Used on windows to manually set the cygwin shell. On some of my windows
" systems, Vundle doesn't work with the Cmd shell. I don't want to set Cygwin as
" the default though, as other functionality doesn't work with it.
function! SetShell(sh)
    if a:sh == 'c'
        set shell=C:/cygwin/bin/bash
        set shellcmdflag=--login\ -c
        set shellxquote=\"
        let s:shell_cygwin=1
    elseif a:sh == 'w'
        set shell=C:\\Windows\\System32\\cmd.exe
        set shellcmdflag=/c
        set shellxquote=(
        let s:shell_cygwin=0
    endif
endfunction

function! VO2MD()
    let lines = []
    let was_body = 0
    for line in getline(1,'$')
        if line =~ '^\t*[^:\t]'
            let indent_level = len(matchstr(line, '^\t*'))
            if was_body " <= remove this line to have body lines separated
                call add(lines, '')
            endif " <= remove this line to have body lines separated
            call add(lines, substitute(line, '^\(\t*\)\([^:\t].*\)', '\=repeat("#", indent_level + 1)." ".submatch(2)', ''))
            call add(lines, '')
            let was_body = 0
        else
            call add(lines, substitute(line, '^\t*: ', '', ''))
            let was_body = 1
        endif
    endfor
    silent %d _
    call setline(1, lines)
endfunction

function! MD2VO()
    let lines = []
    for line in getline(1,'$')
        if line =~ '^\s*$'
            continue
        endif
        if line =~ '^#\+'
            let indent_level = len(matchstr(line, '^#\+')) - 1
            call add(lines, substitute(line, '^#\(#*\) ', repeat("\<Tab>", indent_level), ''))
        else
            call add(lines, substitute(line, '^', repeat("\<Tab>", indent_level) . ': ', ''))
        endif
    endfor
    silent %d _
    call setline(1, lines)
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Environment:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:is_windows = has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_unix = has('unix')

if s:is_unix
    set fileformat="unix"
else
    set fileformat="dos"
endif

set nocompatible
set background=dark

if !s:is_windows
    set term=$TERM " Make arrow and other keys work
endif

" On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
" across (heterogeneous) systems easier.
if s:is_windows
    set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
endif

" If Vundle is not present, then install it.
" Doesn't work on windows due to the path expansions not expanding
" On Windows, Vundle has to be installed manually :(
if !s:is_windows
    let iCanHazVundle=1
    let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
    if !filereadable(vundle_readme)
        echo "Installing Vundle.."
        echo ""
        silent !mkdir -p ~/.vim/bundle
        silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
        let iCanHazVundle=0
    endif

    " Autoinstall bundles if this is a new setup
    if iCanHazVundle == 0
        echo "Installing Plugins, please ignore key map error messages"
        echo ""
        :PluginInstall
    endif
endif

filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Vim Folder Management:
" persistent undo
if exists('+undofile')
    set undofile
    set undodir=~/.vim/cache/undo
endif

" backups
set backup
set backupdir=~/.vim/cache/backup

" swap files
set directory=~/.vim/cache/swap
set swapfile

call EnsureExists('~/.vim/cache')
if exists('+undofile')
    call EnsureExists(&undodir)
endif
call EnsureExists(&backupdir)
call EnsureExists(&directory)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Gitgutter: Shows Git status in the Vim gutter
Plugin 'airblade/vim-gitgutter'

" Pytest: Runs pytest unit tests from inside Vim
Plugin 'alfredodeza/pytest.vim'

" Airline: fancy status line
Plugin 'bling/vim-airline'
    let g:airline_powerline_fonts = 1

" Bufferline: fancy buffer manager
Plugin 'bling/vim-bufferline'
    let g:bufferline_echo = 1

" Autoformat: Code formatting via external programs such as clang-format and
" astyle
if (has('python') || has('python3')) && version >= 704
    Plugin 'Chiel92/vim-autoformat'
endif

" Jedi Vim: based on pythoncomplete, promises more up to date python handling
" After installation, you must run 'git submodule update --init' in your jedi-vim repository.
" Default bindings:
" let g:jedi#pydoc = "K"  " shows pydocs
" let g:jedi#get_definition_command = "<leader>d"
" let g:jedi#goto_command = "<leader>g"
" let g:jedi#related_names_command = "<leader>n"
if (has('python') || has('python3'))
    Plugin 'davidhalter/jedi-vim'
    let g:jedi#rename_command = "<leader><leader>r"
    let g:jedi#auto_vim_configuration = 0
    let g:jedi#popup_select_first = 0
    let g:jedi#completions_enabled = 0
endif

" Easygrep: improved usability of multifile search and replace.
Plugin 'dkprice/vim-easygrep'

" Fontsize: interactive gvim font size changes
" <Leader><Leader>+ to enter increase mode. Subsequent + keys increase further
" <Leader><Leader>- to decrease font size.
Plugin 'drmikehenry/vim-fontsize'

" SuperTab: <tab> does autocomplete
Plugin 'ervandew/supertab'
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<c-x><c-u>"
let g:SuperTabDefaultCompletionTypeDiscovery = ["&omnifunc:<c-x><c-o>","&completefunc:<c-x><c-n>"]
let g:SuperTabClosePreviewOnPopupClose = 1
let g:SuperTabCrMapping = 0
let g:SuperTabNoCompleteAfter = ['^',',','\s']
let g:SuperTabLongestHighlight=0

" Vundle:
Plugin 'gmarik/vundle'

" CSApprox: better colors in terminal vim
if version >= 703
    " Also has a script in 'after' to set the color scheme at start, forcing this plugin to run
    Plugin 'godlygeek/csapprox'
    " IMPORTANT: Uncomment one of the following lines to force
    " using 256 colors (or 88 colors) if your terminal supports it,
    " but does not automatically use 256 colors by default.
    set t_Co=256
    "set t_Co=88
    let g:CSApprox_attr_map = { 'bold' : 'bold', 'italic' : '', 'sp' : '' }
endif

" Tabular: text alignment
" Basic usage is
" :Tabularize /= to align on = sign (use any character)
Plugin 'godlygeek/tabular'

" Xterm Color Table:
" Provides command :XtermColorTable, as well as variants for different splits
" Xterm numbers on the left, equivalent RGB values on the right
" Press # to yank current color (shortcut for yiw)
" Press t to toggle RGB text visibility
" Press f to set RGB text to current color
Plugin 'guns/xterm-color-table.vim'

" Honza Snippet Collection: large and actively developed snippet collection that
" works with neosnippet
Plugin 'honza/vim-snippets'

" Buffergator: list, select and switch between buffers
" F5 to open buffer window
" o: open buffer in current window
" O: same as o, but keeps focus in buffer list
" s: open buffer in new vertical split
" i: open buffer in new horizontal split
" In buffer window:
" <space>, <c-space>: cycle through buffer preview
" cs: cycle sort modes
" cd: cycle display modes
" cw: cycle window split modes
" d: delete selected buffer
" r: refresh buffer list
Plugin 'jeetsukumaran/vim-buffergator'
let g:buffergator_suppress_keymaps = 1 " suppress the default keymaps, as they conflict with other mappings
let g:buffergator_viewport_split_policy = "B"
let g:buffergator_sort_regime = "mru"
let g:buffergator_display_regime = "basename"
let g:buffergator_autoexpand_on_split = 0
let g:buffergator_split_size = 7
map <F5> :BuffergatorToggle<cr>

" Signature: toggle, display, and navigate marks
" m[a-zA-Z]    : Toggle mark
" m<Space>     : Delete all marks
Plugin 'kshenoy/vim-signature'
let g:SignatureEnabledAtStartup = 1
nnoremap <silent><leader>ms :SignatureToggleSigns<cr>

" Easymotion: <leader><leader>motion to activate
Plugin 'Lokaltog/vim-easymotion'
let g:EasyMotion_do_shade = 1

" Tagbar: tag navigation made better
if version >= 700
    Plugin 'majutsushi/tagbar'
    let tagbar_left = 1
    let g:tagbar_autofocus = 1
    let g:tagbar_autoclose = 1
    let g:tagbar_show_linenumbers = -1
    nnoremap <silent> <F6> :TagbarToggle<CR>

    " Add Tagbar support for IDL files (via the ctags extensions in .ctags)
    let g:tagbar_type_idlang = {
                \ 'ctagstype' : 'IDL',
                \ 'kinds' : [
                \ 'p:Procedures',
                \ 'f:Functions',
                \ 'c:Common Blocks'
                \ ]
                \ }

    " Add makefile targets to the already supported macros
    let g:tagbar_type_make = {
                \ 'kinds':[
                \ 'm:macros',
                \ 't:targets'
                \ ]
                \}

    " Markdown support
    let g:tagbar_type_markdown = {
                \ 'ctagstype' : 'Markdown',
                \ 'kinds' : [
                \ 'h:Heading 1',
                \ 'i:Heading 2',
                \ 'k:Heading 3',
                \ 'f:Heading 4'
                \ ]
                \ }
endif

" Vim Indent Guides: visual display of indentation levels
" Toggle display: <leader>ig
if version >= 702
    Plugin 'nathanaelkane/vim-indent-guides'
    let g:indent_guides_start_level = 2
    let g:indent_guides_guide_size = 1
    let g:indent_guides_auto_colors = 0
    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#3a3a3a ctermbg=237
    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#585858 ctermbg=240
endif

" DelimitMate: insert mode auto-completion for quotes, parens, brackets, etc
Plugin 'Raimondi/delimitMate'

" Conflict Marker: Highlight, navigate, and resolve conflicts
" ]x - next conflict
" [x - previous conflict
" ct - use theirs
" co - use ours/mine
" cn - use none
" cb - use both
Plugin 'rhysd/conflict-marker.vim'

" NERDCommenter: source code commenting.
" all commands start with [count]<leader>c
" <space>: toggles comments in selected text
" l,b: aligns comments on left or both sides
" s: sexy comments
" i: inverts comments. The behaviour I expected from toggle, with each
"    line treated individually.
" c: comment
Plugin 'scrooloose/nerdcommenter'
let g:NERDCustomDelimiters = {
            \ 'python': { 'left': '# ' },
            \ }

" NERDtree: slide-out file explorer
if version >= 703
    Plugin 'scrooloose/nerdtree'
    " close vim if the nerdtree buffer is the only one left
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
    map <F7> :NERDTreeToggle<cr>
    map <S-F7> :NERDTreeFind<cr>
    let NERDTreeIgnore=[ '\.pyc', '\~$', '\.swo$', '\.swp$', '\.hg', '\.svn', '\.bzr', '\.os' ]
    let NERDChristmasTree = 1
    let NERDTreeShowLineNumbers = 1
    let NERDTreeWinPos = "left"
    let NERDTreeWinSize = 45
    let NERDTreeMinimalUI = 1
    let NERDTreeQuitOnOpen = 1
endif

" Syntastic: runs source code through external syntax checkers
" check the files in the syntax_checkers directory for details of the required
" checkers.
" By default, files are checked when first opened, and when a buffer is saved.
Plugin 'scrooloose/syntastic'
let g:syntastic_mode_map = {
    \ "mode": "passive",
    \ "passive_filetypes": ["py", "cpp"] }

" Neocomplete: completion framework
" tab to show and cycle through completions
" C-l to complete common strings
" C-e to cancel completion popup
"if has("lua") && version > 703
    "Plugin 'Shougo/neocomplete.vim'
    "let g:neocomplete#enable_auto_select = 0
    "let g:neocomplete#enable_at_startup = 1
    "let g:neocomplete#enable_smart_case = 1
    "let g:neocomplete#sources#syntax#min_keyword_length = 3
    "let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
    "let g:neocomplete#data_directory = '~/.vim/cache/neocomplete'

    "if !exists('g:neocomplete#keyword_patterns')
        "let g:neocomplete#keyword_patterns = {}
    "endif
    "let g:neocomplete#keyword_patterns['default'] = '\h\w*'

    "inoremap <expr><C-g>    neocomplete#undo_completion()
    "inoremap <expr><C-l>    neocomplete#complete_common_string()
    "inoremap <expr><CR>     neocomplete#complete_common_string()

    "" <CR>: close popup and save indent.
    "inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    "function! s:my_cr_function()
        "return neocomplete#close_popup() . "\<CR>"
        "" For no inserting <CR> key.
        ""return pumvisible() ? neocomplete#close_popup() : "\<CR>"
    "endfunction

    "" <TAB>: completion.
    "inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    ""<C-h>, <BS>: close popup and delete backword char.
    "inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    "inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    "inoremap <expr><C-y>  neocomplete#close_popup()
    "inoremap <expr><C-e>  neocomplete#cancel_popup()"
"else
    " falling back to neocompletecache
    Plugin 'Shougo/neocomplcache.vim'
    let g:neocomplcache_enable_at_startup=1
    let g:neocomplcache_temporary_dir='~/.vim/cache/neocomplcache'
    let g:neocomplcache_enable_fuzzy_completion=1
    let g:neocomplcache_enable_smart_case = 1
    let g:neocomplcache_min_syntax_length = 3
    let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

    " Define keyword.
    if !exists('g:neocomplcache_keyword_patterns')
        let g:neocomplcache_keyword_patterns = {}
    endif
    let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplcache#undo_completion()
    inoremap <expr><C-l>     neocomplcache#complete_common_string()
    inoremap <expr><CR>      neocomplcache#complete_common_string()

    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
        return neocomplcache#smart_close_popup() . "\<CR>"
        " For no inserting <CR> key.
        "return pumvisible() ? neocomplcache#close_popup() : "\<CR>"
    endfunction

    " <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    "<C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
    "inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y>  neocomplcache#close_popup()
    inoremap <expr><C-e>  neocomplcache#cancel_popup()
"endif

" NeoSnippet: snippets with neocomplete integration
" C-k: select and expand a snippet from the neocomplete popup
" C-k: jump to next field in the snippet
" tab: select/jump to next field
Plugin 'Shougo/neosnippet.vim'
Plugin 'Shougo/neosnippet-snippets'
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)
" SuperTab like snippets behavior.
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: "\<TAB>"

" For snippet_complete marker.
if has('conceal')
    set conceallevel=2 concealcursor=i
endif

" Enable snipMate compatibility feature.
"let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
"let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

" Gundo: visualise the vim undo tree
if version >= 703
    Plugin 'sjl/gundo.vim'
    nnoremap <F9> :GundoToggle<CR>
endif

" Repeat: Adds repeat support to many plugins
Plugin 'tpope/vim-repeat'

" SpeedDating: Adds time and date support to vim number increment/decrement
" operations (C-a, C-x)
Plugin 'tpope/vim-speeddating'

" VimSurround: handling of "surroundings": quotes, brackets etc
if version >= 700
    Plugin 'tpope/vim-surround'
endif

" VimOutliner:
Plugin 'vimoutliner/vimoutliner'

" DoxygenToolkit: doxygen functionality
" :DoxLic - generate license comment
" :DoxAuthor - generate author skeleton
" :Dox - generate function/class comment. Cursor needs to be on the line
"        of the function header or class.
" :DoxBlock - insert doxygen block on next line
Plugin 'vim-scripts/DoxygenToolkit.vim'
let g:load_doxygen_syntax=1
let g:DoxygenToolkit_authorName="Daniel Collins (daniel.collins@csiro.au)"
let g:DoxygenToolkit_briefTag_pre = "@brief "
let g:DoxygenToolkit_briefTag_post = ""
let g:DoxygenToolkit_templateParamTag_pre = "@tparam "
let g:DoxygenToolkit_templateParamTag_post = ""
let g:DoxygenToolkit_paramTag_pre = "@param "
let g:DoxygenToolkit_paramTag_post = ""
let g:DoxygenToolkit_returnTag = "@return "
let g:DoxygenToolkit_throwTag_pre = "@throw " " @exception is also valid
let g:DoxygenToolkit_throwTag_post = ""
let g:DoxygenToolkit_blockHeader = ""
let g:DoxygenToolkit_blockFooter = ""
let g:DoxygenToolkit_fileTag = "@file "
let g:DoxygenToolkit_authorTag = "@author "
let g:DoxygenToolkit_dateTag = "@date "
let g:DoxygenToolkit_versionTag = "@version "
let g:DoxygenToolkit_blockTag = "@name "
let g:DoxygenToolkit_classTag = "@class "
let g:DoxygenToolkit_commentType = "C++"  " Use // instead of /** .. */

" TaskList: creates a list of todo items from a file
" <Leader>t   Display list.
" q - quit and restore original cursor position
" e - exit and keep window open
" <cr> - quit and jump to selected item
Plugin 'vim-scripts/TaskList.vim'
let g:tlTokenList = ['TODO', 'FIXME', 'XXX', 'todo']

" YankRing: Maintains a history of yanked, deleted and changed text, similar to the Emacs kill ring.
Plugin 'vim-scripts/YankRing.vim'
" control-y shows the yank ring gui
" But I prefer F8
nnoremap <F8> :YRShow<cr>

" ZoomWin: When working with split windows, allows the current window to be
" zoomed and restored
" <c-w>o to zoom the current window to full screen.
" <c-w>o to restore to split windows.
if version >= 702
    Plugin 'vim-scripts/ZoomWin'
endif

" VimWiki: Personal text-based wiki system in Vim, with Markdown support.
Plugin 'mattn/calendar-vim'
Plugin 'vimwiki/vimwiki'

" Store the wiki files and exports in Dropbox
let vimwiki_path='~/Dropbox/vimwiki/'
let vimwiki_export_path='~/Dropbox/vimwiki_exports/'

" Common wiki settings
let wiki_settings={
    \ 'template_path': vimwiki_export_path.'assets/',
    \ 'template_default': 'default',
    \ 'template_ext': '.html',
    \ 'auto_export': 0,
    \ 'nested_syntaxes': {
        \ 'js':'javascript',
    \ }}

" Define all the wikis, with the common settings applied
let wikis=["personal", "stoicism"]
let g:vimwiki_list = []
for wiki_name in wikis
    let wiki=copy(wiki_settings)
    let wiki.path = vimwiki_path.wiki_name.'/'
    let wiki.path_html = vimwiki_export_path.wiki_name.'/'
    let wiki.diary_index = 'index'
    let wiki.diary_rel_path = 'diary/'
    call add(g:vimwiki_list, wiki)
endfor

" QFEnter: restores sanity to opening items from the QuickFix window
" Enter, double-left click: open item in last window
" <leader><enter>: open item in new vertical split
" <leader><space>: open item in new horizontal split
" <leader><tab>: open item in new tab
Plugin 'yssl/QFEnter'
let g:qfenter_open_map = ['<CR>', '<2-LeftMouse>']
let g:qfenter_topen_map = ['<Leader><Tab>']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colours And Fonts:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" the color scheme is set in .vim/after/plugin/setcolorscheme.vim

if has('gui_running')
    if s:is_windows
        set guifont=Consolas:h10:cANSI
    elseif s:is_unix
        "set guifont=Liberation\ Mono\ 10
        set guifont=Monospace\ 10
    endif
endif

" Set terminal color count to 256, as some terminals don't set this by default
set t_Co=256

" vundle managed color schemes
Plugin 'twerth/ir_black'
Plugin 'vim-scripts/tir_black'
Plugin 'vim-scripts/xoria256.vim'
"Plugin 'altercation/vim-colors-solarized'
Plugin 'morhetz/gruvbox'
Plugin 'flazz/vim-colorschemes'
Plugin 'nightsense/office'
Plugin 'nightsense/carbonized'
Plugin 'elmindreda/vimcolors'
Plugin 'hzchirs/vim-material'
Plugin 'tomasiser/vim-code-dark'
Plugin 'lifepillar/vim-solarized8'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language settings for custom file extensions:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.cl set filetype=c



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Required By Vundle:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GUI:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('gui_running')
    " GUI is running or is about to start.
    " Note that the GUI window size is set in the .vim/after/plugin/setsize.vim
    " script.
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tabs Indent And Line Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let tabsize = 4
execute "set tabstop=".tabsize
execute "set shiftwidth=".tabsize
execute "set softtabstop=".tabsize
set expandtab "insert spaces on tab
set autoindent "align new line indent with previous line
set smarttab
set wrap
set formatoptions=qrn1
set backspace=indent,eol,start
set shiftround " round indent to multiple of shiftwidth
set textwidth=80 "lines longer than this will be broken at next whitespace
if version >= 703   " 7.2 and below don't have colorcolumn
    set colorcolumn=80
endif

" sets the smartindent mode for *.py files. It means that after typing lines which
" start with any of the keywords in the list (ie. def, class, if, etc) the next line
" will automatically indent itself to the next level of indentation
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class

set cino=N-s        " Don't indent C++ namespaces


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto Completion Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"set omnifunc=syntaxcomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType cpp,hpp set omnifunc=omni#cpp#complete#Main

" remap control-space to autocomplete when in insert mode
inoremap <C-space> <C-x><C-o>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax enable
set modelines=0
set encoding=utf-8
set scrolloff=3
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
set cursorline
set ttyfast
set shortmess+=filmnrxoOtT " abbreviation of messages (avoids 'hit enter')
set viewoptions=folds,options,cursor,unix,slash " better Unix / windows compatibility
set virtualedit=onemore " allow for cursor beyond last character
set history=1000 " Store a ton of history (default is 20)
set spelllang=en_au
set autowrite "automatic saving of modified buffers in some situations
set ttimeoutlen=50 " reduce the delay when leaving insert mode
set clipboard=unnamed   " syncs the unnamed buffer with the OS clipboard
set autochdir " automatically change window's cwd to file's dir

" Some newer settings
if version >= 703
    set relativenumber
    if version > 703
        " enable hybrid number mode, only in version 7.4+
        set number
    endif
else
    set number
endif

" Folding options
set foldenable
set foldmethod=syntax
set foldlevel=7
let xml_syntax_folding=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ","

" Execute current line in shell
nmap <leader>x :exec '!'.getline('.')<CR>

" Code folding options
nmap <leader>f0 :set foldlevel=0<CR>
nmap <leader>f1 :set foldlevel=1<CR>
nmap <leader>f2 :set foldlevel=2<CR>
nmap <leader>f3 :set foldlevel=3<CR>
nmap <leader>f4 :set foldlevel=4<CR>
nmap <leader>f5 :set foldlevel=5<CR>
nmap <leader>f6 :set foldlevel=6<CR>
nmap <leader>f7 :set foldlevel=7<CR>
nmap <leader>f8 :set foldlevel=8<CR>
nmap <leader>f9 :set foldlevel=9<CR>

" make ; to : to save shifting all the time, even though this gives me grief when using
" a vanilla vim :)
vnoremap ; :
nnoremap ; :

" Map F2 to toggle spell checking
map <F2> :setlocal spell! spelllang=en_au<CR>

" Use <leader>l to toggle display of whitespace
" And set some nice chars to do it with
nmap <leader>l :set list! list?<CR>
set listchars=tab:»\ ,eol:¬

" Backspace to toggle search highlighting
nnoremap <BS> :set hlsearch! hlsearch?<cr>

" clear search highlighting
nnoremap <leader><space> :noh<cr>

" reselect visual block after indent
vnoremap < <gv
vnoremap > >gv

" make Y consistent with D and C - yank to end of line
" Doesn't seem to work. I think a plugin is interfering with the mapping
nnoremap Y y$

" Convert current line to Title Case (too much typing to enter each time)
" Broken at moment
nnoremap <leader>tc :s/\<\(\w\)\(\w*\)\>/\u\1\L\2/<cr>:noh<cr>

" pastetoggle, with visual feedback in normal mode
nnoremap <F12> :set invpaste paste?<CR>
set pastetoggle=<F12>

" Map leader-d to generate a doxygen block for the current line
nmap <leader>d :Dox<cr>

" format document (entire file)
nmap <leader>fd :call Preserve("normal gg=G")<CR>

" strip trailing whitespace from file
nmap <leader>fw :call StripTrailingWhitespace()<CR>

" window killer
nnoremap <silent> Q :call CloseWindowOrKillBuffer()<cr>

" auto center search repeats
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g# g#zz
nnoremap <silent> <C-o> <C-o>zz
nnoremap <silent> <C-i> <C-i>zz

" next error
nnoremap <leader>[ :lprev<CR>
nnoremap <leader>] :lnext<CR>

" Mappings to insert date stamps
" Wed July 14, 2017
nnoremap <leader><leader>d "=strftime('%A %B %d, %Y')<CR>P
" 07:14:59
nnoremap <leader><leader>t "=strftime('%T')<CR>P

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Status Line:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set ruler
set laststatus=2


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Search:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fix regex handling so I can use normal Perl/python regex
nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v
nnoremap :s/ :s/\v
set ignorecase
set smartcase
set incsearch
set noshowmatch


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Movement Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" disable arrow keys in normal and insert modes
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" make tab key match bracket pairs
nnoremap <tab> %
vnoremap <tab> %

" make j and k move by screen lines
nnoremap j gj
nnoremap k gk

" enable the mouse, but hide it unless being used
set mouse=a
set mousehide


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Windows:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" less keystrokes to navigate windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto Commands:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autosave when focus is lost
autocmd FocusLost * :wa

" Override the default mapping of .md to Modula2
autocmd BufNewFile,BufRead *.md set filetype=markdown
