let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \ 'name' : 'chatwork',
      \ 'description' : 'Chatwork operations',
      \ 'syntax': 'uniteSource__charwork',
      \ 'action_table' : {},
      \ 'hooks': {},
      \ }

let s:CHATWORK_OPERATIONS = [
      \ { 'name' : 'post_message', 'source' : 'chatwork_post_message' },
      \ { 'name' : 'messages', 'source' : '' },
      \ ]

function! s:source.gather_candidates(args, context)
  let candidates = []

  let index = 0
  for operation in s:CHATWORK_OPERATIONS
    call add(candidates, {
      \ 'word': operation.name,
      \ 'source': 'chatwork',
      \ 'kind': 'source',
      \ 'action__source_name': operation.source,
      \ })
  endfor

  return candidates
endfunction

" not register source 
"function! unite#sources#chatwork#define()
  "return s:source
"endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
