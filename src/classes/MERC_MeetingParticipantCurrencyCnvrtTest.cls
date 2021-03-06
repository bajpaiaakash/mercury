@isTest
public with sharing class MERC_MeetingParticipantCurrencyCnvrtTest
{

	static Meeting_MERC__c meeting;
	static List<Account> accounts;
	static List<Meeting_Participant_MERC__c> participants;
	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();

	static {
		System.runAs(new User(Id=UserInfo.getUserId()))
		{
			Test.loadData(CurrencyType.sObjectType, 'CurrencyTypes');
		}

		System.runAs(runningUser)
		{
			meeting = MERC_TestFactory.insertMeetings(1, 'GB').get(0);
			accounts = MERC_TestFactory.insertAccounts(200);
			participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);

			meeting.CurrencyIsoCode = 'GBP';
			update meeting;

			for (Meeting_Participant_MERC__c mp : participants)
			{
				mp.CurrencyIsoCode = 'EUR';
			}
			update participants;
		}
	}


	@isTest static void test_should_update_values_correctly()
	{
		System.runAs(testUser)
		{
			for (Meeting_Participant_MERC__c participant : participants)
			{
				participant.Total_Food_Beverage_ToV_Rollup_MERC__c    = 100.0;
				participant.Total_Ground_Transport_ToV_Rollup_MERC__c = 200.0;
				participant.Total_Hotel_ToV_Rollup_MERC__c            = 300.0;
				participant.Total_Registration_ToV_Rollup_MERC__c     = 400.0;
			}
			update participants;
		}

		Boolean perfomedCheck = false;
		for (Meeting_Participant_MERC__c mp : [SELECT Total_Food_Beverage_ToV_MERC__c
			                                        , Total_Ground_Transporation_ToV_MERC__c
			                                        , Total_Hotel_ToV_MERC__c
			                                        , Total_Registration_ToV_MERC__c
			                                     FROM Meeting_Participant_MERC__c
			                                    WHERE Id IN :participants])
		{
			perfomedCheck = true;
			//GBP is 0.822981 to 1 Euro
			System.assertEquals(82.2981,  mp.Total_Food_Beverage_ToV_MERC__c);
			System.assertEquals(164.5962, mp.Total_Ground_Transporation_ToV_MERC__c);
			System.assertEquals(246.8943, mp.Total_Hotel_ToV_MERC__c);
			System.assertEquals(329.1924, mp.Total_Registration_ToV_MERC__c);
		}
		System.assert(perfomedCheck, 'Check not performed on any Meeting Participants');
	}

	@isTest static void test_should_not_update_values_for_individual_sponsorship()
	{
		System.runAs(testUser)
		{
			Id IndvSponsRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Meeting_Participant_MERC__c' AND DeveloperName='Individual_Sponsorship' limit 1].Id;

			for (Meeting_Participant_MERC__c participant : participants)
			{
				participant.Total_Food_Beverage_ToV_Rollup_MERC__c    = null;
				participant.Total_Ground_Transport_ToV_Rollup_MERC__c = null;
				participant.Total_Hotel_ToV_Rollup_MERC__c            = null;
				participant.Total_Registration_ToV_Rollup_MERC__c     = null;
				participant.Total_Food_Beverage_ToV_MERC__c           = 100.0;
				participant.Total_Ground_Transporation_ToV_MERC__c    = 200.0;
				participant.Total_Hotel_ToV_MERC__c                   = 300.0;
				participant.Total_Registration_ToV_MERC__c            = 400.0;
				participant.RecordTypeId 	                          = IndvSponsRecTypeId;
			}
			update participants;
		}

		Boolean perfomedCheck = false;
		for (Meeting_Participant_MERC__c mp : [SELECT Total_Food_Beverage_ToV_MERC__c
			                                        , Total_Ground_Transporation_ToV_MERC__c
			                                        , Total_Hotel_ToV_MERC__c
			                                        , Total_Registration_ToV_MERC__c
			                                     FROM Meeting_Participant_MERC__c
			                                    WHERE Id IN :participants])
		{
			perfomedCheck = true;
			//GBP is 0.822981 to 1 Euro
			System.assertEquals(100.0,  mp.Total_Food_Beverage_ToV_MERC__c);
			System.assertEquals(200.0, mp.Total_Ground_Transporation_ToV_MERC__c);
			System.assertEquals(300.0, mp.Total_Hotel_ToV_MERC__c);
			System.assertEquals(400.0, mp.Total_Registration_ToV_MERC__c);
		}
		System.assert(perfomedCheck, 'Check not performed on any Meeting Participants');
	}
}