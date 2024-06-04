" Title:        syntax-highlighted-cursor
" Description:  Neovim plugin to make cursor color following syntax highlighting
" Last Change:  8 December 2023
" Maintainer:   Johnny Cheng <https://github.com/ukyouz>


" highlight Cursor guifg=white guibg=blue
set guicursor=n-v-c:block-Cursor-blinkon0
set guicursor+=i:ver30-Cursor


function s:ShowCursorLine() abort
    "" https://stackoverflow.com/questions/14920634/cursor-color-in-xterm-change-accordingly-to-the-syntax-in-vim

    " get fg under cursor
    let fg = synIDattr(synIDtrans(synID(line("."), col("."), 1)), "fg")
    " let guifg = synIDattr(synIDtrans(synID(line("."), col("."), 1)), "guifg#")
    " let gui = synIDattr(synIDtrans(synID(line("."), col("."), 1)), "gui#")
    " let fg = synIDattr(synIDtrans(synID(line("."), col("."), 1)), "fg#")
    " set hi Cursor to fg
    echo fg
    " exec "hi Cursor guibg=" . fg
endfunction

function! SynStack()
    if !exists("*synstack")
      return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

nnoremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

com! CheckHighlightUnderCursor echo {l,c,n ->
        \   'hi<'    . synIDattr(synID(l, c, 1), n)             . '> '
        \  .'trans<' . synIDattr(synID(l, c, 0), n)             . '> '
        \  .'lo<'    . synIDattr(synIDtrans(synID(l, c, 1)), n) . '> '
        \ }(line("."), col("."), "name")
" autocmd CursorMoved * call s:ShowCursorLine()

