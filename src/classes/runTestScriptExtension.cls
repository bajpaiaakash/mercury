/****************************************************************************************************************************************** 
* Class Name   : runTestScriptExtension
* Description  : functionality for tests
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/

public with sharing class runTestScriptExtension { 
        
        Public final Id Test = System.currentPageReference().getParameters().get('Id');
        
        Private final MICO_test__c tst;
        
        public Boolean isnewBugs{get;set;}
        
        private list<MICO_Test_Bug_Link__c> BugLink = new list<MICO_Test_Bug_Link__c>();
        private Map<string, id> stepName = new Map<string, id>();
        
        public runTestScriptExtension(ApexPages.StandardController stdController) {
        this.tst = (MICO_test__c)stdController.getRecord();
    }
        
        
        
        Public list<MICO_Bug__c> Bugs {get{
                if(Bugs == null){
                        Bugs = new list<MICO_Bug__c>();
                }
                return Bugs;
                
        }set;
        }
        
        
        Public list<MICO_test_steps__c> TestSp {get{
                if(testSp == null){
                        TestSp = [select id,
                                                        name, 
                                                        Action__c, 
                                                        Expected_Results__c, 
                                                        Tips__c, 
                                                        Outcome__c, 
                                                        Comments__c
                                                        
                                                        from MICO_test_steps__c 
                                                        where test__c = :Test order by Name];
                                                        
                        for(MICO_test_steps__c t : TestSp){
                                stepName.put(t.name, t.id);
                        }
                }
                return TestSp;
        
        
        }set;}
        
          public PageReference addBug(){
                id testId = System.currentPageReference().getParameters().get('Id');

MICO_Test__c test = [Select Id, User_Story__c, User_Story__r.Allocated_Sprint__c, User_Story__r.Project__c from MICO_Test__c where Id =: testId][0];
                string testStepName = System.currentPageReference().getParameters().get('testName');
                isnewBugs = true;
                Bugs.add(new MICO_Bug__c(script_number__c = testStepName, status__c='Raised', User_Story__c= test.User_Story__c, Test_Phase__c = tst.Test_Phase__c, Test_Execution__c = testId, 
                                        project2__c = test.User_Story__r.Project__c, sprint2__c = test.User_Story__r.Allocated_Sprint__c, Logged_By__c = UserInfo.getUserId(),Log_Time__c = system.now()  ));
                
                system.debug(Bugs);
                return null;
        }
        
        Public PageReference Save(){
                update tst;
                update TestSp;  
                if(!bugs.isEmpty()){
                        insert Bugs;
                        for(MICO_Bug__c b: Bugs){
                                id testst = stepName.get(b.script_number__c);
                                BugLink.add(new MICO_Test_Bug_Link__c(Bug__c=b.id, Test_Script__c=tst.id, Test_Step_Result__c=testst));
                        
                        }
                        insert BugLink;
                }
                PageReference savenclose = new PageReference('/'+Test);
                return savenclose;
        }

}