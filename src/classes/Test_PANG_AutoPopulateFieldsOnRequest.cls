/****************************************************************************************************************************************** 
 * Class Name   : Test_PANG_AutoPopulateFieldsOnRequest 
 * Description  : test Class for PANG_AutoPopulateFieldsOnRequest
 * Created By   : Deloitte Consulting
 * 
 *****************************************************************************************************************************************/
@istest(SeeAllData = false)
public class Test_PANG_AutoPopulateFieldsOnRequest {

    /* 
* @Method Name                    :  testAutoPopulateFieldOnRequestConstructor
* @Description                    :  Testing PANG_AutoPopulateFieldsOnRequest for Autopopulation/Insertion .
* @Return Type                    :  void
* @Parameters                     :  None
*/ 

    private static testmethod void testAutoPopulateFieldOnRequestConstructor() {
    
        User u = PANG_TestFactory.getTestingUser();
        PANG_TestFactory.givePermissions(u.id, 'PANG_RWE_Administrator');
        
        System.assertNotEquals(u.id,NULL); 
                
        system.runAs(u){
        
        map<string,id> mRecordTypes = new map<string,id>();
        for (RecordType oRecType: [SELECT id, developername FROM RecordType WHERE SobjectType = 'PANG_Request__c']) {
            mRecordTypes.put(oRecType.developername, oRecType.id);
        }
        
        //Inserting custom settings
        PANG_Request_FieldId_Settings__c p = new PANG_Request_FieldId_Settings__c(SetupOwnerId = UserInfo.getOrganizationId(),Study_Alias_Project_ID__c='123',Business_Unit_Primary__c='123',Primary_Therapeutic_Area__c='123');
        insert p;
        
        System.assertNotEquals(p,NULL); 
        
        test.starttest();

        list<PANG_Project__c> lprojects = PANG_TestFactory.returnStudies(7);
        insert lprojects;
        System.assertEquals(lprojects.size(),7); 
        
        System.assertNotEquals(lprojects.size(),NULL); 
        
        PANG_Request__c req = new PANG_Request__c(Name = 'Test1Request', recordTypeId = mRecordTypes.get('EXPERT_Review'));
        ApexPages.StandardController sc = new ApexPages.standardController(req);
        PANG_AutoPopulateFieldsOnRequest controller = new PANG_AutoPopulateFieldsOnRequest(sc);
        controller.autoPopulateFieldsOnRequest();       
        insert req;
        System.assertNotEquals(req.id,NULL); 
        
        
        PANG_Request__c req8 = new PANG_Request__c(Name = 'Test1Request', recordTypeId = mRecordTypes.get('EXPERT_Review'),Primary_Request__c=req.id);
        ApexPages.StandardController sc8 = new ApexPages.standardController(req8);
        PANG_AutoPopulateFieldsOnRequest controller8 = new PANG_AutoPopulateFieldsOnRequest(sc8);
        controller8.autoPopulateFieldsOnRequest(); 
        
        list<PANG_Request__c> lRequests = new list<PANG_Request__c>();

        lRequests.add( new PANG_Request__c(Name = 'Test1Request', Related_Project__c = lprojects[0].id, recordTypeId = mRecordTypes.get('EXPERT_Review')));
        lRequests.add(new PANG_Request__c(Name = 'Test1Request', Related_Project__c = lprojects[1].id, recordTypeId = mRecordTypes.get('EXPERT_or_ACT_Consultation')));
        lRequests.add(new PANG_Request__c(Name = 'Test1Request', Related_Project__c = lprojects[2].id, recordTypeId = mRecordTypes.get('EXPERT_Workstream')));
        lRequests.add( new PANG_Request__c(Name = 'Test1Request', Related_Project__c = lprojects[3].id, recordTypeId = mRecordTypes.get('Data_Sourcing')));
        lRequests.add( new PANG_Request__c(Name = 'Test1Request', Related_Project__c = lprojects[4].id, recordTypeId = mRecordTypes.get('Internal_Real_World_Data_Analysis')));
        lRequests.add( new PANG_Request__c(Name = 'Test1Request', Related_Project__c = lprojects[5].id, recordTypeId = mRecordTypes.get('RWE_Strategic_Consultation')));
        lRequests.add( new PANG_Request__c(Name = 'Test1Request', Related_Project__c = lprojects[6].id, recordTypeId = mRecordTypes.get('EXPERT_Exception')));
        
        insert lRequests;
        System.assertNotEquals(lRequests.size(),0);
        
        for(integer i=0;i<7;i++){
            ApexPages.StandardController sc1 = new ApexPages.standardController(lRequests[i]);
            PANG_AutoPopulateFieldsOnRequest controller1 = new PANG_AutoPopulateFieldsOnRequest(sc1);
            controller1.autoPopulateFieldsOnRequest();
        }

        test.stoptest();
    }
}

}