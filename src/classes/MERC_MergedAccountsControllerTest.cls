/**
* @author Kyle Thornton
*
* This is the unit test class for the MERC_MergedAccountsController class.
* If you make changes to the setup in this test class you may also want to review if the same
* changes need to be made to MERC_MergedAccountApextTest.cls
* 
* To test manually:
* Merge_History_GLBL__c mh = new Merge_History_GLBL__c();
* mh.Winning_Id_GLBL__c = 'HCP-11180';
* mh.Original_Account_ID_GLBL__c = 'GB-0013';
* insert mh;
* 
*/
@isTest
private class MERC_MergedAccountsControllerTest {

    //maxed out at 3. if we try to do a merge of more than 4 we run into all sorts of limits
    //since a merge can only be done for one winning account at at time
    static final Integer TEST_ACCT_SIZE = 2;
    static User testUser;
    static User odsUser;
    static List<Account> winningAccounts;
    static List<Account> losingAccounts;
    static List<Merge_History_GLBL__c> mergeHistory;
    static List<String> prefTypes;
    static List<String> prefValues;

    static
    {
        MERC_TriggerHandlerStateManager.deactivateAll();
        MERC_TestFactory.insertMercuryCustomSettings();

        testUser = MERC_TestFactory.getTestingUser();
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Profile p = [SELECT id from Profile WHERE Profile.Name = 'Mercury Integration ODS - Platform' limit 1];
            String testemail = 'testuserods@unittest.com';
            odsUser = new User(profileId = p.id, username = testemail, email = testemail,
                               emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                               languagelocalekey = 'en_US', timezonesidkey = 'GMT',
                               alias='utusrods', lastname='lastname');
            insert odsUser;
        }

        winningAccounts = MERC_TestFactory.insertMasterAccountsInCountry(TEST_ACCT_SIZE, 'GB');
        losingAccounts  = MERC_TestFactory.insertMasterAccountsInCountry(TEST_ACCT_SIZE, 'GB');
        mergeHistory = new List<Merge_History_GLBL__c>();
        prefTypes  = new List<String>{'Language Preference','Communication Preference','Speaker Interest', 'Contract Delivery', 'Payment Required'};
        prefValues = new List<String>{'English','E-Mail','Contract Request', 'E-Mail', 'Yes'};

        for (Integer i=0; i<TEST_ACCT_SIZE; i++)
        {
            losingAccounts[i].put('Cust_Id_GLBL__c','CUSTID12'+i);
            winningAccounts[i].put('Cust_Id_GLBL__c','CUSTID11'+i);
            mergeHistory.add( new Merge_History_GLBL__c(Winning_Id_GLBL__c=winningAccounts[i].Cust_ID_GLBL__c, Original_Account_ID_GLBL__c=losingAccounts[i].Cust_ID_GLBL__c ));
        }
        insert mergeHistory;
        update losingAccounts;

        List<Preferences_and_Consent_GLBL__c> prefConsentRecords = new List<Preferences_and_Consent_GLBL__c>();
        /*----- for each account create 5 (prefTypes.size()) preferences -----*/
        for (Integer a=0; a<TEST_ACCT_SIZE; a++)
        {
            for (Integer i=0; i<prefTypes.size(); i++)
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

        System.runAs(odsUser)
        {
            //perform merge of losing accounts to winning accounts
            for (Integer i=0; i<TEST_ACCT_SIZE; i++)
            {
                merge winningAccounts[i] losingAccounts[i];
                // reset between each merge
                GLBL_AccountMergeStampTrigger.runAfterUpdate = false;
                GLBL_AccountMergeStampTrigger.beforeDeleteHasRun = false;
                GLBL_AccountMergeStampTrigger.afterDeleteHasRun = false;
                GLBL_AccountMergeStampTrigger.afterUpdateHasRun = false;
            }
        }
        MERC_TriggerHandlerStateManager.activateAll();
    }

    @isTest 
    static void test_should_initialize_controller()
    {
        System.runAs(testUser)
        {
            Test.startTest();
            MERC_MergedAccountsController controller = new MERC_MergedAccountsController();
            Test.stopTest();
            System.assertEquals(TEST_ACCT_SIZE, controller.ssc.getRecords().size());
            System.assertEquals(TEST_ACCT_SIZE, controller.ssc.getResultSize());
        }
    }

    @isTest 
    static void test_should_return_different_accounts_on_navigation()
    {
        System.runAs(testUser)
        {
            Test.startTest();
            MERC_MergedAccountsController controller = new MERC_MergedAccountsController();
            //we can't create many accounts due to the merge operation hitting limits
            //so drop the page size to small number to force page navigation
            controller.updatePageSize(1);
            List<Account> firstSetOfAccounts = controller.getAccounts();
            controller.ssc.next();
            System.assertNotEquals(firstSetOfAccounts, controller.getAccounts());
            controller.ssc.previous();
            Test.stopTest();
            System.assertEquals(firstSetOfAccounts, controller.getAccounts());
        }
    }

    @isTest 
    static void test_should_return_empty_list_of_accounts_for_no_merge_history()
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

    @isTest 
    static void test_should_set_MERC_MergedAccountApex_object_correctly()
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
            System.assertEquals(mergeHistory.get(0).Winning_Id_GLBL__c, controller.mergeObject.getAccount().Cust_ID_GLBL__c);
            System.assertEquals(mergeHistory.get(0).Original_Account_ID_GLBL__c, controller.mergeObject.losingAccountId);
        }
    }

    @isTest 
    static void test_should_mark_object_complete_and_delete_all_losing_records()
    {

        Test.startTest();
        System.runAs(testUser)
        {
            for (Merge_History_GLBL__c mh : mergeHistory) 
            {
                MERC_MergedAccountsController controller = new MERC_MergedAccountsController();
                controller.completedMergeId = mh.Winning_Id_GLBL__c;
                controller.markMergeObjectComplete();
                System.assert([SELECT Merge_Marked_Complete_MERC__c FROM Merge_History_GLBL__c
                    WHERE Id=:mh.Id].Merge_Marked_Complete_MERC__c, 'Record not marked complete.');
            }
        }
        Database.executeBatch(new MERC_MergedAccountsFinalProcessJob());
        Test.stopTest();

        System.assert([SELECT Merge_Processed_MERC__c
                         FROM Merge_History_GLBL__c
                        WHERE Id=:mergeHistory.get(0).Id].Merge_Processed_MERC__c, 'First record not marked processed.');

        /*----- for each account there were 5 pref and consent records created (prefTypes.size()); there are TEST_ACCT_SIZE
                winning and TEST_ACCT_SIZE losing accounts; 5 pref records should be removed after
                marking the merge object complete for each account. -----*/
        System.assertEquals(TEST_ACCT_SIZE*prefTypes.size(), [SELECT COUNT() FROM Preferences_and_Consent_GLBL__c],'Unexpected count of Pref&Consent remaining.');
    }

    @isTest 
    static void test_should_capture_and_handle_exceptions_in_mark_complete_gracefully()
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