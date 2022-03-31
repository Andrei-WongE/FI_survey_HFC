/// Project: FICP_Survey_Project -- Section J
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
	
	use "$data/j_financial_education_and_capabi-survey", clear
	
	//merge 1:1 country_code year status using "$data/b_financial_sector_landscape_-survey.dta"
		
	keep if status == "Submitted to Review" // 135 observations deleted
	keep if year == 2022 // 0 observations deleted

	merge 1:1 country_code using "$base/WB_CountryClassification.dta"
	keep if year == 2022 // 173 observations deleted
	
	//assert c(N) == 91
	
	//Create output files and setting charinclude
	global filename  "FICP_survey_Section_J_HFC_"  // Change accordinly
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
	
	
	//J. Financial Education and Capability

	//Check duplicate IDs
	sort region country_code
	
	capture drop id_dup
	duplicates tag country_code, generate(id_dup) // Sort and Check for unique identifiers
		if _rc != 0 di "observations by country are NOT unique in country_code"
		else if _rc == 0 di "Observations by country are unique in this section"
	
	listtab $id_info using `hfc_file' if id_dup == 1, delimiter(",") replace headlines("  ,Duplicate Country ID") headchars(charname)
	
	///J1. Is there any agency responsible for leading and/or coordinating financial education policy and programs? 
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(j2_1)
	replace j2_1 = "MISSING" if mcheck == 1 

	mdesc j2_1

	listtab $id_info j2_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in J1") headchars(charname)
	
	//Skip value, missing only, If j2_1 == No, skip J2_2

	capture drop skipcheck
	gen skipcheck = 0
		
	replace skipcheck = 1 if missing(j2_2) & j2_1 == "Other"
	replace j2_2 = "SKIP" if skipcheck == 1 

	listtab $id_info j2_2 skipcheck j2_1 if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Skip values in J1 due to j2_1 == Other, skip J2_2") headchars(charname)
		
	//Cleaning
	
	replace j2_2 = "" if country_code == "MOZ" //Answered Presently the existing  financial education initi even j2_1 = No
	
	///J2. Please provide the following details of the agency or agencies that are mainly responsible for leading and/or coordinating financial education policy and programs?   
	
	#delimit ;
	local var_1 j3_a_1
				j3_a_2
				j3_a_3
				j3_a_5
				j3_b_1
				j3_b_2
				j3_b_3
				j3_b_5
				j3_c_1
				j3_c_2
				j3_c_3
				j3_c_5
				j3_d_1
				j3_d_2
				j3_d_3
				j3_d_5;
	#delimit cr		
	
	//Skip value, missing only, If j2_1 == No, skip j3_a/d_1/5, BUT If j2_1 != No, only j3_a_1/5 cannot be empthy

	capture drop skipcheck
	gen skipcheck = 0
		
	foreach i of local var_1 {
		replace skipcheck = 1 if !missing(`i') & j2_1 != "No"
		
	}

	listtab $id_info `var_1' skipcheck j2_1 if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Skip values in J2 due to j2_1 == No, skip j3_a/d_1/5") headchars(charname)
	
			//Comment: not all fields need to be filled.
	
	//Consitency checks of Number of staff dedicated to financial education [Numeric]
	
			//Comment: j3_a_4 is text, should be numeric!
			destring j3_a_4, replace
			replace j3_a_4 = 0 if j3_a_4 == .
	
	#delimit ;
	local var_1 j3_a_4
				j3_b_4
				j3_c_4
				j3_d_4;
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
		
	//Cleaning	
	
	foreach i of local var_1 {
		sum `i'
	}
	
	listtab $id_info `var_1'  if consischeck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Non numeric values of J2: Number of staff dedicated to financial education") headchars(charname)	

	///J3. Does a dedicated, national, multi-stakeholder structure exist to promote and coordinate the provision of financial education in your country? 
	

	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(j4_1)
	replace j4_1 = "MISSING" if mcheck == 1 

	mdesc j4_1
	

	///J4. Who participates in the multi-stakeholder structure? Please mark all that apply.
	
	//Skip value, missing only, If j5_1_6_other == "No", skip j5_2

	capture drop skipcheck
	gen skipcheck = 0
		
	replace skipcheck = 1 if missing(j5_2) & j5_1_6_other == "Yes"
	
	//Cleaning
	#delimit ;
	local var_1 j5_1_1_government
				j5_1_2_industry
				j5_1_4_internatio
				j5_1_5_unaffiliat
				j5_1_6_other
				j5_2;
	 #delimit cr	
	 
		//Automatically populates with CEROs even if J4_1 != Yes, SO inpute "" when J4_1 != Yes
		foreach i of local var_1 {
				replace `i' = "" if j4_1 != "Yes"

		}
			
		
	listtab $id_info j4_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in J4") headchars(charname)	
	
	listtab $id_info j5_2 skipcheck j5_1_6_other if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Skip values in J4 due to j5_1_6_other == No THEN skip j5_2") headchars(charname)

	///J5. Has the government, either by itself or in coordination with another institution, undertaken a national mapping of financial education activities in the past five years?
	///J6. Has the government,  either by itself or in coordination with another institution, undertaken a financial education gap analysis (identifying opportunities to integrate financial education into large-scale programs) in the past five years? 
	///J7. Has the government,  either by itself or in coordination with another institution, undertaken a learning needs or customer journey assessment (identifying largest educational needs of consumers) in the past five years? 
	///J8. Does the government regularly collect data directly from providers of financial education programs on the reach (e.g. number of beneficiaries) of their programs?
	///J9.  Has the government collected indicators to measure financial capability through a nationally representative individual- or household-level survey conducted in your country in the past five years?
	///J10.  Has the government issued written guidelines to providers on approaches to integrate financial education? Please select all that apply. 
	///J11.  Does the government explicitly require (i.e. via regulation, guidelines, or circular) financial service providers to provide financial education? 
	
	
	#delimit ;
	local var_1 j6_1
				j7_1
				j8_1
				j9_1
				j10_1
				j11_1_1_yesdirect
				j11_1_2_yesdirect
				j11_1_3_yesdirect
				j11_1_4_yesdirect
				j11_1_5_yesdirect
				j12_1;
	 #delimit cr			
		
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i')
		//replace `i' = "MISSING" if mcheck == 1 

	}

	mdesc `var_1'
	
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in J5 to J11") headchars(charname)
	

	
	///J12.  Is financial education included as a component of any government-provided financial programs provided to recipients (e.g. as an element of government wage digitization programs, pension programs, cash transfer programs, remittance programs, agricultural lending programs, MSME financing programs? etc.)? 
		
	
	//Skip value, missing only, If j13_2_9_other == No, skip j13_3

	capture drop skipcheck
	gen skipcheck = 0
		
	replace skipcheck = 1 if missing(j13_3) & j13_2_9_other == "Yes"
		
	listtab $id_info j13_3 skipcheck j13_2_9_other if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Skip values in J12 due to j13_2_9_other == No, skip j13_3") headchars(charname)
	
			
	///J12 a. Please indicate which government programs have incorporated financial education for its recipients?
	//Missing, only if j13_1 != Yes
		
	#delimit ;
	local var_1 j13_2_1_cashtrans
				j13_2_2_remittance
				j13_2_3_government
				j13_2_4_pensionpr
				j13_2_5_taxpaymen
				j13_2_6_agricultur
				j13_2_7_msmefinan
				j13_2_8_smefinanc
				j13_2_9_other;
	 #delimit cr		

	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') & j13_1 == "Yes"
		replace `i' = "MISSING" if mcheck == 1 

	}

	mdesc `var_1'
	
	
	//Cleaning

			//Automatically populates with NOs even if j13_1 != Yes
			foreach i of local var_1 {
				replace `i' = "" if j13_1 != "Yes"
		    }

	listtab $id_info `var_1' mcheck j13_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in J12.a") headchars(charname)
	
	
	///J13. Is financial education included as a topic or subject in public school curriculums?
	
	//Missing values
	capture drop mcheck
	gen mcheck = 0
	
	replace mcheck = 1 if missing(j14_1)
	replace j14_1 = "MISSING" if mcheck == 1 

	mdesc j14_1
	
	listtab $id_info j14_1 if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in J13") headchars(charname)	

	///J14.  For which education levels is financial education included as a topic in public school curriculums (current or planned)? Please mark all that apply. 

	#delimit ;
	local var_1 j15_1_1_primary
				j15_1_2_juniorsec
				j15_1_3_seniorsec
				j15_1_4_university;
	 #delimit cr		
	
	//Skip value, missing only, If j14_1 == "No", Skips J14

	capture drop skipcheck
	gen skipcheck = 0

	foreach i of local var_1 {	
		replace skipcheck = 1 if missing(`i') & j14_1 != "No"
		replace `i' = "MISSING" if mcheck == 1 

	}
	
	//Cleaning

			//Automatically populates with NOs even if j14_1 == "No"
			foreach i of local var_1 {
				replace `i' = "" if j14_1 == "No"
			}

	listtab $id_info `var_1' skipcheck j14_1 if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Skip values in J14 due to j14_1 == No, Skips J14") headchars(charname)


	///J15.  Does the government, either by itself or in coordination with another institution, maintain a website with the objective of improving the financial capability of the public? Please mark all that apply.  
	
	#delimit ;
	local var_1 j16_1_1_yesdisclo
				j16_1_2_yeswithe
				j16_1_3_yeswitho
				j16_1_4_no;
	 #delimit cr		

	//Missing values, musta have value 
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') 
		replace `i' = "MISSING" if mcheck == 1 

	}
	
	mdesc `var_1'	

	//Skip value, missing only, If j16_1_3_yeswitho == No, skip j16_2

	capture drop skipcheck
	gen skipcheck = 0
		
	replace skipcheck = 1 if missing(j16_2) & j16_1_3_yeswitho == "Yes"
		
	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in J15") headchars(charname)	
	
	listtab $id_info j16_2 skipcheck j16_1_3_yeswitho if skipcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Skip values in J15 due to j16_1_3_yeswitho == No THEN skip j16_2 ") headchars(charname)
	
	
	///J16.  Does the government, either by itself or in coordination with another institution, regularly implement any of the following types of financial education programs:   Please mark all that apply.  
	///J17.  Does the government, either by itself or in coordination with another institution implement any of the following financial education policies and programs designed specifically to improve digital literacy and awareness:  Please mark all that apply.  
	///J18.  Does the government, either by itself or in coordination with another institution implement financial education policies and programs that are differentiated based on the following criteria:   Please mark all that apply.  

		#delimit ;
	local var_1 j17_1_10_aimlbase 
				j17_1_11_onlineedu
				j17_1_1_nationalf 
				j17_1_2_publicser 
				j17_1_3_edutainmen 
				j17_1_4_textmessa 
				j17_1_5_digitalga 
				j17_1_6_digitalnu 
				j17_1_7_contentpr 
				j17_1_8_simulation 
				j17_1_9_chatbots
				j18_1_1_access_and
				j18_1_2_protecting 
				j18_1_3_data_priva 
				j18_1_4_understand
				j18_1_5_understand 
				j18_1_6_digital_mo 
				j18_1_7_other_digi
				j19_1_1_gender 
				j19_1_2_age
				j19_1_3_selfemplo
				j19_1_4_nationalit;
	 #delimit cr		

	//Missing values, musta have value 
	capture drop mcheck
	gen mcheck = 0
	
	foreach i of local var_1 {
		replace mcheck = 1 if missing(`i') 
		replace `i' = "MISSING" if mcheck == 1 

	}
	
	mdesc `var_1'	

	listtab $id_info `var_1' if mcheck == 1, delimiter(",") appendto(`hfc_file') replace headlines("  ,Missing values in J16 to J18") headchars(charname)	

	////END////

