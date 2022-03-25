/// Project: FI_Survey_Project -- Section D
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
	
	use "$data/d_legal_regulatory_and_superviso-survey", clear
	
	merge 1:1 country_code year status using "$data/b_financial_sector_landscape_-survey.dta"
		
	keep if status == "Submitted to Review" // 137 observations deleted
	keep if year == 2022 // 0 observations deleted

	//assert c(N) == 84
	
	//Create output files and setting charinclude
	global filename  "FI_survey_Section_D_HFC_"  // Change accordinly
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
	

	///D. Legal, Regulatory and Supervisory Framework for Relevant Financial Service Providers
	
		//Comment: All section D is conditional con b1_1/6!

	//Check duplicate IDs
	sort country_code
	
	capture drop id_dup
	duplicates tag country_code, generate(id_dup) // Sort and Check for unique identifiers
		if _rc != 0 di "observations by country are NOT unique in country_code"
		else if _rc == 0 di "Observations by country are unique in this section"
	
	listtab $id_info using `hfc_file' if id_dup == 1, delimiter(",") replace headlines("Duplicate Country ID") headchars(charname)
	
	///D1. Please specify what authorities (if any) have a clear legal mandate for and are in charge of: i) issuing the following types of regulation for financial service providers, and ii) licensing, supervising, monitoring, and enforcing compliance with such regulation. Enter the name of the authority (or authorities).

	#delimit ;
	local var_1 d1_1_1
				d1_1_2
				d1_1_3
				d1_1_4
				d1_1_5
				d1_1_6
				d1_2_1
				d1_2_2
				d1_2_3
				d1_2_4
				d1_2_5
				d1_2_6
				d1_3_1
				d1_3_2
				d1_3_3
				d1_3_4
				d1_3_5
				d1_3_6
				d1_4_1
				d1_4_2
				d1_4_3
				d1_4_4
				d1_4_5
				d1_4_6
				d1_5_1
				d1_5_2
				d1_5_3
				d1_5_4
				d1_5_5
				d1_5_6;
	#delimit cr	
	 
	#delimit ;
	local var_2 b1_1
				b1_1
				b1_2
				b1_2
				b1_3
				b1_3
				b1_1
				b1_1
				b1_2
				b1_2
				b1_3
				b1_3
				b1_1
				b1_1
				b1_2
				b1_2
				b1_3
				b1_3
				b1_1
				b1_1
				b1_2
				b1_2
				b1_3
				b1_3
				b1_1
				b1_1
				b1_2
				b1_2
				b1_3
				b1_3;
	#delimit cr		
	
	local n : word count `var_2'
	 
	//Consitency checks of d1_1/5_1/6, only IF Commercial banks, Other banks and Financial cooperatives are regulated (B1_1/3==Yes)

	capture drop consischeck
	gen consischeck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace consischeck = 1 if ((`a'== "NA" & `b' == "Yes")| (`a' == "N/A" & `b' == "Yes")|(`a' == "" & `b' == "Yes"))
		//replace `a' = "NA" if consischeck == 1 


	listtab $id_info `var_1' consischeck `var_2' if consischeck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Consitency check of D1 variables: Answer only if Commercial banks, Other banks and Financial cooperatives are regulated") headchars(charname)
	
	
	#delimit ;
	local var_1 d1_2_1_1
				d1_2_1_2
				d1_2_1_3
				d1_2_1_4
				d1_2_1_5
				d1_2_1_6
				d1_2_2_1
				d1_2_2_2
				d1_2_2_3
				d1_2_2_4
				d1_2_2_5
				d1_2_2_6
				d1_2_3_1
				d1_2_3_2
				d1_2_3_3
				d1_2_3_4
				d1_2_3_5
				d1_2_3_6
				d1_2_4_1
				d1_2_4_2
				d1_2_4_3
				d1_2_4_4
				d1_2_4_5
				d1_2_4_6
				d1_2_5_1
				d1_2_5_2
				d1_2_5_3
				d1_2_5_4
				d1_2_5_5
				d1_2_5_6;
	#delimit cr	
	
	#delimit ;
	local var_2 b1_4
				b1_4
				b1_5
				b1_5
				b1_6
				b1_6
				b1_4
				b1_4
				b1_5
				b1_5
				b1_6
				b1_6
				b1_4
				b1_4
				b1_5
				b1_5
				b1_6
				b1_6
				b1_4
				b1_4
				b1_5
				b1_5
				b1_6
				b1_6
				b1_4
				b1_4
				b1_5
				b1_5
				b1_6
				b1_6;
	#delimit cr				
	
	local n : word count `var_2'
	 
	//Consitency checks of d1_2_1/5_1/6, only IF ODTIs, CCPs and NB-EMIs are regulated (B1_4/6==Yes)

	capture drop consischeck
	gen consischeck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace consischeck = 1 if ((`a'== "NA" & `b' == "Yes")| (`a' == "N/A" & `b' == "Yes")|(`a' == "" & `b' == "Yes"))
		//replace `a' = "NA" if consischeck == 1 


	listtab $id_info `var_1' consischeck `var_2' if consischeck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Consitency check of D1 variables: Answer only if DTIs, CCPs and NB-EMIs are regulated") headchars(charname)	
	
	
	///D2.1. Are "commercial banks" permitted to carry out the following activities? 

	#delimit ;
	local var_1	d2_1_a_1
				d2_1_b_1
				d2_1_c_1
				d2_1_d_1
				d2_1_e_1
				d2_1_f_1
				d2_1_g_1
				d2_1_h_1
				d2_1_i_1
				d2_1_j_1
				d2_1_k_1;
	#delimit cr	
	
	//Missing values, conditional on having regulated commercial banks
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & b1_1 == "No"


	//Cleaning
	
	foreach i of local var_1 {
		replace `i' = "NA" if b1_1 == "No"| b1_1 == "NA"


	listtab $id_info `var_1' mcheck b1_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in D2.1, on having regulated commercial banks") headchars(charname)
	
		//Comment: Is an explanation necesary if d2_1_a/k_1== Yes?

		
	///D2.2 Are "other banks" permitted to carry out the following activities?

	#delimit ;
	local var_1 d2_2_a_1
				d2_2_b_1				
				d2_2_c_1				
				d2_2_d_1				
				d2_2_e_1				
				d2_2_f_1				
				d2_2_g_1				
				d2_2_h_1				
				d2_2_i_1				
				d2_2_j_1
				d2_2_k_1;
	#delimit cr	

	
	//Missing values, conditional on having regulated other banks
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & b1_2 == "Yes"


	//Cleaning
	
	foreach i of local var_1 {
		replace `i' = "NA" if b1_2 == "No"| b1_2 == "NA"

	
	
	listtab $id_info `var_1' mcheck b1_2 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in D2.2, on having regulated other banks") headchars(charname)

		//Comment: Is an explanation necesary if d2_2_a/k_1== Yes?
		
	///D2.3 Are “financial cooperatives” permitted to carry out the following activities? 

	#delimit ;
	local var_1 d2_3_a_1				
				d2_3_b_1				
				d2_3_c_1				
				d2_3_d_1				
				d2_3_e_1				
				d2_3_f_1				
				d2_3_g_1				
				d2_3_h_1				
				d2_3_i_1				
				d2_3_j_1				
				d2_3_k_1;
	#delimit cr
	
	//Missing values, conditional on having regulated financial cooperatives
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & b1_3 == "Yes"


	//Cleaning
	
	foreach i of local var_1 {
		replace `i' = "NA" if b1_3 == "No"| b1_3 == "NA"

		
	listtab $id_info `var_1' mcheck b1_3 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in D2.3, on having regulated financial cooperatives") headchars(charname)

		//Comment: Is an explanation necesary if d2_3_a/k_1== Yes?

	///D2.4 Are “ODTIs” permitted to carry out the following activities?  

	#delimit ;
	local var_1 d2_4_a_1				
				d2_4_b_1				
				d2_4_c_1				
				d2_4_d_1				
				d2_4_e_1				
				d2_4_f_1				
				d2_4_g_1				
				d2_4_h_1				
				d2_4_i_1				
				d2_4_j_1				
				d2_4_k_1;
	#delimit cr
	
	//Missing values, conditional on having regulated ODTIs
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if `i' != "Not applicable" & b1_4 == "No"
	

	listtab $id_info `var_1' mcheck b1_4 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in D2.4, on having regulated ODTIs") headchars(charname)

	#delimit ;	
	local var_1	d2_4_a_2				 
				d2_4_b_2				 
				d2_4_c_2				 
				d2_4_d_2				 
				d2_4_e_2				 
				d2_4_f_2				 
				d2_4_g_2				 
				d2_4_h_2				 
				d2_4_i_2				 
				d2_4_j_2				 
				d2_4_k_2;
	#delimit cr
	
	#delimit ;
	local var_2 d2_4_a_1				
				d2_4_b_1				
				d2_4_c_1				
				d2_4_d_1				
				d2_4_e_1				
				d2_4_f_1				
				d2_4_g_1				
				d2_4_h_1				
				d2_4_i_1				
				d2_4_j_1				
				d2_4_k_1;
	#delimit cr
	
	local n : word count `var_2'	

	//Skipping, If d2_4_a_1 != Yes but restricted, skip d2_4_a/k_2
	
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`a') & `b' == "Yes but restricted")

	br $id_info `var_1' skipcheck `var_2' if skipcheck == 1

			
	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in D2.4 due to d2_4_a_1 != Yes but restricted, skip d2_4_a/k_2")headchars(charname)  


	
	///D2.5 Are “CCPs” permitted to carry out the following activities?


	#delimit ;
	local var_1 d2_5_a_1				 
				d2_5_b_1				 
				d2_5_c_1				 
				d2_5_d_1				 
				d2_5_e_1				 
				d2_5_f_1				 
				d2_5_g_1				 
				d2_5_h_1				 
				d2_5_i_1				 
				d2_5_j_1;
	#delimit cr
	
	//Missing values, conditional on having regulated CCPs
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if `i' != "Not applicable" & b1_5 != "Yes"
	
	br $id_info `var_1' mcheck b1_5 if mcheck == 1
	
	listtab $id_info `var_1' mcheck b1_5 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in D2.5, on having regulated CCPs") headchars(charname)

	#delimit ;	
	local var_1	d2_5_a_2				 
				d2_5_b_2				 
				d2_5_c_2				 
				d2_5_d_2				 
				d2_5_e_2				 
				d2_5_f_2				 
				d2_5_g_2				 
				d2_5_h_2				 
				d2_5_i_2				 
				d2_5_j_2;
	#delimit cr
	
	#delimit ;
	local var_2 d2_5_a_1				 
				d2_5_b_1				 
				d2_5_c_1				 
				d2_5_d_1				 
				d2_5_e_1				 
				d2_5_f_1				 
				d2_5_g_1				 
				d2_5_h_1				 
				d2_5_i_1				 
				d2_5_j_1;
	#delimit cr
	
	local n : word count `var_2'	

	//Skipping, If d2_5_a_1 != Yes but restricted, skip d2_5_a/k_2
	
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`a') & `b' == "Yes but restricted")

	br $id_info `var_1' skipcheck `var_2' if skipcheck == 1

			
	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in D2.5 due to d2_5_a_1 != Yes but restricted, skip d2_5_a/k_2")headchars(charname)  	
	
	

	///D2.6 Are “non-bank e-money issuers” permitted to carry out the following activities?

	#delimit ;
	local var_1 d2_6_a_1				 
				d2_6_b_1				 
				d2_6_c_1				 
				d2_6_d_1				 
				d2_6_e_1				 
				d2_6_f_1				 
				d2_6_g_1				 
				d2_6_h_1				 
				d2_6_i_1				 
				d2_6_j_1				 
				d2_6_k_1				 
				d2_6_l_1;
	#delimit cr
	
	//Missing values, conditional on having regulated non-bank e-money issuers
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if `i' != "Not applicable" & b1_6 != "Yes"
	
	br $id_info `var_1' mcheck b1_6 if mcheck == 1
	
	listtab $id_info `var_1' mcheck b1_6 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in D2.6, on having regulated non-bank e-money issuers") headchars(charname)

	#delimit ;	
	local var_2	d2_6_a_2				 
				d2_6_b_2				 
				d2_6_c_2				 
				d2_6_d_2				 
				d2_6_e_2				 
				d2_6_f_2				 
				d2_6_g_2				 
				d2_6_h_2				 
				d2_6_i_2				 
				d2_6_j_2				 
				d2_6_k_2				 
				d2_6_l_2;
	#delimit cr
	
	#delimit ;
	local var_2 d2_6_a_1				 
				d2_6_b_1				 
				d2_6_c_1				 
				d2_6_d_1				 
				d2_6_e_1				 
				d2_6_f_1				 
				d2_6_g_1				 
				d2_6_h_1				 
				d2_6_i_1				 
				d2_6_j_1				 
				d2_6_k_1				 
				d2_6_l_1;
	#delimit cr
	
	local n : word count `var_2'	

	//Skipping, If d2_6_a_1 != Yes but restricted, skip d2_6_a/l_2
	
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`a') & `b' == "Yes but restricted")

	br $id_info `var_1' skipcheck `var_2' if skipcheck == 1	
			
	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in D2.6 due to d2_6_a_1 != Yes but restricted, skip d2_6_a/l_2") headchars(charname)  	
	
	
	///D3a. As part of rulemaking process, does your agency have a formal process to consult with the industry?
	
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(d3_a)
	
	mdesc d3_a

	listtab $id_info d3_a if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in D3a") headchars(charname)
		

	///D3b. With what frequency do you consult with industry?
	///D3c. Through what channel do you consult with industry? (Mark all that apply)
	
	
	#delimit ;
	local var_1 d3_b
				d3_c_1_public_con
				d3_c_2_engagement 
				d3_c_3_statutory_ 
				d3_c_4_issuespec;
	#delimit cr
	
	//Missing values, conditional on having regulated non-bank e-money issuers
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & d3_a != "Yes"
	
	br $id_info `var_1' mcheck d3_a if mcheck == 1
		
	//Cleaning
			
			//Comment: Populates automatically No even if If d3_a = No|NA
	
	foreach i of local var_1 {
		replace `i' = "" if d3_a == "No"|d3_a == "NA"

	br $id_info `var_1' mcheck d3_a if mcheck == 1

	listtab $id_info `var_1' mcheck d3_a if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in D3b and D3c, on having a process to consult with the industry") headchars(charname)
	

	///D4a. As part of rulemaking process, does your agency have a formal process to consult with the consumers?
	
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(d4_a)
	
	mdesc d4_a

	listtab $id_info d4_a if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in D4a") headchars(charname)	

	///D4b. With what frequency do you consult with consumers?
	///D4c. Through what channel do you consult with consumers? (Mark all that apply) 
	
	#delimit ;
	local var_1 d4_b
				d4_c_1_public_con
				d4_c_2_engagement 
				d4_c_3_statutory_ 
				d4_c_4_issuespec;
	#delimit cr
	
	//Missing values, conditional on having regulated non-bank e-money issuers
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & d4_a != "Yes"
	
	br $id_info `var_1' mcheck d4_a if mcheck == 1
		
	//Cleaning
			
		//Comment: Populates automatically No even if If d4_a = No|NA
	
	foreach i of local var_1 {
		replace `i' = "" if d4_a == "No"|d4_a == "NA"

	br $id_info `var_1' mcheck d4_a if mcheck == 1

	listtab $id_info `var_1' mcheck d4_a if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in D4b and D4c, on having a process to consult with the industry") headchars(charname)


	
