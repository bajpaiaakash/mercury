/** 
Apex Class Name     :   Test Sprint Planning
Version             :   1.0  
Created Date        :   18/02/2012
Function            :   This class contains unit tests for validating the behavior of Sprint Planning Apex classes
Modification Log    : 
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deloitte UK                18/02/2012              Original Version 
******************************************************************************/
@isTest
private class Test_sprintPlanning {

    static testMethod void myUnitTest() {
        
        // Perform  data preparation.
        List<MICO_Sprint__c> sprints = new List<MICO_Sprint__c>{};
            
        for(Integer i = 0; i < 200; i++){
            MICO_Sprint__c objSprint = new MICO_Sprint__c(Name        = 'Test-Sprint'+ i,
                                                Status__c   = 'In Planning'
                                            );
            sprints.add(objSprint);
        }
        insert sprints;
        List<MICO_User_Story__c> requirements = new List<MICO_User_Story__c>{};
        
        for(Integer i = 0; i < 200; i++){
            MICO_User_Story__c objRequirement =new MICO_User_Story__c(
                                                    I_Want_To__c            = 'Test-Description-User-Stroy',
                                                    Acceptance_Criteria__c  = 'Test-Acceptance-Criteria',
                                                    Story_Points__c         = '21',
                                                    Story_Points_Other__c   = '21',
                                                    Development_Stage__c    = 'Backlog' ,
                                                    Priority__c             = 0,
                                                    Proposed_Sprint__c      = sprints[1].Id,
                                                    Allocated_Sprint__c     = sprints[1].Id
            );
            requirements.add(objRequirement);
        }
        insert requirements;
        
        test.startTest();
        
        PageReference pageRef = Page.SprintPlanning;
        Test.setCurrentPage(pageRef);
        
        sprintPlanning controller = new sprintPlanning();
        List<SelectOption>      listSprints     = controller.getSprint();
        List<SelectOption>      listProjects     = controller.getProject();
        PageReference           pageRefNull     = controller.syncUserStory();
        System.assertEquals(null, pageRefNull); 
        controller.currentSprint                = sprints[0].Id; 
        List<MICO_User_Story__c> listAllocatedUS   = controller.getAllocatedUserStory();
        List<MICO_User_Story__c> listNonAllocatedUS= controller.getNotAllocatedUserStory();
        
        MICO_Sprint__c testspr     =  controller.spr ;
        list <MICO_User_Story__c> testreq = controller.req;
        list <MICO_User_Story__c> testnonreq = controller.notAllocatedUS ;
        MICO_Sprint__c testsprint      = controller.getSelectedSprint();
        integer test1             = controller.getsfdcPlanned();
        integer test2             = controller.getOtherPlanned();
        integer test3             = controller.getsfdcRemain();
        integer test4             = controller.getOtherRemain();
        
        
        Apexpages.currentPage().getParameters().put('SprintID' , 'AllocateUSies');
        Apexpages.currentPage().getParameters().put('UserStoryID' ,requirements[0].id);
        controller.updateUserStoriesSprint();
        
        
        controller.autoPlan();
        test.stopTest();
        
    }
    
    
    static testMethod void myUnitTest_ElseCases() {
        
        // Perform  data preparation.
        List<MICO_Sprint__c> sprints = new List<MICO_Sprint__c>{};
            
        for(Integer i = 0; i < 200; i++){
            MICO_Sprint__c objSprint = new MICO_Sprint__c(Name        = 'Test-Sprint'+ i,
                                                Status__c   = 'In Planning'
                                            );
            sprints.add(objSprint);
        }
        insert sprints;
        List<MICO_User_Story__c> requirements = new List<MICO_User_Story__c>{};
        
        for(Integer i = 0; i < 200; i++){
            MICO_User_Story__c objRequirement =new MICO_User_Story__c(
                                                    I_Want_To__c            = 'Test-Description-User-Stroy',
                                                    Acceptance_Criteria__c  = 'Test-Acceptance-Criteria',
                                                    Story_Points__c         = '21',
                                                    Story_Points_Other__c   = '21',
                                                    Development_Stage__c    = 'Backlog' ,
                                                    Priority__c             = 0,
                                                    Proposed_Sprint__c     = sprints[1].Id,
                                                    Allocated_Sprint__c     = sprints[1].Id
            );
            requirements.add(objRequirement);
        }
        insert requirements;
        
        test.startTest();
        
        PageReference pageRef = Page.SprintPlanning;
        Test.setCurrentPage(pageRef);
        sprintPlanning controller = new sprintPlanning();
        List<SelectOption>    listSprints       = controller.getSprint();
        PageReference pageRefNull               = controller.syncUserStory();
        System.assertEquals(null, pageRefNull);
        controller.currentSprint                = null; 
        List<MICO_User_Story__c> listAllocatedUS   = controller.getAllocatedUserStory();
        List<MICO_User_Story__c> listNonAllocatedUS= controller.getNotAllocatedUserStory();
        
        MICO_Sprint__c testsprint      = controller.getSelectedSprint();
        integer test1             = controller.getsfdcPlanned();
        integer test2             = controller.getotherPlanned();
        integer test3             = controller.getsfdcRemain();
        integer test4             = controller.getotherRemain();
        
        Apexpages.currentPage().getParameters().put('SprintID' , 'NotAllocateUSies');
        Apexpages.currentPage().getParameters().put('UserStoryID' ,requirements[0].id);
        controller.updateUserStoriesSprint();
        test.stopTest();
        
    } 
}