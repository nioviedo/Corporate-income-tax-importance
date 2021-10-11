********************************************************************************
*** Relative importance of CIT
********************************************************************************



********************************************************************************
*** Set up
********************************************************************************
*cls
*set more off
*cap log close
*cd "C:\Users\Ovi\Desktop\R.A\Corporate taxes are important"
use "${pathinit}/outputs/corporate_taxes_importance/tax_profit", clear
set scheme s1color

********************************************************************************
*Histograms
********************************************************************************
***Corporate taxes out of GDP***
summarize gdp_2018
local m=round(r(mean),0.01)
#delim ;
graph twoway (hist gdp_2018, bin(5) gap(2) frequency color(navy) plotregion(margin(b=0))) 
(scatteri 0 `m' 15 `m', recast(line) lcolor(red) lstyle(dot) )
(scatteri 14 `m' (12) "Mean = `m'", mlabsize(tiny) mlabangle(vertical) mlabcolor(red) c(l) m(i)),
legend(off)
ytitle("No. of countries")
xtitle("Taxes on corporate income as % of GDP in 2018")
;
#delim cr
gr export "$figures/corp_tax_gdp2018.png",replace
//caption("Source: OECD Revenue Statistics Database", size(vsmall))

summarize revenue_2018
local m=round(r(mean),0.01)
#delim ;
graph twoway (hist revenue_2018, bin(5) gap(2) frequency color(emerald) plotregion(margin(b=0))) 
(scatteri 0 `m' 20 `m', recast(line) lcolor(red) lstyle(dot) )
(scatteri 18 `m' (12) "Mean = `m'", mlabsize(tiny) mlabangle(vertical) mlabcolor(red) c(l) m(i)),
legend(off)
ytitle("No. of countries")
xtitle("Taxes on corporate income as % of total tax revenue in 2018")
;
#delim cr
gr export "$figures/corp_tax_revenues2018.png",replace
//caption("Source: OECD Revenue Statistics Database", size(vsmall))

summarize tax_profit
local m=round(r(mean),0.01)
#delim ;
graph twoway (hist tax_profit, bin(5) gap(2) frequency color(olive_teal) plotregion(margin(b=0))) 
(scatteri 0 `m' 20 `m', recast(line) lcolor(blue) lstyle(dot) )
(scatteri 18 `m' (12) "Mean = `m'", mlabsize(tiny) mlabangle(vertical) mlabcolor(blue) c(l) m(i)),
legend(off)
ytitle("No. of countries")
xtitle("Taxes on corporate income as % of gross estimated profits in 2018")
;
#delim cr
gr export "$figures/corp_tax_profits2018.png",replace
//caption("Sources: OECD National Accounts Statistics and OECD Revenue Statistics Database", size(vsmall))


***Bar charts***
*gdp_2018
use "${pathinit}/outputs/corporate_taxes_importance/tax_profit", clear

sort gdp_2018
local b "highest"
local N _N
generate `b' = wb_code[`N']
di `b'
local a "lowest"
generate `a' = wb_code[1]
di `a'

gen gdpsort = -gdp_2018
summarize gdp_2018
local m=round(r(mean),0.01) 
gen cgdposort = - cgdpo
sort cgdposort
keep if _n < 11 | wb_code == `b' | wb_code == `a'
set obs 12
replace wb_code = "OECD" in 12
replace gdp_2018 = `m' in 12
replace gdpsort = -`m' in 12

separate gdp_2018, by(wb_code == "OECD")

#delim;
graph bar gdp_20180 gdp_20181, 
nofill over(wb_code, sort((sum) gdpsort)) bar(1, color(navy)) bar(2, color(ltblue)) 
legend(off)
ylab(0(1)6)
title("Taxes on corporate income as % of GDP in 2018")
;
#delim cr
gr export "$figures/countries_corp_tax_gdp2018.png",replace
//caption("Source: OECD Revenue Statistics Database", size(vsmall))

set scheme s2mono
#delim;
graph bar gdp_20180 gdp_20181, 
nofill over(wb_code, sort((sum) gdpsort)) bar(2, color(black)) 
legend(off)
ylab(0(1)6)
title("Taxes on corporate income as % of GDP in 2018")
caption("Source: OECD Revenue Statistics Database", size(vsmall))
;
#delim cr
gr export "$figures/bw_countries_corp_tax_gdp2018.png",replace

*revenue_2018
use "${pathinit}/outputs/corporate_taxes_importance/tax_profit", clear
set scheme s1color

sort revenue_2018
local b "highest"
local N _N
generate `b' = wb_code[`N']
di `b'
local a "lowest"
generate `a' = wb_code[1]
di `a'

gen revsort = -revenue_2018
summarize revenue_2018
local m=round(r(mean),0.01) 
gen cgdposort = - cgdpo
sort cgdposort
keep if _n < 11 | (wb_code == `b' | wb_code == `a')
set obs 13
replace wb_code = "OECD" in 13
replace revenue_2018 = `m' in 13
replace revsort = -`m' in 13

separate revenue_2018, by(wb_code == "OECD")

#delim;
graph bar revenue_20180 revenue_20181, 
nofill over(wb_code, sort((sum) revsort)) bar(1, color(emerald)) bar(2, color(dkgreen)) 
legend(off)
ylab(0(5)25)
title("Taxes on corporate income as % of tax revenues in 2018")
;
#delim cr
gr export "$figures/countries_corp_tax_revenues.png",replace
//caption("Source: OECD Revenue Statistics Database", size(vsmall))

set scheme s2mono
#delim;
graph bar revenue_20180 revenue_20181, 
nofill over(wb_code, sort((sum) revsort)) bar(2, color(black)) 
legend(off)
ylab(0(5)25)
title("Taxes on corporate income as % of tax revenues in 2018")
caption("Source: OECD Revenue Statistics Database", size(vsmall))
;
#delim cr
gr export "$figures/bw_countries_corp_tax_revenues.png",replace

/*For publishing*/
set scheme plotplain
#delim;
graph bar revenue_20180 revenue_20181, 
nofill over(wb_code, sort((sum) revsort)) bar(2, color(gs0) fcolor(gs0) fintensity(100)) 
legend(off)
ylab(0(5)25)
;
#delim cr
gr export "$figures/bw_countries_corp_tax_revenues_plotplain.png",replace

*tax_profit
use "${pathinit}/outputs/corporate_taxes_importance/tax_profit", clear
set scheme s1color

sort tax_profit
local b "highest"
local N _N
generate `b' = wb_code[`N']
di `b'
local a "lowest"
generate `a' = wb_code[1]
di `a'

gen taxsort = -tax_profit
summarize tax_profit
local m=round(r(mean),0.01) 
gen cgdposort = - cgdpo
sort cgdposort
keep if _n < 11 | wb_code == `b' | wb_code == `a'
set obs 12
replace wb_code = "OECD" in 12
replace tax_profit = `m' in 12
replace taxsort = -`m' in 12

separate tax_profit, by(wb_code == "OECD")

#delim;
graph bar tax_profit0 tax_profit1, 
nofill over(wb_code, sort((sum) taxsort)) bar(1, color(olive_teal)) bar(2, color(teal)) 
legend(off)
ylab(0(2)8)
title("Taxes on corporate income as % of estimated gross profits 2018", size(medium))
;
#delim cr
gr export "$figures/countries_corp_tax_profits2018.png",replace
//caption("Sources: OECD National Accounts Statistics and OECD Revenue Statistics Database", size(vsmall))

set scheme s2mono 
#delim;
graph bar tax_profit0 tax_profit1, 
nofill over(wb_code, sort((sum) taxsort)) bar(2, color(black)) 
legend(off)
ylab(0(2)8)
title("Taxes on corporate income as % of estimated gross profits 2018", size(medium))
caption("Sources: OECD National Accounts Statistics and OECD Revenue Statistics Database", size(vsmall))
;
#delim cr
gr export "$figures/bw_countries_corp_tax_profits2018.png",replace

********************************************************************************
*Black and white
********************************************************************************
***Histograms
use "${pathinit}/outputs/corporate_taxes_importance/tax_profit", clear
set scheme s2mono 

summarize gdp_2018
local m=round(r(mean),0.01)
#delim ;
graph twoway (hist gdp_2018, bin(5) gap(2) frequency plotregion(margin(b=0))) 
(scatteri 0 `m' 15 `m', recast(line) lstyle(dot) )
(scatteri 14 `m' (12) "Mean = `m'", mlabsize(tiny) mlabangle(vertical) c(l) m(i)),
legend(off)
ytitle("No. of countries")
xtitle("Taxes on corporate income as % of GDP in 2018")
caption("Source: OECD Revenue Statistics Database", size(vsmall))
;
#delim cr
gr export "$figures/bw_corp_tax_gdp2018.png",replace

summarize revenue_2018
local m=round(r(mean),0.01)
#delim ;
graph twoway (hist revenue_2018, bin(5) gap(2) frequency plotregion(margin(b=0))) 
(scatteri 0 `m' 20 `m', recast(line) lstyle(dot) )
(scatteri 18 `m' (12) "Mean = `m'", mlabsize(tiny) mlabangle(vertical) mlabcolor(black) c(l) m(i)),
legend(off)
ytitle("No. of countries")
xtitle("Taxes on corporate income as % of total tax revenue in 2018")
caption("Source: OECD Revenue Statistics Database", size(vsmall))
;
#delim cr
gr export "$figures/bw_corp_tax_revenues2018.png",replace

summarize tax_profit
local m=round(r(mean),0.01)
#delim ;
graph twoway (hist tax_profit, bin(5) gap(2) frequency plotregion(margin(b=0))) 
(scatteri 0 `m' 20 `m', recast(line) lstyle(dot) )
(scatteri 18 `m' (12) "Mean = `m'", mlabsize(tiny) mlabangle(vertical) mlabcolor(black) c(l) m(i)),
legend(off)
ytitle("No. of countries")
xtitle("Taxes on corporate income as % of gross estimated profits in 2018")
caption("Sources: OECD National Accounts Statistics and OECD Revenue Statistics Database", size(vsmall))
;
#delim cr
gr export "$figures/bw_corp_tax_profits2018.png",replace

