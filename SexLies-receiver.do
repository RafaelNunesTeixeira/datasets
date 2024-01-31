 import excel "C:\Users\rnunest\OneDrive - UvA\Desktop\Sex, lies and punishment\Fulldata-clean.xlsx", sheet("all_apps_wide-2023-02-06") firstrow clear

**renaming variables**

rename age  ownage
rename gender owngender	

**changing missing data based on prolific data**
replace owngender=2 if owngender==3
replace owngender=0 if owngender==2

**reshape for painel data**
reshape long case place gender age signal decision, i(Id) j(obs)

xtset Id

**defining variables**
gen gend=1 if gender=="Male"
replace gend=0 if gender=="Female"
gen country=1 if place=="United States"
replace country=2 if place=="United Kingdom"
replace country=3 if place=="Netherlands" 
gen idade=1 if age=="20-30"
replace idade=2 if age=="30-40"
gen gendb=1 if genderb=="Male"
replace gendb=0 if genderb=="Female"
gen trend=0
replace trend=1 if obs>7


**Results**

**signal==2 imples selfish outcome, signal==1 implies prosocial outcome**
**decision=1 imples punish**

**regression for punish for selfish outcomes**
xtlogit decision i.gend if signal==2
eststo g1

**controling for the other demographics**
xtlogit decision i.gend i.idade i.country if signal==2
coefplot, drop(_cons) xline(0) aseq
eststo g2
**regression for prosocial outcomes**
xtlogit decision i.gend if signal==1
eststo g3

**controling for demographics**
xtlogit decision i.gend i.idade i.country if signal==1
eststo g4

**robustness check**
xtlogit decision i.gend##i.idade i.gend##i.country if signal==2
eststo g5
xtlogit decision i.gend##i.idade i.gend##i.country if signal==1
eststo g6
eststo pun:esttab g1 g2 g3 g4 using pun.tex, se  star(* 0.10 ** 0.05 *** 0.01) replace
eststo pun2:esttab g2 g5 g4 g6 g5 using pun2.tex, se  star(* 0.10 ** 0.05 *** 0.01) replace

**In-group bias and trend**
xtlogit decision i.gend##i.owngender if signal==2
eststo inbias
xtlogit decision i.gend##i.trend if signal==2
eststo trend
eststo trend:esttab inbias trend trend using trend.tex, se  star(* 0.10 ** 0.05 *** 0.01) replace
gen signal2=signal-1
xtlogit signal2 i.gend##i.trend 
eststo trend2
eststo trend2:esttab trend trend2 using trend2.tex, se  star(* 0.10 ** 0.05 *** 0.01) replace


*****Channels***
**gendb is gender observed in the norm elicitation, 1 male, 0 female**
**empirical**

**empblue implies selfish lie, empgreen implies prosocial lie**
**regressions**
eststo emp1: quietly reg empblue i.gendb if obs==1
eststo emp2: quietly reg empgreen i.gendb if obs==1
eststo emp:esttab emp1 emp2 using emp.tex, se  star(* 0.10 ** 0.05 *** 0.01) replace


**normblue implies selfish lie, normgreen implies selfish truth**
**regressions**
eststo norm1: quietly ologit normblue i.gendb if obs==1
eststo norm2: quietly ologit normgreen i.gendb if obs==1
eststo norm:esttab norm1 norm2 using norm.tex, se  star(* 0.10 ** 0.05 *** 0.01) replace


**perception
**per1 - malicious, per2 - rational, per3 - emotional, per4 - situation, per5 - mistake
eststo per1: quietly ologit per1 i.gendb if obs==1
eststo per2: quietly ologit per2 i.gendb if obs==1
eststo per3: quietly ologit per3 i.gendb if obs==1
eststo per4: quietly ologit per4 i.gendb if obs==1
eststo per5: quietly ologit per5 i.gendb if obs==1
eststo per:esttab per1 per2 per3 per4 per5 using per.tex, se  star(* 0.10 ** 0.05 *** 0.01) replace

**channels**
eststo chan: logit decision empblue normblue normgreen per1 per2 per3 per4 per5 if signal==2
eststo chan1: logit decision empblue if signal==2
eststo chan2: logit decision normblue normgreen  if signal==2
eststo chan3: logit decision per1 per2 per3 per4 per5 if signal==2
eststo channel:esttab chan1 chan2 chan3 chan using channel.tex, se  star(* 0.10 ** 0.05 *** 0.01) replace

**robustness check for channels**
eststo mchan: logit decision empblue normblue normgreen per1 per2 per3 per4 per5 if signal==2 & gendb==gend
eststo mchan1: logit decision empblue if signal==2 & gendb==gend
eststo mchan2: logit decision normblue normgreen  if signal==2 & gendb==gend
eststo mchan3: logit decision per1 per2 per3 per4 per5 if signal==2 & gendb==gend
eststo mchannel:esttab mchan1 mchan2 mchan3 mchan using mchannel.tex, se  star(* 0.10 ** 0.05 *** 0.01) replace

****appendix

eststo male: quietly estpost summarize ownage residence brother if obs==1 & owngender==1
eststo female: quietly estpost summarize ownage residence brother if obs==1 & owngender==0
eststo diff: quietly estpost ttest ownage residence brother if obs==1, by(owngender) unequal
eststo summ: esttab male female diff using sum.tex, cells( "mean(pattern(1 1 0) fmt(2)) b(star pattern(0 0 1) fmt(2))"  "sd(pattern(1 1 0) fmt(2) par)  p(pattern(0 0 1) par([ ]) fmt(2))")  label addnote("* p<0.05, ** p<0.01, *** p<0.001""Standard deviation in parentheses""t statistics in brackets")  replace


**comparing first and second order for each elicitation**

replace per1=perc21 if obs==2
replace per2=perc22 if obs==2
replace per3=perc23 if obs==2
replace per4=perc24 if obs==2
replace per5=perc25 if obs==2
eststo pso: quietly estpost summarize per1 per2 per3 per4 per5 if obs==1
eststo pfo:  quietly estpost summarize per1 per2 per3 per4 per5 if obs==2
eststo pdiff: quietly estpost ttest per1 per2 per3 per4 per5 if obs<3, by(obs)
eststo summ: esttab pso pfo pdiff using pfs.tex, cells( "mean(pattern(1 1 0) fmt(2)) b(star pattern(0 0 1) fmt(2))"  "sd(pattern(1 1 0) fmt(2) par)  p(pattern(0 0 1) par([ ]) fmt(2))")  label addnote("* p<0.1, ** p<0.05, *** p<0.01""Standard deviation in parentheses""t statistics in brackets")  replace

replace normblue=normblue2 if obs==2
replace normgreen=normgreen2 if obs==2
eststo nso: reg empblue i.gendb
eststo nfo:  reg empblue i.gendb
eststo ndiff: quietly estpost ttest normblue normgreen if obs<3, by(obs)
eststo summ: esttab nso nfo ndiff using nfs.tex, cells( "mean(pattern(1 1 0) fmt(2)) b(star pattern(0 0 1) fmt(2))"  "sd(pattern(1 1 0) fmt(2) par)  p(pattern(0 0 1) par([ ]) fmt(2))")  label addnote("* p<0.1, ** p<0.05, *** p<0.01""Standard deviation in parentheses""t statistics in brackets")  replace

