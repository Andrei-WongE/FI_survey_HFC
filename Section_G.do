/// Project: FI_Survey_Project -- Section G
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
	
	use "$data/g_disclosure-survey.dta", clear
	
	merge 1:1 country_code year status using "$data/b_financial_sector_landscape_-survey.dta"
	
	keep if status == "Submitted to Review" // 137 observations deleted
	keep if year == 2022 // 0 observations deleted

	//assert c(N) == 84
	
	//Create output files and setting charinclude
	global filename  "FI_survey_Section_G_HFC_"  // Change accordinly
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
		
	///G1.1, Are there any requirements (law or regulation) for financial service providers to provide information to consumers in a document with a standardized format in paper or electronic form (e.g. key facts statement, disclosure statement, summary sheet)? Please mark all that apply. 


	#delimit ;
	local var_1 g1_1_1
				g1_1_2
				g1_1_3
				g1_1_4
				g1_1_5
				g1_1_6
				g1_1_2_1
				g1_1_2_2
				g1_1_2_3
				g1_1_2_4
				g1_1_2_5
				g1_1_2_6;
	 #delimit cr
	 			
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in G1.1") headchars(charname)


	///G1.2 Are there any requirements (law or regulation) to provide information to consumers in a document with a standardized format in paper or electronic form (e.g. key facts statement, disclosure statement, summary sheet) during each of the three transaction stages? Please mark all that apply.

	#delimit ;
	local var_1 g1_2_1
				g1_2_2
				g1_2_3;
	 #delimit cr
	 			
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in G1.2") headchars(charname)
	

	///G2. If financial service providers are required to use a document with a standardized format, is the standardized format tested with consumers to determine whether information provided is easy to understand and allows consumers to make an informed choice?


	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(g2_1)

	mdesc g2_1
	
	listtab $id_info g2_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in G2") headchars(charname)
	
	
	///G3. By law or regulation, at the shopping and/or pre-contractual stage, do the disclosure requirements cover:
	 
	#delimit ;
	local var_1 g3_1_1
				g3_1_2
				g3_1_3
				g3_1_4
				g3_1_5
				g3_2_1
				g3_2_2
				g3_2_3
				g3_2_4
				g3_2_5
				g3_3_1
				g3_3_2
				g3_3_3
				g3_3_4
				g3_3_5
				g3_4_1
				g3_4_2
				g3_4_3
				g3_4_4
				g3_4_5;
	#delimit cr		
	
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in G3") headchars(charname)
	
		
   //Consistency check, If g2_1 == No|NA then ALL g3_1/4_1/5 = NA (No to disclosure requirements)
    capture drop consistcheck
	gen consistcheck = 0
	
	foreach i of local var_1 {
		replace consistcheck = 1 if `i' != "NA" & g2_1 == "No"


	listtab $id_info `var_1' consistcheck g2_1 if consistcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Consistency check of G2 due to disclosure requirements [b2_b == No THEN g3_1/4_1/5 = NA]") headchars(charname)  
	//Comment lots of countries have not followed this reasoning.
	


	///G4. By law or regulation, are financial service providers required to provide their customers with periodic statements after a product or service is first acquired? 

	#delimit ;
	local var_1 g4_a_1
				g4_a_2
				g4_a_3
				g4_a_4
				g4_a_5
				g4_a_6
				g4_b_1
				g4_b_2
				g4_b_3
				g4_b_4
				g4_b_5
				g4_b_6
				g4_c_1
				g4_c_2
				g4_c_3
				g4_c_4
				g4_c_5
				g4_c_6
				g4_d_1
				g4_d_2
				g4_d_3
				g4_d_4
				g4_d_5
				g4_d_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6;
	#delimit cr		
	
	//Missing values, Need to have Yes/No
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in G4") headchars(charname)
	
	
	///G5. By law or regulation, do the disclosure requirements for periodic statements mentioned in question G4 above cover:


	#delimit ;
	local var_1 g5_1_a_1
				g5_1_a_2
				g5_1_a_3
				g5_1_a_4
				g5_1_a_5
				g5_1_a_6
				g5_1_b_1
				g5_1_b_2
				g5_1_b_3
				g5_1_b_4
				g5_1_b_5
				g5_1_b_6
				g5_2_a_1
				g5_2_a_2
				g5_2_a_3
				g5_2_a_4
				g5_2_a_5
				g5_2_a_6
				g5_2_b_1
				g5_2_b_2
				g5_2_b_3
				g5_2_b_4
				g5_2_b_5
				g5_2_b_6
				g5_2_c_1
				g5_2_c_2
				g5_2_c_3
				g5_2_c_4
				g5_2_c_5
				g5_2_c_6
				g5_2_d_1
				g5_2_d_2
				g5_2_d_3
				g5_2_d_4
				g5_2_d_5
				g5_2_d_6
				g5_2_e_1
				g5_2_e_2
				g5_2_e_3
				g5_2_e_4
				g5_2_e_5
				g5_2_e_6
				g5_3_a_1
				g5_3_a_2
				g5_3_a_3
				g5_3_a_4
				g5_3_a_5
				g5_3_a_6
				g5_3_b_1
				g5_3_b_2
				g5_3_b_3
				g5_3_b_4
				g5_3_b_5
				g5_3_b_6
				g5_3_c_1
				g5_3_c_2
				g5_3_c_3
				g5_3_c_4
				g5_3_c_5
				g5_3_c_6
				g5_3_d_1
				g5_3_d_2
				g5_3_d_3
				g5_3_d_4
				g5_3_d_5
				g5_3_d_6
				g5_3_e_1
				g5_3_e_2
				g5_3_e_3
				g5_3_e_4
				g5_3_e_5
				g5_3_e_6
				g5_3_f_1
				g5_3_f_2
				g5_3_f_3
				g5_3_f_4
				g5_3_f_5
				g5_3_f_6
				g5_3_g_1
				g5_3_g_2
				g5_3_g_3
				g5_3_g_4
				g5_3_g_5
				g5_3_g_6;
	#delimit cr		
	
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'
		 
    #delimit ;
	local var_2 g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6
				g4_e_1
				g4_e_2
				g4_e_3
				g4_e_4
				g4_e_5
				g4_e_6;
	#delimit cr		
	  
	local n : word count `var_2'
	
   //Consistency check, If g4_e_1/6 == Yes then ALL g5_1/3_a/g_1/6 = NA (No disclosure requirements for periodic statements)

    capture drop consistcheck
	gen consistcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace consistcheck = 1 if (`a' != "NA" & `b' == "Yes")

	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in G5") headchars(charname)
	
	listtab $id_info `var_1' consistcheck `var_2' if consistcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Consistency check of G5 due to disclosure requirements for periodic statements [g4_e_1/6 == Yes THEN g5_1/3_a/g_1/6 = NA]") headchars(charname)  

	
	///G6. By law or regulation, are financial service providers required to notify their customers of any changes in the terms and conditions? 
	///G7. Has your country required or encouraged financial service providers to adopt industry standards on social performance or customer protection?
	///G7a. Does any industry Code of Conduct exist? 

	#delimit ;
	local var_1 g6_1
				g7_1
				g7_a;
	#delimit cr		
	
	//Missing values, Need to have Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	mdesc `var_1'
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in G6 and G7a") headchars(charname)
	
	
	///G7b. Please indicate if the code(s) apply to the following types of products: 

	#delimit ;	
	local var_1	g7_b_1_2
				g7_b_1_3
				g7_b_1_4
				g7_b_1_5
				g7_b_1_6
				g7_b_1_7
				g7_b_2_2
				g7_b_2_3
				g7_b_2_4
				g7_b_2_5
				g7_b_2_6
				g7_b_2_7
				g7_b_3_2
				g7_b_3_3
				g7_b_3_4
				g7_b_3_5
				g7_b_3_6
				g7_b_3_7
				g7_b_4_2
				g7_b_4_3
				g7_b_4_4
				g7_b_4_5
				g7_b_4_6
				g7_b_4_7
				g7_b_5_2
				g7_b_5_3
				g7_b_5_4
				g7_b_5_5
				g7_b_5_6
				g7_b_5_7;
	#delimit cr
	
	#delimit ;	
	local var_2	b1_1
				b1_2
				b1_3
				b1_4
				b1_5
				b1_6
				b1_1
				b1_2
				b1_3
				b1_4
				b1_5
				b1_6
				b1_1
				b1_2
				b1_3
				b1_4
				b1_5
				b1_6
				b1_1
				b1_2
				b1_3
				b1_4
				b1_5
				b1_6
				b1_1
				b1_2
				b1_3
				b1_4
				b1_5
				b1_6;
	#delimit cr
	
	local n : word count `var_2'	

	//Skip value, missing only, If b1_1/6 == NA|No, skip g7_b_1/5_1/7 == NA
	
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (`a' != "NA" & `b' == "Yes")


	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in G7b due to b1_1/6 == NA|No THEN g7_b_1/5_1/7 == NA")headchars(charname)  

	//Comment: IF g7_a == No|NA THEN automatically g7_b_1/4_1/7 == ""
 
	
	///G8. If any industry Code of Conduct exists, please provide a Yes/No answer for each industry Code. 

	//Comment: IF g7_a == No|NA THEN automatically g8_a/h_1/5 == ""


	////END////

