/**
 * @author Kyle Thornton
 *
 * Unit tests for the CUST_RefreshLOVsReviewController class
 */
@isTest
private class CUST_RefreshLOVsReviewControllerTest {

	static CST_App_Menu_Pool_GLBL__c pool;
	static {
		MERC_TestFactory.insertMercuryCustomSettings();
		pool = new CST_App_Menu_Pool_GLBL__c(
						Altrnt_Id_Typ_Desc_Capture_Date_GLBL__c =Date.newInstance(2014,05,22),
						Altrnt_Id_Typ_Desc_GLBL__c              ='Important',
						Bnft_Dsgn_Cd_Capture_Date_GLBL__c       =Date.newInstance(2014,05,22),
						Bnft_Dsgn_Cd_GLBL__c                    ='MD,PhD,MA',
						Clsfctn_Cd_Capture_Date_GLBL__c         =Date.newInstance(2014,05,22),
						Clsfctn_Cd_GLBL__c                      ='MA',
						Cmnctn_Chnl_Cd_Capture_Date_GLBL__c     =Date.newInstance(2014,05,22),
						Cmnctn_Chnl_Cd_GLBL__c                  ='RE345,TRANSPARENCY CONSENT,Email',
						Cnsnt_Prps_Cd_Capture_Date_GLBL__c      =Date.newInstance(2014,05,22),
						Cnsnt_Prps_Cd_GLBL__c                   ='',
						Cnsnt_Sts_Cd_Capture_Date_GLBL__c       =Date.newInstance(2014,05,22),
						Cnsnt_Sts_Cd_GLBL__c                    ='44523,34579,ABC',
						CurrencyIsoCode                         = 'EUR',
						Last_Job_Status_GLBL__c                 ='Job 70711000004MvLiAAK processed 1 batches with 0 failures. 2014-05-22 18:34:14',
						Party_Sts_Cd_Capture_Date_GLBL__c       =Date.newInstance(2014,05,22),
						Party_Sts_Cd_GLBL__c                    ='MA',
						Priority_Rank_Nbr_Capture_Date_GLBL__c  =Date.newInstance(2014,05,22),
						Priority_Rank_Nbr_GLBL__c               ='1,2',
						Rltnshp_Typ_Desc_Capture_Date_GLBL__c   =Date.newInstance(2014,05,22),
						Rltnshp_Typ_Desc_GLBL__c                ='Employee',
						Spclty_Desc_Cd_Capture_Date_GLBL__c     =Date.newInstance(2014,05,22),
						Spclty_Desc_Cd_GLBL__c                  ='Orthopedic Surgeon,Primary Care,Oncology,Cardiology'
    	);
		CST_App_Settings_CUST__c appSetting = [SELECT Id FROM CST_App_Settings_CUST__c WHERE Settings_Language_CUST__c='en' limit 1];
		pool.App_Settings_CUST__c = appSetting.Id;
	}

	@isTest static void test_refresh_works() {
		insert pool;
		ApexPages.StandardController stdController = new ApexPages.StandardController(pool);

		CUST_RefreshLOVsReviewController controller = new CUST_RefreshLOVsReviewController(stdController);
		System.assertEquals(pool.Id, controller.pool.Id);
		controller.fieldsToRefresh = 'Bnft_Dsgn_Cd_GLBL__c';
		controller.applySelectedLOVs();
		System.assert(ApexPages.getMessages().get(0).getSummary().startsWith('The following fields were updated successfully: Account_Bnft_Dsgn_Cd_CUST__c'));
	}

	@isTest static void test_bad_refresh_error_caught() {
		insert pool;
		ApexPages.StandardController stdController = new ApexPages.StandardController(pool);
		CUST_RefreshLOVsReviewController controller = new CUST_RefreshLOVsReviewController(stdController);
		controller.fieldsToRefresh = 'bad_field__c';
		controller.applySelectedLOVs();
		System.assert(ApexPages.getMessages().get(0).getSummary().startsWith('Unable to refresh fields on App Settings record.'));
	}

	@isTest static void test_no_fields_to_refresh_error_caught() {
		insert pool;
		ApexPages.StandardController stdController = new ApexPages.StandardController(pool);
		CUST_RefreshLOVsReviewController controller = new CUST_RefreshLOVsReviewController(stdController);
		controller.applySelectedLOVs();
		System.assertEquals('No fields selected for refresh.',ApexPages.getMessages().get(0).getSummary());
	}

	@isTest static void test_no_record_id_caught() {
		//pool does not get inserted here so no id available
		ApexPages.StandardController stdController = new ApexPages.StandardController(pool);
		CUST_RefreshLOVsReviewController controller = new CUST_RefreshLOVsReviewController(stdController);
		System.assertEquals('No App Settings record found.',ApexPages.getMessages().get(0).getSummary());
	}
}