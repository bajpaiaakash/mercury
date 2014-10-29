/* Class Name  : Test_ACED_Channel_TriggerHandler
* Description  : Test Class for ACED_Channel_TriggerHandler
* Created By   : Venugopal
* Created Date : 9/30/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/
@isTest(SeeAllData=false)

public class Test_ACED_Channel_TriggerHandler {

    
    static testMethod void createNewChannelAttribute() {
    
        User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
            
    System.runAs(runAsUser) {
    
        Test.startTest();
        List<ACED_Channel__c> lChannel = ACED_DataFactory.createChannels(10);
        List<ACED_Channel_Attribute__c> lChannelAttrAct = ACED_DataFactory.createActualChannelAttributes(10, lChannel  );
        List<ACED_Channel_Attribute__c> lChannelAttrPot = ACED_DataFactory.createPotentialChannelAttributes(10, lChannel );

        System.assertEquals(10, lChannelAttrAct.size());
        System.assertEquals(20, lChannelAttrPot.size());        
               
        Test.stopTest( );            
        
        }
    }
}