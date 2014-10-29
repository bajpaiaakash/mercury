@isTest 
public class Test_UserStoryTriggerClass {

    /*
     * Method name  : Test_UserStoryTriggerClass 
     * @description Function tests the trigger actions on User Story.
     */
    public static testMethod void test_productActions() {
    
    MICO_User_Story__c testRequirement = new MICO_User_Story__c();
    MICO_Project__c testProject = new MICO_Project__c();
    testProject.Name       = 'TestProject';
    insert TestProject;
    
    testRequirement.Project__c = TestProject.id;
    testRequirement.Acceptance_Criteria__c = 'OldAcceptanceCriteria';
    testRequirement.Compliance_Criteria__c = 'OldCC';
    insert testRequirement;
    
    testRequirement.Acceptance_Criteria__c = 'NewAcceptanceCriteria';
    testRequirement.Compliance_Criteria__c = 'NewCC';
    update testRequirement;
        
    MICO_AC_History__c newlyCreatedACHistoryRecord = [Select Acceptance_Criteria__c  from MICO_AC_History__c 
                                                 where User_Story__c = :testRequirement.id
                                                 ORDER BY SystemModStamp DESC NULLS LAST
                                                 LIMIT 1];
    System.assertEquals('OldAcceptanceCriteria', newlyCreatedACHistoryRecord.Acceptance_Criteria__c);

        } 
        
        
     }