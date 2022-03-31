/// Project: FICP_Survey_Project -- Section C
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
	
	use "$data/c_financial_inclusion_policies_a-survey", clear
	
	//merge 1:1 country_code year status using "$data/b_financial_sector_landscape_-survey.dta"
		
	keep if status == "Submitted to Review" // 142 observations deleted
	keep if year == 2022 // 0 observations deleted

	merge 1:1 country_code using "$base/WB_CountryClassification.dta"
	keep if year == 2022 // 173 observations deleted
	
	//assert c(N) == 91
	
	//Create output files and setting charinclude
	global filename  "FICP_survey_Section_C_HFC_"  // Change accordinly
	global filedate : di %tdCCYY.NN.DD date(c(current_date), "DMY") // date of the report
	
	local hfc_file "$base/Data/$filename$filedate.csv"

	export excel using  "$base/Data/$filename$filedate.csv", replace
	
	
	
	foreach var of varlist _all {
		//di `"`: var label `var''"' 
		char `var'[charname] "`var'" 
	}
	
/////////////////////////////////////////////////////////////
//// 1. Checks skip logic and missing values by section          ////
////////////////////////////////////////////////////////////
	
	
	///C. Financial Inclusion Policies and strategies

	//Check duplicate IDs
	sort region country_code
	
	capture drop id_dup
	duplicates tag country_code, generate(id_dup) // Sort and Check for unique identifiers
		if _rc != 0 di "observations by country are NOT unique in country_code"
		else if _rc == 0 di "Observations by country are unique in this section"
	
	listtab $id_info using `hfc_file' if id_dup == 1, delimiter(",") replace headlines("  ,Duplicate Country ID") headchars(charname)
	
	///C1. Does your country have any of the following national strategy documents to promote activities relevant to financial inclusion:
	
	 #delimit ;
	local var_1 c1_1_1
				c1_2_1
				c1_3_1
				c1_4_1
				c1_5_1
				c1_6_1
				c1_7_1;
	 #delimit cr
	 
	//Missing values. Need to have an answer
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')
	}
	br $id_info `var_1' if mcheck == 1
	mdesc `var_1'
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: Status") headchars(charname)
	
	 #delimit ;
	local var_1 c1_1_2_specify
				c1_2_2_specify
				c1_3_2_specify
				c1_4_2_specify
				c1_5_2_specify
				c1_6_2_specify
				c1_7_2_specify;
	 #delimit cr
	 
	 #delimit ;
	local var_2 c1_1_2
				c1_2_2
				c1_3_2
				c1_4_2
				c1_5_2
				c1_6_2
				c1_7_2;
	 #delimit cr	 
	 
	local n : word count `var_2'	 
	 
  //Skip value, If c1_1/7_2 == No|NA, skip c1_1/7_2_specify

    capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if missing(`a') & `b' == "Yes"
	}

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Skip values in C1 due to c1_1/7_2 == No|NA, skip c1_1/7_2_specify") headchars(charname)  
		 

	 #delimit ;
	local var_1 c1_1_3
				c1_1_4
				c1_1_5
				c1_1_6
				c1_1_7;
	 #delimit cr
	 
  //Missing values, If c1_1_1 == No|NA, skip c1_1_3/7 National Financial Inclusion Strategy

 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_1_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_1_1 if mcheck == 1
	listtab $id_info `var_1' mcheck c1_1_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: National Financial Inclusion Strategy") headchars(charname)  		 
		 
	 #delimit ;
	local var_1 c1_2_3
				c1_2_4
				c1_2_5
				c1_2_6
				c1_2_7;
	 #delimit cr
	 
  //Missing values, If c1_2_1 == No|NA, skip c1_2_3/7 General financial sector development strategy with a financial inclusion component

 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_2_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_2_1 if mcheck == 1
	
	listtab $id_info `var_1' mcheck c1_2_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: General financial sector development strategy with a financial inclusion component") headchars(charname)  	
	
	
	 #delimit ;
	local var_1 c1_3_3
				c1_3_4
				c1_3_5
				c1_3_6
				c1_3_7;
	 #delimit cr
	 
  //Missing values, If c1_3_1 == No|NA, skip c1_3_3/7 National development strategy with a financial inclusion component

 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_3_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_3_1 if mcheck == 1
	
	listtab $id_info `var_1' mcheck c1_3_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: National development strategy with a financial inclusion component") headchars(charname)  	
		
	
	 #delimit ;
	local var_1 c1_4_3
				c1_4_4
				c1_4_5
				c1_4_6
				c1_4_7;
	 #delimit cr
	 
  //Missing values, If c1_4_1 == No|NA, skip c1_4_3/7 Microfinance strategy

 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_4_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_4_1 if mcheck == 1
	
	listtab $id_info `var_1' mcheck c1_4_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: Microfinance strategy") headchars(charname)  		
	

	 #delimit ;
	local var_1 c1_5_3
				c1_5_4
				c1_5_5
				c1_5_6
				c1_5_7;
	 #delimit cr
	 
  //Missing values, If c1_5_1 == No|NA, skip c1_5_3/7 Financial Capability/Literacy/Education strategy

 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_5_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_5_1 if mcheck == 1
	
	listtab $id_info `var_1' mcheck c1_5_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: Financial Capability/Literacy/Education strategy") headchars(charname)  		
	
	
	 #delimit ;
	local var_1 c1_6_3
				c1_6_4
				c1_6_5
				c1_6_6
				c1_6_7;
	 #delimit cr
	 
  //Missing values, If c1_6_1 == No|NA, skip c1_6_3/7 Digital development strategy with a financial inclusion component
  
 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_6_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_6_1 if mcheck == 1
	
	listtab $id_info `var_1' mcheck c1_6_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: Digital development strategy with a financial inclusion component") headchars(charname)  	
	
	
	 #delimit ;
	local var_1 c1_7_3
				c1_7_4
				c1_7_5
				c1_7_6
				c1_7_7;
	 #delimit cr
	 
  //Missing values, If c1_7_1 == No|NA, skip c1_7_3/7 Digital Financial Services or fintech strategy
  
 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_7_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_7_1 if mcheck == 1
	
	listtab $id_info `var_1' mcheck c1_7_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: Digital Financial Services or fintech strategy") headchars(charname)  		
	
	
	#delimit ;
	local var_1 c1_1_8_1_women 
				c1_1_8_2_youth 
				c1_1_8_3_microenter
				c1_1_8_4_smes
				c1_1_8_5_farmers
				c1_1_8_6_migrantsr 
				c1_1_8_7_peoplewit 
				c1_1_8_8_poor;
	#delimit cr

	
	
  //Missing values, If c1_1_1 == No|NA, skip c1_8_1/8_* National Financial Inclusion Strategy, explicit numerical targets for one or more of the following categories?

 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_1_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_1_1 if mcheck == 1
	listtab $id_info `var_1' mcheck c1_1_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: National Financial Inclusion Strategy:   explicitnumerical targets") headchars(charname)  		 
		 
		 
		 
	#delimit ;
	local var_1 c1_2_8_1_women 
				c1_2_8_2_youth 
				c1_2_8_3_microenter
				c1_2_8_4_smes
				c1_2_8_5_farmers
				c1_2_8_6_migrantsr 
				c1_2_8_7_peoplewit 
				c1_2_8_8_poor;
	#delimit cr
	
 //Missing values, If c1_2_1 == No|NA, skip c1_2_8_1/8_* General financial sector development strategy with a financial inclusion component, explicit numerical targets for one or more of the following categories?

 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_2_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_2_1 if mcheck == 1
	
	listtab $id_info `var_1' mcheck c1_2_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: General financial sector development strategy with a financial inclusion component:   explicit numerical targets") headchars(charname)  	
	
	
	 #delimit ;
	local var_1 c1_3_8_1_women 
				c1_3_8_2_youth 
				c1_3_8_3_microenter
				c1_3_8_4_smes
				c1_3_8_5_farmers
				c1_3_8_6_migrantsr 
				c1_3_8_7_peoplewit 
				c1_3_8_8_poor;
	 #delimit cr
	 
  //Missing values, If c1_3_1 == No|NA, skip c1_3_8_1/8_* National development strategy with a financial inclusion component, explicit numerical targets for one or more of the following categories?

 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_3_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_3_1 if mcheck == 1
	
	listtab $id_info `var_1' mcheck c1_3_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: National development strategy with a financial inclusion component:   explicit numerical targets") headchars(charname)  	
		
	
	 #delimit ;
	local var_1 c1_4_8_1_women 
				c1_4_8_2_youth 
				c1_4_8_3_microenter
				c1_4_8_4_smes
				c1_4_8_5_farmers
				c1_4_8_6_migrantsr 
				c1_4_8_7_peoplewit 
				c1_4_8_8_poor;
	 #delimit cr
	 
  //Missing values, If c1_4_1 == No|NA, skip c1_4_8_1/8_* Microfinance strategy, explicit numerical targets for one or more of the following categories?

 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_4_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_4_1 if mcheck == 1
	
	listtab $id_info `var_1' mcheck c1_4_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: Microfinance strategy:   explicit numerical targets") headchars(charname)  		
	

	 #delimit ;
	local var_1 c1_5_8_1_women 
				c1_5_8_2_youth 
				c1_5_8_3_microenter
				c1_5_8_4_smes
				c1_5_8_5_farmers
				c1_5_8_6_migrantsr 
				c1_5_8_7_peoplewit 
				c1_5_8_8_poor;
	 #delimit cr
	 
  //Missing values, If c1_5_1 == No|NA, skip c1_5_8_1/8_* Financial Capability/Literacy/Education strategy, explicit numerical targets for one or more of the following categories?

 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_5_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_5_1 if mcheck == 1
	
	listtab $id_info `var_1' mcheck c1_5_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: Financial Capability/Literacy/Education strategy:   explicit numerical targets") headchars(charname)  		
	
	
	 #delimit ;
	local var_1 c1_6_8_1_women 
				c1_6_8_2_youth 
				c1_6_8_3_microenter
				c1_6_8_4_smes
				c1_6_8_5_farmers
				c1_6_8_6_migrantsr 
				c1_6_8_7_peoplewit 
				c1_6_8_8_poor;
	 #delimit cr
	 
  //Missing values, If c1_6_1 == No|NA, skip c1_6_8_1/8_* Digital development strategy with a financial inclusion component, explicit numerical targets for one or more of the following categories?
  
 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_6_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_6_1 if mcheck == 1
	
	listtab $id_info `var_1' mcheck c1_6_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: Digital development strategy with a financial inclusion component:   explicit numerical targets") headchars(charname)  	
	
	
	 #delimit ;
	local var_1 c1_7_8_1_women 
				c1_7_8_2_youth 
				c1_7_8_3_microenter
				c1_7_8_4_smes
				c1_7_8_5_farmers
				c1_7_8_6_migrantsr 
				c1_7_8_7_peoplewit 
				c1_7_8_8_poor ;
	 #delimit cr
	 
  //Missing values, If c1_7_1 == No|NA, skip c1_7_8_1/8_* Digital Financial Services or fintech strategy, explicit numerical targets for one or more of the following categories?
  
 	capture drop mcheck
	gen mcheck = 0
		
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c1_7_1 != "No"
		
	} 
	br $id_info `var_1' mcheck c1_7_1 if mcheck == 1
	
	listtab $id_info `var_1' mcheck c1_7_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C1: Digital Financial Services or fintech strategy:   explicit numerical targets") headchars(charname)  			
	
	
		 
		//Comment: If Status == NA, subsequent questions still open
		//Comment: Check BIH
		//Comment: Automatically populates No in c1_1/7_8_1/8_*  even if  c1_1_1 == No
		
	
	///C2. Which of the following programs or policies has your country implemented to promote financial inclusion? Please mark all that apply.  
	
	
	#delimit ;
	local var_1 c2_1_1_requiremen 
				c2_1_2_requiremen 
				c2_1_3_requiremen 
				c2_1_4_priority_l 
				c2_1_5_tax_incent 
				c2_1_6_deposit_ta 
				c2_1_7_digitizati
				c2_1_8_requiring_
				c2_1_9_innovation 
				c2_1_10_requiremen;
	 #delimit cr			
		
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	}

	mdesc `var_1'
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C2") headchars(charname)

	
	///C2.2 For any initiative which provides a basic account product, please provide the following details about the basic transaction accounts required to be made available in your jurisdiction

	
	#delimit ;			
	local var_1 c2_2_1 
				c2_2_2
				c2_2_3_1_areprovid 
				c2_2_3_2_dothebas
				c2_2_3_3_arebasic 
				c2_2_3_4_doestheb 
				c2_2_3_5_arethere 
				c2_2_3_6_other;
	 #delimit cr			
		
	//Missing values. Need to have an answer
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	}

	mdesc `var_1'

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C2.2") headchars(charname)
		
		
	//Cleaning: Variable name wrong! c2_2_a_secify, changed to c2_2_a_specify
	capture rename c2_2_a_secify c2_2_1_specify
	label var c2_2_1_specify "c2_2_1_specify"
		
	#delimit ;
	local var_1 c2_2_1_specify
				c2_2_2_specify
				c2_2_3_specify;
	 #delimit cr	
	 
	#delimit ;
	local var_2 c2_2_1
				c2_2_2
				c2_2_3_6_other;
	 #delimit cr		 
	 
	local n : word count `var_2'
	
	//Skip value, missing only, If c2_2_a_1/3 != Other, Skips c2_2_1/3_specify

	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if (missing(`a') & (`b' == "Other"|`b' == "Yes"))
	}

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Skip values in C2.2 due to If c2_2_a_1/3 != Other, Skips c2_2_1/3_specify") headchars(charname)	
	
		//Comment: c2_2_a_1/3, not required, just comments

		
	///C2.3a Are a basic set of features required to be provided for the basic transaction accounts?  
	
	//Missing values. Need to answer Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(c2_3_a)

	mdesc c2_3_a

	listtab $id_info c2_3_a if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C2.3a") headchars(charname)	
	
	///C2.3b Please mark all required features that apply and indicate the terms under which they must be provided

	#delimit ;
	local var_1 c2_3_b_1
				c2_3_c_1
				c2_3_b_2
				c2_3_c_2
				c2_3_b_3
				c2_3_c_3
				c2_3_b_4
				c2_3_c_4
				c2_3_b_5
				c2_3_c_5
				c2_3_b_6
				c2_3_c_6
				c2_3_b_7
				c2_3_c_7
				c2_3_b_8
				c2_3_c_8
				c2_3_b_9
				c2_3_c_9
				c2_3_b_10
				c2_3_c_10;
	 #delimit cr
	 
	//Missing values. Need to have an answer
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c2_3_a == "Yes"

	}
	br $id_info `var_1' if mcheck == 1
	mdesc `var_1'
	
	//Cleaning
			//Comment: Automatically populates No even if  IF c2_3_a ==No|NA
			foreach i of local var_1 {
				replace `i' = "" if c2_3_a == "No"| c2_3_a == "NA"
			}
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C2.3b") headchars(charname)


	///C2.3c Are the following features embedded at no extra cost to the customer:
	
	#delimit ;
	local var_1 c2_3c_1_choice_of_
				c2_3c_2_offline_al 
				c2_3c_3_security_a;
	 #delimit cr
	 
	//Missing values. Need to have an answer
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & c2_3_a == "Yes"

	}

	mdesc `var_1'
	
	//Cleaning
			//Comment: Automatically populates No even if  IF c2_3_a ==No|NA
			foreach i of local var_1 {
				replace `i' = "" if c2_3_a == "No"| c2_3_a == "NA"
			}
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C2.3c") headchars(charname)

	
	///C3. In order to monitor the level of access to financial services, has your agency or any other agency conducted any of the following in the past 3 years? Please mark all that apply. 
			
	local var_1 c3_1_1 c3_2_1 c3_3_1 c3_4_1 c3_5_1 c3_6_1
		
	//Missing values. Need to answer Yes/No/NA
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')

	}

	mdesc `var_1'

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in C3") headchars(charname)
	
	
	#delimit ;
	local var_1 c3_1_2
				c3_1_3
				c3_2_2
				c3_2_3
				c3_3_2
				c3_3_3
				c3_4_2
				c3_4_3
				c3_5_2
				c3_5_3
				c3_6_2
				c3_6_3;
	 #delimit cr	
	 
	#delimit ;
	local var_2 c3_1_1 
				c3_1_1
				c3_2_1
				c3_2_1
				c3_3_1
				c3_3_1 
				c3_4_1
				c3_4_1
				c3_5_1 
				c3_5_1
				c3_6_1
				c3_6_1;
	 #delimit cr		 
	 
	local n : word count `var_2'
	
	//Skip value, missing only, If c3_1/6_1 == No|NA, skip c3_1/6_2 and  c3_1/6_3

	capture drop skipcheck
	gen skipcheck = 0
	
	forvalues i = 1/`n'  {
		local a : word `i' of `var_1'
		local b : word `i' of `var_2'
		
		dis "`a'"  "`b'"
		replace skipcheck = 1 if missing(`a') & `b' == "Yes"
	}

	listtab $id_info `var_1' skipcheck `var_2' if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Skip values in C3 due to If c3_1/6_1 == No|NA THEN skip c3_1/6_2 and c3_1/6_3") headchars(charname)	
		
	
		//Comment: c3_1/6_3 have Non URL responses
		//Comment: check BIH responses

		


	///END///














	