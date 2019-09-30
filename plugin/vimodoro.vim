if exists('g:loaded_vimodoro')
  finish
endif
let g:loaded_vimodoro = 1

func PopupCallback(id,result)
endfunc

func! s:i20s(n,l)
    let s:m = 0
    while pow(10,a:l-s:m) - a:n > 1
       let s:m = s:m + 1 
    endwhile
    let r = ''
    while s:m > 1
        let s:m = s:m - 1 
        let r = r.'0'
    endwhile
    return r.string(a:n)
endfunc

func! s:i2ts(n)
    return s:i20s(a:n/60,2).':'.s:i20s(a:n%60,2)
endfunc

func LockFilter(winid, key)
  if a:key == 'x'
	call popup_close(a:winid,-1)
    call s:PomodoroStop()
	return 1
  endif
  return 1
endfunc

" debug
" let s:time = {'work':15,'break':3}

let s:time = {'work':25*60,'break':5*60}
let s:mode = 'work'
let s:dict = {'count': s:time[s:mode]}
let s:btxt = "Break Time !"

function! s:dict.countdown(timer) abort
 let self.count -= 1
  if self.count
    if self.count % 30 == 0
        echo s:i2ts(self.count)
    endif
    if s:mode == 'break'
        let text = [s:btxt,s:i2ts(self.count)]
        call popup_settext(s:id, text)
    endif
  else
    if s:mode == 'work'
        let s:mode = 'break'
        let text = s:btxt
        let s:id = popup_menu([text,""],{'pos':'center','filter':'LockFilter','callback':'PopupCallback'})
    else
        let s:mode = 'work'
        call popup_close(s:id, -1)
        call popup_dialog("Start Vimming!",{'pos':'center','time':3000})
    endif
    let self.count = s:time[s:mode]
  endif
endfunction


func s:PomodoroStart()
    call s:PomodoroStop()

	let s:timer = timer_start(1000, s:dict.countdown, {'repeat': -1})
endfunc

func s:PomodoroStop()
    if exists('s:timer')
        call timer_stop(s:timer)
    endif        
endfunc

command! Pomodoro call s:PomodoroStart()
command! PomodoroStop call s:PomodoroStop()

