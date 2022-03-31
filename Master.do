/// Project: FICP_Survey_Project -- Master files
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
        //Finds long variable names
        //Saves original variables order
        //General cleaning
    3. Label variables
    4. Order variables in original sequence and saves dta

    */
///-----------------------------------------------------------------------------

	
	if "`c(username)'" == "WB573601"  {
		global base "C:\Users\WB573601\OneDrive - WBG\Documents\Abbas Projects\FICP 2022\"
		cd "$base"
		
	}
	
	if "`c(username)'" == "wb562573"  {
		global base "C:\Users\wb562573\OneDrive - WBG\Documents\FICP -team\FICP survey\"
		cd "$base"	
		
	}
	
	else {
		global base "D:\Documents\Consultorias\World_Bank\FICP_Survey_Project" //Folder where the do-files are located
		cd "$base"
		
	}
	
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

		//BE AWARE: ALL do files should be in the same folder as this do-file

	//Set data version and id categories by changing the following do-file:
		
		include "Global_macro_A.do"
		
	//B. Financial Sector Landscape	
	
		do "Section_B.do"
	
	//C. Financial Inclusion Policies and strategies	

		do "Section_C.do"
		
	//D. Legal, Regulatory and Supervisory Framework for Relevant Financial Service Providers	

		do "Section_D.do"
	
	//E. Enabling Regulatory Framework for Financial Inclusion
	
		do "Section_E.do"

	//F. Institutional Arrangements and Regulatory Framework for Financial Consumer Protection	

		do "Section_F.do"
	
	//G. Disclosure and Transparency	

		do "Section_G.do"
	
	//H. Fair Treatment and Business Conduct	

		do "Section_H.do"
	
	//I. Complaints Handling, Dispute Resolution, and Recourse	

		do "Section_I.do"
	
	//J. Financial Education and Capability

		do "Section_J.do"

	//////////////////////END Master file///////////////////////
