/// Project: FI_Survey_Project -- Section I
///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------
/// Program Setup
///-----------------------------------------------------------------------------

    version 16              // Set Version number for backward compatibility
    set more off             // Disable partitioned output
    clear all               // Start with a clean slate
    set linesize 80         // Line size limit to make output more readable
    macro drop _all         // Clear all macros
    capture log close       // Close existing log files
	
///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------

    /* RUNS THE FOLLOWING:
	0. Import files and HFC file set-up  
	1. Checks skip logic and missing values by section
    2. Cleaning variables by section
        //Finds long variable include
        //Saves original variables order
        //General cleaning
    3. Label variables
    4. Order variables in original sequence and saves dta

    */
///-----------------------------------------------------------------------------

    //Set directory
	include "Global_macro_A.do"
	
	global data "D:/Documents/Consultorias/World_Bank/FI_Survey_Project/Data/Database `dir'"
			
	global output "D:/Documents/Consultorias/World_Bank/FI_Survey_Project/OUTPUT"
	

	
    //Install required packages
	//ssc install listtab
	
/////////////////////////////////////////////////////////////
//// 0. Import files and HFC file set-up          ////
////////////////////////////////////////////////////////////
	
	use "$data/i_complaints_handling_dispute_re-survey", clear
	
	merge 1:1 country_code year status using "$data/b_financial_sector_landscape_-survey.dta"
		
	keep if status == "Submitted to Review" // 137 observations deleted
	keep if year == 2022 // 0 observations deleted

	//assert c(N) == 84
	
	//Create output files and setting charinclude
	global filename  "FI_survey_Section_I_HFC_"  // Change accordinly
	global filedate : di %tdCCYY.NN.DD date(c(current_date), "DMY") // date of the report
	
	local hfc_file "$base/Data/$filename$filedate.csv"

	export excel using  "$base/Data/$filename$filedate.csv", replace
	
	global id_info "country_code"
	
	foreach var of varlist _all {
		//di `"`: var label `var''"' 
		char `var'[charname] "`var'" 

	
/////////////////////////////////////////////////////////////
//// 1. Checks skip logic and missing values by section          ////
////////////////////////////////////////////////////////////
	
	
	//I. Complaints Handling, Dispute Resolution, and Recourse

	//Check duplicate IDs
	sort country_code
	
	capture drop id_dup
	duplicates tag country_code, generate(id_dup) // Sort and Check for unique identifiers
		if _rc != 0 di "observations by country are NOT unique in country_code"
		else if _rc == 0 di "Observations by country are unique in this section"
	
	listtab $id_info using `hfc_file' if id_dup == 1, delimiter(",") replace headlines("Duplicate Country ID") headchars(charname)
	
	///I1a. Does any law or regulation set standards for internal complaints handling by financial service providers?  Please indicate all that apply
	
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(i1a)
	
	mdesc i1a
	
	listtab $id_info i1a if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in I1a") headchars(charname)

	///I1b.Please indicate for each type of provider if standards for internal complaints handling exist by law or regulation 

	#delimit ;
	local var_1 i1b_1
				i1b_2
				i1b_3
				i1b_4
				i1b_5
				i1b_6;
	#delimit cr		
	
	#delimit ;
	local var_2 b1_2
				b1_3
				b1_4
				b1_5
				b1_6;
	#delimit cr		
	
	local n : word count `var_2'	
	
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'	

	//Skip value, missing only, If b1_1/6 == Yes, then i1b_1/6 == NA
	
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (`a' != "NA" & `b' == "Yes")|(missing(`a') )


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in I1b") headchars(charname)

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in I1b due to b1_1/6 == NA|No THEN i1b_1/6 == NA") headchars(charname)  
	
	
	///I1.2 Does any law or regulation set standards in any of the following areas for internal complaints handling by financial service providers?   Please mark all that apply. 
	
	#delimit ;
	local var_1 i1_2_1_1_requiremen
				i1_2_1_2_requiremen
				i1_2_1_3_timeliness
				i1_2_1_4_accessibil 
				i1_2_1_5_recordkee 
				i1_2_1_6_standardiz 
				i1_2_1_7_standardiz
				i1_2_1_8_providing 
				i1_2_1_9_undertakin 
				i1_2_1_10_informing;
	#delimit cr	
	
	//Skip value, missing only, If i1a ==No|NA, then i1_2_1_1/10_* ==""

	capture drop skipcheck
	gen skipcheck = 0
		
	foreach i of local var_1 {
		replace skipcheck = 1 if `i' != "" & (i1a == "No"|i1a == "NA")



	listtab $id_info `var_1' skipcheck i1a if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in I1.2 due to i1a ==No|NA THEN i1_2_1_1/10_* == ") headchars(charname)	


	///I2.  Is there any out-of-court alternative dispute resolution (ADR) entity in place (e.g. ombudsman) that allows a customer of a financial service provider to seek recourse if the customer’s complaint is not resolved to their satisfaction by the relevant financial service provider?  Please mark all that apply. 
	
	
	#delimit ;
	local var_1	i2_1_1_yesasche
				i2_1_2_yesasche 
				i2_1_3_yesasche
				i2_1_4_nodispute;
	#delimit cr				

	
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in I2") headchars(charname)

	//Skip value, missing only, Ii2_1_4_nodispute == Yes THEN End of module (No questions I3a, I3b, I4 to I12, I13.1 to I13.4)
	
	
	#delimit ;
	local var_1	i3b_1
				i3b_2
				i4_1_1_commercial 
				i4_1_2_otherbank
				i4_1_3_financial 
				i4_1_4_odtis
				i4_1_5_ccps
				i4_1_6_nbemis
				i5_1
				i6_1
				i7_1
				i8_1
				i9_1_1_fromabud
				i9_1_2_fromabud
				i9_1_3_byafinan
				i9_1_4_bydirect
				i10_1
				i11_1
				i11_2
				i11_3
				i11_4
				i11_5
				i13_2_a
				i13_2_b
				i13_2_c
				i13_2_d
				i13_2_e
				i13_2_f
				i13_2_g
				i13_2_h
				i13_2_i
				i13_2_j
				i13_2_k
				i13_2_l
				i13_2_m
				i13_1_n
				i13_3_a
				i13_3_b
				i13_3_c
				i13_3_d
				i13_3_e
				i13_3_f
				i13_3_g
				i13_3_h
				i13_3_i
				i13_3_j
				i13_3_k
				i13_3_l
				i13_4_a
				i13_4_b
				i13_4_c
				i13_4_d
				i13_4_e
				i13_4_f;
	#delimit cr			
	
	
	capture drop skipcheck
	gen skipcheck = 0
		
	foreach i of local var_1 {
		dis "`i' "
		replace skipcheck = 1 if `i' != "" & (i2_1_4_nodispute == "Yes")


	listtab $id_info `var_1' skipcheck i2_1_4_nodispute if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in I2 due to  i2_1_4_nodispute == Yes THEN End of module") headchars(charname)		
	
		//Comment: check numeric, SEE I12
			/*i12_a_1
			i12_a_2
			i12_a_3
			i12_b_1
			i12_b_2
			i12_b_3*/

	///I3a. Please provide the name of the ADR entity for which you are responding:  
	///I3b. Does your ADR entity provide services free of charge or at a cost? 
	
	
	#delimit ;
	local var_1	i3_1
				i3b_1;
	#delimit cr				

	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if  missing(`i') & (i2_1_4_nodispute == "Yes")

	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in I3a and I3b") headchars(charname)
	
	//Skip value, missing only, If i3b_1 == At a cost please explain, i3b_2 != ""

	capture drop skipcheck
	gen skipcheck = 0
		
	replace skipcheck = 1 if i3b_2 != "" & (i3b_1  == "At a cost please explain" & i2_1_4_nodispute == "No")

	listtab $id_info i3b_2 skipcheck i3b_1 if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in I3b due to i3b_1 == At a cost please explain THEN i3b_2 !=  ") headchars(charname)	
	

	///I4. Which institutional categories are covered by the ADR entity specified in I3?   Please mark all that apply. 

	#delimit ;
	local var_1	i4_1_1_commercial 
				i4_1_2_otherbank
				i4_1_3_financial 
				i4_1_4_odtis
				i4_1_5_ccps
				i4_1_6_nbemis;
	#delimit cr				

	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if  missing(`i') & (i2_1_4_nodispute == "No")


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in I4") headchars(charname)
		
		//Comment:  Automatically populates with No even if i2_1_4_nondispute == Yes
	
	///I5. Please indicate whether : 
	
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if  missing(i5_1) & (i2_1_4_nodispute == "No")
	
	listtab $id_info i5_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in I5") headchars(charname)	
	
	///I6. If it is a statutory/government run scheme, is it: 
	///I7. Please also indicate whether such scheme:  
	///I8. If the ADR entity is housed within the financial sector regulator, please indicate whether it is  


	#delimit ;
	local var_1	i6_1
				i7_1;
	#delimit cr				

	//Skip value, missing only, If i5_1 !=It is a statutorygovernment run scheme, skip I6 to I8	AND
	
	capture drop skipcheck
	gen skipcheck = 0

	foreach i of local var_1 {	
		replace skipcheck = 1 if `i' != "" & (i5_1  == "It is a statutorygovernment run scheme" & i2_1_4_nodispute == "No")


	listtab $id_info `var_1' skipcheck i5_1 if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in I6 and I7 due to i5_1  == It is a statutorygovernment run scheme THEN skip I6 to I8") headchars(charname)	
			

	//Skip value, missing only, If i5_1 !=It is a statutorygovernment run scheme, skip I6 to I8	AND
	//                          If i7_1 = Is independent from the financial sector regulator, SKIP I8	
	
	capture drop skipcheck
	gen skipcheck = 0

	replace skipcheck = 1 if i8_1 == "" & (i7_1 == "Is housed within the financial sector regulator" & i5_1  == "It is a statutorygovernment run scheme" & i2_1_4_nodispute == "No")
	
	listtab $id_info i8_1 skipcheck i7_1 i5_1 if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in I8 due to i7_1 = Is independent from the financial sector regulator AND i5_1  == It is a statutorygovernment run scheme THEN skip I8") headchars(charname)		
	
	
	///I9. Regarding the ADR entity specified in I3, how is it funded? Please mark all that apply. 
	///I10. Does the ADR entity require that consumers first submit their complaints to the relevant financial service provider? 
	///I11. Does the ADR entity conduct any of the following activities? (Please mark all that apply) 

	#delimit ;
	local var_1	i9_1_1_fromabud
				i9_1_2_fromabud
				i9_1_3_byafinan
				i9_1_4_bydirect
				i10_1
				i11_1
				i11_2
				i11_3
				i11_4
				i11_5;
	#delimit cr		

	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if  !missing(`i') & (i2_1_4_nodispute == "No")


	listtab $id_info `var_1' mcheck i2_1_4_nodispute if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in I9, I10 and I11") headchars(charname)
			
	
		//Comment: I9 Automatically populates with No even if i2_1_4_nondispute == Yes
		//Comment: Skipping due to Ii2_1_4_nodispute == Yes, checked above, SEE line 219
		

	///I12. Please provide the following statistics for the operations of ADR entity in [2020] or the most recent year for which data is available. (Please provide the year) 
	
		
	#delimit ;
	local var_1 i12_a_1
				i12_a_2
				i12_a_3
				i12_b_1
				i12_b_2
				i12_b_3;
	 #delimit cr	
	 
	//Consitency checks of statistics for the operations of ADR entity in [2020] or the most recent year for which data is available [Numeric]	

	capture drop consischeck
	gen consischeck = 0	
	
	foreach i of local var_1 {
		capture confirm numeric var `i' if 
		if _rc == 0 {
		display "Variables are fine"
	
		
		display "Variables have problems"
		replace consischeck = 1
	   }	

	
	listtab $id_info `var_1' currency_type if consischeck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Non numeric values of I12:Statistics for the operations of ADR entity") headchars(charname)	

	///I13.1 What are the most frequent reasons for complaints received by the ADR entity related to financial consumer protection? Please rank the top most frequent issues and products complained about by assigning numbers 1, 2, 3, 4 and 5 with 1 being the most frequent. I13.2 Select the top 3 issues/products/distribution channels most complained about
	///I13.3 Rank the top 3 products most complained about
	///I13.4 Rank the top 3 distribution channels most complained about

	#delimit ;
	local var_1 i13_2_b
				i13_2_c
				i13_2_d
				i13_2_e
				i13_2_f
				i13_2_g
				i13_2_h
				i13_2_i
				i13_2_j
				i13_2_k
				i13_2_l
				i13_2_m;
	#delimit cr		
	
	
	#delimit ;
	local var_2	i13_3_a
				i13_3_b
				i13_3_c
				i13_3_d
				i13_3_e
				i13_3_f
				i13_3_g
				i13_3_h
				i13_3_i
				i13_3_j
				i13_3_k
				i13_3_l;
	#delimit cr	
	
	
	#delimit ;
	local var_3 i13_4_a
				i13_4_b
				i13_4_c
				i13_4_d
				i13_4_e
				i13_4_f;
	 #delimit cr	
	
	destring `var_1' `var_2' `var_3', replace
	
	capture drop i13_2_total
	egen i13_2_total = rowtotal(`var_1'), missing

	br i13_2_total `var_1'
	//Consitency check, ranking form 1 to 5, unique values
	
	//Double check!!!
	
	
	//Missing values, Need to have Text
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(i13_1_n) & (!missing(i13_2_m) & i2_1_4_nodispute == "No")

	listtab $id_info i13_1_n mcheck i13_2_m if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in I9, I10 and I11") headchars(charname)
	
	
	////END////

