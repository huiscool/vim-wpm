" wpm.vim add a wpm (word per minute) meter in status bar
" vim8.0 is requried
" Usage: 
" add `source /path/to/wpm.vim` in your .vimrc file (replace with the actual wpm.vim path)
" run `:ShowWPM` in cmdline mode, and you will see a meter in your status line
" run `:HideWPM` to exit 

function! AverageWPMCallback(wpm, cpm)
	let b:awpm = a:wpm
	let b:acpm = a:cpm
	call RedrawWPM()
endfunction

function! InstantWPMCallback(wpm, cpm)
	let b:wpm = a:wpm
	let b:cpm = a:cpm
	call RedrawWPM()
endfunction

function! RedrawWPM()
  set statusline=""
	set statusline+=AWPM\:%{b:awpm};\ 
	set statusline+=ACPM\:%{b:acpm};\ 
	set statusline+=WPM\:%{b:wpm};\ 
	set statusline+=CPM\:%{b:cpm}; 
	silent redraw
endfunction
				
function! SampleWPM(maxlen, intv, callback)
	let points = [wordcount()]
	let intv = a:intv
	let maxlen = a:maxlen
	let Callback = a:callback
	function! AddPointAndGetPoints() closure
		let curlen = (len(points)-1) * intv
		if curlen < maxlen
			let points += [wordcount()]
		else
			let points = points[1:] + [wordcount()]
		endif
		return points
	endfunction
	function! TimerCallback(Callback, timer) closure
		let ps = AddPointAndGetPoints()
		let curlen = (len(ps)-1)*intv
		let wpm = (ps[-1]['words'] - ps[0]['words']) * 60000 / curlen
		let cpm = (ps[-1]['chars'] - ps[0]['chars']) * 60000 / curlen
		call Callback(wpm,cpm)
	endfunction
	call timer_start(a:intv, funcref('TimerCallback', [a:callback]), {'repeat':-1})
endfunction

function! ShowWPM()
	let b:originLastStatus=&laststatus
	let b:originStatusline=&statusline
	set laststatus=2
	let b:wpm = 0
	let b:cpm = 0
	let b:awpm = 0
	let b:acpm = 0
	call SampleWPM(10000, 500, function('InstantWPMCallback'))
	call SampleWPM(60000, 1000, function('AverageWPMCallback'))
endfunction

function! HideWPM()
	call timer_stopall()
	let &statusline=b:originStatusline
	let &laststatus=b:originLastStatus
endfunction

command! ShowWPM call ShowWPM()
command! HideWPM call HideWPM()
