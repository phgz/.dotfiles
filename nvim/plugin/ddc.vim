function! s:wise_tab() abort
    if ddc#can_complete() 
        if trim(g:ddc#_prev_input) ==# g:ddc#_items[0]['word']
            if UltiSnips#CanExpandSnippet()
                return "\<cmd>call UltiSnips#ExpandSnippet()\<CR>"
            else
                return "\<TAB>"
            endif
        else
           return ddc#map#insert_item(0)
       endif
    else
        return "\<TAB>"
    endif
endfunction

call ddc#custom#patch_global('sources', ['ultisnips', 'treesitter', 'file', 'nvim-lsp'])

" 'matcher_length' <- only matches candidates > current word length.
call ddc#custom#patch_global('sourceOptions', {
      \ '_': {
      \   'matchers': ['matcher_fuzzy'],
      \   'sorters': ['sorter_fuzzy'],
      \   'converters': ['converter_remove_overlap'],
      \   'minAutoCompleteLength' : 1,
      \   'ignoreCase': v:false
      \     }
      \ })

call ddc#custom#patch_global('filterParams', {
  \   'matcher_fuzzy': {
  \     'splitMode': 'word'
  \   }
  \ })
      
call ddc#custom#patch_global('sourceOptions', {
      \ 'treesitter': {'mark': 'TS'},
      \ 'ultisnips': {'mark': 'U'},
      \ 'omni': {'mark': 'O'},
      \ 'nvim-lsp': {'forceCompletionPattern': '\.\w*|:\w*|->\w*'},
      \ 'file': {
      \ 'mark': 'F',
	  \   'forceCompletionPattern': '\S/\S*',
      \ }
      \})

call ddc#custom#patch_global('sourceParams', {
            \ 'file': {'trailingSlash': v:false}
      \ })

call ddc#custom#patch_global('completionMode', 'inline')
"
    " let g:chains = ['around', 'tmux']
    " function! MyChainCompletion() abort
    "   let head = g:chains[0]
    "   let g:chains = g:chains[1:] + [head]
    "   return ddc#map#manual_complete([head])
    " endfunction

inoremap <silent> <expr> <Tab> pumvisible() ? '<C-n>' : <SID>wise_tab()
inoremap <silent> <expr> <S-Tab> pumvisible() ? '<C-p>' : ddc#map#manual_complete('nvim-lsp')
inoremap <silent> <expr> <cr> pumvisible() ? '<C-y>' : '<Cr>'
inoremap <silent> <expr> <esc> pumvisible() ? '<C-e>' : '<esc>'

let g:popup_preview_config = {
        \   'border': v:false,
        \   'winblend': 30,
        \   'maxHeight': 20,
        \ }

call popup_preview#enable()
call ddc#enable()
