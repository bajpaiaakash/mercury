/**
* @author Sean Harrison
*
* This is a unit test class for MERC_InvoiceXmlWriter.cls which is intended
* as a trigger on Invoice_MERC__c
*/
@isTest
private class MERC_InvoiceXmlWriterTest {

    static List<Account> accounts;
    static List<Meeting_MERC__c> meetings;
    static List<Meeting_Participant_MERC__c> participants;
    static List<Invoice_MERC__c> invoices;
    static List<Invoice_Line_Item_MERC__c> lineItems;
    static Integer numOfLineItems;
    static User runningUser = MERC_TestFactory.getRunningUser();
    static User testUser = MERC_TestFactory.getTestingUser();
    static List<User> testGroupUserList = MERC_TestFactory.insertTestPublicGroupUsers(1,'System Administrator','Lilly Employee','System_Administrators');
   
    // exercise the addition (and deletion) of xml files to associated content
    @isTest
    static void createXMLFiles() {

      testGroupUserList[0].UserPermissionsSFContentUser = true;
      update testGroupUserList[0];
      System.runAs(testGroupUserList[0]) {
        //set up the data. Normally this would be done in a static block outside of the test class but that causes
        //the error 'You have uncommitted work pending. Please commit or rollback before calling out site:developer.salesforce.com'
        //to to be thrown for the testCallOut method below
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        MERC_TriggerHandlerStateManager.deactivateAll();
        accounts = MERC_TestFactory.insertAccounts(1);
        meetings = MERC_TestFactory.insertMeetings(1);
        //participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accounts);
        participants = MERC_TestFactory.insertParticipants_forLinetems(meetings.get(0).Id, accounts);
        invoices = MERC_TestFactory.insertInvoices(participants);

        numOfLineItems = 2;
        for (Meeting_Participant_MERC__c p : participants) {
            p.Services_Rendered_MERC__c = 'Yes';
        }
        update participants;
        lineItems = MERC_TestFactory.insertInvoiceLineItems(invoices[0].Id,numOfLineItems);
  
        //start the test
        //the call to MERC_InvoiceXmlWriter.writeXml() queries for a content library so we can't use
        //System.runas(testUser) since we have no way of associating that user to the Mercury content library
        RecordType rt = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Invoice_Line_Item_MERC__c' AND DeveloperName = 'Consulting_Project_MERC'];
        lineitems = [SELECT Id, Amount_MERC__c, Consulting_Amount_MERC__c, Invoice_MERC__c FROM Invoice_Line_Item_MERC__c WHERE Id in :lineItems];
        for (Invoice_Line_Item_MERC__c item : lineitems) {
            item.Amount_MERC__c = 100;
            // Fulfill conditions for Populate Ad Hoc Amount_MERC workflow
            item.Consulting_Amount_MERC__c = 99;
            item.RecordTypeId = rt.Id;
        }
      
        //
      
       Test.startTest(); 
      

       update lineItems;
        
        
        List<String> invoiceIds = new List<String>();
        invoices = [SELECT Id, Invoice_Attached_MERC__c, Submit_for_Payment_MERC__c FROM Invoice_MERC__c WHERE Id in :invoices];
        for (Invoice_MERC__c invoice : invoices) {
            invoiceIds.add(invoice.Id);
            invoice.Submit_for_Payment_MERC__c = 'Yes';
            invoice.Invoice_Attached_MERC__c = true;  // tell it a PDF is already present.  "Lie to me and tell me everything is all right" - Jonny Lang
        }

        update invoices; 
       
  

        //if this fails make sure the running user is added to the mercury library.
       List<ContentVersion> contentVers;
      // Update testUser to Salesforce CRM Content User   
    
     

              MERC_InvoiceXmlWriter.writeXml(invoiceIds);
    
             contentVers = new List<ContentVersion>(
                [SELECT ContentDocumentId From ContentVersion WHERE Invoice_MERC__c in :invoices AND Title like '%.xml%']
                );
          
            System.assert(!contentVers.isEmpty(), 'no XML files in ContentVersion table');
            
          
            System.assertEquals(contentVers.size(),invoices.size(),
                'There seem to be different number of xml files ('+contentVers.size()+') and invoices ('+invoices.size()+')');
        
        // adding another should delete the old one...
       invoices = [SELECT Cost_Center_MERC__c FROM Invoice_MERC__c WHERE Id in :invoices];
        for (Invoice_MERC__c invoice : invoices) {
            invoice.Cost_Center_MERC__c = '7654321';
        }
        update invoices;

        MERC_InvoiceXmlWriter.writeXml(invoiceIds);
        Test.stopTest();

            contentVers = [SELECT ContentDocumentId From ContentVersion WHERE Invoice_MERC__c in :invoices AND Title like '%.xml%'];
            System.assert(!contentVers.isEmpty(), 'no XML files in ContentVersion table');
            System.assertEquals(contentVers.size(),invoices.size(),
                'There seem to be different number of xml files ('+contentVers.size()+') and invoices ('+invoices.size()+')');
       }
    }

    // exercise callout in  MERC_InvoiceXmlWriter.execute()
    @isTest
    static void testCallout() {

        System.runAs(testGroupUserList[0]) {
            //since we are simply exercising the code we don't need to setup any dummy data. the dummy data setup was
            //removed to avoid getting the You have uncommitted work pending. Please commit or rollback before calling out site:developer.salesforce.com error
            //everything is hard coded here and our code is exercised.
            MERC_XmlWriterRestResource.RemoteXmlWriterResponse response = new MERC_XmlWriterRestResource.RemoteXmlWriterResponse();
            response.success = true;
            response.message = 'XML writer job successfully queued 1 jobs';
            String responseString = JSON.serialize(response);
            MERC_XmlWriterCalloutMock mock = new MERC_XmlWriterCalloutMock(200, 'OK', responseString, null);

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock);
            MERC_InvoiceXmlWriter.execute(new Set<ID>(), UserInfo.getSessionId());
            Test.stopTest();
        }
    }

    //If this test errors in a sandbox please ensure the Access Level for "Access to Send Email" in the Email Administration
    //is set to "All Email" and not just "System Email" which would cause a failure.
    @isTest
    static void testSendErrorEmail() {
        System.runAs(testGroupUserList[0]) {
            //since we are simply exercising the code we don't need to setup any dummy data. the dummy data setup was
            //removed to avoid getting the You have uncommitted work pending. Please commit or rollback before calling out site:developer.salesforce.com error
            //everything is hard coded here and our code is exercised.
            MERC_XmlWriterRestResource.RemoteXmlWriterResponse response = new MERC_XmlWriterRestResource.RemoteXmlWriterResponse();
            response.success = false;
            response.message = 'XML writer job successfully queued 1 jobs';
            String responseString = JSON.serialize(response);
            MERC_XmlWriterCalloutMock mock = new MERC_XmlWriterCalloutMock(999, 'NOT FOUND', responseString, null);

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock);
            MERC_InvoiceXmlWriter.execute(new Set<ID>(), UserInfo.getSessionId());
            Test.stopTest();
        }
    }

}