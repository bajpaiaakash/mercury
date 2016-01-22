/**
 * @author Joseph Ferraro
 *
 * Description: This is the unit test for the MERC_HotelAllocationCalculator class
 */
@isTest
private class MERC_HotelAllocationCalculatorTest {

    static List<Meeting_MERC__c> meetings;
    static List<Account> accounts;
    static List<Meeting_Day_MERC__c> meetingDays;
    static List<Meeting_Participant_MERC__c> participants;
    static List<Meeting_Vendor_MERC__c> hotels;
    static MERC_DailyAttendanceController controller;
    static List<Travel_Itinerary_MERC__c> hotelItineraries;
    static Meeting_MERC__c meeting;

    static {
        accounts = MERC_TestFactory.insertAccounts(20); //insert 100 accounts
        //accounts = [SELECT ID, FirstName, LastName, RecordTypeId, PersonEmail FROM Account WHERE RecordTypeId = :MERC_TestFactory.hcpRecordTypeId limit 100];
        meetings = MERC_TestFactory.insertMeetings(1); //insert 1 meetings
        meeting = meetings.get(0);
        meetingDays = MERC_TestFactory.insertMeetingDays(meeting.Id, 3); //insert 3 days
        hotels = MERC_TestFactory.insertHotelsForMeeting(2, meeting.Id);
        participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
        //hotelItineraries = MERC_TestFactory.insertHotelItineraries(participants, meetingDays.get(0).Date_MERC__c, meetingDays.get(2).Date_MERC__c);
    }

    @isTest static void testShouldProperlyCalculateHotelAllocations() {
        Test.startTest();
        Id hotelItineraryRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Merc_Hotel' AND SObjectType = 'Travel_Itinerary_MERC__c'].Id;

        Meeting_Vendor_MERC__c hotel1 = hotels.get(0);
        Meeting_Vendor_MERC__c hotel2 = hotels.get(1);

        Meeting_Day_MERC__c day1 = meetingDays.get(0);
        Meeting_Day_MERC__c day2 = meetingDays.get(1);
        Meeting_Day_MERC__c day3 = meetingDays.get(2);

        Hotel_Allocation_MERC__c hotel1Day1Allocation = new Hotel_Allocation_MERC__c();
        hotel1Day1Allocation.Meeting_Vendor_MERC__c = hotel1.Id;
        hotel1Day1Allocation.Meeting_Day_MERC__c = day1.Id;
        hotel1Day1Allocation.Total_Rooms_in_Block_MERC__c = 50;
        insert hotel1Day1Allocation;

        Hotel_Allocation_MERC__c hotel1Day2Allocation = new Hotel_Allocation_MERC__c();
        hotel1Day2Allocation.Meeting_Vendor_MERC__c = hotel1.Id;
        hotel1Day2Allocation.Meeting_Day_MERC__c = day2.Id;
        hotel1Day2Allocation.Total_Rooms_in_Block_MERC__c = 50;
        insert hotel1Day2Allocation;

        Hotel_Allocation_MERC__c hotel1Day3Allocation = new Hotel_Allocation_MERC__c();
        hotel1Day3Allocation.Meeting_Vendor_MERC__c = hotel1.Id;
        hotel1Day3Allocation.Meeting_Day_MERC__c = day3.Id;
        hotel1Day3Allocation.Total_Rooms_in_Block_MERC__c = 50;
        insert hotel1Day3Allocation;

        Travel_Itinerary_MERC__c t = new Travel_Itinerary_MERC__c();
        t.Meeting_Participant_MERC__c = participants.get(0).Id;
        t.Sgmnt_Bgin_TS_MERC__c = day1.Date_MERC__c; //check in day 1
        t.Sgmnt_End_TS_MERC__c = day3.Date_MERC__c; //check out day 3
        t.Account_MERC__c = participants.get(0).Account_MERC__c;
        t.RecordTypeId = hotelItineraryRecordTypeId;
        t.Meeting_Vendor_MERC__c = hotel1.Id;
        insert t;

        Test.stopTest();

        system.assertEquals(1, [SELECT Booked_Rooms__c FROM Hotel_Allocation_MERC__c WHERE Id = :hotel1Day1Allocation.Id].Booked_Rooms__c);
        system.assertEquals(1, [SELECT Booked_Rooms__c FROM Hotel_Allocation_MERC__c WHERE Id = :hotel1Day2Allocation.Id].Booked_Rooms__c);
        system.assertEquals(0, [SELECT Booked_Rooms__c FROM Hotel_Allocation_MERC__c WHERE Id = :hotel1Day3Allocation.Id].Booked_Rooms__c);
    }

}