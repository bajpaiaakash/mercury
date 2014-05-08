/**
 * @author Kyle Thornton
 *
 * Test class for MERC_TravelItineraryStampMtgHandler class
 */
@isTest
private class MERC_TravelItineraryStampMtgHandlerTest {

	static User testUser;
	static Meeting_MERC__C meeting                        = MERC_TestFactory.insertMeetings(1).get(0);
	static List<Account> accounts                         = MERC_TestFactory.insertAccounts(200);
	static List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
	static List<Travel_Itinerary_MERC__c> itineraries     = new List<Travel_Itinerary_MERC__c>();
	static {
		System.runas(new User(Id=UserInfo.getUserId()))
		{
			testUser = MERC_TestFactory.insertTestUsers(1, null).get(0);
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='Mercury_Customer_Meeting_Services_Edit' limit 1];
			insert new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=testUser.id);
			update new User(id=testUser.Id, UserRoleId=[SELECT Id FROM UserRole WHERE Name='Global' limit 1].id);
		}

		Account vendorAcct = new Account( Name         = 'Vendor'
			                            , RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND DeveloperName='Vendor_GLBL' limit 1].Id);
		insert vendorAcct;

		Meeting_Vendor_MERC__c vendor = new Meeting_Vendor_MERC__c(Meeting_MERC__c=meeting.id, Account_MERC__c=vendorAcct.Id);
		insert vendor;

		Id hotelRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Hotel_MERC' AND sObjectType='Travel_Itinerary_MERC__c' limit 1].Id;
		for (Meeting_Participant_MERC__c p : participants)
		{
			itineraries.add( new Travel_Itinerary_MERC__c( RecordTypeId                = hotelRecTypeId
														 , Meeting_Participant_MERC__c = p.id
														 , Travel_Detail_Typ_MERC__c   = 'Accomidation'
														 , Sgmnt_Bgin_TS_MERC__c       = DateTime.now().addDays(2)
														 , Sgmnt_End_TS_MERC__c        = DateTime.now().addDays(3)
														 , Meeting_Vendor_MERC__c      = vendor.Id
														 , Account_MERC__c             = accounts[0].Id
														 , Confirm_ToV_Reporting_Change_MERC__c = false)
			);
		}
		insert itineraries;
	}

	@isTest static void test_method_one() {
		System.runAs(testUser)
		{
			meeting = [SELECT Id, Participant_ToV_Updated_Date_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id limit 1];
			System.assertEquals(null, meeting.Participant_ToV_Updated_Date_MERC__c);
			for (Travel_Itinerary_MERC__c ti : itineraries)
			{
				ti.Confirm_ToV_Reporting_Change_MERC__c = true;
			}
			Test.startTest();
			update itineraries;
			Test.stopTest();
			System.assertNotEquals(null, [SELECT Participant_ToV_Updated_Date_MERC__c FROM Meeting_MERC__c WHERE Id = :meeting.Id].Participant_ToV_Updated_Date_MERC__c);
		}
	}
}