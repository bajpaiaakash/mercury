/* Class Name  : Test_ACED_RedirectOnNew
* Description  : Test Class for ACED_RedirectOnNew
* Created By   : Goutham
* Created Date : 9/30/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest  (SeeAllData = false)

//test class for ACED_RedirectOnNew
public class Test_ACED_RedirectOnNew{

//test method for ACED_RedirectOnNew
    static testMethod void redirectOnNewTest() {
    
    //Declaring the User with Digital dashboard owner Permission set           
    System.runAs(ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner')) {
    
    Test.startTest();
    
    //Declaring the instance of class and calling the method
    ACED_RedirectOnNew newClass = New ACED_RedirectOnNew(New ApexPages.StandardController(New ACED_Programs__c()));
    Pagereference pr = newClass.redirect();
         
    Test.stopTest();
    
    }
}
}