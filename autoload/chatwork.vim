
if !exists("g:chatwork_token")
  echo "Error:"
  echo "You must write a setting 'let g:chatwork_token = \"your chatwork api token'\" in your .vimrc"
  let s:is_confirm = confirm('ok?')
  finish
endif

" define script variables {{{
let s:V = vital#of('chatworker')
let s:Http = s:V.import('Web.HTTP')
let s:Json = s:V.import('Web.JSON')

let s:baseUri = 'https://api.chatwork.com/v1'
let s:paths = {
 \   'rooms' : { 'path' : '/rooms', 'method' : 'get' },
 \   'post_message' : { 'path' : '/rooms/__rid__/messages', 'method' : 'post' },
 \ }
" }}}


" API {{{
function! chatwork#getRoomList()
  " cache room list for performance and save api call
  if !exists('s:roomList')
    let s:roomList = s:requestApi('rooms', {}, g:chatwork_token, {})
  endif
  
  let roomData = []
  
  for item in s:roomList
    call add(roomData, { 
      \ 'id' : item.room_id,
      \ 'name' : item.name,
      \ })
  endfor
  return roomData
endfunction

function! chatwork#postMessage(rid, msg)
  let result = s:requestApi('post_message', {'body' : a:msg}, g:chatwork_token, {'__rid__' : a:rid})
  if exists('result.message_id')
    echo '..........Post succeed!!'
  endif
endfunction
" }}}

" Private method {{{
function! s:requestApi(name, params, token, replacements)
  let requestUri = s:baseUri . s:getPath(get(s:paths, a:name).path, a:replacements)
  let request = 's:Http.' . get(s:paths, a:name).method
  execute "let dataStr = " . request . "(requestUri, a:params, {'X-ChatWorkToken' : '" . a:token . "'})"
  let response = s:Json.decode(string(dataStr))
  let content = s:Json.decode(response.content)
  if response.status == 401
    echohl ErrorMsg
    echomsg "Eoror: " . content['errors'][0] 
    echomsg "Please set correct API Token and restart vim."
    echohl None
    let ans = confirm('ok?')
    return []
  endif
  return content
endfunction

function! s:getPath(str, replacements)
  let path = a:str
  for key in keys(a:replacements)
    let path = substitute(path, key, a:replacements[key], 'g')
  endfor
  return path
endfunction
"}}}

" vim:set et ts=2 sts=2 sw=2 tw=0:
" vim:set foldmethod=marker:
