@isTest
private class MERC_AllocatedCAPCalculatorTest {

    static List<Meeting_MERC__c> meetings;
    static List<Account> accounts;
    static List<Meeting_Participant_MERC__c> participants;
    static List<Invoice_MERC__c> invoices;
    static List<Invoice_Line_Item_MERC__c> invoicelineitems;
    static User runningUser = MERC_TestFactory.getRunningUser();
    static User testUser = MERC_TestFactory.getTestingUser();
    static Id MeetingRecordTypeId =  [Select ID FROM RecordType WHERE SObjectType = 'Meeting_MERC__c' AND DeveloperName = 'Ad_Hoc_Consulting' LIMIT 1].Id;
    static Id InvoiceRecordTypeId =  [Select ID FROM RecordType WHERE SObjectType = 'Invoice_MERC__c' AND DeveloperName = 'Invoice_Locked_MERC' LIMIT 1].Id;
    static Id CreditNoteRecordTypeId =  [Select ID FROM RecordType WHERE SObjectType = 'Invoice_MERC__c' AND DeveloperName = 'Credit_Note_Locked_MERC' LIMIT 1].Id;
    static Id MeetingRecordTypeNonconsId = [Select ID FROM RecordType WHERE SObjectType = 'Meeting_MERC__c' AND DeveloperName = 'Meeting_Active' LIMIT 1].Id;   

    static {
        MERC_TestFactory.loadFMVSettings();
        System.runAs(runningUser) {
        MERC_TriggerHandlerStateManager.deactivateAll();
        accounts = MERC_TestFactory.insertHcpAccountsInCountry(1, 'GB'); //insert 5 accounts
        meetings = MERC_TestFactory.insertMeetings(1); //insert 2 meetings
        participants = MERC_TestFactory.insertParticipants_forLinetems(meetings.get(0).Id, accounts); //insert 5
        List<Account> accts = [SELECT Id, Service_Provider_Tier_MERC__c, Academic_Qualifications_MERC__c
                                     FROM Account
                                    WHERE Id IN :accounts];
        for (Account a : accts)
        {
                //values in loaded custom setting data will map to min=60, max=100 for a tier 3 phd non-md
                a.Service_Provider_Tier_MERC__c = 3;
                a.Academic_Qualifications_MERC__c = 'PhD non-MD';
        }
        update accts;
       
        invoices = MERC_TestFactory.insertInvoices(participants);       
        invoicelineitems = MERC_TestFactory.insertInvoiceLineItems(invoices.get(0).id,1);
        }
    MERC_TestFactory.loadFMVSettings();
    }

    
    @isTest
    static void test_should_rollupinvoices_of_consulting_type_meetings() {
        System.runAs(testUser) {
            Meeting_MERC__c m = meetings.get(0);
            m.RecordTypeId = MeetingRecordTypeId;
            m.Meeting_Status_MERC__c = 'Active';
            m.MERC_Meeting_Complete_Canceled_Clsd_Date__c = NULL;
            update m;
            
            Test.startTest();
            Meeting_Participant_MERC__c Mp = participants.get(0);
            Mp.Types_of_Service_MERC__c = 'Consulting Project';
            update Mp;
            
            
            Invoice_Line_Item_MERC__c ILI = invoicelineitems.get(0);
            ILI.Consulting_Amount_MERC__c = 500.0;
            ILI.VAT_Rate_MERC__c = 1.0;
            Update ILI;
            
            Invoice_MERC__c Inv = invoices.get(0);
            update Inv;
            
            Invoice_Line_Item_MERC__c ILI1 = invoicelineitems.get(0);
            ILI1.Consulting_Amount_MERC__c = 400.0;
            ILI1.VAT_Rate_MERC__c = 2.0;
            Update ILI1;
            
            Invoice_MERC__c Inv1 = invoices.get(0);
            Inv1.Submit_for_Payment_MERC__c = 'Yes';
            Inv1.Invoice_Attached_MERC__c = True;
            Inv1.RecordTypeId = InvoiceRecordTypeId;
            update Inv1;
            
            System.assertEquals(400, [SELECT MERC_Consulting_Contracted_Amt_excl_VAT__c FROM Invoice_MERC__c WHERE Id = :Inv1.Id].MERC_Consulting_Contracted_Amt_excl_VAT__c);
            
            Test.stopTest();
            

            
            
       }
    
    }
    
    @isTest
    static void test_should_rollupinvoices_of_Non_consulting_type_meetings() {
        System.runAs(testUser) {
            Meeting_MERC__c m = meetings.get(0);
            m.RecordTypeId = MeetingRecordTypeNonconsId;
            m.Meeting_Status_MERC__c = 'Active';
            m.Meeting_Objectives_MERC__c = 'Test';
            m.Target_Audience_List_MERC__c = 'Nurse';
            m.MERC_Meeting_Complete_Canceled_Clsd_Date__c = NULL;
            update m;
            
            Test.startTest();
            Meeting_Participant_MERC__c Mp = participants.get(0);
            Mp.Types_of_Service_MERC__c = 'Consulting Project';
            update Mp;
            
            
            Invoice_Line_Item_MERC__c ILI = invoicelineitems.get(0);
            ILI.Consulting_Amount_MERC__c = 500.0;
            ILI.VAT_Rate_MERC__c = 1.0;
            Update ILI;
            
            Invoice_MERC__c Inv = invoices.get(0);
            update Inv;
            
            Invoice_Line_Item_MERC__c ILI1 = invoicelineitems.get(0);
            ILI1.Consulting_Amount_MERC__c = 400.0;
            ILI1.VAT_Rate_MERC__c = 2.0;
            Update ILI1;
            
            Invoice_MERC__c Inv1 = invoices.get(0);
            Inv1.Submit_for_Payment_MERC__c = 'Yes';
            Inv1.Invoice_Attached_MERC__c = True;
            Inv1.RecordTypeId = InvoiceRecordTypeId;
            update Inv1;
            
            System.assertEquals(400, [SELECT MERC_Consulting_Contracted_Amt_excl_VAT__c FROM Invoice_MERC__c WHERE Id = :Inv1.Id].MERC_Consulting_Contracted_Amt_excl_VAT__c);
            
            
            Test.stopTest();
            
            
       }
    
    }
    
    @isTest
    static void test_should_rollupcreditnote_of_consulting_type_meetings() {
        System.runAs(testUser) {
            Meeting_MERC__c m = meetings.get(0);
            m.RecordTypeId = MeetingRecordTypeId;
            m.Meeting_Status_MERC__c = 'Active';
            m.MERC_Meeting_Complete_Canceled_Clsd_Date__c = NULL;
            update m;
            
            Test.startTest();
            Meeting_Participant_MERC__c Mp = participants.get(0);
            Mp.Types_of_Service_MERC__c = 'Consulting Project';
            update Mp;
            
            Invoice_Line_Item_MERC__c ILI = invoicelineitems.get(0);
            ILI.Consulting_Amount_MERC__c = 500.0;
            ILI.VAT_Rate_MERC__c = 1.0;
            Update ILI;
            
            Invoice_MERC__c CN = invoices.get(0);
            CN.RecordTypeId = CreditNoteRecordTypeId;
            update CN;
            
            Invoice_Line_Item_MERC__c ILI1 = invoicelineitems.get(0);
            ILI1.Consulting_Amount_MERC__c = 400.0;
            ILI1.VAT_Rate_MERC__c = 2.0;
            Update ILI1;
            
            Invoice_MERC__c CN1 = invoices.get(0);
            CN1.Submit_for_Payment_MERC__c = 'Yes';
            CN1.Invoice_Attached_MERC__c = True;
            CN1.RecordTypeId = CreditNoteRecordTypeId;
            update CN1;
            
            System.assertEquals(400, [SELECT MERC_Consulting_Contracted_Amt_excl_VAT__c FROM Invoice_MERC__c WHERE Id = :CN1.Id].MERC_Consulting_Contracted_Amt_excl_VAT__c);
            
            Test.stopTest();
            
            
       }
    
    }
    
    @isTest
    static void test_should_rollupCreditnote_of_Non_consulting_type_meetings() {
        System.runAs(testUser) {
            Meeting_MERC__c m = meetings.get(0);
            m.RecordTypeId = MeetingRecordTypeNonconsId;
            m.Meeting_Status_MERC__c = 'Active';
            m.Meeting_Objectives_MERC__c = 'Test';
            m.Target_Audience_List_MERC__c = 'Nurse';
            m.MERC_Meeting_Complete_Canceled_Clsd_Date__c = NULL;
            update m;
            
            Test.startTest();
            Meeting_Participant_MERC__c Mp = participants.get(0);
            Mp.Types_of_Service_MERC__c = 'Consulting Project';
            update Mp;
            
            
            Invoice_Line_Item_MERC__c ILI = invoicelineitems.get(0);
            ILI.Consulting_Amount_MERC__c = 500.0;
            ILI.VAT_Rate_MERC__c = 1.0;
            Update ILI;
            
            Invoice_MERC__c CN = invoices.get(0);
            CN.RecordTypeId = CreditNoteRecordTypeId;
            update CN;
            
            Invoice_Line_Item_MERC__c ILI1 = invoicelineitems.get(0);
            ILI1.Consulting_Amount_MERC__c = 400.0;
            ILI1.VAT_Rate_MERC__c = 2.0;
            Update ILI1;
            
            Invoice_MERC__c CN1 = invoices.get(0);
            CN1.Submit_for_Payment_MERC__c = 'Yes';
            CN1.Invoice_Attached_MERC__c = True;
            CN1.RecordTypeId = CreditNoteRecordTypeId;
            update CN1;
            
            
            System.assertEquals(400, [SELECT MERC_Consulting_Contracted_Amt_excl_VAT__c FROM Invoice_MERC__c WHERE Id = :CN1.Id].MERC_Consulting_Contracted_Amt_excl_VAT__c);
            
            Test.stopTest();
             
       }
    
    }
    
    
    
    }