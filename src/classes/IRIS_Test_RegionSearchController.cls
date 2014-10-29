/*
*  Classname : Iriss_Test_RegionSearchController
*   Created By: Deloitte USI    
*   Created Date: 26-Mar-2014
*   Description: This class is the test class for Iriss_RegionSearchController class.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/
@isTest

public with sharing class IRIS_Test_RegionSearchController{

    static testMethod void testSearchRegion(){
        system.runas(IRIS_Utility.CreateUserForTestMethods()){
            IRIS_Region__c oReg = Iris_Test_Setup.createRegion('TestRegion');
            Test.setCurrentPage(Page.Iris_RegionSearch);
            ApexPages.currentPage().getParameters().put('regionIds', oReg.id);
            ApexPages.currentPage().getParameters().put('selectedRegionIds', oReg.id);  
            IRIS_RegionSearchController controller = new IRIS_RegionSearchController();
            controller.saveResponse();
            IRIS_RegionSearchController checklst = new IRIS_RegionSearchController();
            System.Assert(checklst.lstRegionWrapp.size()>0);
        }    
    }
}