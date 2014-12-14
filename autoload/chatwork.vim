
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
 \   'messages' : { 'path' : '/rooms/__rid__/messages', 'method' : 'get' },
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

function! chatwork#getMessageList(rid)
  let messageData = []
  let rid = a:rid

  " content cache
  if !exists('s:messageList')
    let s:messageList = {}
  endif
  let s:messageList[rid] = has_key(s:messageList, rid) ?
        \ s:messageList[rid] :
        \ s:requestApi('messages', {'force' : 1}, g:chatwork_token, {'__rid__' : rid})

  " ここは整形済みをキャッシュ対応
  let content = s:requestApi('messages', {}, g:chatwork_token, {'__rid__' : rid})
  if type(content) != type('')
    call extend(s:messageList[rid], content)
  endif
  
  for item in s:messageList[rid]
    call add(messageData, { 
      \ 'id' : item.message_id,
      \ 'name' : item.account.name,
      \ 'rid' : rid,
      \ 'aid' : item.account.account_id,
      \ 'body' : item.body,
      \ 'send_time' : item.send_time,
      \ 'update_time' : item.update_time,
      \ })
  endfor
  return messageData
endfunction

function! chatwork#postMessage(rid, msg)
  let result = s:requestApi('post_message', {'body' : a:msg}, g:chatwork_token, {'__rid__' : a:rid})
  if exists('result.message_id')
    echo '..........Post succeed!!'
  endif
endfunction

function! chatwork#outputBuffer(name, content)
  let bufname = "[cw: " . a:name . "]"
  if !bufexists(bufname)
    wincmd p
    vsplit
    exec "edit " . bufname
    nnoremap <buffer> q <C-w>c
    "nnoremap <buffer> r :call chatwork#replyMessage()<CR>
    setlocal bufhidden=wipe buftype=nofile noswapfile buflisted
  elseif bufwinnr(bufname) != -1
    execute bufwinnr(bufname) 'wincmd w'
  else
    vsplit
    execute 'buffer' bufnr(bufname)
  endif
  silent % delete _
  silent $ put =a:content
endfunction

function! chatwork#updateMessages()
  " not implement yet
endfunction

function! chatwork#replyMessage()
  let line = getline('.')
  " bufferからもってくればいいかも
endfunction
" }}}

" Private method {{{
function! s:requestApi(name, params, token, replacements)
  let requestUri = s:baseUri . s:getPath(get(s:paths, a:name).path, a:replacements)
  let request = 's:Http.' . get(s:paths, a:name).method
  execute "let dataStr = " . request . "(requestUri, a:params, {'X-ChatWorkToken' : '" . a:token . "'})"
  let response = s:Json.decode(string(dataStr))
  if len(response.content) > 0
    let content = s:Json.decode(response.content)
  else
    let content = ''
  endif
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
