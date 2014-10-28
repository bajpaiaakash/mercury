@isTest
private class Test_MICO_DesignTrigger {

    static testMethod void testDesignHistory() {
    	
    	//set up the pre-requisite data
    	MICO_App__c app = new MICO_App__c();
		MICO_Project__c project = new MICO_Project__c();
		MICO_Design__c design = new MICO_Design__c();
		app.Name = 'MICO';
		project.Name = 'MICOSprints';
		design.Name = 'TestDesign';
		
		insert app;
		insert project;   
		
		//insert approver
		User approver = new User(Alias             = 'aprvr',
							Email             = 'approver@mico-test.com',
							EmailEncodingKey  = 'UTF-8',
							LastName          = 'User',
							FirstName         = 'Approver',
							LanguageLocaleKey = 'en_US',
							LocaleSidKey      = 'en_US',
							ProfileId         = [select Id from Profile where Name = 'GLBL_Chatter Only' limit 1].Id,
							TimeZoneSidKey    = 'America/Chicago',
							Username          = 'stakeholder@mico-test' + Math.round(Math.random() * 10000) + '.com',
							UserRoleId        = null,
							Country           = 'Great Britain');
		insert approver;
		
		design.App__c = app.Id;
		design.Project__c = project.Id;
		design.Overview__c = 'Test';
		design.Data_Model__c = 'Test';
		design.Fields__c = 'Test';
		design.Objects__c = 'Test';
		design.Other_Components__c = 'Test';
		design.Page_Layouts__c = 'Test';
		design.Visualforce_Pages__c = 'Test';
		design.Apex_Classes__c = 'Test';
		design.Apex_Trigger__c = 'Test';
		design.MICO_Approver__c = approver.Id;
		
		insert design;
		
		//run the test
		test.startTest();
		
		design.Approval_Status__c = 'Pending Approval';
		
		update design;
		
		MICO_Design_History__c designHistory = new MICO_Design_History__c();
		designHistory = ([SELECT Id, Design_Overview__c, Data_Model__c, Fields__c,
						  Objects__c, Other_Components__c, Apex_Classes__c , Apex_Trigger__c , 
						  Approver__c, Approval_Date__c 
				   FROM MICO_Design_History__c
				   WHERE Design__c = :design.Id 
				   LIMIT 1])[0];
		
		// check values are copied over
		System.assertEquals(design.Overview__c, designHistory.Design_Overview__c);
		System.assertEquals(design.Data_Model__c, designHistory.Data_Model__c);
		System.assertEquals(design.Fields__c, designHistory.Fields__c);
		System.assertEquals(design.Objects__c, designHistory.Objects__c);
		System.assertEquals(design.Other_Components__c, designHistory.Other_Components__c);
		System.assertEquals(design.Apex_Classes__c, designHistory.Apex_Classes__c);
		System.assertEquals(design.Apex_Trigger__c, designHistory.Apex_Trigger__c);
		System.assertEquals(design.MICO_Approver__c, designHistory.Approver__c);
		
		
		design.Approval_Status__c = 'Approved';
		
		update design;
		
		designHistory = ([SELECT Id, Approval_Date__c 
				   FROM MICO_Design_History__c
				   WHERE Design__c = :design.Id 
				   LIMIT 1])[0];
    	
    	//check approval date is stamped
    	System.assertEquals(design.MICO_Approval_Date__c, designHistory.Approval_Date__c);
    	
    	test.stopTest();
    }	
		
}