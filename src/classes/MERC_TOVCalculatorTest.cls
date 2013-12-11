@isTest
private class MERC_TOVCalculatorTest {
	
	static List<Account> accounts;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;

	static {
		accounts = MERC_TestFactory.insertAccounts(5);
		meetings = MERC_TestFactory.insertMeetings(1);
		meetingDays = MERC_TestFactory.insertMeetingDays(meetings.get(0).Id, 3);
		participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts);
	}

	//@isTest static void testShouldRollTovUpToParticipants() {
	//	Test.startTest();

	//	//set participant 1 to attending on day 1
	//	Daily_Attendance_TOV_MERC__c tovForParticipant1Day1 = MERC_TestFactory.insertTov(meetingDays.get(0).Id, participants.get(0).Id);

	//	Meeting_Day_MERC__c day1 = [SELECT Id, 
	//									Daily_Ground_Trans_Amount_MERC__c, 
	//									Daily_Registration_Amount_MERC__c, 
	//									Daily_Food_Beverage_Amount_MERC__c, 
	//									Daily_Other_Amount_MERC__c
	//										FROM Meeting_Day_MERC__c WHERE Id = :meetingDays.get(0).Id];

	//	Meeting_Participant_MERC__c participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c, Total_Other_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

	//	tovForParticipant1Day1 = [SELECT Id, Est_Grnd_Transp_MERC__c, Est_Reg_Amt_ToV_MERC__c, Est_Food_Bev_ToV_MERC__c, Est_Other_ToV_MERC__c, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day1.Id];

	//	//assert that meeting day 1's food bev estimate rolled up up to the participant total
	//	System.assert(tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c == participant1.Total_Food_Beverage_ToV_MERC__c);

	//	//set participant 1 to attending on day 2
	//	Daily_Attendance_TOV_MERC__c tovForParticipant1Day2 = MERC_TestFactory.insertTov(meetingDays.get(1).Id, participants.get(0).Id);
		
	//	participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c, Total_Other_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];
		
	//	tovForParticipant1Day2 = [SELECT Id, Est_Grnd_Transp_MERC__c, Est_Reg_Amt_ToV_MERC__c, Est_Food_Bev_ToV_MERC__c, Est_Other_ToV_MERC__c, Est_Hotel_ToV_MERC__c FROM Daily_Attendance_TOV_MERC__c WHERE Id = :tovForParticipant1Day2.Id];

	//	//assert that meeting day 1 and meeting day 2 food bev estimate rolled up up to the participant total
	//	System.assert((tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c + tovForParticipant1Day2.Est_Food_Bev_ToV_MERC__c) == participant1.Total_Food_Beverage_ToV_MERC__c);

	//	//now remove attendance on day 2
	//	delete tovForParticipant1Day2;

	//	participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c, Total_Other_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

	//	//now ensure the rollup re-calculated
	//	System.assert(tovForParticipant1Day1.Est_Food_Bev_ToV_MERC__c == participant1.Total_Food_Beverage_ToV_MERC__c);

	//	//now remove attendance on day 1
	//	delete tovForParticipant1Day1;

	//	participant1 = [SELECT Id, Total_Hotel_ToV_MERC__c, Total_Hours_of_Service_MERC__c, Total_Ground_Transporation_ToV_MERC__c, Total_Registration_ToV_MERC__c, Total_Food_Beverage_ToV_MERC__c, Total_Other_ToV_MERC__c FROM Meeting_Participant_MERC__c WHERE Id = :participants.get(0).Id];

	//	//now ensure the rollup re-calculated
	//	System.assertEquals(0, participant1.Total_Food_Beverage_ToV_MERC__c);

	//	Test.stopTest();
	//}
}