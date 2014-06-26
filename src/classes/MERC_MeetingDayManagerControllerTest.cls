/**
 *
 * @author Kyle Thornton
 *
 * Unit tests for MERC_MeetingDayManagerController
 */
@isTest
private class MERC_MeetingDayManagerControllerTest {

	static User testUser = MERC_TestFactory.getRunningUser();
	static Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
	static Meeting_Vendor_MERC__c hotel = MERC_TestFactory.insertHotelsForMeetings(1, new List<Meeting_MERC__c>{meeting}).get(0);

	@isTest static void test_method_one() {
		PageReference pRef = Page.MERC_MeetingDayManager;
		pRef.getParameters().put('id', meeting.id);
		Test.setCurrentPage(pRef);

		System.runAs(testUser) {
			ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(new List<Meeting_Day_MERC__c>());
			MERC_MeetingDayManagerController controller = new MERC_MeetingDayManagerController(stdController);

			PageReference ref = controller.add();
			System.assertEquals(null, ref);
			System.assertEquals(1, controller.children.size());

			controller.add();
			System.assertEquals(2, controller.children.size());

			Account vendor = new Account(RecordTypeId=MERC_TestFactory.vendorRecordTypeId, Name='vendor', Primary_Address_Country_GLBL__c='GB');
			insert vendor;

			controller.addHotel();
			controller.hotels.get(0).so.put('Account_MERC__c', vendor.id);
			controller.saveHotels();
			System.assertEquals(2, controller.hotels.size());

			System.assertEquals('vendor', MERC_MeetingDayManagerController.getVendors('vend', 'GB').get(0).Name);

			controller.clientHash = controller.children.get(0).hash;
			ref = controller.remove();
			System.assertEquals(null, ref);
			System.assertEquals(1, controller.children.size());

			controller.save();
			System.assertEquals(1, [SELECT COUNT() FROM Meeting_Day_MERC__c]);

			System.assert(!controller.getMeetingDayFields().isEmpty());

			controller.clientHash = controller.hotels.get(1).hash;
			controller.removeHotel();
			controller.saveHotels();
			System.assertEquals(1,controller.hotels.size());
		}
	}
}