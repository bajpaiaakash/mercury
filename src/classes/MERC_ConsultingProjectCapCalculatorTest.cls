/**
 * @author Joseph Ferraro
 *
 * Asserts functionality for Trigger handler (MERC_ConsultingProjectCapCalculator) that calculates Consulting_Project_Paid_CAP_MERC__c on Account
 */

@isTest
private class MERC_ConsultingProjectCapCalculatorTest {

	static List<Meeting_MERC__c> meetings;
	static List<Account> accounts;
	static List<Meeting_Day_MERC__c> meetingDays;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Meeting_Participant_MERC__c> participants2;

	static {
		accounts = MERC_TestFactory.insertAccounts(5); //insert 5 accounts
		meetings = MERC_TestFactory.insertMeetings(2); //insert 2 meetings
		meetingDays = MERC_TestFactory.insertMeetingDays(meetings.get(0).Id, 3); //insert 3 days
		participants = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts); //insert 5 participants
		participants2 = MERC_TestFactory.insertParticipants(meetings.get(1).Id, accounts); //insert 5 participants
		MERC_TestFactory.loadDeclarativeRollupSummaries();
	}

	@isTest static void basic_test() {
		Test.startTest();

		Meeting_Participant_MERC__c p1 = participants.get(0);
		p1.Services_Rendered_MERC__c = 'Yes';
		update p1;

		Payee_MERC__c p = new Payee_MERC__c();
		p.Account_MERC__c = p1.Account_MERC__c;
		p.Name = 'foo';
		insert p;

		Invoice_MERC__c i = new Invoice_MERC__c();
		i.Invoice_Date_MERC__c = Date.today();
		i.Meeting_Participant_MERC__c = p1.Id;
		i.Cost_Center_MERC__c = '1234567';
		insert i;

		Invoice_Line_Item_MERC__c lineItem = new Invoice_Line_Item_MERC__c();
		lineItem.Consulting_Amount_MERC__c = 20;
		lineItem.Invoice_MERC__c = i.Id;
		lineItem.RecordTypeId = [SELECT ID FROM RecordType WHERE SobjectType = 'Invoice_Line_Item_MERC__c' AND DeveloperName = 'Consulting_Project_MERC'].Id;
		insert lineItem;

		i.Submit_for_Payment_MERC__c = 'Yes';
		i.Invoice_Attached_MERC__c = true; //simulate pdf being attached.
		update i;

		System.assertEquals(20, [SELECT Consulting_Project_Amount_excl_VAT_MERC__c FROM Invoice_MERC__c WHERE Id = :i.Id].Consulting_Project_Amount_excl_VAT_MERC__c);

		i.Invoice_Date_MERC__c = Date.today();
		update i;

		System.assertEquals(20, [SELECT Consulting_Project_Paid_CAP_MERC__c FROM Account WHERE Id = :p1.Account_MERC__c].Consulting_Project_Paid_CAP_MERC__c);

		Test.stopTest();
	}

}