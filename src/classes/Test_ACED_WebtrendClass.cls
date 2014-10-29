/* Class Name  : Test_ACED_WebtrendClass
* Description  : Test Class for ACED_WebtrendClass
* Created By   : Goutham
* Created Date : 9/23/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest(SeeAllData=false)
public class Test_ACED_WebtrendClass{

    static testMethod void insertNewDeliveryActualLine() {
    
    User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
            
    System.runAs(runAsUser) {
    
    ACED_WebtrendClass WebtrendClass = New ACED_WebtrendClass();
    ACED_WebtrendClass.Dimensions Dim = New ACED_WebtrendClass.Dimensions();       
    ACED_WebtrendClass.Measures measures = New ACED_WebtrendClass.Measures();
    ACED_WebtrendClass.Definition  Def = New ACED_WebtrendClass.Definition();
    Test.startTest();
        try{
        ACED_WebtrendClass.parse('');
        }
        catch(exception e){
        }  
    Test.stopTest();
    }
}
}