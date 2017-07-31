if exists('g:macra_loaded')
  finish
endif
let g:macra_loaded = 1

nnoremap <silent> <Plug>(macra-start) :<C-u>call macra#start()<CR>
nnoremap <silent> <Plug>(macra-stop)  :<C-u>call macra#stop()<CR>
nnoremap <silent> <Plug>(macra-run)   :<C-u>call macra#run()<CR>
xnoremap <silent> <Plug>(macra-run)   :call macra#run_over()<CR>

if get(g:, 'macra#default_mappings', 1)
  nmap q <Plug>(macra-start)
  nmap @ <Plug>(macra-run)
  xmap @ <Plug>(macra-run)
endif
