let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/Devel/Minos
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +30 templates/homepage.hamlet
badd +2 app/main.hs
badd +1 src/Application.hs
badd +1 src/Judge/Problems.hs
badd +42 src/Judge/Submissions.hs
badd +1 src/Model.hs
badd +172 src/Foundation.hs
badd +34 config/settings.yml
badd +20 src/Handler/Home.hs
badd +1 package.yaml
badd +18 config/models.persistentmodels
badd +15 src/Handler/Profile.hs
badd +132 src/Settings.hs
badd +10 templates/profile.hamlet
badd +1 templates/homepage.julius
badd +1 templates/homepage.lucius
badd +1 config/routes.yesodroutes
badd +26 Minos.cabal
badd +14 templates/addproblem.hamlet
badd +1 src/Handler/Common.hs
badd +1 src/Handler/Addproblem.hs
badd +16 app/DevelMain.hs
badd +38 templates/default-layout.hamlet
badd +34 templates/default-layout-wrapper.hamlet
badd +1 templates/signup.hamlet
badd +1 src/Handler/Signup.hs
badd +1 .gitignore
badd +7 .git/info/exclude
badd +6 src/Import/NoFoundation.hs
badd +5 src/Import.hs
badd +11 templates/problems.hamlet
badd +2 src/Handler/Problems.hs
badd +46 stack.yaml
badd +15 templates/problemslist.hamlet
badd +73 templates/default-layout.lucius
badd +13 test/Handler/CommentSpec.hs
badd +1 Minos
argglobal
%argdel
$argadd templates/homepage.hamlet
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit templates/problems.hamlet
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
wincmd =
argglobal
balt templates/homepage.hamlet
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 11 - ((10 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 11
normal! 051|
wincmd w
argglobal
if bufexists(fnamemodify("templates/addproblem.hamlet", ":p")) | buffer templates/addproblem.hamlet | else | edit templates/addproblem.hamlet | endif
if &buftype ==# 'terminal'
  silent file templates/addproblem.hamlet
endif
balt templates/default-layout.hamlet
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 14 - ((13 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 14
normal! 047|
wincmd w
2wincmd w
wincmd =
if exists(':tcd') == 2 | tcd ~/Devel/Minos | endif
tabnext
edit ~/Devel/Minos/src/Handler/Addproblem.hs
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
wincmd =
argglobal
balt ~/Devel/Minos/src/Handler/Problems.hs
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 16 - ((15 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 16
normal! 023|
wincmd w
argglobal
if bufexists(fnamemodify("~/Devel/Minos/src/Handler/Problems.hs", ":p")) | buffer ~/Devel/Minos/src/Handler/Problems.hs | else | edit ~/Devel/Minos/src/Handler/Problems.hs | endif
if &buftype ==# 'terminal'
  silent file ~/Devel/Minos/src/Handler/Problems.hs
endif
balt ~/Devel/Minos/src/Handler/Signup.hs
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 2 - ((1 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 2
normal! 0
wincmd w
wincmd =
if exists(':tcd') == 2 | tcd ~/Devel/Minos | endif
tabnext
edit ~/Devel/Minos/src/Application.hs
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
wincmd =
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 1 - ((0 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
normal! 029|
wincmd w
argglobal
if bufexists(fnamemodify("~/Devel/Minos/src/Settings.hs", ":p")) | buffer ~/Devel/Minos/src/Settings.hs | else | edit ~/Devel/Minos/src/Settings.hs | endif
if &buftype ==# 'terminal'
  silent file ~/Devel/Minos/src/Settings.hs
endif
balt ~/Devel/Minos/src/Application.hs
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 58 - ((18 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 58
normal! 038|
wincmd w
wincmd =
if exists(':tcd') == 2 | tcd ~/Devel/Minos | endif
tabnext
edit ~/Devel/Minos/src/Foundation.hs
argglobal
balt ~/Devel/Minos/src/Model.hs
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 172 - ((32 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 172
normal! 021|
tabnext
edit ~/Devel/Minos/src/Judge/Problems.hs
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
wincmd =
argglobal
balt ~/Devel/Minos/src/Handler/Home.hs
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 1 - ((0 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
normal! 033|
wincmd w
argglobal
if bufexists(fnamemodify("~/Devel/Minos/src/Judge/Submissions.hs", ":p")) | buffer ~/Devel/Minos/src/Judge/Submissions.hs | else | edit ~/Devel/Minos/src/Judge/Submissions.hs | endif
if &buftype ==# 'terminal'
  silent file ~/Devel/Minos/src/Judge/Submissions.hs
endif
balt ~/Devel/Minos/src/Judge/Problems.hs
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 42 - ((37 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 42
normal! 015|
wincmd w
wincmd =
if exists(':tcd') == 2 | tcd ~/Devel/Minos | endif
tabnext
edit ~/Devel/Minos/src/Model.hs
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
wincmd =
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 14 - ((9 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 14
normal! 0
wincmd w
argglobal
if bufexists(fnamemodify("~/Devel/Minos/config/models.persistentmodels", ":p")) | buffer ~/Devel/Minos/config/models.persistentmodels | else | edit ~/Devel/Minos/config/models.persistentmodels | endif
if &buftype ==# 'terminal'
  silent file ~/Devel/Minos/config/models.persistentmodels
endif
balt ~/Devel/Minos/src/Model.hs
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 25 - ((16 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 25
normal! 024|
wincmd w
wincmd =
if exists(':tcd') == 2 | tcd ~/Devel/Minos | endif
tabnext
edit ~/Devel/Minos/config/routes.yesodroutes
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
wincmd =
argglobal
balt ~/Devel/Minos/config/models.persistentmodels
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 19 - ((18 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 19
normal! 039|
wincmd w
argglobal
if bufexists(fnamemodify("~/Devel/Minos/config/settings.yml", ":p")) | buffer ~/Devel/Minos/config/settings.yml | else | edit ~/Devel/Minos/config/settings.yml | endif
if &buftype ==# 'terminal'
  silent file ~/Devel/Minos/config/settings.yml
endif
balt ~/Devel/Minos/src/Settings.hs
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 8 - ((7 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 8
normal! 0
wincmd w
wincmd =
if exists(':tcd') == 2 | tcd ~/Devel/Minos | endif
tabnext
edit ~/Devel/Minos/package.yaml
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
wincmd =
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 53 - ((37 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 53
normal! 013|
wincmd w
argglobal
if bufexists(fnamemodify("~/Devel/Minos/config/settings.yml", ":p")) | buffer ~/Devel/Minos/config/settings.yml | else | edit ~/Devel/Minos/config/settings.yml | endif
if &buftype ==# 'terminal'
  silent file ~/Devel/Minos/config/settings.yml
endif
balt ~/Devel/Minos/package.yaml
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 18 - ((0 * winheight(0) + 22) / 45)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 18
normal! 0
wincmd w
wincmd =
if exists(':tcd') == 2 | tcd ~/Devel/Minos | endif
tabnext 1
set stal=1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
let g:this_session = v:this_session
let g:this_obsession = v:this_session
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
