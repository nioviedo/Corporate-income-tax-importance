********************************************************************************
*Assess corporate tax relevance
********************************************************************************
*** Main inputs: various .csv and .xlsx, oecd_members.dta and pwt.dta
*** Output: tax_profit.dta
*** Author: Nicolas Oviedo
*** Original: 25/03/2021
********************************************************************************

********************************************************************************
*** Set up
********************************************************************************
cls
set more off
cap log close
*cd "C:\Users\Ovi\Desktop\R.A\Corporate taxes are important"
global input_data "D:\Data\inputs\cross_country_tax_data\corporate_taxes_importance"
global output_data "D:\Data\outputs\corporate_taxes_importance"

********************************************************************************
*** 2018
********************************************************************************
***Estimate profits/GDP using OECD national accounts

insheet using "SNA_TABLE1_25032021145730189.csv", comma clear

sort location year

order location country year transact transaction value

keep if year == 2018

by location: egen A = total(value) if transact =="D2_D3" | transact =="B2G_B3G"
by location: egen B = total(value) if transact == "B1_GI"
by location: egen C = total(A)
by location: egen gdp = total(B)
gen rk = [(C/2)/gdp]*100

collapse rk, by(location country year)

save rk.dta, replace

***Cleanse OECD data on corporate taxes as share of gdp and revenues
*Cleanse data
import excel ctp-2020-580-en-t016.xlsx, clear
drop A
drop in 1/7
drop in 41/44
compress
ren B country
ren C gdp_1990
ren D gdp_2000
ren E gdp_2010
ren F gdp_2017
ren G gdp_2018
ren H revenue_1990
ren I revenue_2000
ren J revenue_2010
ren K revenue_2017
ren L revenue_2018
drop in 1/1

replace country = "Belgium" in 3
replace country = "Denmark" in 8
replace country = "France" in 11
replace country = "Lithuania" in 22
replace country = "Luxembourg" in 23
replace country = "Switzerland" in 34

*Add rk
merge 1:1 country using rk, keepusing(rk)
drop if _merge == 1
drop _merge

*Generate tax_profit
destring(gdp_2018), replace
gen tax_profit = (gdp_2018/rk)*100
summ tax_profit, mean
gen unweight_avg=r(mean)

lab var rk "(Gross operating surplus and gross mixed income + Taxes less subsidies on production and imports)/GDP"
foreach yr in 1990 2000 2010 2017 2018{
lab var gdp_`yr' "Taxes on corporate income as % of GDP in year `yr'"
lab var revenue_`yr' "Taxes on corporate income (1200) as % of total tax revenue in year `yr'"
}
lab var tax_profit "Taxes on corporate income/(Gross operating surplus and gross mixed income + Taxes less subsidies on production and imports)"
lab var unweight_avg "Unweighted average of tax_profit"

save tax_profit, replace

***Add country codes
use tax_profit, clear
merge 1:1 country using "C:\Users\Ovi\Desktop\R.A\Data\outputs\oecd_members", keepusing(wb_code)
drop if _merge == 2 
move wb_code country
replace wb_code = "LUX" in 22
drop _merge
destring(revenue_2018), replace

save tax_profit, replace

***Gather 2018 real GDP from PWT
drop _all
tempfile penn
save `penn', emptyok
use "C:\Users\Ovi\Desktop\R.A\Data\inputs\pwt100",clear
ren countrycode wb_code
keep if year == 2018
compress
append using `penn'	
quietly save `penn', replace
use tax_profit, clear
gen year = 2018
merge 1:1 wb_code year using `penn', keepusing(cgdpo)
lab var cgdpo "Output-side real 2018 GDP at current PPPs (in mil. 2017US$)"
drop if _merge == 2
drop _merge
drop year

save tax_profit, replace


***Histograms***
use tax_profit, clear


summarize gdp_2018
local m=round(r(mean),0.01)
#delim ;
graph twoway (hist gdp_2018, bin(5) gap(2) frequency color(navy) plotregion(margin(b=0))) 
(scatteri 0 `m' 15 `m', recast(line) lcolor(red) lstyle(dot) )
(scatteri 14 `m' (12) "Mean = `m'", mlabsize(tiny) mlabangle(vertical) mlabcolor(red) c(l) m(i)),
legend(off)
ytitle("No. of countries")
xtitle("Taxes on corporate income as % of GDP in 2018")
caption("Source: OECD Revenue Statistics Database", size(vsmall))
;
#delim cr
gr export "corp_tax_gdp2018.png",replace

summarize revenue_2018
local m=round(r(mean),0.01)
#delim ;
graph twoway (hist revenue_2018, bin(5) gap(2) frequency color(emerald) plotregion(margin(b=0))) 
(scatteri 0 `m' 20 `m', recast(line) lcolor(red) lstyle(dot) )
(scatteri 18 `m' (12) "Mean = `m'", mlabsize(tiny) mlabangle(vertical) mlabcolor(red) c(l) m(i)),
legend(off)
ytitle("No. of countries")
xtitle("Taxes on corporate income as % of total tax revenue in 2018")
caption("Source: OECD Revenue Statistics Database", size(vsmall))
;
#delim cr
gr export "corp_tax_revenues2018.png",replace

summarize tax_profit
local m=round(r(mean),0.01)
#delim ;
graph twoway (hist tax_profit, bin(5) gap(2) frequency color(olive_teal) plotregion(margin(b=0))) 
(scatteri 0 `m' 20 `m', recast(line) lcolor(blue) lstyle(dot) )
(scatteri 18 `m' (12) "Mean = `m'", mlabsize(tiny) mlabangle(vertical) mlabcolor(blue) c(l) m(i)),
legend(off)
ytitle("No. of countries")
xtitle("Taxes on corporate income as % of gross estimated profits in 2018")
caption("Source: OECD Revenue Statistics Database", size(vsmall))
;
#delim cr
gr export "corp_tax_profits2018.png",replace

***Bar charts***


*****************************
use tax_profit, clear

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
caption("Source: OECD Revenue Statistics Database", size(vsmall))
;
#delim cr

gr export "countries_corp_tax_gdp2018.png",replace

********************************************************************************
*** Building time series
********************************************************************************
***Estimate profits/GDP using OECD national accounts
insheet using "SNA_TABLE1_01102021171317470.csv", comma clear
//source: https://stats.oecd.org/Index.aspx?datasetcode=SNA_TABLE1_ARCHIVE#

sort location year
order location country year transact transaction value
keep if measure == "C"

by location year: egen A = total(value) if transact =="D2_D3" | transact =="B2G_B3G"
by location year: egen B = total(value) if transact == "B1_GI"
by location year: egen C = total(A)
by location year: egen gdp = total(B)
gen rk = [(C/2)/gdp]*100
lab var rk "Gross profits + taxes on production / GDP at current prices"

collapse rk, by(location country year)
label data "Panel of profits/GDP for OECD 1950-2020"
gen var = "PIGDP"
gen indicator = "Gross profits over GDP"
ren rk value
order location country var indicator year value

save "$output_data/rk_1950_2020.dta", replace

***Cleanse OECD data on corporate taxes as share of gdp and revenues
//Cleanse data
insheet using "RS_GBL_01102021173736704.csv", comma clear

drop gov tax yea levelofgovernment
drop unitcode-referenceperiod
drop flagcodes flags
drop taxrevenue
ren cou location

//Add rk
append using "$output_data/rk_1950_2020.dta"
sort location year var

***Create the panel
drop indicator
reshape wide value, i(location year) j(var, string)
ren value* *
lab var PIGDP "Gross profits over GDP"
lab var TAXGDP "CIT revenue as % of GDP"
lab var TAXPER "CIT revenue as % of total taxation"
order location country year PIGDP TAXGDP TAXPER

replace PIGDP = PIGDP/100
replace TAXGDP = TAXGDP/100
replace TAXPER = TAXPER/100
gen TAXPI = TAXGDP*(1/PIGDP)
lab var TAXPI "CIT revenue over gross profits"

lab data "CIT importance panel for OECD 1950-2020"

save "$output_data/tax_profit_1950_2020", replace
