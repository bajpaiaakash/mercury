/**
 * @author : Kyle Thornton
 *
 * Test class for MERC_MeetingContentStampHandler
 */
@isTest
private class MERC_MeetingContentStampHandlerTest {

	static Id workspaceId;
	static String versionData      = 'foo';
	static Blob versionDataBlob    = Blob.valueOf(versionData);
	static Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
	static Id meetingRecTypeId     = [Select Id From RecordType WHERE DeveloperName = 'Meeting_MERC' AND SobjectType = 'ContentVersion' LIMIT 1].Id;
	static List<Product_Group_GLBL__c> products;
	static
	{
		workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Mercury' Limit 1].Id; //we can't create this in a test
		system.assertNotEquals(workspaceId, null, 'The workspace \'Mercury\' does not exist or is not availble to the running user.');

		products = new List<Product_Group_GLBL__c>();
		for (Integer i=0; i<3; i++)
		{
			products.add(new Product_Group_GLBL__c( Name                 = 'Test Product ' + i
				                                  , Cntry_Cd_GLBL__c     = 'ZZ'
				                                  , Crt_Dt_GLBL__c       = Date.today()
				                                  , Dialect_Nm_GLBL__c   = 'English'
				                                  , Grp_Prps_Cd_GLBL__c  = 'MKTP'
				                                  , Lst_Pblsh_Dt_GLBL__c = Date.today()
				                                  , Updt_Dt_GLBL__c      = Date.today())
			);
		}
		insert products;

		List<Meeting_Products_MERC__c> meetingProducts = new List<Meeting_Products_MERC__c>();
		for (Product_Group_GLBL__c pg : products)
		{
			meetingProducts.add(new Meeting_Products_MERC__c(Meeting_MERC__c=meeting.Id, Product_MERC__c=pg.Id));
		}
		insert meetingProducts;
	}

	@isTest static void test_product_fields_are_populated() {

		List<ContentVersion> cvList = new List<ContentVersion>();
		Id libraryId =  [select Id from ContentWorkspace WHERE Name = 'Mercury'].Id;
		for (Integer i=0; i<200; i++)
		{
			ContentVersion cv         = new ContentVersion();
			cv.Title                  = 'foo';
			cv.PathOnClient           = 'foo';
			cv.FirstPublishLocationId = libraryId;
			cv.VersionData            = versionDataBlob;
			cv.RecordTypeID           = meetingRecTypeId;
			cv.Meeting_MERC__c        = meeting.Id;
			cvList.add(cv);
		}
		Test.startTest();
		insert cvList;
		Test.stopTest();

		cvList = [SELECT Id, Product_1_MERC__c, Product_2_MERC__c, Product_3_MERC__c FROM ContentVersion WHERE Id IN :cvList];
		System.assertEquals(200, cvList.size());
		for (ContentVersion cv : cvList)
		{
			System.assert(cv.Product_1_MERC__c != null);
			System.assert(cv.Product_2_MERC__c != null);
			System.assert(cv.Product_3_MERC__c != null);
		}
	}
}