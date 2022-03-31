/// Project: FICP_Survey_Project -- Section B
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
	

	
	else {
		global base "D:/Documents/Consultorias/World_Bank/FICP_Survey_Project"
		cd "$base"
		
		global data "D:/Documents/Consultorias/World_Bank/FICP_Survey_Project/Data/Database `dir'"
			
		global output "D:/Documents/Consultorias/World_Bank/FICP_Survey_Project/OUTPUT"
	}
	
    //Install required packages
	//ssc install listtab
	
/////////////////////////////////////////////////////////////
//// 0. Import files and HFC file set-up          ////
////////////////////////////////////////////////////////////
	
	use "$data/b_financial_sector_landscape_-survey.dta", clear
	
	keep if status == "Submitted to Review" // 137 observations deleted
	keep if year == 2022 // 0 observations deleted
	
	merge 1:1 country_code using "$base/WB_CountryClassification.dta"
	keep if year == 2022 // 173 observations deleted

	//assert c(N) == 91
	
	//Create output files and setting charinclude
	global filename  "FICP_survey_Section_B_HFC_"  // Change accordinly
	global filedate : di %tdCCYY.NN.DD date(c(current_date), "DMY") // date of the report
	
	local hfc_file "$base/Data/$filename$filedate.csv"

	export excel using  "$base/Data/$filename$filedate.csv", replace
	
	
	
	foreach var of varlist _all {
		char `var'[charname] "`var'"
	}
	
/////////////////////////////////////////////////////////////
//// 1. Checks skip logic and missing values by section          ////
////////////////////////////////////////////////////////////
	
	
	//B. Financial Sector Landscape	

	//Check duplicate IDs
	sort region country_code
	
	capture drop id_dup
	duplicates tag country_code, generate(id_dup) // Sort and Check for unique identifiers
		if _rc != 0 di "observations by country are NOT unique in country_code"
		else if _rc == 0 di "Observations by country are unique in this section"
	
	listtab $id_info using `hfc_file' if id_dup == 1, delimiter(",") replace headlines("  ,Duplicate Country ID") headchars(charname)
	
	///B1. To facilitate international comparison, the Survey groups financial service providers into six (6) broad categories. In the table below, we ask you to classify institutions existing in your country into these six (6) categories. We ask you to list the types of institutions that are supervised/regulated in your country and to place them into the appropriate category. Where there is some ambiguity as to which category an institution belongs, please use your best judgment to pick one category. Please also note that we are only interested in institutions which provide standard “retail banking”-like products (such as loans or deposit/payment services) and not insurance companies, mutual funds, investment banks, private equity funds, etc.
	
	#delimit ;
	local var_1 b1_1
				b1_2
				b1_3
				b1_4
				b1_5
				b1_6;
	 #delimit cr			
		
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')
	}
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in B1") headchars(charname)
		
	mdesc `var_1'
	

	///B2. Are there CCPs in your country which are not supervised or regulated? If so, please indicate which types:
	
	#delimit ;
	local var_1 b2_x_1_paydaylen
				b2_x_2_financeco
				b2_x_3_microcredi
				b2_x_4_digitalle
				b2_x_5_moneylend
				b2_x_6_digitalcr
				b2_x_7_other;
	 #delimit cr			
		
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')
	}
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in B2") headchars(charname)
		
	mdesc `var_1'
	
	//Skip value, missing only
    capture drop skipcheck
	gen skipcheck = 0
	
	replace skipcheck = 1 if missing(b2_x_others) & b2_x_7_other  == "Yes"

	listtab $id_info b2_x_others skipcheck b2_x_7_other if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Skip values in B2")headchars(charname)  	

	///B2.a Is the concept of e-money incorporated into the law?
	///B2.b Can non-bank institutions issue e-money?
	
	#delimit ;
	local var_1 b2_a
				b2_b;
	 #delimit cr			
		
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')
	}
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in B2.a and B2.b") headchars(charname)
		
	mdesc `var_1'	
	
	///B2.c Please list the categories of non-bank e-money issuers currently operating in the country and provide details.
	
	#delimit ;
	local var_1 b2c_1_1
				b2c_2_1
				b2c_3_1
				b2c_4_1
				b2c_5_1
				b2c_6_1;
	 #delimit cr
	 
	//Skip value, missing only, If b2_b = No | NA, skip B2c
    capture drop skipcheck
	gen skipcheck = 0
	
	foreach i of local var_1 {
		replace skipcheck = 1 if missing(`i') & b2_b == "Yes"
	}

	listtab $id_info `var_1' skipcheck b2_b if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Skip values in B2c due to b2_b == Yes")headchars(charname)  


	#delimit ;
	local var_1 b2c_1_2
				b2c_2_2
				b2c_3_2
				b2c_4_2
				b2c_5_2
				b2c_6_2;
	 #delimit cr
	 
	#delimit ;
	local var_2 b2c_1_1
				b2c_2_1
				b2c_3_1
				b2c_4_1
				b2c_5_1
				b2c_6_1;
	 #delimit cr	 
	 
	local n : word count `var_2'
	 
	//Skip value, missing only, If b2c_*_1 == No | NA, skip b2c_1/6_2/2

    capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`a') & `b' == "Yes")  
	}
			
	listtab $id_info `var_1' skipcheck b2_b if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Skip values in B2c due to b2c_*_1 == No | NA")headchars(charname)  
	
			//Comment: Example not checked

	///B3. Please provide information regarding the following institutions, as of December 2020. Please write N/A if not applicable to your country.

	#delimit ;
	local var_1 b3_1_1
				b3_1_2
				b3_1_3
				b3_1_4
				b3_1_5
				b3_1_6
				b3_2_1
				b3_2_2
				b3_2_3
				b3_2_4
				b3_2_5
				b3_2_6
				b3_3_1
				b3_3_2
				b3_3_3
				b3_3_4
				b3_3_5
				b3_3_6;
	 #delimit cr	
	 
	#delimit ;
	local var_2 b1_1
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

	//Missing values, only missing
    capture drop mcheck
	gen mcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace mcheck = 1 if (missing(`a') & `b' == "Yes") // Comment: text and numbes!!
	}
	br $id_info `var_1' if mcheck == 1
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in B3, conditional on b1_1/6") headchars(charname)
		
	mdesc `var_1'

	//Consitency checks of Tota_assets [Numeric]
	
	#delimit ;
	local var_1 b3_3_1
				b3_3_2
				b3_3_3
				b3_3_4
				b3_3_5
				b3_3_6;
	 #delimit cr		

	capture drop consischeck
	gen consischeck = 0	
	
	foreach i of local var_1 {
		capture confirm numeric var `i' 
		if _rc == 0 {
		display "Variables are fine"
		}
		else {
		display "Variables have problems"
		replace consischeck = 1
	   }	
	}
	
	listtab $id_info `var_1' currency_type if consischeck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Non numeric values of B3:Tota_assets") headchars(charname)	
	
	//Consitency checks of Total_assets [Non-negative] //Double check!!!
	/*
	//capture drop consischeck
	gen consischeck_1 = 0	
	
	foreach i of local var_1 {
		replace consischeck_1 = 1 if `i' <=0 & consischeck == 0
	}
		
	listtab $id_info `var_1' currency_type if consischeck_1 == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Cero o non-negative value of B3:Tota_assets") headchars(charname)
*/

	//Double check b3_3_2- b3_3_6!!! Text and numbers!!!
	
	////END////

