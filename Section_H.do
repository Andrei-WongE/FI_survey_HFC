/// Project: FI_Survey_Project -- Section H
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
	
	use "$data/h_fair_treatment_and_business_co-survey.dta", clear
		
	keep if status == "Submitted to Review" // 137 observations deleted
	keep if year == 2022 // 0 observations deleted

	//assert c(N) == 84
	
	//Create output files and setting charinclude
	global filename  "FI_survey_Section_H_HFC_"  // Change accordinly
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
	
	
	//H. Fair Treatment and Business Conduct 

	//Check duplicate IDs
	sort country_code
	
	capture drop id_dup
	duplicates tag country_code, generate(id_dup) // Sort and Check for unique identifiers
		if _rc != 0 di "observations by country are NOT unique in country_code"
		else if _rc == 0 di "Observations by country are unique in this section"
	
	listtab $id_info using `hfc_file' if id_dup == 1, delimiter(",") replace headlines("Duplicate Country ID") headchars(charname)
	
	///H1.For the following products types, are there provisions in law or regulation that require financial service providers to provide consumers with products only if they are determined to be appropriate  for a consumer’s specific needs and circumstances?  Please mark all that apply.

	#delimit ;
	local var_1 h_1_1_depositpr
				h_1_2_credit
				h_1_3_otherprod;
	 #delimit cr	

	#delimit ;
	
	local var_2 h_1_1
				h_1_2
				h_1_3;
	 #delimit cr	
	 
	 local n : word count `var_2'
	 
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'
	
	//Skip value, missing only, If h_1_1/3_* == NO, skip h_1_1/3

	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`b') & `a' == "Yes")

	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in H1") headchars(charname)

	listtab $id_info `var_2' skipcheck `var_1' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in H1 due to h_1_1/3_* == NO THEN skip h_1_1/3") headchars(charname)	
	

	///H2a. Are there provisions in law or regulation that restrict excessive borrowing by individuals and/or require financial service providers to assess affordability of credit for the prospective borrowers?  Please mark all that apply. 


	#delimit ;
	local var_1 h_2_1_debttoin
				h_2_2_restrictio
				h_2_3_creditpro
				h_2_4_other
				h_2_5_no;
	 #delimit cr
	 
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'

	//Skip value, missing only, If h_2_4_other == NO, skip h_2_1

	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if (missing(h_2_1) & h_2_4_other == "Yes")
	
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in H2a") headchars(charname)
	
	listtab $id_info h_2_1 skipcheck h_2_4_other if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in H2a due to h_2_4_other == No THEN SKIP h_2_1") headchars(charname)

	
	///H2b.  Are credit providers required to collect and validate any of the following type of information? 


	#delimit ;
	local var_1 h2b_a_1
				h2b_a_2
				h2b_b_1
				h2b_b_2
				h2b_c_1
				h2b_c_2;
	 #delimit cr
	 
	//Skip value, missing only, If h_2_3_creditpro == NO, skip h2b_a/c_1/2

	capture drop skipcheck
	gen skipcheck = 0
	
	foreach i of local var_1 {
		replace skipcheck = 1 if missing(`i') & h_2_3_creditpro == "Yes"



	listtab $id_info `var_1' skipcheck h_2_3_creditpro if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in H2b due to h_2_3_creditpro == NO THEN skip h2b_a/c_1/2") headchars(charname)	
	
		//Comment: Check Mozambique

	///H3a. Are there provisions in law or regulation that require financial service providers to do the following? 


	#delimit ;
	local var_1 h3a_a_1
				h3a_a_2
				h3a_a_3
				h3a_b_1
				h3a_b_2
				h3a_b_3
				h3a_c_1
				h3a_c_2
				h3a_c_3;
	 #delimit cr
	 
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in H3a") headchars(charname)



	///H3b. For the provision in law or regulation that require financial service providers to assess the target market for a new product, are they required to undertake the following?


	#delimit ;
	local var_1 h3a_c_1
				h3a_c_2
				h3a_c_3
				h3a_c_1
				h3a_c_2
				h3a_c_3;
	 #delimit cr
	 
	#delimit ;
	local var_2 h3b_a_1
				h3b_a_2
				h3b_a_3
				h3b_b_1
				h3b_b_2
				h3b_b_3;
	 #delimit cr	 
	 
	 local n : word count `var_2'
	 
	//Skip value, missing only, If h3a_c_1/3 == No, skip h3b_a/b_1/3

	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`b') & `a' == "Yes")


	
	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in H3b due to h3a_c_1/3 == No THEN skip h3b_a/b_1/3") headchars(charname)	


	///H4. Are there provisions in law or regulation that prohibit or restrict financial service providers from carrying out any of the following practices: Please mark all that apply.
	///H5. Are there any of the following provisions in law or regulation restricting terms and practices which can limit customer mobility between financial service providers?  Please mark all that apply.
	///H6. Are financial service providers required by law or regulation to have the appropriate governance and internal controls are in place to ensure that customers are treated fairly during the conduct of the following business processes?   Please mark all that apply.
	///H7. Are financial service providers required by law or regulation to have certain minimum level of professional competence for staff dealing with consumers?  
	///H8. Are financial service providers required by law or regulation to have certain minimum level of professional competence for agents dealing with consumers?   
	///H9. Are there provisions in law or regulation that establish minimum standards for debt collection practices?  
	///H10. Are financial service providers required by law or regulation to do any of the following regarding conflicts of interest? 
	
	#delimit ;
	local var_1 h4_1
				h4_2
				h4_3
				h4_4
				h4_5
				h5_1
				h5_2
				h5_3
				h5_4
				h6_1
				h6_2
				h6_3
				h7_1
				h8_1
				h9_1
				h10_1
				h10_2
				h10_3
				h10_4;
	 #delimit cr
	 
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in H4 to H10") headchars(charname)

	
	////END////

