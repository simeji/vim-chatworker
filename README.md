vim-chatworker
==============

The vim plugin to use chatwork (by api).

note: This plugin is one of plugin for [unite.vim](https://github.com/Shougo/unite.vim) now.

## Installation

Let's say you used [NeoBundle](https://github.com/Shougo/neobundle.vim) to manage your vim plugins.

in your `.vimrc`
```
" Install 'unite.vim' if you don't have it.
NeoBundle 'unite.vim'
NeoBundle 'simeji/vim-chatworker.git'

" set your chatwork token.
let g:chatwork_token = 'your chatwork token'
```

## Usage

If you want to use as the unite.vim plugin.

Open the vim and execute command below.
``````````
:Unite chatwork
``````````
