let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \ 'name' : 'chatwork_post_message',
      \ 'description' : 'Chatwork operations',
      \ 'syntax': 'uniteSource__charwork',
      \ 'action_table' : {
      \     'post' : {
      \         'description' : 'post message',
      \         'is_selectable' : 1,
      \     }
      \ },
      \ 'default_action' : 'post',
      \ 'hooks': {},
      \ }

" tmp
let g:unite_source_alias_aliases = {
      \   "chatwork" : {
      \       "source" : "chatwork_post_message",
      \   }
      \}

function! s:source.gather_candidates(args, context)
  let candidates = []

  for item in chatwork#getRoomList()
    call add(candidates, {
      \ 'word': item.name,
      \ 'action__room_name': item.name,
      \ 'action__room_id': item.id,
      \ })
  endfor

  return candidates
endfunction

function! s:source.action_table.post.func(candidates)
  for candidate in a:candidates
    let msg = input('[' . candidate.action__room_name . '] Input message: ')
    call chatwork#postMessage(candidate.action__room_id, msg)
  endfor
endfunction

function! unite#sources#chatwork_post_message#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
