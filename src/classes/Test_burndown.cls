@isTest 
public class Test_burndown {

public static testMethod void test_burndown() {

MICO_Project__c testProject = new MICO_Project__c();
    testProject.Name = 'TestProject';
    insert TestProject;
    
MICO_User_Story__c testRequirement = new MICO_User_Story__c();
    testRequirement.Project__c = TestProject.id;
    testRequirement.Acceptance_Criteria__c = 'OldAcceptanceCriteria';
    testRequirement.Compliance_Criteria__c = 'OldCC';
    insert testRequirement;


 MICO_Sprint__c currentsprint = New MICO_Sprint__c(
  Start_Date__c = System.today(), 
  End_Date__c = System.today().addDays(10),
  Number_Working_Days_in_Sprint__c = 5,
  Project__c = TestProject.Id);
    insert currentSprint;
  
  String sprintId = String.ValueOf(currentsprint.ID);
  
 automateBurnDown.generateSprintBurndown(sprintID);
  
  
  }
  
}