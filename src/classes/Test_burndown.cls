/****************************************************************************************************************************************** 
* Class Name   : Test_burndown
* Description  : This is a test class which tests the functionality of automateBurnDown Class    
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
@isTest 
public class Test_burndown {

public static testMethod void test_burndown() {
    
    //Project Record
    MICO_Project__c testProject = new MICO_Project__c();
    testProject.Name = 'TestProject';
    insert TestProject;
  
  //Sprint Record 
  MICO_Sprint__c currentsprint = New MICO_Sprint__c(
  Start_Date__c = System.today(), 
  End_Date__c = System.today().addDays(10),
  Number_Working_Days_in_Sprint__c = 5,
  Status__c = 'In Progress' ,
  Project__c = TestProject.Id);
  insert currentSprint;
    
    //User Story 
    MICO_User_Story__c testRequirement = new MICO_User_Story__c();
    testRequirement.Project__c = TestProject.id;
    testRequirement.Acceptance_Criteria__c = 'OldAcceptanceCriteria';
    testRequirement.Compliance_Criteria__c = 'OldCC';
    testRequirement.Allocated_Sprint__c = currentSprint.Id ;
    insert testRequirement;
    
  //insert template record
   MICO_test_templates__c TT = new MICO_Test_templates__c( 
   user_story__c = testRequirement.Id,
   Title__c = 'My test template title',
   Introduction__c = 'My test template introduction'
   );
  
  String sprintId = String.ValueOf(currentsprint.ID);
  
  automateBurnDown.generateSprintBurndown(sprintID);
 
  automateBurnDown.updateSprintBurndown(sprintID);
  
  automateBurnDown.generateTestScriptBurndown(sprintID);
  
  automateBurnDown.updateTestScriptSprintBurndown(sprintID);
  }
  
}