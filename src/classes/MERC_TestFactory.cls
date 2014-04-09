public with sharing class MERC_TestFactory {
	
	public static Id hcpRecordTypeId = [Select ID From RecordType Where SObjectType = 'Account' and DeveloperName = 'HCP_GLBL'].ID;
	public static Id employeeRecordTypeId = [Select ID From RecordType Where SObjectType = 'Account' and DeveloperName = 'Employee_GLBL'].ID;
	public static Id vendorRecordTypeId = [Select ID From RecordType Where SObjectType = 'Account' and DeveloperName = 'Vendor_GLBL'].ID;

	public static void insertMercuryCustomSettings() {
		Mercury_Settings_MERC__c settings = Mercury_Settings_MERC__c.getOrgDefaults();
		settings.Budget_Edit_Validation_MERC__c = true;
		insert settings;
	}

	public static void loadTimeZoneFieldMapSettings() {
		List<sObject> timeZoneFieldMappings = Test.loadData(Time_Zone_Field_Mappings_MERC__c.sObjectType, 'TimeZoneMappingTestData_MERC');
	}

	public static void loadDeclarativeRollupSummaries() {
		List<sObject> rollups = Test.loadData(glbl_rollup__LookupRollupSummary__c.sObjectType, 'DeclarativeRollupTestData_MERC');
	}

	public static void loadFMVSettings() {
		//TODO when oliver updates fmv settings
		//List<sObject> rollups = Test.loadData(glbl_rollup__LookupRollupSummary__c.sObjectType, 'DeclarativeRollupTestData_MERC');
	}

	public static List<Account> insertAccounts(Integer numberOfAccounts, Id recordTypeId) {
		List<Account> accs = new List<Account>();
		for (Integer i = 0; i < numberOfAccounts; i++) {
			String randomString = MERC_Util.generateRandomString(8);
			Account a = new Account();
			a.FirstName = 'UnitTest';
			a.LastName = randomString;
			a.RecordTypeId = recordTypeId;
			a.PersonEmail = 'ut-'+randomString+'@gmail.com';
			accs.add(a);
		}
		insert accs;
		return accs;
	}

	public static List<Account> insertAccounts(Integer numberOfAccounts) {
		return insertAccounts(numberOfAccounts, hcpRecordTypeId);
	}

	public static List<Account> insertEmployeeAccounts(Integer numberOfAccounts) {
		List<Account> accs = new List<Account>();
		for (Integer i = 0; i < numberOfAccounts; i++) {
			Account a = new Account();
			a.FirstName = 'UnitTest';
			a.LastName = 'Smith'+numberOfAccounts;
			a.RecordTypeId = employeeRecordTypeId;
			a.PersonEmail = 'unittest'+i+'@gmail.com';
			accs.add(a);
		}
		insert accs;
		return accs;
	}

	public static List<Invoice_MERC__c> insertInvoices(List<Meeting_Participant_MERC__c> participants) {
		List<Invoice_MERC__c> invoices = new List<Invoice_MERC__c>();
		for (Meeting_Participant_MERC__c m : participants) {
			Invoice_MERC__c i = new Invoice_MERC__c();
			i.Invoice_Date_MERC__c = Date.today();
			i.Meeting_Participant_MERC__c = m.Id;
			i.Cost_Center_MERC__c = '1234567';
			invoices.add(i);
		}
		insert invoices;
		return invoices;
	}

	public static List<Invoice_Line_Item_MERC__c> insertInvoiceLineItems(String invoiceId, Integer numberOfLineItems) {
		List<Invoice_Line_Item_MERC__c> lineItems = new List<Invoice_Line_Item_MERC__c>();
		for (Integer i = 0; i < numberOfLineItems; i++) {
			Invoice_Line_Item_MERC__c lineItem = new Invoice_Line_Item_MERC__c();
			lineItem.Invoice_MERC__c = invoiceId;
			lineItems.add(lineItem);
		}
		insert lineItems;
		return lineItems;
	}

	public static List<Meeting_MERC__c> insertMeetings(Integer numberOfMeetings) {
		List<Meeting_MERC__c> mtgs = new List<Meeting_MERC__c>();
		for (Integer i = 0; i < numberOfMeetings; i++) {
			Meeting_MERC__c m = new Meeting_MERC__c();
			m.Date_of_Event_MERC__c = Date.today().addDays(2);
			m.End_Date_of_Event_MERC__c = Date.today().addDays(2);
			m.Name = 'Event Name'+i;
			m.Meeting_Time_Zone_MERC__c = 'Greenwich Mean Time (Europe/London)';
			mtgs.add(m);
		}
		insert mtgs;
		return mtgs;
	}

	public static Daily_Attendance_TOV_MERC__c insertTov(String meetingDayId, String meetingParticipantId) {
		return insertTov(meetingDayId, meetingParticipantId, null);
	}

	public static Daily_Attendance_TOV_MERC__c insertTov(String meetingDayId, String meetingParticipantId, String status) {
		Daily_Attendance_TOV_MERC__c tov = new Daily_Attendance_TOV_MERC__c();
		tov.Meeting_Day_MERC__c = meetingDayId;
		tov.Meeting_Participant_MERC__c = meetingParticipantId;
		if (status != null)
			tov.Status_MERC__c = status;
		insert tov;
		return tov;
	}

	public static List<Travel_Itinerary_MERC__c> insertHotelItineraries(List<Meeting_Participant_MERC__c> participants, Date startDate, Date endDate) {
		List<Travel_Itinerary_MERC__c> hotelItineraries = new List<Travel_Itinerary_MERC__c>();
		for (Meeting_Participant_MERC__c mp : participants) {
			Travel_Itinerary_MERC__c ti = new Travel_Itinerary_MERC__c();
			ti.Meeting_Participant_MERC__c = mp.Id;
			ti.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(startDate, Time.newInstance(12, 0, 0, 0));
			ti.Sgmnt_End_TS_MERC__c = Datetime.newInstance(endDate, Time.newInstance(15, 0, 0, 0));
			hotelItineraries.add(ti);
		}
		insert hotelItineraries;
		return hotelItineraries;
	}

	public static List<Meeting_Vendor_MERC__c> insertHotelsForMeeting(Integer numberOfHotels, String meetingId) {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < numberOfHotels; i++) {
			Account a = new Account();
			a.RecordTypeId = vendorRecordTypeId;
			a.Name = MERC_Util.generateRandomString(5);
			accounts.add(a);
		}
		insert accounts;

		List<Meeting_Vendor_MERC__c> hotels = new List<Meeting_Vendor_MERC__c>();
		for (Integer i = 0; i < accounts.size(); i++) {
			Meeting_Vendor_MERC__c v = new Meeting_Vendor_MERC__c();
			v.Account_MERC__c = accounts.get(i).Id;
			v.Room_Rate_MERC__c = (i+1)*50;
			v.Meeting_MERC__c = meetingId;
			hotels.add(v);
		}
		insert hotels;
		return hotels;
	}

	public static List<Meeting_Day_MERC__c> insertMeetingDays(String meetingId, Integer numberOfDays) {
		List<Meeting_Day_MERC__c> mtgDays = new List<Meeting_Day_MERC__c>();
		for (Integer i = 0; i < numberOfDays; i++) {
			Meeting_Day_MERC__c m = new Meeting_Day_MERC__c();
			m.Date_MERC__c = Date.today().addDays(i);
			m.Meeting_MERC__c = meetingId;
			m.Daily_Food_Beverage_Amount_MERC__c = 100;
			m.Daily_Ground_Trans_Amount_MERC__c = 100;
			m.Daily_Registration_Amount_MERC__c = 100;
			mtgDays.add(m);
		}
		insert mtgDays;
		return mtgDays;
	}

	public static List<Meeting_Participant_MERC__c> insertParticipants(String meetingId, List<Account> accounts) {
		return insertParticipants(meetingId, accounts, null);
	}

	public static List<Meeting_Participant_MERC__c> insertParticipants(String meetingId, List<Account> accounts, String status) {
		String pStatus = status == null ? 'Invited' : status;
		List<Meeting_Participant_MERC__c> participants = new List<Meeting_Participant_MERC__c>();
		for (Integer i = 0; i < accounts.size(); i++) {
			Meeting_Participant_MERC__c p = new Meeting_Participant_MERC__c();
			p.Account_MERC__c = accounts.get(i).Id;
			p.Meeting_MERC__c = meetingId;
			p.Status_MERC__c = pStatus;
			participants.add(p);
		}

		insert participants;
		return participants;
	}

	public static List<Meeting_Participant_MERC__c> insertBulkParticipants(List<Meeting_MERC__c> meets, List<Account> accts) {
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

	public static Budget_MERC__c insertBudget(String meetingId) {
		Budget_MERC__c b = new Budget_MERC__c();
		b.Meeting_MERC__c = meetingId;
		b.Status_MERC__c = 'Draft';
		b.Cost_Center_MERC__c = '1234567';
        b.RecordTypeId = [Select ID From RecordType Where SobjectType = 'Budget_MERC__c' AND DeveloperName = 'MERC_Budget_Draft'].ID;
        insert b;
        return b;
	}

	public static List<Budget_Line_Item_MERC__c> insertBudgetLineItems(String budgetId, Integer numberOfLineItems) {
		List<Budget_Line_Item_MERC__c> lineItems = new List<Budget_Line_Item_MERC__c>();
		for (Integer i = 0; i < numberOfLineItems; i++) {
			Budget_Line_Item_MERC__c lineItem = new Budget_Line_Item_MERC__c();
			lineItem.Amount_MERC__c = i+100;
			lineItem.Type_MERC__c = 'some type';
			lineItem.Budget_MERC__c = budgetId;
			lineItems.add(lineItem);
		}
		insert lineItems;
		return lineItems;
	}

	public static HCP_Contract_MERC__c insertHCPContract(String accountId) {
		HCP_Contract_MERC__c c = new HCP_Contract_MERC__c();
		c.Account_MERC__c = accountId;
		c.Country_MERC__c = 'UK';
		insert c;
		return c;
	}

	public static List<User> insertTestUsers(Integer numberOfUsers, String profileName) {
		List<User> users = new List<User>();

		if (profileName == null) {
			profileName = 'Mercury Customer Meeting Services - Read Only';
		}

        Profile p = [SELECT id from Profile WHERE Profile.Name =  :profileName limit 1];   
        
        for (Integer i = 0; i < numberOfUsers; i++) {
	        String testemail = 'testuser'+i+'@unittest.com';
	        User u = new User(profileId = p.id, username = testemail, email = testemail, 
	                           emailencodingkey = 'UTF-8', localesidkey = 'en_US', 
	                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
	                           alias='utuser'+i, lastname='lastname');
	        users.add(u);
	    }
        
        Database.insert(users);
        return users;
	}
}