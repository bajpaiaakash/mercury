@isTest(seeAllData = false)
public class Test_DocumentController{

    static testMethod void DocumentController(){
            
            //create a project
            MICO_Project__c pro = new MICO_Project__c();
            pro.Name = 'Test Project';
            insert pro;
            
            // create a definition
            MICO_Definitions__c def = new MICO_Definitions__c();
            def.Project__c = pro.Id;
            def.Name = 'Tracker';
            def.Term_Acronym__c = 'TRK';
            insert def;
            
            // create a sprint
            MICO_References__c ref = new MICO_References__c();
            ref.Project__c = pro.Id;
            ref.Name = 'Tracker User Guide';
            ref.Document_ID__c = 'TRK-000';
            insert ref;
            
            MICO_Sprint__c  sp = new MICO_Sprint__c();
            sp.Name = 'Test Sprint 1';
            sp.Project__c = pro.Id;
            insert sp;
            
            // create a standard story
            MICO_User_Story__c r = new MICO_User_Story__c();
            r.Proposed_Sprint__c = sp.Id;
            r.Allocated_Sprint__c = sp.Id;
            r.Functional_Area__c  = 'SFA';
            r.Sub_Process__c = 'Marketing';
            r.User__c = UserInfo.getUserId();
            r.Supporting_BA__c = UserInfo.getUserId();
            r.Development_Stage__c = '9. Done';
            r.Project__c = pro.Id;
            insert r;
            
            MICO_UserStory2Design__c  usd = new MICO_UserStory2Design__c();
            usd.User_Story__c = r.Id;
            insert usd;
            
            // a story we will not select
            MICO_User_Story__c r2 = new MICO_User_Story__c();
            r2.Proposed_Sprint__c = sp.Id;
            r2.Allocated_Sprint__c = sp.Id;
            r2.Functional_Area__c  = 'SFA';
            r2.Sub_Process__c = 'Marketing';
            r2.User__c = UserInfo.getUserId();
            r2.Supporting_BA__c = UserInfo.getUserId();
            r2.Development_Stage__c = '9. Done';
            r2.Project__c = pro.Id;
            insert r2;
            
            MICO_UserStory2Design__c  usd2 = new MICO_UserStory2Design__c();
            usd2.User_Story__c = r2.Id;
            insert usd2;
                        
            // a story with some missing criteria
            MICO_User_Story__c r3 = new MICO_User_Story__c();
            r3.Proposed_Sprint__c = sp.Id;
            r3.Allocated_Sprint__c = sp.Id;
            r3.Functional_Area__c  = null;
            r3.Sub_Process__c = null;
            r3.User__c = UserInfo.getUserId();
            r3.Supporting_BA__c = UserInfo.getUserId();
            r3.Development_Stage__c = '9. Done';
            r3.Project__c = pro.Id;
            insert r3;
            
            MICO_UserStory2Design__c  usd3 = new MICO_UserStory2Design__c();
            usd2.User_Story__c = r3.Id;
            insert usd3;
            
            // initialise the doc controller
            DocumentController TDC = new DocumentController();
            
            String domainName = TDC.domainName;
            TDC.Version = '1.0';
            TDC.Organization = 'Deloitte';
            TDC.Project_Name = 'Tracker';
            TDC.createDocument(); // run without stories, so we can generate definitions and references
            TDC.CreateFunctionalDocument(); // run without stories, so we can generate definitions and references
            TDC.Version = '';
            TDC.Organization = '';
            TDC.Project_Name = '--None--';
            TDC.getProjNameList();
            TDC.getUserStories(); 
            TDC.initUS= r ;
            TDC.createQuerySOQL();
            TDC.toggleSort();
            TDC.lstSprintProposed.add(sp.Id);
            TDC.lstSprintAllocated.add(sp.Id);
            TDC.lstUS = new List<DocumentController.cUS>();
            
            // add our stories to the list
            DocumentController.cUS  cus = new DocumentController.cUS(r);
            cus.selected = true;
            TDC.lstUS.add(cus);
            TDC.userStoriesList.add(cus);
            
            DocumentController.cUS  cus2 = new DocumentController.cUS(r2, true);
            TDC.lstUS.add(cus2);
            TDC.userStoriesList.add(cus2);
            
            DocumentController.cUS  cus3 = new DocumentController.cUS(r3, true);
            TDC.lstUS.add(cus3);
            TDC.userStoriesList.add(cus3);
            
            TDC.processUnselected();
            TDC.processSelected();
            TDC.selectedUS.add(r);
            TDC.selectedUS.add(r2);
            TDC.selectedUS.add(r3);
            TDC.createDocument();
            TDC.CreateFunctionalDocument();
            
            TDC.Version = '1.0';
            TDC.Organization = 'Deloitte';
            TDC.Project_Name = 'Tracker';
            TDC.createDocument(); // run this again now that we've set up the fields
            TDC.CreateFunctionalDocument(); // run this again now that we've set up the fields
            TDC.generateQAcards();
            
            
            delete r;
            DocumentController TDC1 = new DocumentController();
            TDC1.getUserStories(); 
    } 

}