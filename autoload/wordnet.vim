function! wordnet#escape_quotes (word)
  return "'" . substitute(a:word, "'", "''", 'g')  .  "'"
endfunction

function! wordnet#get_word() range
  try
    let a_save = @a
    normal! gv"ay
    return substitute(@a, '\v(\n|\s)+', ' ', 'g')
  finally
    let @a = a_save
  endtry
endfunction

function! wordnet#browse (word)
  call system(g:wordnet_path . "wnb " . wordnet#escape_quotes(a:word))
endfunction

function! wordnet#overviews (word)
  echom g:wordnet_path . "wn " . wordnet#escape_quotes(a:word) . " -over"
  let definition = system(g:wordnet_path . "wn " . wordnet#escape_quotes(a:word) . " -over")
  if definition == ""
    let definition = "Word not found: " . a:word
  endif
  call s:WordNetOpenWindow(definition)
endfunction

function! wordnet#synonyms (word)
  let synonyms = system(g:wordnet_path . "wn " . wordnet#escape_quotes(a:word) . " -synsn -synsv -synsa -synsr")
  if synonyms == ""
    let synonyms = "Word not found: " . a:word
  endif
  call s:WordNetOpenWindow(synonyms)
endfunction


function! s:WordNetOpenWindow (text)

  " If the buffer is visible
  if bufwinnr("__WordNet__") > -1
    " switch to it
    exec bufwinnr("__WordNet__") . "wincmd w"
    hide
  endif

  if bufnr("__WordNet__") > -1
    exec bufnr("__WordNet__") . "bdelete!"
  endif

  exec 'silent! keepalt botright 20split'
  exec ":e __WordNet__"
  let s:wordnet_buffer_id = bufnr('%')

  call append("^", split(a:text, "\n"))
  exec 0
  " Mark the buffer as scratch
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nonumber
  setlocal nobuflisted
  setlocal readonly
  setlocal nomodifiable

  mapclear <buffer>
  nmap <buffer> q :q<CR>
  "syn match overviewHeader      /^Overview of .\+/
  "
  "syn match definitionEntry  /\v^[0-9]+\. .+$/ contains=numberedList,word
  "syn match numberedList  /\v^[0-9]+\. / contained
  "syn match word  /\v([0-9]+\.[0-9\(\) ]*)@<=[^-]+/ contained
  "hi link overviewHeader Title
  "hi link numberedList Operator
  "hi def word term=bold cterm=bold gui=bold
endfunction
