let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \ 'name' : 'chatwork_view_message',
      \ 'description' : 'Chatwork operations',
      \ 'syntax': 'uniteSource__chatwork',
      \ 'action_table' : {
      \     'view' : {
      \         'description' : 'view message'
      \     }
      \ },
      \ 'default_action' : 'view',
      \ 'hooks': {},
      \ }

" tmp

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

function! s:source.action_table.view.func(candidates)
  for candidate in a:candidates
    let messages = chatwork#getMessageList(candidate.action__room_id)
    echo messages
  endfor
endfunction

function! unite#sources#chatwork_view_message#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
