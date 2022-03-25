/// Project: FI_Survey_Project -- Section E
///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------
/// Program Setup
///-----------------------------------------------------------------------------

    version 16              // Set Version number for backward compatibility
    set more off             // Dsisble partitioned output
    clear all               // Start with a clean slate
    set linesize 80         // Line size limit to make output more readable
    macro drop _all         // Clear all macros
    capture log close       // Close existing log files
	
///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------

    /* RUNS THE FOLLOWING:
	0. Import and merge files
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
//// 0. Import files           ////
////////////////////////////////////////////////////////////
	
	/*Merge all files in a folder 
	
	dir "$data\*.dta"

	local flist: dir "$data\*.dta"
	
	foreach f of local flist {
	   merge 1:1 using `f', generate(merge_`f') 
}
	*/
	
/////////////////////////////////////////////////////////////
//// 1. Checks skip logic and missing values by section          ////
////////////////////////////////////////////////////////////
	
	//A. Background Information	
	
	
	//B. Financial Sector Landscape	

	
	//C. Financial Inclusion Policies and strategies	

	
	//D. Legal, Regulatory and Supervisory Framework for Relevant Financial Service Providers	

	
	//E. Enabling Regulatory Framework for Financial Inclusion
	use "$data/e_regulatory_framework_relevant_-survey.dta", clear
	
	merge 1:1 country_code year status using "$data/b_financial_sector_landscape_-survey.dta"
	
	keep if status == "Submitted to Review" // 137 observations deleted
	keep if _merge == 3 // 0 observations deleted
	keep if year == 2022 // 0 observations deleted

	//assert c(N) == 84
	
	//Create output files and setting charinclude
	global filename  "FI_survey_Section_E_HFC_"
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
	
	///E1 Please indicate which types of financial service providers are allowed to contract third-party agents to perform some of their transactions. Check all that apply for each type of financial service provider
	
	local var_1 e1_a_1 e1_a_2 e1_a_3 e1_a_4 e1_a_5 e1_h_6
	
	local var_2 b1_1 b1_2 b1_3 b1_4 b1_5 b1_6
	
	local n : word count `var_2'
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E1") headchars(charname)
		
	mdesc `var_1'
	
	//Consitency checks of e1_a/h_1/6, only IF b1_1/6 == Yes
	capture drop consischeck
	gen consischeck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace consischeck = 1 if (`a' != "NA" & `b' == "Yes") //Dobule check, is this conditional OK???
	
	br $id_info `var_1' consischeck `var_2' if consischeck == 1
	
	listtab $id_info `var_1' consischeck `var_2' if consischeck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Consitency check of E1 variables: Answer accoding to b1_1/6") headchars(charname)

		
	///E2. If financial service providers are allowed to have agents, please specify which type of rules apply regulating the relationships between the financial service provider, the agent, and the consumer:
	#delimit ;
	local var_1 e2_a_1
				e2_a_2
				e2_a_3
				e2_a_4
				e2_a_5
				e2_a_6
				e2_b_1
				e2_b_2
				e2_b_3
				e2_b_4
				e2_b_5
				e2_b_6
				e2_c_1
				e2_c_2
				e2_c_3
				e2_c_4
				e2_c_5
				e2_c_6
				e2_d_1
				e2_d_2
				e2_d_3
				e2_d_4
				e2_d_5
				e2_d_6
				e2_e_1
				e2_e_2
				e2_e_3
				e2_e_4
				e2_e_5
				e2_e_6
				e2_f_1
				e2_f_2
				e2_f_3
				e2_f_4
				e2_f_5
				e2_f_6
				e2_g_1
				e2_g_2
				e2_g_3
				e2_g_4
				e2_g_5
				e2_g_6
				e2_h_1
				e2_h_2
				e2_h_3
				e2_h_4
				e2_h_5
				e2_h_6;
	 #delimit cr			
		
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E2") headchars(charname)
		
	mdesc `var_1'

	///E3. If any of the following terms are explicitly defined in law or regulation, please indicate the [bases on which each term] is defined.
	
	
	#delimit ;
	local var_1 e4_a_1
				e4_a_2
				e4_a_3
				e4_a_4
				e4_b_1
				e4_b_2
				e4_b_3
				e4_b_4
				e4_c_1
				e4_c_2
				e4_c_3
				e4_c_4
				e4_d_1
				e4_d_2
				e4_d_3
				e4_d_4
				e4_e_1
				e4_e_2
				e4_e_3
				e4_e_4
				e4_f_1
				e4_f_2
				e4_f_3
				e4_f_4;
	 #delimit cr			
		
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E3") headchars(charname)
		
	mdesc `var_1'
	
	///E4. Please indicate if there is a framework regarding insurance activities that:
	#delimit ;
	local var_1 e4_2_a
				e4_2_b
				e4_2_c
				e4_2_d
				e4_2_e
				e4_2_f;
	 #delimit cr			
		
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E4") headchars(charname)
		
	mdesc `var_1'

	///E5.  Do regulations include tiered branching requirements that allow financial service providers to establish and operate modified or simplified branches (e.g. mobile branches, sub-branches, outlets)? Note that third-party agents are not considered as modified or simplified branches.
	#delimit ;
	local var_1 e5_1
				e5_2
				e5_3
				e5_4
				e5_5
				e5_6;
	 #delimit cr			
	
	local var_2 b1_1 b1_2 b1_3 b1_4 b1_5 b1_6
	
	local n : word count `var_2'
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E5") headchars(charname)
		
	mdesc `var_1'
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (`a' != "NA" & `b' == "Yes")
		


	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E5")headchars(charname)
	   
	 
	///E6.  Do financial service providers have access, or report, to a credit bureau or credit registry? A credit bureau is a privately owned company which collects information relating to the credit ratings of individuals and makes it available to banks, finance companies, etc. Credit registries, the other main type of credit reporting institutions, tend to be public entities, managed by bank supervisors or central banks. Check all that apply for each type of financial service provider.
	#delimit ;
	local var_1 e6_a_1
				e6_a_2
				e6_a_3
				e6_a_4
				e6_a_5
				e6_a_6
				e6_b_1
				e6_b_2
				e6_b_3
				e6_b_4
				e6_b_5
				e6_b_6
				e6_c_1
				e6_c_2
				e6_c_3
				e6_c_4
				e6_c_5
				e6_c_6
				e6_d_1
				e6_d_2
				e6_d_3
				e6_d_4
				e6_d_5
				e6_d_6
				e6_e_1
				e6_e_2
				e6_e_3
				e6_e_4
				e6_e_5
				e6_e_6
				e6_f_1
				e6_f_2
				e6_f_3
				e6_f_4
				e6_f_5
				e6_f_6;
	 #delimit cr	
	 
	local var_2 b1_1 b1_2 b1_3 b1_4 b1_5 b1_6
	
	local n : word count `var_2'
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E6") headchars(charname)
	
	mdesc `var_1'
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (`a' != "NA" & `b' == "Yes")


	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E6")headchars(charname)
	
	///E7. Are financial service providers subject to explicit caps on interest rates or other limitations on loan pricing, e.g. maximum profit margins, maximum spread or restrictions on loan fees and charges? Select one option for each type of financial service provider. 
	#delimit ;
	local var_1 e7_a_1
				e7_a_2
				e7_a_3
				e7_a_4
				e7_a_5
				e7_a_6
				e7_b_1
				e7_b_2
				e7_b_3
				e7_b_4
				e7_b_5
				e7_b_6
				e7_c_1
				e7_c_2
				e7_c_3
				e7_c_4
				e7_c_5
				e7_c_6;
	 #delimit cr	
	 
	local var_2 b1_1 b1_2 b1_3 b1_4 b1_5 b1_6
	
	local n : word count `var_2'
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E7") headchars(charname)

	mdesc `var_1'
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (`a' != "NA" & `b' == "Yes")

		
	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E7")headchars(charname)
	
	
	///E8. Does regulation explicitly require authorization of new or modified financial products?
	#delimit ;
	local var_1 e8_a_1
				e8_a_2
				e8_a_3
				e8_a_4
				e8_a_5
				e8_a_6
				e8_b_1
				e8_b_2
				e8_b_3
				e8_b_4
				e8_b_5
				e8_b_6
				e8_c_1
				e8_c_2
				e8_c_3
				e8_c_4
				e8_c_5
				e8_c_6;
	 #delimit cr	
	 
	local var_2 b1_1 b1_2 b1_3 b1_4 b1_5 b1_6
	
	local n : word count `var_2'
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E8") headchars(charname)
		
	mdesc `var_1'
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (`a' != "NA" & `b' == "Yes")


	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E8")headchars(charname)	   
	   
	///E9. Is there a requirement in law or regulation that customers’ e-money funds be separated from the funds of the e-money issuer?  
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(e9_1)

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E9") headchars(charname)
		
	mdesc `var_1'
		
	///E10a. Is it specified in law or regulation which type of account must be used to safeguard e-money funds? Please mark all that apply. 
	
	#delimit ;
	local var_1 e10_1_1_trustacco
				e10_1_2_escrowacc 
				e10_1_4_regularac 
				e10_1_5_accountat 
				e10_1_6_other 
				e10_1_7_doesnots;
	 #delimit cr	
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E10a") headchars(charname)
		
	mdesc `var_1'

	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if (missing(e10_1_specify) & e10_1_6_other  == "Yes")

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E10a")headchars(charname)
	
	
	///E11. Are non-bank e-money issuers prohibited by law or regulation from using customer funds for purposes other than redeeming e-money and executing fund transfers? 
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(e11_1)

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E11") headchars(charname)
	
	mdesc `var_1'
		
	///E12. Are non-bank e-money issuers permitted by law or regulation to pay interest on customers’ e-money accounts or share profits with their e-money customers?  Please mark all that apply. 
	#delimit ;
	local var_1 e12_1_1_thelawre
				e12_1_2_thelawre
				e12_1_3_neither
				e12_1_4_notapplic;
	 #delimit cr	
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') 

		
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E12") headchars(charname)

	mdesc `var_1'
	
	///E13.1 Are there legal and/or regulatory requirements specifying which documents individuals must submit for opening a transaction account with a financial service provider?
	#delimit ;
	local var_1 e13_1
				e13_2
				e13_3
				e13_4
				e13_5;
	 #delimit cr	
	 
	local var_2 b1_1 b1_2 b1_3 b1_4 b1_6
	
	local n : word count `var_2'
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E13.1") headchars(charname)
		
	mdesc `var_1'
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (`a' != "NA" & `b' == "Yes")


	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E13.1")headchars(charname)
	
	
	///E13.2  Are there legal and/or regulatory requirements specifying which documents individuals must submit for opening an e-money account with a financial service provider?
	#delimit ;
	local var_1 e13_2_1
				e13_2_2
				e13_2_3
				e13_2_4
				e13_2_5;
	 #delimit cr	
	 
	local var_2 b1_1 b1_2 b1_3 b1_4 b1_6
	
	local n : word count `var_2'
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E13.2") headchars(charname)
		
	mdesc `var_1'
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (`a' != "NA" & `b' == "Yes")


	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E13.2")headchars(charname)
	
	
	///E14. According to current law or regulation, which of the following information is required to open the lowest risk-based transaction or e-money account and what documents are required/accepted to verify it?
	#delimit ;
	local var_1 e14_a_1_1
				e14_a_1_2
				e14_a_1_3
				e14_a_1_4
				e14_a_1_5
				e14_a_1_6
				e14_a_2_1
				e14_a_2_2
				e14_a_2_3
				e14_a_2_4
				e14_a_2_5
				e14_a_2_6
				e14_a_3_1
				e14_a_3_2
				e14_a_3_3
				e14_a_3_4
				e14_a_3_5
				e14_a_3_6
				e14_a_4_1
				e14_a_4_2
				e14_a_4_3
				e14_a_4_4
				e14_a_4_5
				e14_a_4_6
				e14_a_5_1
				e14_a_5_2
				e14_a_5_3
				e14_a_5_4
				e14_a_5_5
				e14_a_5_6
				e14_b_1_1
				e14_b_1_2
				e14_b_1_3
				e14_b_1_4
				e14_b_1_5
				e14_b_1_6
				e14_b_2_1
				e14_b_2_2
				e14_b_2_3
				e14_b_2_4
				e14_b_2_5
				e14_b_2_6
				e14_c_1_1
				e14_c_1_2
				e14_c_1_3
				e14_c_1_4
				e14_c_1_5
				e14_c_1_6
				e14_c_2_1
				e14_c_2_2
				e14_c_2_3
				e14_c_2_4
				e14_c_2_5
				e14_c_2_6
				e14_d_1_1
				e14_d_1_2
				e14_d_1_3
				e14_d_1_4
				e14_d_1_5
				e14_d_1_6
				e14_e_1_1
				e14_e_1_2
				e14_e_1_3
				e14_e_1_4
				e14_e_1_5
				e14_e_1_6
				e14_f_1
				e14_f_2
				e14_f_3
				e14_f_4
				e14_f_5
				e14_f_6;
	 #delimit cr	
	 
	local var_2 b1_1 b1_2 b1_3 b1_4 b1_5 b1_6
	
	local n : word count `var_2'
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E14") headchars(charname)
		
	mdesc `var_1'
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (`a' != "NA" & `b' == "Yes")
	

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E14")headchars(charname)
	
	
	///E15a Can financial service providers verify a customer’s identity through digital means in the context of transaction or e-money account opening?
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(e14_2_1)

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E15a") headchars(charname)
		
		
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if missing(e14_2_1_explain)& e14_2_1 == "Yes other"

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E15a")headchars(charname)
	
	
	///E15b What information can be verified through digital means? (Select all that apply)
	#delimit ;
	local var_1 e15_b_1_name
				e15_b_2_sexgender 
				e15_b_3_dateofbi 
				e15_b_4_address 
				e15_b_5_nationalit 
				e15_b_6_validitya;
	 #delimit cr	
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E15b") headchars(charname)
		
	mdesc `var_1'
	
	//Skip value, missing only // Double check!!!!
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (`a' != "NA" & `b' == "Yes")

	   
	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E15b")headchars(charname)	   
	   
	///E16a. Can financial service providers use biometric verification (e.g., using fingerprints, face, or iris) to confirm the identity of a customer?
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(e16_a_1)

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E16a") headchars(charname)

	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if missing(e16_a_1_explain)& e16_a_1 == "Yes other"

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E16a")headchars(charname)
		
	///E16b. Are financial service providers charged a fee for digital identity verification / authentication by the identity provider(s)?
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(e16_b_1)
	
	capture assert mcheck == 1 

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E16b") headchars(charname)

	///E17. What elements of a risk-based approach to AML/CFT regulation have been implemented? Please mark all that apply
	#delimit ;
	local var_1 e17_a_1_1
				e17_a_1_2
				e17_a_1_3
				e17_a_1_4
				e17_a_1_5
				e17_b_1_1
				e17_b_1_2
				e17_b_1_3
				e17_b_1_4
				e17_b_1_5
				e17_c_1_1
				e17_c_1_2
				e17_c_1_3
				e17_c_1_4
				e17_c_1_5
				e17_d_1_1
				e17_d_1_2
				e17_d_1_3
				e17_d_1_4
				e17_d_1_5;
	 #delimit cr	
	 
	local var_2 b1_1 b1_2 b1_3 b1_4 b1_6
	
	local var_3 e17_d_2_1 e17_d_2_2 e17_d_2_3 e17_d_2_4 e17_d_2_5

	local n : word count `var_2'
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E17") headchars(charname)
		
	mdesc `var_1'
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (`a' != "NA" & `b' == "Yes")
		
	
	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E17")headchars(charname)	
	/*
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(`var_3')  & `var_1'  == "Yes"  //Double check!!
	   
	 */
	 
	///E18. What simplified CDD measures for account opening are allowed? Please mark all that apply
	#delimit ;
	local var_1 e18_a_1
				e18_b_1_1_bylaw
				e18_b_1_2_providerd
				e18_a_2
				e18_b_2_1_bylaw
				e18_b_2_2_providerd
				e18_a_3
				e18_b_3_1_bylaw
				e18_b_3_2_providerd
				e18_a_4
				e18_b_4_1_bylaw
				e18_b_4_2_providerd;
	 #delimit cr	
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E18") headchars(charname)
		
	mdesc `var_1'
	//Double check!!
	
	///E19a. Is non-face-to-face (i.e. remote) account opening allowed? (Select all that apply)
	#delimit ;
	local var_1 e19_a_1_1_yespeople
				e19_a_1_2_yesagents
				e19_a_1_3_yesother
				e19_a_1_4_no;
	 #delimit cr	
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E19a") headchars(charname)
		
	mdesc `var_1'
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if missing(e19_a_1_explain)& e19_a_1_3_yesother == "Yes other"	

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E19a")headchars(charname)
	
	
	///E19b How is remote customer due diligence facilitated? (Select all that apply)
	#delimit ;
	local var_1 e19_b_1_1_theperson
				e19_b_1_2_identityi 
				e19_b_1_3_peopledig 
				e19_b_1_4_otherplea;
	 #delimit cr	
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E19b") headchars(charname)
		
	mdesc `var_1'
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if missing(e17_2_1_specify)& e19_b_1_4_otherplea == "Yes other" ///Problem! See Skip Logic sheet	

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E19b")headchars(charname)
	
	
	////E20a. Does your country have a digital ID solution/system in place that enables people to authenticate themselves remotely (without in-person presences) to securely access transactions or services online ?
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(e21_a_1)

	listtab $id_info e21_a_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E20a") headchars(charname)
		
	///E20b. Please provide the name / website for the system(s):
	///E20c. Which entities currently serve as digital identity providers (select all that apply)
	///E20d. How many digital identity providers are there? (Select which one applies)
	#delimit ;
	local var_1 e21_b_1
				e21_c_1_1_government
				e21_c_1_2_privatese 
				e21_c_1_3_other 
				e21_c_1_specify
				e21_d_1;
	 #delimit cr	
			
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	foreach i of local var_1 {
		replace skipcheck = 1 if missing(`i') & (e21_a_1 == "No"|e21_a_1 == "NA") //Double check!!



	listtab $id_info `var_1' skipcheck e21_a_1 e21_a_1 if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skipping values in E20b E20c E20d") headchars(charname)
		
	mdesc `var_1'	
	
	///E21a. A	re financial service providers in your country subject to any of the following data protection requirements? (select all that apply)(Personal data here refers to any information about an identified or identifiable individual)
	
	#delimit ;
	local var_1 e20_1_1_rulesrega e20_1_1_rulesrega e20_1_2_rulesrega e20_1_3_obligation e20_1_4_rulesrest e20_1_5_obligation e20_1_6_rulesrest e20_1_7_obligation e20_1_8_ruleslimi e20_1_9_obligation e20_1_10_obligation e20_1_11_obligation e20_1_12_obligation;
	 #delimit cr	
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E21a") headchars(charname)
		
	mdesc `var_1'	
	
	///E21b. Are the data protection requirements you selected in E20a found in: (select all that apply)
	
	//Skiping values
	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if missing(e20_b_1_specify) & e20_b_1 == "Yes"
		
	listtab $id_info e20_b_1_specify skipcheck e20_b_1 if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skipping values in E21b") headchars(charname)
	
	
	///E21c. When are financial service providers permitted to share/disclose personal data about an individual with other parties? (select all that apply)
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if missing(e20_c_1_explain) & e20_c_1_4_other == "Yes"
	
	listtab $id_info e20_c_1_explain skipcheck e20_c_1_4_other if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skipping values in E21c") headchars(charname)
	
	
	///E21d. An individual’s consent to sharing/disclosure of their personal data must meet these requirements: (select all that apply)
	
	#delimit ;
	local var_1 e20_d_1_1_theremust
				e20_d_1_2_theconsen 
				e20_d_1_3_theconsen
				e20_d_1_4_theconsen
				e20_d_1_5_theindivi;
	 #delimit cr	
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E21d") headchars(charname)
	
	mdesc `var_1'	
	
	///E22. Please provide information about key fintech innovations beyond payments in your market:
	#delimit ;
	local var_1 e22_a_1
				e22_a_2
				e22_a_3
				e22_a_4
				e22_a_5
				e22_a_6
				e22_b_1
				e22_b_2
				e22_b_3
				e22_b_4
				e22_b_5
				e22_b_6
				e22_c_1
				e22_c_2
				e22_c_3
				e22_c_4
				e22_c_5
				e22_c_6
				e22_d_1
				e22_d_2
				e22_d_3
				e22_d_4
				e22_d_5
				e22_d_6
				e22_e_1
				e22_e_2
				e22_e_3
				e22_e_4
				e22_e_5
				e22_e_6;
	#delimit cr	
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')


	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E22") headchars(charname)
		
	mdesc `var_1'
	
	// Other conditional values:
	//a2. If yes, approximately how many providers are active as of 2019?
	#delimit ;
	local var_1 e22_a_1_1
				e22_a_1_2
				e22_a_1_3
				e22_a_1_4
				e22_a_1_5
				e22_a_1_6;
	#delimit cr	

	#delimit ;
	local var_1 e22_a_1
				e22_a_2
				e22_a_3
				e22_a_4
				e22_a_5
				e22_a_6;
	#delimit cr	
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`a') & `b' == "Yes")
	


	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E22: If yes, approximately how many providers are active as of 2019?") headchars(charname)
	
	//a3. Approximately how many customers are using these services to your knowledge?
	#delimit ;
	local var_1 e22_a_2_1
				e22_a_2_2
				e22_a_2_3
				e22_a_2_4
				e22_a_2_5
				e22_a_2_6;
	#delimit cr	

	#delimit ;
	local var_2 e22_a_1
				e22_a_2
				e22_a_3
				e22_a_4
				e22_a_5
				e22_a_6;
	#delimit cr	
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`a') & `b' == "Yes")
	

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E22: Approximately how many customers are using these services to your knowledge?") headchars(charname)	
	
	//b2. Specify who issues the license/authorization
	#delimit ;
	local var_1 e22_b_1_1
				e22_b_1_2
				e22_b_1_3
				e22_b_1_4
				e22_b_1_5
				e22_b_1_6;
	#delimit cr	

	#delimit ;
	local var_2 e22_b_1
				e22_b_2
				e22_b_3
				e22_b_4
				e22_b_5
				e22_b_6;
	#delimit cr	
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`a') & `b' == "Yes")
	

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E22: Specify who issues the license/authorization") headchars(charname)	
	
	//c2. specify who supervises these products/providers for FCP
	#delimit ;
	local var_1 e22_c_1_1
				e22_c_1_2
				e22_c_1_3
				e22_c_1_4
				e22_c_1_5
				e22_c_1_6;
	#delimit cr	

	#delimit ;
	local var_2 e22_c_1
				e22_c_2
				e22_c_3
				e22_c_4
				e22_c_5
				e22_c_6;
	#delimit cr	
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`a') & `b' == "Yes")
	

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E22: specify who supervises these products/providers for FCP") headchars(charname)	
	
	
	///E23. Please indicate if your country has adopted any of the following data sharing models (select all that apply)
	#delimit ;
	local var_1 e23_1_1_openbanki
				e23_1_2_digitallo
				e23_1_3_openapis
				e23_1_4_other;
	 #delimit cr	
			
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Missing values in E23") headchars(charname)
		
	mdesc `var_1'	
	
	//Skip value, missing only
	capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if missing(e23_1_specify) & e23_1_4_other == "Yes"	

	listtab $id_info e23_1_specify skipcheck e23_1_4_other if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("Skip values in E23")headchars(charname)
	
	////END////

	//F. Institutional Arrangements and Regulatory Framework for Financial Consumer Protection	

	
	//G. Disclosure and Transparency	

	
	//H. Fair Treatment and Business Conduct	

	
	//I. Complaints Handling, Dispute Resolution, and Recourse	

	
	//J. Financial Education and Capability
