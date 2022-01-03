function! s:wise_tab() abort
    if ddc#can_complete() 
        if trim(g:ddc#_prev_input) ==# g:ddc#_candidates[0]['word']
            if UltiSnips#CanExpandSnippet()
                return "\<cmd>call UltiSnips#ExpandSnippet()\<CR>"
            else
                return "\<TAB>"
            endif
        else
           return ddc#map#insert_candidate(0)
       endif
    else
        return "\<TAB>"
    endif
endfunction

" 'matcher_length' <- only matches candidates > current word length.
" 'rg', 'around', 'buffer', 'tmux'
call ddc#custom#patch_global('sources', ['ultisnips', 'treesitter', 'file', 'nvim-lsp'])

call ddc#custom#patch_global('sourceOptions', {
      \ '_': {
      \   'matchers': ['matcher_fuzzy'],
      \   'sorters': ['sorter_fuzzy'],
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
      \ 'around': {'mark': 'A'},
      \ 'ultisnips': {'mark': 'U'},
      \ 'omni': {'mark': 'O'},
      \ 'tmux': {'mark': 'T'},
      \ 'buffer': {'mark': 'B'},
      \ 'rg': {'mark': 'rg', 'minAutoCompleteLength': 4,},
      \ 'nvim-lsp': {'forceCompletionPattern': '\.\w*|:\w*|->\w*'},
      \ 'file': {
      \ 'mark': 'F',
	  \   'forceCompletionPattern': '\S/\S*',
      \ }
      \})

call ddc#custom#patch_global('sourceParams', {
            \ 'around': {'maxSize': 500},
            \ 'tmux': {'currentWinOnly': v:false},
            \ 'file': {'trailingSlash': v:true}
      \ })

call ddc#custom#patch_global('completionMode', 'inline')
"
    " let g:chains = ['around', 'tmux']
    " function! MyChainCompletion() abort
    "   let head = g:chains[0]
    "   let g:chains = g:chains[1:] + [head]
    "   return ddc#map#manual_complete([head])
    " endfunction

inoremap <expr> <Tab> pumvisible() ? '<C-n>' : <SID>wise_tab()
inoremap <silent><expr> <S-Tab> pumvisible() ? '<C-p>' : ddc#map#manual_complete('nvim-lsp')
inoremap <silent><expr> <cr> pumvisible() ? '<C-y>' : '<Cr>'
inoremap <silent><expr> <esc> pumvisible() ? '<C-e>' : '<esc>'

let g:ddc_nvim_lsp_doc_config = {
        \ 'documentation': {
        \   'enable': v:true,
        \   'border': 'none',
        \   'winblend': 30,
        \ },
        \ 'signature': {
        \   'enable': v:false,
        \   'border': 'none',
        \   'winblend': 30,
        \   'maxHeight': 2,
        \ },
        \ }

hi! link DdcNvimLspDocDocument Pmenu
hi! link DdcNvimLspDocBorder Pmenu

call ddc_nvim_lsp_doc#enable()
call ddc#enable()
