/**
* @author Kyle Thornton
*
* This is the unit test class for the MERC_MergedAccountsController class.
* If you make changes to the setup in this test class you may also want to review if the same
* changes need to be made to MERC_MergedAccountApextTest.cls
*/
@isTest
private class MERC_MergedAccountsControllerTest {

    static final Integer TEST_ACCT_SIZE  = 30;
    static List<Account> winningAccounts = MERC_TestFactory.insertHcpAccountsInCountry(TEST_ACCT_SIZE, 'GB');
    static List<Account> losingAccounts  = MERC_TestFactory.insertHcpAccountsInCountry(TEST_ACCT_SIZE, 'GB');
    static User          testUser        = MERC_TestFactory.insertTestUsers(1, null).get(0);

    static List<Merge_History_GLBL__c> mergeHistory = new List<Merge_History_GLBL__c>();

    static {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='Mercury_Customer_Meeting_Services_Edit' limit 1];
        insert new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=testUser.id);
        update new User(id=testUser.Id, UserRoleId=[SELECT Id FROM UserRole WHERE Name='Global' limit 1].id);

        for (Integer i=0; i<TEST_ACCT_SIZE; i++)
        {
            mergeHistory.add( new Merge_History_GLBL__c(Winning_Id_GLBL__c=winningAccounts[i].Id, Original_Account_ID_GLBL__c=losingAccounts[i].Id ));
        }
        insert mergeHistory;

        List<Preferences_and_Consent_GLBL__c> prefConsentRecords = new List<Preferences_and_Consent_GLBL__c>();
        List<String> prefTypes  = new List<String>{'Language Preference','Communication Preference','Speaker Interest', 'Contract Delivery', 'Payment Required'};
        List<String> prefValues = new List<String>{'English','E-Mail','Contract Request', 'E-Mail', 'Yes'};
        /*----- for each account create 5 preferences -----*/
        for (Integer a=0; a<TEST_ACCT_SIZE; a++)
        {
            for (Integer i=0; i<5; i++)
            {
                prefConsentRecords.add(
                    new Preferences_and_Consent_GLBL__c( Preference_Type_MERC__c     = prefTypes[i]
                                                       , Preference_Sub_Type_MERC__c = prefValues[i]
                                                       , Account_GLBL__c             = winningAccounts[a].Id)
                );
                prefConsentRecords.add(
                    new Preferences_and_Consent_GLBL__c( Preference_Type_MERC__c     = prefTypes[i]
                                                       , Preference_Sub_Type_MERC__c = prefValues[i]
                                                       , Account_GLBL__c             = losingAccounts[a].Id)
                );
            }
        }
        insert prefConsentRecords;

        /*----- create a custom setting for pref and consent records.
                we need to make assumptions about existing metadata like field sets -----*/
        insert new Account_Merge_Related_Lists_MERC__c( Name                         = 'Preferences_and_Consent_GLBL__c'
                                                      , Parent_Account_Field_MERC__c = 'Account_GLBL__c'
                                                      , Winning_Acct_Related_List_Field_Set_MERC__c = 'Account_Merge_Fields'
                                                      , Losing_Acct_Related_List_Field_Set_MERC__c  = 'Account_Merge_Fields'
                                                      , Allow_Winning_Account_Deletes__c            = true);
    }

    @isTest static void test_should_initialize_controller()
    {
        System.runAs(testUser)
        {
            Test.startTest();
            MERC_MergedAccountsController controller = new MERC_MergedAccountsController();
            Test.stopTest();
            System.assertEquals(10, controller.ssc.getRecords().size());
            System.assertEquals(30, controller.ssc.getResultSize());
        }
    }

    @isTest static void test_should_return_different_accounts_on_navigation()
    {
        System.runAs(testUser)
        {
            Test.startTest();
            MERC_MergedAccountsController controller = new MERC_MergedAccountsController();
            List<Account> firstSetOfAccounts = controller.getAccounts();
            controller.ssc.next();
            System.assertNotEquals(firstSetOfAccounts, controller.getAccounts());
            controller.ssc.previous();
            Test.stopTest();
            System.assertEquals(firstSetOfAccounts, controller.getAccounts());
        }
    }

    @isTest static void test_should_return_empty_list_of_accounts_for_no_merge_history()
    {
        delete mergeHistory;
        System.runAs(testUser)
        {
            Test.startTest();
            MERC_MergedAccountsController controller = new MERC_MergedAccountsController();
            Test.stopTest();
            System.assert(controller.getAccounts().isEmpty());
        }
    }

    @isTest static void test_should_set_MERC_MergedAccountApex_object_correctly()
    {
        System.runAs(testUser)
        {
            Test.startTest();
            MERC_MergedAccountsController controller = new MERC_MergedAccountsController();
            /*----- mergeObject should be null if the activeAccountId is not set -----*/
            controller.updateMergeObject();
            System.assertEquals(null, controller.mergeObject);

            controller.activeAccountId = mergeHistory.get(0).Winning_Id_GLBL__c;
            controller.updateMergeObject();
            Test.stopTest();
            System.assertEquals(mergeHistory.get(0).Winning_Id_GLBL__c, controller.mergeObject.getAccount().Id);
            System.assertEquals(mergeHistory.get(0).Original_Account_ID_GLBL__c, controller.mergeObject.losingAccountId);
        }
    }

    @isTest static void test_should_mark_object_complete_and_delete_all_losing_records()
    {
        System.runAs(testUser)
        {
            Test.startTest();
            MERC_MergedAccountsController controller = new MERC_MergedAccountsController();
            controller.completedMergeId = mergeHistory.get(0).Winning_Id_GLBL__c;
            controller.markMergeObjectComplete();

            Test.stopTest();
            /*----- for each account there were 5 pref and consent records created; there are TEST_ACCT_SIZE
                    winning and TEST_ACCT_SIZE losing accounts; 5 pref records should be removed after
                    marking the merge object complete -----*/
            System.assertEquals(TEST_ACCT_SIZE*5*2-5, [SELECT COUNT() FROM Preferences_and_Consent_GLBL__c]);
            System.assert([SELECT Merge_Processed_MERC__c
                             FROM Merge_History_GLBL__c
                            WHERE Id=:mergeHistory.get(0).Id].Merge_Processed_MERC__c);
        }
    }

    @isTest static void test_should_capture_and_handle_exceptions_in_mark_complete_gracefully()
    {
        System.runAs(testUser)
        {
            Test.startTest();
            MERC_MergedAccountsController controller = new MERC_MergedAccountsController();
            controller.completedMergeId = null;
            controller.markMergeObjectComplete();
            Test.stopTest();

            System.assertEquals(1, ApexPages.getMessages().size());
            System.assertEquals('Unable to process this row. Please contact an administrator.', ApexPages.getMessages().get(0).getSummary());
        }
    }

}