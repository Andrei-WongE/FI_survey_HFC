/// Project: FI_Survey_Project -- Section F
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
	
	use "$data/f_institutional_arrangements_and-survey.dta", clear
		
	keep if status == "Submitted to Review" // 133 observations deleted
	keep if year == 2022 // 0 observations deleted

	//assert c(N) == 84
	
	//Create output files and setting charinclude
	global filename  "FI_survey_Section_F_HFC_"  // Change accordingly
	global filedate : di %tdCCYY.NN.DD date(c(current_date), "DMY") // date of the report
	
	local hfc_file "$base/Data/$filename$filedate.csv"

	export excel using  "$base/Data/$filename$filedate.csv", replace
	
	global id_info "country_code"
	
	foreach var of varlist _all {
		char `var'[charname] "`var'"

	
	//Check duplicate IDs
	sort country_code
	
	capture drop id_dup
	duplicates tag country_code, generate(id_dup) // Sort and Check for unique identifiers
		if _rc != 0 di "observations by country are NOT unique in country_code"
		else if _rc == 0 di "observations by country are unique in this section"
	
	listtab $id_info using `hfc_file' if id_dup == 1, delimiter(",") replace headlines("Duplicate Country ID") headchars(charname)	
	
/////////////////////////////////////////////////////////////
//// 1. Checks skip logic and missing values by section          ////
////////////////////////////////////////////////////////////
	
	
	///F1.1 What type(s) of legal framework exists in your country pertaining to financial consumer protection? Please mark all that apply.
	
	#delimit ;
	local var_1 f1_1_a_1	
				f1_1_b_1
				f1_1_c_1
				f1_1_d_1	
				f1_1_e_1			
				f1_1_f_1;
	 #delimit cr		
	 
	#delimit ;
	local var_2 f1_1_a_2
				f1_1_b_2
				f1_1_c_2
				f1_1_d_2
				f1_1_e_2
				f1_1_f_2;
	#delimit cr		 

	local n : word count `var_2'
	
	//Skip value, missing only, If f1_1_*_1 == No | NA, skip f1_1_*_2

	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`b') & `a' == "Yes")


	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F1.1 due to f1_1_*_1 == No | NA ")headchars(charname)
	   
	   
	///F1.2 What type(s) of regulations exist in your country pertaining to financial consumer protection topics?  Please mark all that apply.
	
	#delimit ;
	local var_1 f1_2_a_1	
				f1_2_b_1
				f1_2_c_1
				f1_2_d_1	
				f1_2_e_1;
	 #delimit cr		
	 
	#delimit ;
	local var_2 f1_2_a_2
				f1_2_b_2
				f1_2_c_2
				f1_2_d_2
				f1_2_e_2;
	#delimit cr		 

	local n : word count `var_2'
	
	//Skip value, missing only, If f1_2_*_1 == No | NA, skip f1_2_*_2

	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`b') & `a' == "Yes")


	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F1.2 due to f1_2_*_1 == No | NA ")headchars(charname)


	///F2. Please indicate which statement best describes the structure for financial consumer protection regulation and supervision in your country?   Please mark all that apply.  
	
	#delimit ;
	local var_1 f2_a_1	
				f2_b_1
				f2_c_1
				f2_d_1	
				f2_e_1;
	 #delimit cr		
	 
	#delimit ;
	local var_2 f2_a_2	
				f2_b_2
				f2_c_2
				f2_d_2	
				f2_e_2;
	#delimit cr		 

	local n : word count `var_2'
	
	//Skip value, missing only, If f2_*_1 == NA, skip f2_*_2

	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`b') & `a' == "Yes")


	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F2 due to f2_*_1 == NA ") headchars(charname)
	
	//Skip value, missing only, If f2_e_1== NA, skip f2_1_specify

	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if missing(f2_1_specify)& f2_e_1 == "Yes"

	listtab $id_info f2_1_specify skipcheck f2_e_1 if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F2 due to f2_e_1== NA")headchars(charname)


	///F3. Which of the following best describes the separate unit(s) or team(s) designated to implement, oversee and/or enforce aspects of financial consumer protection law or regulation in your agency?  Please mark all that apply.  
	
	#delimit ;
	local var_1 f3_1_1_theunito
				f3_1_2_theunito 
				f3_1_3_theunito
				f3_1_4_notapplic;
	 #delimit cr	
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in F3") headchars(charname)


	///F4. What are the main activities of the separate unit(s) or team(s) with respect to financial consumer protection for financial services providers?  Please mark all that apply.  

	#delimit ;
	local var_1 f4a_1_1_marketmon
				f4a_1_2_marketmon
				f4a_1_3_mysteryin 
				f4a_1_4_consumeri 
				f4a_1_5_onsitein 
				f4a_1_6_offsitei 
				f4a_1_7_thematic_r 
				f4a_1_8_enforcemen 
				f4a_1_9_collection;
	 #delimit cr	
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in F4") headchars(charname)

	
	//Skip value, missing only, If All f4a_1_* == No, skip f4a_2, f4a_3
	egen All_f4a_1_ = concat(f4a_1_*)
	gen count_o = length(All_f4a_1_) - length(subinstr(All_f4a_1_, "o", "", .)) // Number of o's is the length of the string MINUS the length of the string with the o's removed.

	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if count_o != 9 & (missing(f4a_2) | missing(f4a_3) ) // Double check
	
	listtab $id_info f4a_1_* skipcheck f4a_2 f4a_3 if skipcheck == 1 & count_o == 9, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F4 due to All f4a_1_* == No") headchars(charname)
	
	drop All_f4a_1_ count_o
	
	//Skip value, missing only, If f4b_1_1_regulation == No, skip f4b_2
	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if missing(f4b_2) & f4b_1_1_regulation == "Yes"

	listtab $id_info f4b_2 skipcheck f4b_1_1_regulation if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F4 due to f4b_1_1_regulation == No")headchars(charname)	
	
	
	//Skip value, missing only, If f4c_1  == No, skip f4c_2
	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if missing(f4c_1) & f4c_1 == "Yes"

	listtab $id_info f4c_2 skipcheck f4c_1 if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F4 due to f4c_1  == No") headchars(charname)		
	
	
	//Skip value, missing only, If All f4d_1_* == No, skip f4d_2
	egen All_f4d_1_ = concat(f4d_1_*)
	gen count_o = length(All_f4d_1_) - length(subinstr(All_f4d_1_, "o", "", .)) // Number of o's is the length of the string MINUS the length of the string with the o's removed.

	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if count_o != 9 & missing(f4d_2)
		
	listtab $id_info f4d_1_* skipcheck f4d_2 if skipcheck == 1 & count_o == 9, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F4 due to All f4d_1_* == No") headchars(charname)
	
	drop All_f4d_1_ count_o

	
	//Skip value, missing only, If All f4e_1_* == No, skip f4e_2
	egen All_f4e_1_ = concat(f4e_1_*)
	gen count_o = length(All_f4e_1_) - length(subinstr(All_f4e_1_, "o", "", .)) // Number of o's is the length of the string MINUS the length of the string with the o's removed.

	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if count_o != 9 & missing(f4e_2)
		
	listtab $id_info f4e_1_* skipcheck f4e_2 if skipcheck == 1 & count_o == 9, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F4 due to All f4e_1_* == No") headchars(charname)
	
	drop All_f4e_1_ count_o	
	
	//Comment: No skipping value forf4f_1 and f4f_2
	

	///F5 What corrective measures or enforcement actions can does your  agency take to enforce financial consumer protection laws and regulations?  Please mark all that apply and for each one, please indicate the number of times this action was taken in the most recent year for which data is available:  

	#delimit ;
	local var_1 f5_a_1
				f5_b_1
				f5_c_1
				f5_d_1
				f5_e_1
				f5_f_1
				f5_g_1
				f5_h_1
				f5_i_1
				f5_j_1
				f5_k_1
				f5_l_1
				f5_m_1
				f5_n_1
				f5_o_1
				f5_p_1;
	 #delimit cr
	 			
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in F5") headchars(charname)

	
		#delimit ;
	local var_1 f5_a_1
				f5_b_1
				f5_c_1
				f5_d_1
				f5_e_1
				f5_f_1
				f5_g_1
				f5_h_1
				f5_i_1
				f5_j_1
				f5_k_1
				f5_l_1
				f5_m_1
				f5_n_1
				f5_o_1
				f5_p_1;
	#delimit cr	
	 
	#delimit ;
	local var_2 f5_a_2
				f5_b_2
				f5_c_2
				f5_d_2
				f5_e_2
				f5_f_2
				f5_g_2
				f5_h_2
				f5_i_2
				f5_j_2
				f5_k_2
				f5_l_2
				f5_m_2
				f5_n_2
				f5_o_2
				f5_p_2;
	#delimit cr 
	 
	 local n : word count `var_2'
	
	//Skip value, missing only, If All f5_*_1 == No|NA, skip f5_*_2 and f5_*_3, BUT f5_*_3 never missing!

	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`b') & `a' == "Yes")

	
	listtab $id_info `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F5 due to All f5_*_1 == No|NA") headchars(charname)				
	
	//Comment: f5_*_2 labels are wrong! 125 instead of 1-25
	
	//Skip value, missing only, If f5_p_1 == No|NA, skip f5_p_2_1

	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if (missing(f5_p_2_1) & f5_p_1 == "Yes")

	listtab $id_info f5_p_2_1 skipcheck f5_p_1 if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F5 due to f5_p_1 == No|NA") headchars(charname)

	
					
	///F6.a  Does your agency collect aggregated consumer complaints data from supervised financial service providers or alternative dispute resolution entities (i.e. not directly from consumers)? 
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(f6_a)

	mdesc f6_a
	
	listtab $id_info f6_a if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in f6_a") headchars(charname)
	
	
	///F6.b What actions does it conduct in relation to complaints data (please specify for each type of institution, if different)?

	#delimit ;
	local var_1 f6b_1_1
				f6b_1_2
				f6b_1_3
				f6b_1_4
				f6b_1_5
				f6b_1_6
				f6b_2_1
				f6b_2_2
				f6b_2_3
				f6b_2_4
				f6b_2_5
				f6b_2_6
				f6b_3_1
				f6b_3_2
				f6b_3_3
				f6b_3_4
				f6b_3_5
				f6b_3_6
				f6b_4_1
				f6b_4_2
				f6b_4_3
				f6b_4_4
				f6b_4_5
				f6b_4_6
				f6b_5_1
				f6b_5_2
				f6b_5_3
				f6b_5_4
				f6b_5_5
				f6b_5_6;
	 #delimit cr	
	
	//Skip value, missing only, If f6_a == No/NA, skip f6b_* 
	capture drop skipcheck
	gen skipcheck = 0
		
	foreach i of local var_1 {
		replace skipcheck = 1 if missing(`i') & f6_a == "Yes"

	
	listtab $id_info f6b_* skipcheck f6_a if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F6b due to f6_a == No/NA") headchars(charname)		
	

	///F7a. Are minimum criteria for financial consumer protection analyzed as part of the licensing process for financial service providers?
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(f7a_1)

	mdesc f6_a
	
	listtab $id_info f7a_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in f7a_1") headchars(charname)
	
	
	///F7b. Please select all that apply:
	
	//Skip value, missing only, If f7b_1_3_other = No, skip f7b_1_specify
	
	capture drop skipcheck
	gen skipcheck = 0

	replace skipcheck = 1 if missing(f7b_1_specify) & f7b_1_3_other == "Yes"

	listtab $id_info f7b_1_specify skipcheck f7b_1_3_other if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F7b due to f7b_1_3_other = No") headchars(charname)	

	///F7c. Is the financial consumer protection licensing regime by financial services provider type (as opposed to by product type)? 
	
		//Comment: These values are authomatically populated. f7c_1 is empthy when f7a_1 == "No".
		
	///F7d. Please specify the financial consumer protection licensing categories by financial services provider type that apply :

		//Comment: These values are authomatically populated.


	///F8. Please provide details about the use of data and data analytics within your agency for the purposes of financial consumer protection/market conduct supervision 
	
	//WARNING: Why populated authomatically with No? Run: br f8a_1- f8d_6_name if strpos("BRB", country_code )
	
	/* CHANGE OF VARIABLES IN NEW DATABASE!!!!!!!!!!!
	#delimit ;
	local var_1 f8a_1
				f8a_2
				f8a_3
				f8a_4
				f8a_5
				f8a_6
				f8b_1
				f8b_2
				f8b_3
				f8b_4
				f8b_5
				f8b_6
				f8d_1
				f8d_2
				f8d_3
				f8d_4
				f8d_5
				f8d_6;
	 #delimit cr
	 			
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in F8") headchars(charname)

	
	//Skip value, missing only, If f8_1/6 == Other specify, skip f8a_*_specify
	
	#delimit ;
	local var_1 f8a_1
				f8a_2
				f8a_3
				f8a_4
				f8a_5
				f8a_6;
	#delimit cr 

	#delimit ;
	local var_2 f8a_1_specify
				f8a_2_specify
				f8a_3_specify
				f8a_4_specify
				f8a_5_specify
				f8a_6_specify;
	#delimit cr 
	
	local n : word count `var_2'
	
	capture drop skipcheck
	gen skipcheck = 0
		
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`b') & `a' == "Other specify")


	listtab $id_info `var_2' skipcheck `var_1' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F8 due to f8_1/6 == Other specify") headchars(charname)		

	
	
*/ //END of CHANGE of VARIABLES

	//Skip value, missing only, If f8c_1/6__1_webscrapi == No, skip f8_web_scraping_specify_1/6
	
	#delimit ;
	local var_1 f8c_1_1_webscrapi 
				f8c_2_1_webscrapi 
				f8c_3_1_webscrapi 
				f8c_4_1_webscrapi 
				f8c_5_1_webscrapi 
				f8c_6_1_webscrapi;
	#delimit cr 

	#delimit ;
	local var_2 f8_web_scraping_specify_1
				f8_web_scraping_specify_2
				f8_web_scraping_specify_3
				f8_web_scraping_specify_4
				f8_web_scraping_specify_5
				f8_web_scraping_specify_6;
	#delimit cr 
	
	local n : word count `var_2'
	
	capture drop skipcheck
	gen skipcheck = 0
		
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`b') & `a' == "Yes")


	listtab $id_info `var_2' skipcheck `var_1' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F8 due to f8c_1/6__1_webscrapi == No") headchars(charname)		

	//Skip value, missing only, If f8c_1/6_3_other == No, skip f8_other_specify_1/6
	
	#delimit ;
	local var_1 f8c_1_3_other
				f8c_2_3_other
				f8c_3_3_other
				f8c_4_3_other
				f8c_5_3_other
				f8c_6_3_other;
	#delimit cr 

	#delimit ;
	local var_2 f8_other_specify_1
				f8_other_specify_2
				f8_other_specify_3
				f8_other_specify_4
				f8_other_specify_5
				f8_other_specify_6;
	#delimit cr 
	
	local n : word count `var_2'
	
	capture drop skipcheck
	gen skipcheck = 0
		
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`b') & `a' == "Yes")


	listtab $id_info `var_2' skipcheck `var_1' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F8 due to f8c_1/6_3_other == No") headchars(charname)	
	
	
	
	//Skip value, missing only, If f8d_1/6 == No, skip f8_other_specify_1/6
	
	#delimit ;
	local var_1 f8d_1
				f8d_2
				f8d_3
				f8d_4
				f8d_5
				f8d_6;
	#delimit cr 

	#delimit ;
	local var_2 f8d_1_name
				f8d_2_name
				f8d_3_name
				f8d_4_name
				f8d_5_name
				f8d_6_name;
	#delimit cr 
	
	local n : word count `var_2'
	
	capture drop skipcheck
	gen skipcheck = 0
		
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`b') & `a' == "Yes")


	listtab $id_info `var_2' skipcheck `var_1' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in F8 due to f8d_1/6 == No") headchars(charname)	
	
	
