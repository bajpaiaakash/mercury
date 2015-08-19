@isTest
public with sharing class MERC_TestFactory {

    public static Id employeeRecordTypeId =     [Select ID FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Employee_GLBL' LIMIT 1].Id;
    public static Id hcpRecordTypeId =          [Select ID FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'HCP_GLBL' LIMIT 1].Id;
    public static Id vendorRecordTypeId =       [Select ID FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Vendor_GLBL' LIMIT 1].Id;

    public static Id masteredAddressRecordTypeId =  [SELECT ID FROM RecordType WHERE SObjectType = 'Address_GLBL__c' AND DeveloperName = 'Mastered_Address' LIMIT 1].Id;
    public static Id otherAddressRecordTypeId =     [SELECT ID FROM RecordType WHERE SObjectType = 'Address_GLBL__c' AND DeveloperName = 'Other_Address' LIMIT 1].Id;

    public static Id hotelItineraryRecordTypeId =   [SELECT ID FROM RecordType WHERE SObjectType = 'Travel_Itinerary_MERC__c' AND DeveloperName = 'Hotel_MERC' LIMIT 1].Id;

    public static Boolean adjustForSFDCSetMockBug {get{if (adjustForSFDCSetMockBug==null) return false; else return adjustForSFDCSetMockBug;}
                           set{adjustForSFDCSetMockBug = value&&Test.isRunningTest();}}

    public static void insertMercuryCustomSettings() {
        Mercury_Settings_MERC__c settings = Mercury_Settings_MERC__c.getOrgDefaults();
        settings.Budget_Edit_Validation_MERC__c = true;
        insert settings;

        List<Content_Library_Lookup_MERC__c> contentLookupSettings = Test.loadData(Content_Library_Lookup_MERC__c.sObjectType, 'ContentLibraryLookup_MERC');
        List<Account_Merge_Related_Lists_MERC__c> mergeSettings = Test.loadData(Account_Merge_Related_Lists_MERC__c.sObjectType, 'AccountMergeSettings_MERC');
        List<CST_App_Settings_CUST__c> cstSettings = Test.loadData(CST_App_Settings_CUST__c.sObjectType, 'CST_Test_Settings');
    }

    public static void loadTimeZoneFieldMapSettings() {
        List<sObject> timeZoneFieldMappings = Test.loadData(Time_Zone_Field_Mappings_MERC__c.sObjectType, 'TimeZoneMappingTestData_MERC');
    }

    public static List<sObject> loadTravelProposalSegmentTypeSettings() {
        return Test.loadData(Travel_Proposal_Segment_Type_MERC__c.sObjectType, 'TravelProposalSegementTypes_MERC');
    }

    public static void loadCAPSettings() {
        List<sObject> capSettings = Test.loadData(CAP_Settings_MERC__c.sObjectType, 'CAP_MERC');
    }

    public static void loadFMVSettings() {
        List<sObject> fmvSettings = Test.loadData(FMV_Settings_MERC__c.sObjectType, 'FMV_MERC');
    }

    public static List<Account> insertBusinessAccounts(Integer numberOfAccounts, Id recordTypeId) {
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            String randomString = MERC_Util.generateRandomString(8);
            Account a = new Account();
            a.Name = 'unittest'+randomString;
            a.RecordTypeId = recordTypeId;
            accs.add(a);
        }
        insert accs;
        return accs;
    }

    public static List<Opportunity> insertOpportunities(Integer numberOfOpportunities, Id accountId) {
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < numberOfOpportunities; i++) {
            String randomString = MERC_Util.generateRandomString(8);
            Opportunity o = new Opportunity();
            o.Name = 'unittest'+randomString;
            o.StageName = 'Reviewing';
            o.AccountId = accountId;
            o.CloseDate = Date.today().addDays(5);
            o.Amount = 5000;
            opps.add(o);
        }
        insert opps;
        return opps;
    }

    public static List<Account> insertAccounts(Integer numberOfAccounts) {
        return insertAccounts(numberOfAccounts, hcpRecordTypeId);
    }
    public static List<Account> insertAccounts(Integer numberOfAccounts, Id recordTypeId) {
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            String randomString = MERC_Util.generateRandomString(8);
            Account a = new Account();
            a.FirstName = 'unittest';
            a.LastName = randomString;
            a.RecordTypeId = recordTypeId;
            a.PersonEmail = 'ut-'+randomString+'@unittest.com';
            accs.add(a);
        }
        insert accs;
        return accs;
    }

    public static List<Account> insertMasterAccountsInCountry(Integer numberOfAccounts, String country) {
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            String randomString = MERC_Util.generateRandomString(8);
            Account a = new Account();
            a.FirstName = 'unittest';
            a.LastName = randomString;
            a.RecordTypeId = hcpRecordTypeId;
            a.PersonEmail = 'ut-'+randomString+'@unittest.com';
            a.Cust_Id_GLBL__c = randomString;
            a.Country_of_Residence_GLBL__c = country;
            accs.add(a);
        }
        insert accs;
        return accs;
    }

    public static List<Account> insertHcpAccountsInCountry(Integer numberOfAccounts, String country) {
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            String randomString = MERC_Util.generateRandomString(8);
            Account a = new Account();
            a.FirstName = 'unittest';
            a.LastName = randomString;
            a.RecordTypeId = hcpRecordTypeId;
            a.PersonEmail = 'ut-'+randomString+'@unittest.com';
            a.Country_of_Residence_GLBL__c = country;
            accs.add(a);
        }
        insert accs;
        return accs;
    }

    public static List<Account> insertEmployeeAccounts(Integer numberOfAccounts) {
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            Account a = new Account();
            a.FirstName = 'unittest';
            a.LastName = 'Smith'+numberOfAccounts;
            a.RecordTypeId = employeeRecordTypeId;
            a.PersonEmail = 'unittest'+i+'@unittest.com';
            accs.add(a);
        }
        insert accs;
        return accs;
    }

    private static Address_GLBL__c newAddress(Account account){
        Address_GLBL__c address = new Address_GLBL__c();
        address.Account_GLBL__c = account.Id;
        address.RecordTypeId = otherAddressRecordTypeId;
        return address;
    }

    public static Address_GLBL__c insertAddress(Account account){
        Address_GLBL__c address = MERC_TestFactory.newAddress(account);
        insert address;
        return address;
    }

    public static Address_GLBL__c insertMasteredAddressWithCountry(Account account, String country){
        Address_GLBL__c address = MERC_TestFactory.newAddress(account);
        address.Adrs_Cntry_Cd_GLBL__c = country;
        address.RecordTypeId = masteredAddressRecordTypeId;
        insert address;
        return address;
    }

    public static Address_GLBL__c insertAddressWithCountry(Account account, String country){
        Address_GLBL__c address = MERC_TestFactory.newAddress(account);
        address.Adrs_Cntry_Cd_GLBL__c = country;
        insert address;
        return address;
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
        return insertMeetings(numberOfMeetings, null);
    }

    public static List<Meeting_MERC__c> insertMeetings(Integer numberOfMeetings, String countryName) {
        return insertMeetings(numberOfMeetings, countryName, null);
    }

    // TODO - this method arbitrarily sets the start/end dates 2 days in future and length to one day. Also, not in synch with insertMeetingDays()
    public static List<Meeting_MERC__c> insertMeetings(Integer numberOfMeetings, String countryName, String status) {
        if (countryName == null)
            countryName = 'GB';
        List<Meeting_MERC__c> mtgs = new List<Meeting_MERC__c>();
        for (Integer i = 0; i < numberOfMeetings; i++) {
            Meeting_MERC__c m = new Meeting_MERC__c();
            m.Date_of_Event_MERC__c = Date.today().addDays(2);
            m.End_Date_of_Event_MERC__c = Date.today().addDays(2);
            m.Start_Time_of_Meeting_MERC__c = DateTime.newInstance(Date.today().addDays(2), Time.newInstance(10, 0, 0, 0));
            m.End_Time_of_Meeting_MERC__c = DateTime.newInstance(Date.today().addDays(2), Time.newInstance(14, 0, 0, 0));
            m.Name = 'Event Name'+i;
            m.Meeting_Time_Zone_MERC__c = 'Greenwich Mean Time (Europe/London)';
            m.Event_Country_MERC__c = countryName;
            if(status != null){
                m.Meeting_Status_MERC__c = status;
            }
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

    public static List<Daily_Attendance_TOV_MERC__c> insertBulkTovs(List<Meeting_Day_MERC__c> meetingDays, List<Meeting_Participant_MERC__c> meetingParicipants) {
        List<Daily_Attendance_TOV_MERC__c> tovs = new List<Daily_Attendance_TOV_MERC__c>();
        for (Meeting_Day_MERC__c meetingDay : meetingDays) {
            for (Meeting_Participant_MERC__c meetingParticipant : meetingParicipants) {
                if (meetingParticipant.Meeting_MERC__c == meetingDay.Meeting_MERC__c) {
                    Daily_Attendance_TOV_MERC__c tov = new Daily_Attendance_TOV_MERC__c();
                    tov.Meeting_Day_MERC__c = meetingDay.Id;
                    tov.Meeting_Participant_MERC__c = meetingParticipant.Id;
                    tovs.add(tov);
                }
            }
        }
        insert tovs;
        return tovs;
    }

    public static List<Travel_Itinerary_MERC__c> insertHotelItineraries(List<Meeting_Participant_MERC__c> participants, Date startDate, Date endDate) {
        List<Travel_Itinerary_MERC__c> hotelItineraries = new List<Travel_Itinerary_MERC__c>();
        for (Meeting_Participant_MERC__c mp : participants) {
            Travel_Itinerary_MERC__c ti = new Travel_Itinerary_MERC__c();
            ti.RecordTypeId = hotelItineraryRecordTypeId;
            ti.Meeting_Participant_MERC__c = mp.Id;
            ti.Account_MERC__c = mp.Account_MERC__c;
            ti.Sgmnt_Bgin_TS_MERC__c = Datetime.newInstance(startDate, Time.newInstance(12, 0, 0, 0));
            ti.Sgmnt_End_TS_MERC__c = Datetime.newInstance(endDate, Time.newInstance(15, 0, 0, 0));
            hotelItineraries.add(ti);
        }
        insert hotelItineraries;
        return hotelItineraries;
    }

    public static List<Preferences_and_Consent_GLBL__c> insertPreferenceForAccounts(List<Account> accounts, String type, String value, Boolean isPrivate) {
        Id recordTypeId;
        if (isPrivate)
            recordTypeId = [SELECT ID FROM RecordType WHERE SobjectType = 'Preferences_and_Consent_GLBL__c' AND DeveloperName = 'Preferences_Private_EVNT_MVN'].Id;
        else
            recordTypeId = [SELECT ID FROM RecordType WHERE SobjectType = 'Preferences_and_Consent_GLBL__c' AND DeveloperName = 'Preferences_EVNT_MVN'].Id;

        List<Preferences_and_Consent_GLBL__c> pcs = new List<Preferences_and_Consent_GLBL__c>();
        for (Account a : accounts) {
            Preferences_and_Consent_GLBL__c pc = new Preferences_and_Consent_GLBL__c();
            pc.Account_GLBL__c = a.Id;
            pc.RecordTypeId = recordTypeId;
            pc.Preference_Type_MERC__c = type;
            pc.Preference_Sub_Type_MERC__c = value;
            pcs.add(pc);
        }
        insert pcs;
        return pcs;
    }

    public static List<Meeting_Vendor_MERC__c> insertHotelsForMeeting(Integer numberOfHotels, String meetingId) {
        return insertHotelsForMeetings(numberOfHotels, new List<Meeting_MERC__c>{ new Meeting_MERC__c(Id=meetingId)});
    }

    public static List<Meeting_Vendor_MERC__c> insertHotelsForMeetings(Integer numberOfHotels, List<Meeting_MERC__c> meetings) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numberOfHotels; i++) {
            Account a = new Account();
            a.RecordTypeId = vendorRecordTypeId;
            a.Name = MERC_Util.generateRandomString(5);
            accounts.add(a);
        }
        insert accounts;

        List<Meeting_Vendor_MERC__c> hotels = new List<Meeting_Vendor_MERC__c>();

        for (Meeting_MERC__c meeting : meetings) {
            for (Integer i = 0; i < accounts.size(); i++) {
                Meeting_Vendor_MERC__c v = new Meeting_Vendor_MERC__c();
                v.Account_MERC__c = accounts.get(i).Id;
                v.Room_Rate_MERC__c = (i+1)*50;
                v.Meeting_MERC__c = meeting.Id;
                hotels.add(v);
            }
        }
        insert hotels;
        return hotels;
    }

    public static List<Meeting_Day_MERC__c> insertMeetingDays(String meetingId, Integer numberOfDays) {
        return insertBulkMeetingDays(new List<Meeting_MERC__c>{new Meeting_MERC__c(Id=meetingId)}, numberOfDays);
    }

    public static List<Meeting_Day_MERC__c> insertBulkMeetingDays(List<Meeting_MERC__c> meetings, Integer numberOfDays) {
        List<Meeting_Day_MERC__c> mtgDays = new List<Meeting_Day_MERC__c>();
        for (Meeting_MERC__c meeting : meetings) {
            for (Integer i = 0; i < numberOfDays; i++) {
                Meeting_Day_MERC__c m = new Meeting_Day_MERC__c();
                m.Date_MERC__c = Date.today().addDays(i);
                m.Meeting_MERC__c = meeting.Id;
                m.Daily_Food_Beverage_Amount_MERC__c = 100;
                m.Daily_Ground_Trans_Amount_MERC__c = 100;
                m.Daily_Registration_Amount_MERC__c = 100;
                mtgDays.add(m);
            }
        }

        insert mtgDays;
        return mtgDays;
    }

    public static List<Meeting_Tasks_MERC__c> insertMeetingTask(String participantId) {
        return insertBulkMeetingTasks(new List<Meeting_Participant_MERC__c>{new Meeting_Participant_MERC__c(Id=participantId)});
    }

    public static List<Meeting_Tasks_MERC__c> insertBulkMeetingTasks(List<Meeting_Participant_MERC__c> participants) {
        List<Meeting_Tasks_MERC__c> tasks = new List<Meeting_Tasks_MERC__c>();
        Meeting_Process_MERC__c process = new Meeting_Process_MERC__c(Meeting_Participant_MERC__c = participants.get(0).Id);
        insert process;

        for (Meeting_Participant_MERC__c participant : participants) {
            Meeting_Tasks_MERC__c task = new Meeting_Tasks_MERC__c();
            //task.Meeting_Participant_MERC__c = participant.Id;
            task.Meeting_Process_MERC__c = process.Id;
            tasks.add(task);
        }

        insert tasks;
        return tasks;
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
            p.Services_Rendered_MERC__c = 'Yes';
            p.Alliance_MERC__c = 'Not Applicable';  // new process around FMV
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

    public static Budget_MERC__c insertStandAloneBudget() {
        Id budgetRecordTypeId = [Select ID From RecordType Where SobjectType = 'Budget_MERC__c' AND DeveloperName = 'MERC_Budget_Draft'].Id;
        Budget_MERC__c budget = null;

        budget = new Budget_MERC__c();
        budget.Meeting_MERC__c     = MERC_TestFactory.insertMeetings(1).get(0).id;
        budget.Status_MERC__c      = 'Draft';
        budget.Cost_Center_MERC__c = '123';
        budget.RecordTypeId        = budgetRecordTypeId;
        insert budget;
        return budget;
    }

	public static Budget_MERC__c insertBudget(String meetingId, boolean flag) {

        return insertBulkBudgets(new List<Meeting_MERC__c>{new Meeting_MERC__c(Id=meetingId)},flag).get(0);  //Modified by Jyoti Gaur for US-37784 on 01 June
    }

    public static List<Budget_MERC__c> insertBulkBudgets(List<Meeting_MERC__c> meetings, boolean flag1) {  //Modified by Jyoti Gaur for US-37784 on 01 June
        List<Budget_MERC__c> budgets = new List<Budget_MERC__c>();
        Id budgetRecordTypeId = [Select ID From RecordType Where SobjectType = 'Budget_MERC__c' AND DeveloperName = 'MERC_Budget_Draft'].Id;
        Budget_MERC__c bdgt = null;
        if(flag1 == true){
                bdgt= new Budget_MERC__c();
                bdgt.Meeting_MERC__c     = MERC_TestFactory.insertMeetings(1).get(0).id;
                bdgt.Status_MERC__c      = 'Draft';
                bdgt.Cost_Center_MERC__c = '123';
                bdgt.RecordTypeId        = budgetRecordTypeId;
                insert bdgt;
        }

        for (Meeting_MERC__c meeting : meetings) {
            Budget_MERC__c b      = new Budget_MERC__c();
            b.Meeting_MERC__c     = meeting.Id;
            b.Status_MERC__c      = 'Draft';
            b.Cost_Center_MERC__c = '1234567';
            b.RecordTypeId        = budgetRecordTypeId;
            b.Previous_Budget_Revision_MERC__c = bdgt.id;
            budgets.add(b);
        }
        insert budgets;
        List<Budget_Line_Item_MERC__c> BLI=insertBudgetLineItems(budgets[0].Id, 5);
        List<Budget_MERC__c> bdgtlist=[select id,Meeting_MERC__c,Status_MERC__c,Cost_Center_MERC__c,RecordTypeId,Previous_Budget_Revision_MERC__c,Total_Budget_Line_items__c from Budget_MERC__c where id =:budgets[0].Id];
        budgets[0] = bdgtlist[0];   //Modified by Jyoti Gaur for US-37784 on 01 June
        return budgets;
    }

    public static List<Budget_Line_Item_MERC__c> insertBudgetLineItems(String budgetId, Integer numberOfLineItems) {

        return insertBulkBudgetLineItems(new List<Budget_MERC__c>{new Budget_MERC__c(Id=budgetId)}, numberOfLineItems);
    }

    public static List<Budget_Line_Item_MERC__c> insertBulkBudgetLineItems(List<Budget_MERC__c> budgets, Integer numberOfLineItems) {
        List<Budget_Line_Item_MERC__c> lineItems = new List<Budget_Line_Item_MERC__c>();
        for (Budget_MERC__c budget : budgets) {
            for (Integer i = 0; i < numberOfLineItems; i++) {
                Budget_Line_Item_MERC__c lineItem = new Budget_Line_Item_MERC__c();
                lineItem.Amount_MERC__c = i+100;
                lineItem.Type_MERC__c = 'some type';
                lineItem.Budget_MERC__c = budget.Id;
                lineItems.add(lineItem);
            }
        }
        insert lineItems;
        return lineItems;
    }

    public static HCP_Contract_MERC__c insertHCPContract(String accountId) {
        HCP_Contract_MERC__c c = new HCP_Contract_MERC__c();
        c.Account_MERC__c = accountId;
        c.Country_MERC__c = 'GB';
        insert c;
        return c;
    }

    public static List<Team_Member_MERC__c> insertNewPrimaryMeetingOwners(List<Meeting_MERC__c> meets, List<User> members, String RT) {
        if (meets.size()!=members.size()) return null;

        List<Team_Member_MERC__c> result = new List<Team_Member_MERC__c>();

        // clear fields to satisfy validation rule
        meets = [SELECT Meeting_Owner_Email_MERC__c, Prmry_Mtng_Ownr_Nm_MERC__c FROM Meeting_MERC__c WHERE Id in :meets];
        for (Meeting_MERC__c m : meets) {
            m.Meeting_Owner_Email_MERC__c = null;
            m.Prmry_Mtng_Ownr_Nm_MERC__c = null;
        }
        update meets;

        Id recTypeId = [Select ID From RecordType Where SObjectType = 'Team_Member_MERC__c' and DeveloperName = :RT].ID;
        for (Integer n = 0; n<meets.size(); n++) {
            Team_Member_MERC__c tm = new Team_Member_MERC__c();
            tm.RecordTypeId = recTypeId;
            tm.User_MERC__c = members.get(n).Id;
            tm.Meeting_MERC__c = meets.get(n).Id;
            tm.Role_MERC__c = MERC_TeamMemberDeletePMO.PMO;
            result.add(tm);

            meets.get(n).Meeting_Owner_Email_MERC__c = members.get(n).Email;
            meets.get(n).Prmry_Mtng_Ownr_Nm_MERC__c = members.get(n).FirstName +' '+members.get(n).LastName;
        }
        insert result;
        update meets;

        return result;
    }

    public static User getUserInRole(String roleName) {
        List<UserRole> roles = [SELECT Name FROM UserRole];

        User rUser;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            rUser = insertTestUsers(1, null).get(0);
            UserRole r =[SELECT Name FROM UserRole WHERE Id = :rUser.userRoleId limit 1];
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='Mercury_Customer_Meeting_Services_Edit' limit 1];
            insert new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=rUser.id);
            update new User(id=rUser.Id, UserRoleId=[SELECT Id FROM UserRole WHERE Name=:roleName limit 1].id);
        }
        return rUser;
    }

    public static User getRunningUser() {
        return getUserInRole('Lilly Employee');
    }

    public static User getTestingUser() {
        User u = getUserInRole('CEO');
        return u;
    }

    public static List<User> insertTestUsers(Integer numberOfUsers, String profileName) {
        List<User> users = new List<User>();

        if (profileName == null) {
            profileName = 'GSO Basic User_Salesforce';
        }

        return insertTestUsers(numberOfUsers, profileName, null, null);
    }

    public static List<Registration_Question_MERC__c> insertQuestions(List<String> answerTypes, Id meetingId, Boolean createAnswers) {
        List<Registration_Question_MERC__c> questions = new List<Registration_Question_MERC__c>();
        for (Integer i=0; i<answerTypes.size(); i++) {
            questions.add(
                new Registration_Question_MERC__c(
                    Answer_Type_MERC__c = answerTypes[i],
                    Meeting_MERC__c    = meetingId,
                    Order_Number_MERC__c      = i+1,
                    Question_MERC__c   = 'Question ' + String.valueOf(i+1),
                    Service_Provider_MERC__c = true
                ));
        }

        insert questions;

        if (createAnswers) {
            List<Answer_MERC__c> answers = new List<Answer_MERC__c>();
            for (Registration_Question_MERC__c question : questions) {
                if (question.Answer_Type_MERC__c == 'Text') {
                    continue;
                }

                Answer_MERC__c answer1 = new Answer_MERC__c(
                    Answer_Text_MERC__c           = 'Answer 1 for ' + question.Question_MERC__c,
                    Registration_Question_MERC__c = question.Id,
                    Order_Number_MERC__c          = 1
                );

                Answer_MERC__c answer2 = new Answer_MERC__c(
                    Answer_Text_MERC__c           = 'Answer 2 for ' + question.Question_MERC__c,
                    Registration_Question_MERC__c = question.Id,
                    Order_Number_MERC__c          = 2
                );

                answers.add(answer1);
                answers.add(answer2);
            }
            insert answers;
        }

        return questions;
    }

    /*
     * Some Mercury workflows may conflict with unit tests (known issue: https://success.salesforce.com/ideaview?id=08730000000BrpCAAS)
     * In these cases, confirm these test users have username with "unitest" string &
     * use formula qualifier: !CONTAINS($User.Username, "unittest")
     */
    private static Integer userIndex = 0;
    public static List<User> insertTestUsers(Integer numberOfUsers, String profileName, String roleName, String groupName) {
        List<User> users = new List<User>();

        if (roleName  == null) roleName  = 'Lilly Employee';
        if (groupName == null) groupName = 'MERC_Content_Regional_GB';

        Profile p = [SELECT id from Profile WHERE Profile.Name =  :profileName limit 1];
        UserRole r =[SELECT Id FROM UserRole WHERE Name=:roleName limit 1];

        for (Integer i = 0; i < numberOfUsers; i++) {
            String testemail = 'testuser'+userIndex+'@unittest.com';
            User u = new User(profileId = p.id, userRoleId = r.id, username = testemail, email = testemail,
               alias='utusr'+userIndex, lastname='lastname', emailencodingkey = 'UTF-8', localesidkey = 'en_US',
               languagelocalekey = 'en_US', timezonesidkey = 'GMT'
               );
            userIndex++;
            users.add(u);
        }
        insert(users);

        Group g = [SELECT Id FROM Group WHERE Name = :groupName limit 1];
        List<GroupMember> members = new List<GroupMember>();
        for (User u : users) {
            members.add(new GroupMember(GroupId=g.Id,UserOrGroupId=u.Id));
        }
        List<Group> groups = [SELECT Id FROM Group WHERE Name LIKE '%GB'];
        for (Group grp : groups) {
            for (User u : users)
            {
                members.add(new GroupMember(GroupId=grp.Id,UserOrGroupId=u.Id));
            }
        }
        insert members;

        return users;
    }

    static void p(String m) {
        System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
    }
}