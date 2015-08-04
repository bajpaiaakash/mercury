/*
 * TEST_JLGO_AcceptEmail
 */
@isTest
private class TEST_JLGO_AcceptEmail {
    /*
     *  Test Main
     */
	static testMethod void Main() {
        //create test data
        List<JLGO_GrantRequest__c> lstGrant = CreateTestData_JLGO_GrantRequest();
        //Email Class
        JLGO_AcceptEmail accept = new JLGO_AcceptEmail();
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        //Attachment Class
        Messaging.InboundEmail.BinaryAttachment bAtt = new Messaging.InboundEmail.BinaryAttachment();
        Messaging.InboundEmail.TextAttachment tAtt = new Messaging.InboundEmail.TextAttachment();
        //Test Start ----->>
        Test.startTest();
        //*****************************************************
        //1:send dummy Emails with attachment
        //*****************************************************
        email.subject = 'test subject';
        email.plainTextBody = 'test body';
        email.fromAddress = 'test_b@test.com';
		//blob
		bAtt.body = blob.valueOf('test');
		bAtt.fileName = 'my attachment name';	
		bAtt.mimeTypeSubType = 'plain/txt';
		//text
		tAtt.body = 'test';
		tAtt.fileName = 'my attachment name2';
		tAtt.mimeTypeSubType = 'plain/txt';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {bAtt};
		email.textAttachments = new Messaging.inboundEmail.textAttachment[] {tAtt};
		//send
		Messaging.InboundEmailResult result = accept.handleInboundEmail(email, env);
        system.assert(result.success);
        //Insert Result
        List<task> lstTask = [Select id from task where whatid = :lstGrant[0].id];
        system.assert(!lstTask.isEmpty());
        List<Attachment> lstAtt = [Select id ,parent.id from Attachment where ParentId = :lstTask[0].id];
        system.debug(lstAtt);
        system.assertEquals(lstAtt.size(), 2);
        //*****************************************************
        //2: send Emails for GrantRequestData
        //*****************************************************
        email  = new Messaging.InboundEmail();
        email.subject = 'test subject '+ system.label.JLGO_CutStringFrom + lstGrant[1].id + system.label.JLGO_CutStringTo;
        email.plainTextBody = 'test body';
        email.fromAddress = 'test_b@test.com';
        result = accept.handleInboundEmail(email, env);
        system.assert(result.success);
        lstTask = [Select id from task where whatid = :lstGrant[1].id];
		system.assert(!lstTask.isEmpty());        
        //*****************************************************
        //3: Send Dummy Emails When Dummy of GrantRequestData is not exist
        //*****************************************************
        delete lstGrant;
        email  = new Messaging.InboundEmail();
        email.subject = 'test subject';
        email.plainTextBody = 'test body';
        email.fromAddress = 'test_b@test.com';
        result = accept.handleInboundEmail(email, env);
		system.assert(result.success);
        lstTask = [Select id from task where whatid IN (Select id from JLGO_GrantRequest__c where dummyflag__c = true)];
        system.assert(!lstTask.isEmpty());
        //*****************************************************
        //4: Exception
        //*****************************************************
        email  = new Messaging.InboundEmail();
        integer i=0;
        //Over Max Length
        while(i<255){
            email.subject = email.subject+'a';
            i++;
        }
        email.plainTextBody = 'test body';
        email.fromAddress = 'test_b@test.com';
        result = accept.handleInboundEmail(email, env);
        system.assert(result.success);
        List<GLBL_Error_Log__c> lstGel = [select id from GLBL_Error_Log__c];
        system.assert(!lstGel.isEmpty());
        //Test End ----->>
        Test.stopTest();
    }
    static List<JLGO_GrantRequest__c> CreateTestData_JLGO_GrantRequest(){
        List<JLGO_GrantRequest__c> lstGrant = new List<JLGO_GrantRequest__c>();
        //Dummy
        JLGO_GrantRequest__c r = new JLGO_GrantRequest__c();
        r.ApplicationStatus__c = '受付';
        r.ApplicationDate__c = system.today();
        r.DummyFlag__c = true;
        lstGrant.Add(r);
        //Acceppt
        r = new JLGO_GrantRequest__c();
        r.ApplicationStatus__c = '受付';	
        r.ApplicationDate__c = system.today();
        lstGrant.Add(r);
        insert lstGrant;
        return lstGrant;
    }
}