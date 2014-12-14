let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \ 'name' : 'chatworker',
      \ 'description' : 'Chatwork operations',
      \ 'syntax': 'uniteSource__chatwork',
      \ 'action_table' : {
      \     'view' : {
      \         'description' : 'view message'
      \     },
      \     'post' : {
      \         'description' : 'post message',
      \         'is_selectable' : 1,
      \     }
      \ },
      \ 'default_action' : 'view',
      \ 'hooks': {},
      \ }

let s:CHATWORK_OPERATIONS = [
      \ { 'name' : 'view_message', 'source' : 'chatwork_view_message' },
      \ { 'name' : 'post_message', 'source' : 'chatwork_post_message' },
      \ ]

function! s:source.gather_candidates(args, context)
  let candidates = []

  for item in chatwork#getRoomList()
    call add(candidates, {
      \ 'word': item.name,
      \ 'action__room_name': item.name,
      \ 'action__room_id': item.id,
      \ })
  endfor
  "let candidates = []

  "for operation in s:CHATWORK_OPERATIONS
    "call add(candidates, {
      "\ 'word': operation.name,
      "\ 'source': 'chatwork',
      "\ 'kind': 'source',
      "\ 'action__source_name': operation.source,
      "\ })
  "endfor

  return candidates
endfunction

function! s:source.action_table.post.func(candidates)
  for candidate in a:candidates
    let msg = input('[' . candidate.action__room_name . '] Input message: ')
    call chatwork#postMessage(candidate.action__room_id, msg)
  endfor
endfunction

function! s:source.action_table.view.func(candidate)
  let rid = a:candidate.action__room_id
  let rname = a:candidate.action__room_name
  let messages = chatwork#getMessageList(rid)
  call chatwork#outputBuffer(rname . ':' . rid , s:formatMessages(messages))
endfunction

function! s:formatMessages(messages)
  let messages = a:messages
  let enterCode = "\n"
  let m = []
  for msg in messages
    let lineStr = msg.name .' | '. msg.send_time .' =============== '. enterCode . msg.body . enterCode
    let lineStr = lineStr . '[[Replay]] ('. msg.aid .':'. msg.rid .'-'. msg.id .')' . enterCode
    call add(m, lineStr)
  endfor
  return join(m, enterCode)
endfunction

" not register source 
function! unite#sources#chatworker#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
