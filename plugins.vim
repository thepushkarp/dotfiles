" Plugin file

" Plugin home
let g:plugged_home = '~/.vim/plugged'

" Plugins List
call plug#begin(g:plugged_home)

  " UI related
  Plug 'chriskempson/base16-vim'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

  " Better Visual Guide
  Plug 'Yggdroot/indentLine'

  " syntax check
  Plug 'w0rp/ale'

  " Autocomplete
  Plug 'ncm2/ncm2'
  Plug 'roxma/nvim-yarp'
  Plug 'ncm2/ncm2-bufword'
  Plug 'ncm2/ncm2-path'

  " Formater
  Plug 'Chiel92/vim-autoformat'

  " Editorconfig
  Plug 'editorconfig/editorconfig-vim'

  " Colour Scheme
  Plug 'drewtempelmeyer/palenight.vim'

  " Vim Tmux Navigator
  Plug 'christoomey/vim-tmux-navigator'

  " NerdTree
  Plug 'scrooloose/nerdtree'

  " DevIcons
  Plug 'ryanoasis/vim-devicons'

  " Git
  Plug 'tpope/vim-fugitive'
  Plug 'airblade/vim-gitgutter'
  Plug 'Xuyuanp/nerdtree-git-plugin'

  " Prettier
  Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

call plug#end()

