/* Class Name  : Test_ACED_GoogleAnalyticsWrapper
* Description  : Test Class for ACED_GoogleAnalyticsWrapper
* Created By   : Goutham
* Created Date : 12/30/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest(SeeAllData=false)
public class Test_ACED_GoogleAnalyticsWrapper{

    static testMethod void insertNewDeliveryActualLine() {
    
    User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
            
    System.runAs(runAsUser) {
    
    ACED_GoogleAnalyticsWrapper AnalyticsWrapper= New ACED_GoogleAnalyticsWrapper();
    ACED_GoogleAnalyticsWrapper.ColumnHeaders ch = New ACED_GoogleAnalyticsWrapper.ColumnHeaders();       
    ACED_GoogleAnalyticsWrapper.Query query = New ACED_GoogleAnalyticsWrapper.Query();
    ACED_GoogleAnalyticsWrapper.TotalsForAllResults total = New ACED_GoogleAnalyticsWrapper.TotalsForAllResults();
    ACED_GoogleAnalyticsWrapper.ProfileInfo pf = New ACED_GoogleAnalyticsWrapper.ProfileInfo();
    ACED_GoogleAnalyticsWrapper.TokenClass token = New ACED_GoogleAnalyticsWrapper.TokenClass();
    Test.startTest();
        try{
        ACED_GoogleAnalyticsWrapper.parse('');
        }
        catch(exception e){
        }  
    Test.stopTest();
    }
}
}