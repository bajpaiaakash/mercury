/**
 * @author Kyle Thornton
 *
 * This is the unit test for the MERC_MeetingCurrencyUpdateHandlerTest.
 */

@isTest
private class MERC_MeetingCurrencyUpdateHandlerTest {

	static User testUser = MERC_TestFactory.getRunningUser();
	static List<Account> accounts;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Daily_Attendance_TOV_MERC__c> tovs;
	static List<Meeting_Vendor_MERC__c> hotels;
	static List<Hotel_Allocation_MERC__c> hotelAllocations;
	static String userCurrency = [SELECT CurrencyIsoCode FROM User WHERE Id=:UserInfo.getUserId()].CurrencyIsoCode;

	static
	{
		System.runAs(testUser)
		{
			MERC_TriggerHandlerStateManager.deactivateAll();
			accounts        = MERC_TestFactory.insertAccounts(5);
			meetings        = MERC_TestFactory.insertMeetings(10);
			participants    = MERC_TestFactory.insertBulkParticipants(meetings, accounts);
			meetingDays     = MERC_TestFactory.insertBulkMeetingDays(meetings, 2);
			tovs            = MERC_TestFactory.insertBulkTovs(meetingDays, participants);
			hotels          = MERC_TestFactory.insertHotelsForMeetings(1, meetings);
			hotelAllocations= new List<Hotel_Allocation_MERC__c>();
			for (Meeting_Vendor_MERC__c hotel : hotels) {
				for (Meeting_Day_MERC__c meetingDay : meetingDays) {
					if (meetingDay.Meeting_MERC__c == hotel.Meeting_MERC__c) {
						hotelAllocations.add(new Hotel_Allocation_MERC__c(Meeting_Day_MERC__c=meetingDay.Id, Meeting_Vendor_MERC__c=hotel.Id));
					}
				}
			}
			insert hotelAllocations;
			MERC_TriggerHandlerStateManager.activateAll();
		}
	}

	@isTest static void test_method_one() {
		System.runAs(testUser) {
			System.assertEquals(10, [SELECT COUNT() FROM Meeting_MERC__c WHERE CurrencyIsoCode=:userCurrency]);
			System.assertEquals(50, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE CurrencyIsoCode=:userCurrency]);

			Test.startTest();
			for (Meeting_MERC__c meeting : meetings) {
				meeting.put('CurrencyIsoCode', 'DKK');
			}
			update meetings;
			Test.stopTest();

			System.assertEquals(10, [SELECT COUNT() FROM Meeting_MERC__c WHERE CurrencyIsoCode='DKK']);
			//participant shouldn't change
			System.assertEquals(50, [SELECT COUNT() FROM Meeting_Participant_MERC__c WHERE CurrencyIsoCode=:userCurrency]);
			System.assertEquals(20, [SELECT COUNT() FROM Meeting_Day_MERC__c WHERE CurrencyIsoCode='DKK']);
			System.assertEquals(100, [SELECT COUNT() FROM Daily_Attendance_TOV_MERC__c WHERE CurrencyIsoCode='DKK']);
			System.assertEquals(10, [SELECT COUNT() FROM Meeting_Vendor_MERC__c WHERE CurrencyIsoCode='DKK']);
			System.assertEquals(20, [SELECT COUNT() FROM Hotel_Allocation_MERC__c WHERE CurrencyIsoCode='DKK']);
		}
	}
}