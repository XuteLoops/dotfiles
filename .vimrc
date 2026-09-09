" ============================================================================
" ~/.vimrc — vanilla Vim, no plugins. Tested-compatible with Vim 8.0+
" ============================================================================

" ---------------------------------------------------------------------------
" Sensible basics
" Vim only loads its built-in defaults.vim when you have NO vimrc — so these
" would silently be off otherwise.
" ---------------------------------------------------------------------------
set backspace=indent,eol,start  " Backspace can delete autoindent, line breaks,
                                " and text from before the current insert
set ruler                       " cursor line:column in the bottom-right corner
set wildmenu                    " Tab-complete :commands/filenames in a popup menu
set number                      " line numbers (skipped question -> sane default;
                                " add `set relativenumber` too for hybrid mode)
set mouse=                      " keyboard only: no mouse cursor placement/scroll

" ---------------------------------------------------------------------------
" Syntax & filetypes (no colorscheme/background settings: Vim auto-detects
" dark vs. light from the terminal and picks readable default colors)
" ---------------------------------------------------------------------------
syntax enable                   " built-in syntax highlighting
filetype plugin indent on       " detect filetype -> syntax + indent rules

" ---------------------------------------------------------------------------
" Indentation: real Tab characters, displayed 2 columns wide, everywhere
" ---------------------------------------------------------------------------
set tabstop=2                   " a Tab character counts as 2 columns
set softtabstop=2               " editing keys treat a tab as 2 columns
set shiftwidth=2                " >>, << and autoindent step by 2
set noexpandtab                 " always insert real Tabs, never spaces
set autoindent                  " new line copies previous line's indent

" The python/rust ftplugins try to force PEP-8 / rustfmt style (spaces).
" This autocommand is registered *after* `filetype plugin indent on`, so it
" runs after them and re-imposes tabs for every filetype.
augroup force_tabs
  autocmd!
  autocmd FileType * setlocal tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab
augroup END

" ---------------------------------------------------------------------------
" Smarter search — all built-in, no plugin needed
" ---------------------------------------------------------------------------
set ignorecase                  " /foo matches Foo, FOO, ...
set smartcase                   " ...unless you type an uppercase letter
set incsearch                   " jump to the match *while you type*
set hlsearch                    " highlight all matches after Enter
" Ctrl-L clears the highlight, then does its usual redraw:
nnoremap <silent> <C-l> :nohlsearch<CR><C-l>

" ---------------------------------------------------------------------------
" System clipboard — same y/d/p keys as always, they just also reach the
" desktop clipboard (no "*/"+ register prefixes needed).
" Side effect to know: deletes (d, x, c) now also overwrite your clipboard.
" ---------------------------------------------------------------------------
if has('unnamedplus')           " build with full clipboard support
  set clipboard=unnamedplus     " use the Ctrl+C/Ctrl+V clipboard
elseif has('clipboard')
  set clipboard=unnamed         " fallback: mouse-selection (PRIMARY) clipboard
endif
" The `if` guards mean this vimrc still loads cleanly on builds without
" clipboard support (e.g. vim-minimal, remote servers).

" ---------------------------------------------------------------------------
" Persistent undo: `u` still works after closing and reopening a file
" ---------------------------------------------------------------------------
if has('persistent_undo')
  let s:undodir = expand('~/.vim/undo')
  if !isdirectory(s:undodir)
    call mkdir(s:undodir, 'p', 0700)  " private: undo history can hold secrets
  endif
  let &undodir = s:undodir
  set undofile
  unlet s:undodir
endif

" ---------------------------------------------------------------------------
" Strip trailing whitespace on save
" ---------------------------------------------------------------------------
function! s:TrimTrailingWhitespace() abort
  " Skip where trailing spaces are meaningful (markdown hard line breaks,
  " diff context lines) or where rewriting is a bad idea (binary files)
  if &binary || &filetype =~# '\v^(markdown|diff)$'
    return
  endif
  let l:view = winsaveview()        " remember cursor position & scroll
  keeppatterns %s/\s\+$//e          " `e`: no error when nothing to strip;
                                    " keeppatterns: don't clobber your last /search
  call winrestview(l:view)
endfunction

augroup trim_whitespace
  autocmd!
  autocmd BufWritePre * call <SID>TrimTrailingWhitespace()
augroup END
