@isTest
private class Test_MICO_BitbucketEmailHookManager {

    static testMethod void testHandleInboundEmail() {
    	
    	//set up the pre-requisite data
    	
    	// custom settings
    	MICO_SCM_Commit_Settings__c defaultSetting = new MICO_SCM_Commit_Settings__c();
    	defaultSetting.Name = 'Default';
    	defaultSetting.Defect_Pattern__c = 'DEF-[0-9]{6}';
    	defaultSetting.User_Story_Pattern__c = 'US-[0-9]{6}';
    	insert defaultSetting;
    	
    	// app
		MICO_App__c app = new MICO_App__c();
		app.Name = 'tracker';
		insert app;
		
		// project
		MICO_Project__c project = new MICO_Project__c();
		project.Name = 'tracker';
		insert project;                      
		
		// user story
		MICO_User_Story__c story = new MICO_User_Story__c();
		story.Project__c = project.Id;
		story.App__c = app.Id;
		insert story;
		story = ([SELECT Id, Name
				FROM MICO_User_Story__c
				WHERE Id = :story.Id 
				LIMIT 1])[0];
				
		// defect
		MICO_Bug__c defect = new MICO_Bug__c();
		defect.Project2__c = project.Id;
		defect.Problem__c = 'tracker defect';
		insert defect;
		defect = ([SELECT Id, Name
				FROM MICO_Bug__c
				WHERE Id = :defect.Id 
				LIMIT 1])[0];
    	
    	// email message with 2 commits
        Messaging.Inboundemail email = new Messaging.Inboundemail();
        email.fromAddress = 'commits@tracker.com';
        email.subject = 'Commit details';
        email.plainTextBody = 
        	'3 new commits in Tracker:' + '\n' + 
			'' +  '\n' + 
			'https://bitbucket.org/devservices/tracker/commits/123456/' + '\n' + 
			'Changeset:   123456' + '\n' + 
			'Branch:      None' + '\n' + 
			'User:        tracker' + '\n' + 
			'Date:        2014-07-14 21:45:52' + '\n' + 
			'Summary:     commit message 1, linked to ' + defect.Name + ' and ' + story.Name + '.' + '\n' + 
			'' + '\n' + 
			'Affected #:  1 file' + '\n' + 
			'' + '\n' + 
			'https://bitbucket.org/devservices/tracker/commits/78910/' + '\n' + 
			'Changeset:   78910' + '\n' + 
			'Branch:      None' + '\n' + 
			'User:        tracker' + '\n' + 
			'Date:        2014-07-14 21:46:24' + '\n' + 
			'Summary:     commit message 2' + '\n' + 
			'' + '\n' + 
			'Affected #:  2 files' + '\n' + 
			'' + '\n' +  
			'Repository URL: https://bitbucket.org/devservices/tracker/' + '\n'
        	;
        
        Messaging.Inboundenvelope envelope = new Messaging.Inboundenvelope();
        
        //now run the test
        test.startTest();
        
		// create the email handler
    	MICO_BitbucketEmailHookManager inboundEmailHandler = new MICO_BitbucketEmailHookManager();
    	inboundEmailHandler.handleInboundEmail(email, envelope);
    	
    	//check that 2 commits have been created
    	List<MICO_SCM_Commit__c> commits = [SELECT Id, Body__c FROM MICO_SCM_Commit__c];
    	System.assertEquals(2, commits.size());
    	
    	// check that a link has been created to the bug record
    	MICO_SCM_Commit_Bug_Link__c defectLink = ([SELECT Id, Defect__c, SCM_Commit__c FROM MICO_SCM_Commit_Bug_Link__c])[0];
    	System.assertEquals(defect.Id, defectLink.Defect__c);
        
        // check that a link has been created to the bug record
    	MICO_SCM_Commit_Requirement_Link__c storyLink = ([SELECT Id, Requirement__c, SCM_Commit__c FROM MICO_SCM_Commit_Requirement_Link__c])[0];
    	System.assertEquals(story.Id, storyLink.Requirement__c);
    	
        test.stopTest();
    }
}