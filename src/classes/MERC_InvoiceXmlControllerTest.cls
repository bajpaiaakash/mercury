/** 
* @author Sean Harrison 
* 
* This is a unit test class for MERC_InvoiceXmlController.cls which itself is an extension
* for MERC_InvoiceAFIXML.page. Normally this page is called via aa @future callout via
* MERC_InvoiceXmlWriter.cls. These unit test exercise the controller directly.
*
* NOTE: Due to Salesforce limitations this unit test assumes the existence of a Salesforce
* Content Library named "Mercury"
*/
@isTest
private class MERC_InvoiceXmlControllerTest {
    
    static List<Account> accounts;
    static List<Meeting_MERC__c> meetings;
    static List<Meeting_Participant_MERC__c> participants;
    static List<Invoice_MERC__c> invoices;
    static List<Invoice_Line_Item_MERC__c> lineItems;
    static Integer numOfLineItems;
    static String testString;
   
    static User runningUser = MERC_TestFactory.getRunningUser();
    static User testUser = MERC_TestFactory.getTestingUser();
    static List<User> testGroupUserList = MERC_TestFactory.insertTestPublicGroupUsers(1,'System Administrator','Lilly Employee','System_Administrators');
   
     /*
     *  Call the page and make sure each section appears
     */
    @isTest 
    static void testEachSectionAppearsExceptTif() {

  testGroupUserList[0].UserPermissionsSFContentUser = true;
      update testGroupUserList[0];
      System.runAs(testGroupUserList[0]) {
      
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        accounts = MERC_TestFactory.insertAccounts(1);
        meetings = MERC_TestFactory.insertMeetings(1);
        participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accounts);
       

        numOfLineItems = 2;
        for (Meeting_Participant_MERC__c p : participants) {
            p.Services_Rendered_MERC__c = 'Yes';
        }
        update participants;
      
        testString = 'MERC_InvoiceXmlControllerTest';
       
       
       //
        PageReference ref = Page.MERC_InvoiceAFIXML;
        Test.setCurrentPage(ref);

        Test.startTest();
         invoices = MERC_TestFactory.insertInvoices(participants);
        lineItems = MERC_TestFactory.insertContractedInvoiceLineItems(invoices[0].Id,numOfLineItems);

        MERC_InvoiceXmlController controller = new MERC_InvoiceXmlController(new ApexPages.StandardController(invoices[0]));
        Test.stopTest();

        System.assertEquals(controller.invoiceLines.size(), numOfLineItems,'Expected '+numOfLineItems+'but got '+
            controller.invoiceLines.size()+'. line items are: '+controller.invoiceLines);

        System.assert(controller.cdataLines != null && controller.cdataLines != '','cdataLines appears incomplete? : '+controller.cdataLines);

        System.assert(controller.scannedTifSection==null,'There shouldn\'t be a TIF section but there is?? : '+controller.scannedTifSection);
        }
    }

    /*
     * An optional TIF section is driven by the presence of specific Content.
     * Vote for this Idea: https://success.salesforce.com/ideaView?id=08730000000ZWp2AAG
     */
    @isTest 
    static void testTifSection() {

    testGroupUserList[0].UserPermissionsSFContentUser = true;
      update testGroupUserList[0];
      System.runAs(testGroupUserList[0]) {
      
       MERC_TestFactory.adjustForSFDCSetMockBug = true;
        accounts = MERC_TestFactory.insertAccounts(1);
        meetings = MERC_TestFactory.insertMeetings(1);
        participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accounts);
       

        numOfLineItems = 2;
        for (Meeting_Participant_MERC__c p : participants) {
            p.Services_Rendered_MERC__c = 'Yes';
        }
        update participants;
      
        testString = 'MERC_InvoiceXmlControllerTest';
        
        ///
        PageReference ref = Page.MERC_InvoiceAFIXML;
        Test.setCurrentPage(ref);
     
         
        Test.startTest();
         invoices = MERC_TestFactory.insertInvoices(participants);
         lineItems = MERC_TestFactory.insertContractedInvoiceLineItems(invoices[0].Id,numOfLineItems);
        
        ContentVersion tifObjInsert = new ContentVersion();
        tifObjInsert.VersionData = Blob.valueOf('12345678');
        tifObjInsert.PathOnClient = invoices[0].Id + '.tif';
        insert tifObjInsert;

        ContentVersion tifObj= [SELECT Id,ContentDocumentId FROM ContentVersion where Id = :tifObjInsert.Id];
        ContentWorkspace library = [SELECT Id FROM ContentWorkspace where Name = 'Mercury' LIMIT 1];

        ContentWorkspaceDoc docLink = new ContentWorkspaceDoc();
        docLink.ContentWorkspaceId = library.Id;
        docLink.ContentDocumentId = tifObj.ContentDocumentId;
        insert docLink;

        tifObj.Invoice_MERC__c = invoices[0].Id;
        tifObj.Title = invoices[0].Id + '.tif';
        update tifObj;
 
     
        MERC_InvoiceXmlController controller = new MERC_InvoiceXmlController(new ApexPages.StandardController(invoices[0]));

     Test.stopTest();

        System.assert(controller.scannedTifSection!=null,'There should be a TIF section');
        }
    }

    /*
     * Format of SAP Cost Element is variable - make sure we are formatting correctly
     */
     @isTest
    static void testSAPCostElementIsCorrect() {
    
      testGroupUserList[0].UserPermissionsSFContentUser = true;
      update testGroupUserList[0];
      System.runAs(testGroupUserList[0]) {
      
        MERC_TestFactory.adjustForSFDCSetMockBug = true;
        MERC_TriggerHandlerStateManager.deactivateAll();

        accounts = MERC_TestFactory.insertAccounts(1);
        meetings = MERC_TestFactory.insertMeetings(1);
        participants = MERC_TestFactory.insertParticipants(meetings[0].Id, accounts);
       

        numOfLineItems = 2;
        for (Meeting_Participant_MERC__c p : participants) {
            p.Services_Rendered_MERC__c = 'Yes';
        }
        update participants;
      
        testString = 'MERC_InvoiceXmlControllerTest';
        
        //
        MERC_TriggerHandlerStateManager.deactivateAll();
        invoices = MERC_TestFactory.insertInvoices(participants);
        Test.startTest();
        lineItems = MERC_TestFactory.insertContractedInvoiceLineItems(invoices[0].Id,numOfLineItems);
            for (Invoice_Line_Item_MERC__c li : lineItems) li.Cost_Element_MERC__c = 'Extra cash for First Fridays - 7654321';
            update lineitems;
            PageReference ref = Page.MERC_InvoiceAFIXML;
            Test.setCurrentPage(ref);
            MERC_InvoiceXmlController controller = new MERC_InvoiceXmlController(new ApexPages.StandardController(invoices[0]));
            for (MERC_InvoiceXmlController.InvoiceLineWrapper li : controller.invoiceLines) {
                System.assertEquals(10, li.SAPCostElement.length(), 'cost element string wrong length');
                System.assert(li.SAPCostElement.startsWith('000'), 'Unexpected cost element format: '+li.SAPCostElement);
            }
       Test.stopTest();
       }
     }
}