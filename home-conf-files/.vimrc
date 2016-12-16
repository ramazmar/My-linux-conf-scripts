map <F2> :w<CR>
map <F4> :wq<CR>

colorscheme evening
let g:syntastic_mode_map = { 'passive_filetypes': ['python'] }

" Plugin 'Valloric/YouCompleteMe'
" These are the tweaks I apply to YCM's config, you don't need them but they might help.
" YCM gives you popups an

syntax on
set sw=4
set tabstop=4
set expandtab
set autoindent
set ai
set nocp
set ignorecase
set noai


" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif


