/** 
* @author Sean Harrison 
* 
* This class is to be run anonymously during PFT for manual testing of the Invoice/SAP integration flow
*/
public with sharing class MERC_CreateBulkSAPData {

	static final Integer TEST_SET_SIZE = 1;
	static List<Account> accounts;
	static List<Meeting_MERC__c> meetings;
	static List<Meeting_Participant_MERC__c> participants;
	static List<Invoice_MERC__c> invoices;
	static List<Invoice_Line_Item_MERC__c> lineItems;
	static Integer numOfLineItems;

	static Id hcpRecordTypeId = [Select ID From RecordType Where SObjectType = 'Account' and DeveloperName = 'HCP_GLBL'].ID;

	public static void insertTestData() {
		accounts = insertAccounts(1, hcpRecordTypeId);
		meetings = insertMeetings(1);
		participants = insertBulkParticipants(meetings, accounts);
		invoices = insertInvoices(participants);

		numOfLineItems = 2;
		for (Meeting_Participant_MERC__c p : participants) {
			p.Services_Rendered_MERC__c = 'Yes';
		}
		update participants;
		lineItems = insertBulkInvoiceLineItems(invoices,numOfLineItems);
	}

	public static void deleteTestData() {
		delete meetings;
		delete accounts;
	}


	static List<Account> insertAccounts(Integer numberOfAccounts, Id recordTypeId) {
		List<Account> accs = new List<Account>();
		for (Integer i = 0; i < numberOfAccounts; i++) {
			String randomString = MERC_Util.generateRandomString(8);
			Account a = new Account();
			a.FirstName = 'SAPLoadTest';
			a.LastName = randomString;
			a.RecordTypeId = recordTypeId;
			a.PersonEmail = 'ut-'+randomString+'@gmail.com';
			accs.add(a);
		}
		insert accs;
		return accs;
	}
	static List<Meeting_MERC__c> insertMeetings(Integer numberOfMeetings) {
		String countryName = 'GB';
		List<Meeting_MERC__c> mtgs = new List<Meeting_MERC__c>();
		for (Integer i = 0; i < numberOfMeetings; i++) {
			Meeting_MERC__c m = new Meeting_MERC__c();
			m.Date_of_Event_MERC__c = Date.today().addDays(2);
			m.End_Date_of_Event_MERC__c = Date.today().addDays(2);
			m.Start_Time_of_Meeting_MERC__c = DateTime.newInstance(Date.today().addDays(2), Time.newInstance(10, 0, 0, 0));
			m.End_Time_of_Meeting_MERC__c = DateTime.newInstance(Date.today().addDays(2), Time.newInstance(14, 0, 0, 0));
			m.Name = 'SAPLoadTest'+i;
			m.Meeting_Time_Zone_MERC__c = 'Greenwich Mean Time (Europe/London)';
			m.Event_Country_MERC__c = countryName;
			mtgs.add(m);
		}
		insert mtgs;
		return mtgs;
	}
	static List<Meeting_Participant_MERC__c> insertBulkParticipants(List<Meeting_MERC__c> meets, List<Account> accts) {
		List<Meeting_Participant_MERC__c> pList = new List<Meeting_Participant_MERC__c>();
		for (Meeting_MERC__c meeting : meets) {
			for (Account a : accts) {
				Meeting_Participant_MERC__c p = new Meeting_Participant_MERC__c();
				p.Account_MERC__c = a.Id;
				p.Meeting_MERC__c = meeting.Id;
				p.Status_MERC__c = 'Invited';
				pList.add(p);
			}
		}

		insert pList;
		return pList;
	}
	static List<Invoice_MERC__c> insertInvoices(List<Meeting_Participant_MERC__c> mps) {
		List<Invoice_MERC__c> invs = new List<Invoice_MERC__c>();
		for (Meeting_Participant_MERC__c m : mps) {
			Invoice_MERC__c i = new Invoice_MERC__c();
			i.Invoice_Date_MERC__c = Date.today();
			i.Meeting_Participant_MERC__c = m.Id;
			i.Cost_Center_MERC__c = '1234567';
			invs.add(i);
		}
		insert invs;
		return invs;
	}
	static List<Invoice_Line_Item_MERC__c> insertBulkInvoiceLineItems(List<Invoice_MERC__c> invs, Integer numberOfLineItems) {
		List<Invoice_Line_Item_MERC__c> lis = new List<Invoice_Line_Item_MERC__c>();
		for (Invoice_MERC__c inv : invs) {
			for (Integer i = 0; i < numberOfLineItems; i++) {
				Invoice_Line_Item_MERC__c lineItem = new Invoice_Line_Item_MERC__c();
				lineItem.Invoice_MERC__c = inv.Id;
				lis.add(lineItem);
			}
		}
		insert lis;
		return lis;
	}

}