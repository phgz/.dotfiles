" " let g:popup_preview_config = #{
" "             \   border: v:false,
" "             \   winblend: 30,
" "             \   maxHeight: 12,
" "             \   supportUltisnips: v:true,
" "             \ }
"
" " function! s:wise_tab() abort
" "     if ddc#map#can_complete() 
" "         if trim(g:ddc#_prev_input) ==# g:ddc#_items[0]['word']
" "             if UltiSnips#CanExpandSnippet()
" "                 return "\<cmd>call UltiSnips#ExpandSnippet()\<CR>"
" "             else
" "                 return "\<TAB>"
" "             endif
" "         else
" "             return ddc#map#insert_item(0, "\<C-e>")
" "         endif
" "     else
" "         return "\<TAB>"
" "     endif
" " endfunction
"
"
" " call ddc#custom#patch_global('sources', ['tabnine','treesitter', 'nvim-lsp_by-treesitter'])
" call ddc#custom#patch_global('sources', ['nvim-lsp', 'ultisnips', 'file'])
"
" " 'matcher_length' <- only matches candidates > current word length.
" call ddc#custom#patch_global('sourceOptions', #{
"             \ _: #{
"             \   matchers: ['matcher_fuzzy'],
"             \   sorters: ['sorter_fuzzy'],
"             \   converters: ['converter_remove_overlap'],
"             \   minAutoCompleteLength : 1,
"             \   ignoreCase: v:false
"             \     }
"             \ })
"
" call ddc#custom#patch_global('filterParams', #{
"             \   matcher_fuzzy: #{ splitMode: 'word' }
"             \ })
"
" call ddc#custom#patch_global('sourceOptions', #{
"             \ tabnine: #{ mark: 'TN', maxCandidates: 5, isVolatile: v:true },
"             \ treesitter: #{mark: 'TS'},
"             \ ultisnips: #{mark: 'U'},
"             \ omni: #{mark: 'O'},
"             \ nvim-lsp_by-treesitter: #{ mark: 'lsp'},
"             \ nvim-lsp: #{mark: 'LSP',forceCompletionPattern: '\.\w*|:\w*|->\w*'},
"             \ file: #{mark: 'F', forceCompletionPattern: '\S/\S*' }
"             \})
"
" call ddc#custom#patch_global('sourceParams', #{
"             \ nvim-lsp_by-treesitter: #{ kindLabels: #{ Class: 'c' } },
"             \ file: #{trailingSlash: v:false}
"             \ })
"
" call ddc#custom#patch_global('ui', 'inline')
"
"
" " inoremap <silent> <expr> <Tab> pumvisible() ? '<C-n>' : <SID>wise_tab()
" " inoremap <silent> <expr> <S-Tab> pumvisible() ? '<C-p>' : ddc#map#manual_complete('nvim-lsp', 'native')
" " inoremap <silent> <expr> <cr> pumvisible() ? '<C-y>' : '<Cr>'
" " inoremap <silent> <expr> <esc> pumvisible() ? '<C-e>' : '<esc>'
"
" call popup_preview#enable()
" call ddc#enable()
