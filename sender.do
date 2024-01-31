import excel "C:\Users\rnunest\OneDrive - UvA\Desktop\Sex, lies and punishment\fulldata-clean-sender.xlsx", sheet("all_apps_wide-2023-02-07") firstrow


**
replace gender=0 if gender==2

**decisionb implies decision when seeing selfish outcome, decisiong implies decision when receiving prosocial outcome, gender means sender's gender with 1 male 0 female**

logit decisiong i.gender, vce(cluster residence)
eststo lie1
logit decisionb i.gender, vce(cluster residence)
eststo lie2
eststo lie:esttab lie1 lie2 using lie.tex,  se  star(* 0.10 ** 0.05 *** 0.01) replace


**nocluester
logit decisiong i.gender
eststo lie3
logit decisionb i.gender
eststo lie4
eststo lie:esttab lie3 lie4 using lie2.tex,  se  star(* 0.10 ** 0.05 *** 0.01) replace

**resoning for clustering**
eststo US: quietly estpost summarize decisiong decisionb if residence==1
eststo UK: quietly estpost summarize decisiong decisionb if residence==2
eststo Netherlands: quietly estpost summarize decisiong decisionb if residence==3
eststo residence: esttab US UK Netherlands using residence.tex, cells( "mean(pattern(1 1 1) fmt(2))"  "sd(pattern(1 1 1) fmt(2) par) ")  label addnote("Standard deviation in parentheses")  replace


***Note that people in the netherlands acted quite differently compared to people at the US and UK. There are two ways of solving this issue, or clustering by residence of not using their data
***logit decisiong i.gender if residence<3
