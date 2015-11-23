@isTest
private class MERC_MarketingCloudClientTest {

	@isTest static void test_getClassifications() {

		insertConfig();

		Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator());
		Test.startTest();

		List<MERC_MarketingCloudClient.SendClassification> sendClassifications = MERC_MarketingCloudClient.getClassifications();

		Test.stopTest();
	}

	@isTest static void test_getSenders() {

		insertConfig();

		Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator());
		Test.startTest();

		List<MERC_MarketingCloudClient.SenderProfile> senderProfiles = MERC_MarketingCloudClient.getSenders();

		Test.stopTest();
	}

	@isTest static void test_getSendersBeId() {

		insertConfig();

		Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator());
		Test.startTest();

		List<MERC_MarketingCloudClient.SenderProfile> senderProfiles = MERC_MarketingCloudClient.getSendersById(null);

		Test.stopTest();
	}

	@isTest static void test_postDataExtensionEntries() {
		insertConfig();
		MERC_MarketingCloudClient.DataExtension de = dataExt();
		List<MERC_MarketingCloudClient.DataExtensionEntry> deEntries = new List<MERC_MarketingCloudClient.DataExtensionEntry>();
		deEntries.add(deEntry());

		Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator(200));
		Test.startTest();

		try {
			MERC_MarketingCloudClient.createDataExtensionEntries(de, deEntries);
		} catch (exception e) {
			System.debug('#### FAILURE! ' + e);
		}

		Test.stopTest();
	}

	@isTest static void test_postDataExtension() {
		insertConfig();
		MERC_MarketingCloudClient.DataExtension de = dataExt();

		Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator(200));
		Test.startTest();

		try {
			MERC_MarketingCloudClient.DataExtensionResponse der = MERC_MarketingCloudClient.createDataExtension(de);
		} catch (exception e) {
			System.debug('#### FAILURE! ' + e);
		}

		Test.stopTest();
	}

	@isTest static void test_updateSubscriber() {
		insertConfig();
		MERC_MarketingCloudClient.Subscriber subscriber = getSubscriber();

		Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator(200));
		Test.startTest();

		try {
			String testString = MERC_MarketingCloudClient.updateSubscriber(subscriber);
		} catch (exception e) {
			System.debug('#### FAILURE! ' + e);
		}

		Test.stopTest();
	}

	@isTest static void test_getThumbnail() {
		insertConfig();

        Sonoma_ET_Config__c config = MERC_ETTestUtils.CreateConfig();
        insert config;
        
        MERC_TriggerHandlerStateManager.deactivate(MERC_PrimaryMeetingOwnerHandler.class);
        List<Meeting_MERC__c> meetings = MERC_ETTestUtils.CreateMeetings(1);
        insert meetings;

		Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator(200));
		Test.startTest();

		try {
			String testString = MERC_MarketingCloudClient.getThumbnail(MERC_ETTestUtils.createMeetingEmailSend(meetings[0].Id, 1)[0]);
		} catch (exception e) {
			System.debug('#### FAILURE! ' + e);
		}

		Test.stopTest();
	}

	@iSTest static void test_innerClasses() {

		MERC_MarketingCloudClient.FuelResponseBody frb = new MERC_MarketingCloudClient.FuelResponseBody();
		frb.expiresIn = 1;
		frb.legacyToken = 'test';
		System.assertEquals('test', frb.legacyToken);

		MERC_MarketingCloudClient.Entry entry = new MERC_MarketingCloudClient.Entry();
		entry.id = 'test';
		entry.name = 'test';
		entry.description = 'test';
		System.assertEquals('test', entry.id);

		MERC_MarketingCloudClient.ListResponse lr = new MERC_MarketingCloudClient.ListResponse();
		lr.startIndex = 0;
		lr.itemsPerPage = 0;
		lr.totalResults = 0;
		System.assertEquals(0, lr.startIndex);

		MERC_MarketingCloudClient.KeyValue kv = new MERC_MarketingCloudClient.KeyValue();
		kv.key = 'test';
		kv.value = 'test';
		System.assertEquals('test', kv.key);

		MERC_MarketingCloudClient.EmailFolder ef = new MERC_MarketingCloudClient.EmailFolder();
		ef.type = 'test';
		ef.lastUpdated = 'the other day';
		ef.createdBy = 'testy test';
		ef.parentId = 'test';
		ef.iconType = 'test';
		System.assertEquals('test', ef.parentId);

		MERC_MarketingCloudClient.Email email = new MERC_MarketingCloudClient.Email();
		email.id = 'test';
		email.type = 'test';
		email.status = kv;
		email.name = 'test';
		email.subject = 'test';
		email.categoryId = 'test';
		email.customerKey = 'test';
		email.sampleAudienceOnly = false;
		email.preheader = 'test';
		email.emailType = 0;
		email.messageId = 0;
		System.assertEquals('test', email.Id);

		MERC_MarketingCloudClient.FolderedEmail fe = getFolderedEmail();
		fe.subject = null;
		fe.email = email;
		String encodedSubject = fe.encodedSubject;
		System.assertEquals('test', fe.subject);

		MERC_MarketingCloudClient.EntryType et = new MERC_MarketingCloudClient.EntryType();

		MERC_MarketingCloudClient.SendClassification sc = new MERC_MarketingCloudClient.SendClassification();
		sc.key = 'test';
		sc.honorListLevelOptOut = true;
		sc.senderProfileId = 'test';
		sc.deliveryProfileId = 'test';
		sc.classificationType = et;
        System.assertEquals('test', sc.key);

		List<MERC_MarketingCloudClient.SendClassification> scList = new List<MERC_MarketingCloudClient.SendClassification>();
		scList.add(sc);

		MERC_MarketingCloudClient.SendClassificationResponse scr = new MERC_MarketingCloudClient.SendClassificationResponse();
		scr.entry = scList;

		MERC_MarketingCloudClient.SenderProfile sp = new MERC_MarketingCloudClient.SenderProfile();
		sp.key = 'test';
		sp.profileName = 'test';
		sp.fromEmail = 'test@test.com';
		sp.fromName = 'test';
        System.assertEquals('test', sp.key);        

		List<MERC_MarketingCloudClient.SenderProfile> spList = new List<MERC_MarketingCloudClient.SenderProfile>();
		spList.add(sp);

		MERC_MarketingCloudClient.SenderProfileResponse spr = new MERC_MarketingCloudClient.SenderProfileResponse();
		spr.entry = spList;

		MERC_MarketingCloudClient.DataExtension de = new MERC_MarketingCloudClient.DataExtension();
		de.dataExtensionName = 'test'; 
		System.assertEquals('test', de.dataExtensionName);

        MERC_MarketingCloudClient.Field field = new MERC_MarketingCloudClient.Field();
        field.fieldName = 'test';
        field.fieldType = 'test';
        field.isPrimaryKey = false;
        field.isTemplateField = false;
        field.length = 'test';
        field.nullable = true;
        System.assertEquals('test', field.fieldName);        

        MERC_MarketingCloudClient.DataExtensionResponse der = new MERC_MarketingCloudClient.DataExtensionResponse();
        der.Id = 'test';
        System.assertEquals('test', der.Id);

        MERC_MarketingCloudClient.ImageThumbnailSecureResponse itsr = new MERC_MarketingCloudClient.ImageThumbnailSecureResponse();
        itsr.data = 'test';
        System.assertEquals('test', itsr.data);

		MERC_MarketingCloudClient.SendDefinition sd = new MERC_MarketingCloudClient.SendDefinition('test', false, 'test', 42, 'test', 'test', 'test', 'test', 'test');
        System.assertEquals('test', sd.dataExtensionId);

        MERC_MarketingCloudClient.SendDefinition sd2 = new MERC_MarketingCloudClient.SendDefinition();
        sd2.dataExtensionId = 'test';
        System.assertEquals('test', sd2.dataExtensionId);

        MERC_MarketingCloudClient.CreateSendDefinitionResponse csdr = new MERC_MarketingCloudClient.CreateSendDefinitionResponse();
        csdr.id = 'test';
        System.assertEquals('test', csdr.Id);

		MERC_MarketingCloudClient.StartSendDefinitionResponse ssdr = new MERC_MarketingCloudClient.StartSendDefinitionResponse();
        ssdr.id = 'test';
        ssdr.statusMessage = 'test';
        ssdr.jobId = 'test';
        ssdr.clientId = 'test';
        System.assertEquals('test', ssdr.Id);

		MERC_MarketingCloudClient.CheckSendDefinitionStatusResponse csdsr = new MERC_MarketingCloudClient.CheckSendDefinitionStatusResponse();
        csdsr.id = 'test';
        csdsr.sendStatus = 'test';
        csdsr.jobId = 'test';
        csdsr.clientId = 'test';
        System.assertEquals('test', csdsr.Id);

	}

	static MERC_MarketingCloudClient.DataExtension dataExt () {

		MERC_ETSendEmailWrapper wrapper = wrapper();

        /**
         * create/authorize extension
         */
        MERC_ETAuthorizer authorizer = new MERC_ETAuthorizer();

        Blob deAESKey = Crypto.generateAesKey(256);
        String hexDeAESKey = EncodingUtil.convertToHex(deAESKey);

        //account for max length of DE name
        String deSubject = wrapper.Email.subject.length() > 140 ? wrapper.Email.subject.substring(0, 139) : wrapper.Email.subject;
        String deName = 'SalesforceMeeting-Test-' + deSubject.replaceAll('[^a-zA-Z0-9]+', '') + '-' + Datetime.now().format('yyyyMMdd\'T\'HHmmssSSS');
        String deKey = 'Test ' + Datetime.now().format('yyyyMMdd\'T\'HHmmssSSS');

        //default expiration to 3 days for immediate sends, otherwise ensure DE will still be around when scheduled send actually goes out.
        Datetime deExpiration = Datetime.now().addDays(3);
        if (wrapper.SendTime != 'now') {
            deExpiration = wrapper.FutureSendTime.addDays(3);
        }

		return new MERC_MarketingCloudClient.DataExtension(deName, 'this is a test', deKey, deExpiration);
	}

	static MERC_ETSendEmailWrapper wrapper() {
	    MERC_TestFactory.adjustForSFDCSetMockBug = true;

	    MERC_MarketingCloudClient.FolderedEmail fe = getFolderedEmail();

        List<Meeting_MERC__c> meetings = MERC_ETTestUtils.CreateMeetings(1);
        for (Meeting_MERC__c m : meetings) {
            m.RecordTypeId = MERC_ETTestUtils.GetRecordType('Ad_Hoc_Consulting', 'Meeting_MERC__c').Id;
            m.City_of_Meeting_MERC__c = 'test city';
            m.Preferred_Venue_MERC__c = 'test venue';
            m.Start_Time_of_Meeting_MERC__c = Datetime.now();
            m.End_Time_of_Meeting_MERC__c = Datetime.now().addDays(5);
            m.Event_Id_MERC__c = 'test id';
        }
        insert meetings;

        List<Account> personAccounts = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('HCP_GLBL', 5);
        insert personAccounts;

        List<Meeting_Participant_MERC__c> participants = MERC_ETTestUtils.CreateParticipants(meetings[0], personAccounts);
        insert participants;

        return new MERC_ETSendEmailWrapper(fe, participants, 'fromAddress@test.com', 'From Name', true, true, 'now', null, 'test', 'test');
    }

	static MERC_MarketingCloudClient.DataExtensionEntry deEntry() {
		MERC_MarketingCloudClient.DataExtensionEntry deEntry = new MERC_MarketingCloudClient.DataExtensionEntry();
		List<MERC_MarketingCloudClient.FieldEntry> feList = new List<MERC_MarketingCloudClient.FieldEntry>();

		for (Integer i = 0, j = 0; i < 4; i++) {
			MERC_MarketingCloudClient.FieldEntry fe = new MERC_MarketingCloudClient.FieldEntry();
			fe.fieldName = 'Test';
			fe.fieldValue = 'Test Value ' + i;
			feList.add(fe);
		}

		MERC_MarketingCloudClient.FieldEntry key = new MERC_MarketingCloudClient.FieldEntry();
		key.fieldName = 'Test';
		key.fieldValue = 'Test';

		deEntry.keys = key;
		deEntry.values = feList;
		return deEntry;
	} 

	static MERC_MarketingCloudClient.Subscriber getSubscriber() {
		MERC_MarketingCloudClient.Subscriber result = new MERC_MarketingCloudClient.Subscriber('2345678','TestyTester','test@test.com','test');
		return result;
	}

	static MERC_MarketingCloudClient.FolderedEmail getFolderedEmail() {

		MERC_MarketingCloudClient.FolderedEmail fe = new MERC_MarketingCloudClient.FolderedEmail();
        fe.id = 'folderedid';
        fe.name = 'folder email name';
        fe.subject = 'folder email title';
        fe.categoryId = 'test';
        return fe;
	}

	static void insertConfig() {
		et4ae5__configuration__c etConfig = MERC_ETTestUtils.CreateEtConfig();
        etConfig.et4ae5__username__c = 'testusername';
        etConfig.et4ae5__password__c = 'testpassword';
        etConfig.et4ae5__auth_api_url__c = 'www.testauthurl.com/Auth.svc';
        etConfig.et4ae5__root_rest_api_url__c = 'www.testresturl.com';
        etConfig.et4ae5__url_root__c = 'urlroot';
        etConfig.et4ae5__integration_type__c = 'MERC_MarketingCloudClient';
        etConfig.et4ae5__url_part__c = 'urlpart';
        insert etConfig;
	}
}