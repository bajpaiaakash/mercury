/*
*  Classname : Iriss_Test_CountrySearchController 
*   Created By: Deloitte USI    
*   Created Date: 26-Mar-2014
*   Description: This class is the test class for Iriss_RegionSearchController class.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/
@isTest

public with sharing class IRIS_Test_CountrySearchController {
    
    public static List<IRIS_Country__c> lstCount{get;set;}
    
    static testMethod void testSearchCountry(){
    system.runas(IRIS_Utility.CreateUserForTestMethods()){
        List<String> lstCon = new List<String>{'India','US','UK'};
        lstCount = Iris_Test_Setup.createCountries(lstCon);
        Test.setCurrentPage(Page.Iris_CountrySearch);
        List<id> lstid = new List<id>();
        String sId='';
        for(IRIS_Country__c oCount : [Select id From IRIS_Country__c Where (Name = 'India' OR Name = 'US') AND id IN: lstCount]){
            lstid.add(oCount.id);
        }
        for(id i : lstid){
            sId += i+';';
        }
        ApexPages.currentPage().getParameters().put('countryIds', sId );
        IRIS_CountrySearchController controller = new IRIS_CountrySearchController();
        controller.saveResponse();
        IRIS_CountrySearchController checklst = new IRIS_CountrySearchController();
        System.Assert(checklst.lstCounWrapp.size()>0);
        for(IRIS_CountrySearchController.CountryWrapper eachwrapper : checklst.lstCounWrapp)
        {
            if(eachwrapper.countryName == 'US' || eachwrapper.countryName=='India')
                System.assert(eachwrapper.isSelected == true);
                System.debug('each record that is selected is :::: '+eachwrapper.countryName + 'and is its selected boolean value is ::: '  + eachwrapper.isselected);
            }
        }
    }
}