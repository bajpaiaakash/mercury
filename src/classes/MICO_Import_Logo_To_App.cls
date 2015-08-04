/*********************************************************************************
Class Name      : MICO_Import_Logo_To_App
Description     : This controller is used to support the MICO_Generate_Form page
				  to build the required URLs for the logos that are exported
				  to the word file generated
Created By      : Madhuri Nittala               
Created Date    : April 2, 2015
Modification Log:
---------------------------------------------------------------------------------- 
Developer                   Date                   Description
-----------------------------------------------------------------------------------            
Madhuri Nittala             April 9, 2015          Initial Version
*********************************************************************************/
public with sharing class MICO_Import_Logo_To_App {
	public Id current_App_Id;
	public String lillyLogoURL{get;set;}
	public String cirrusLogoURL{get;set;}
	
	/*
		Constructor to get the application Id for MICO application Id and invoke the getlogoURLs method to build the
		URL of Lilly and Cirrus Logo
	*/
    public MICO_Import_Logo_To_App(ApexPages.StandardController MICO_App) {
    	current_App_Id = MICO_App.getRecord().id;
    	getlogoURLs();
    }
    
/*********************************************************************************
Method Name    : getPrintView
Description    : This method returns the string required to set the printview of the word 
				 file to make it non-optimizable for the browser 
Return Type    : String
Parameter      : None
*********************************************************************************/    
    public String getPrintView(){
        return
        '<!--[if gte mso 9]>' +
            '<xml>' +
            '<w:WordDocument>' +
            '<w:View>Print</w:View>' +
            '<w:Zoom>100</w:Zoom>' +
            '<w:DoNotOptimizeForBrowser/>' +
            '</w:WordDocument>' +
            '</xml>' +
            '<![endif]>';
    }
   
    public void getLogoURLs(){
      List<Document> docList = [Select Id,DeveloperName  from Document where DeveloperName ='LillyLogo' OR DeveloperName='Cirrus_Logo'];
   	  Id lillyLogoId;
   	  Id cirrusLogoId;
   	  for(Document d :docList){	
      	if(d.DeveloperName.equals('LillyLogo')){
        	lillyLogoId = d.Id;
    	}
    	else{
        	cirrusLogoId = d.Id;
    	}
	  }
      Id oId = UserInfo.getOrganizationId();
      String baseURl = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm()) ;
      lillyLogoURL = baseURl +'/servlet/servlet.ImageServer?id='+lillyLogoId+'&oid='+oId;
      cirrusLogoURL = baseURl +'/servlet/servlet.ImageServer?id='+cirrusLogoId+'&oid='+oId;  
   }

}