@isTest
private class MERC_MeetingProductNewEditTest {
	
	@isTest static void test_should_run_without_error() {

		Product_Group_GLBL__c product = new Product_Group_GLBL__c();
		product.Cntry_Cd_GLBL__c = 'ZZ';
		product.Crt_Dt_GLBL__c = Date.today();
		product.Dialect_Nm_GLBL__c = 'Enlgish';
		product.Grp_Prps_Cd_GLBL__c = 'MKTP';
		product.Lst_Pblsh_Dt_GLBL__c = Date.today();
		product.Updt_Dt_GLBL__c = Date.today();
		insert product;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(product);
        
        //no assertion needed just need to make sure this runs successfully
        MERC_MeetingProductNewEdit meetingPrductNewEdit = new MERC_MeetingProductNewEdit(sc);
	}
}