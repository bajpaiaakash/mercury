@isTest
private class MERC_MeetingParticipantNewEditCtrlTest {
	
	static List<Account> accounts;
	static List<Meeting_MERC__c> meetings;

	static {
		accounts = MERC_TestFactory.insertAccounts(1); //insert 1 account
		meetings = MERC_TestFactory.insertMeetings(1); //insert 1 meeting
	}

	@isTest static void testNewMeetingParticipant() {
		system.assertEquals(0, [SELECT count() FROM Meeting_Participant_MERC__c]);

		PageReference ref = Page.MERC_MeetingParticipantNewEdit;
		Test.setCurrentPage(ref);

		Meeting_Participant_MERC__c newMeetingParticipant = new Meeting_Participant_MERC__c();
		newMeetingParticipant.Meeting_MERC__c = meetings.get(0).Id;
		newMeetingParticipant.RecordTypeId = [SELECT ID FROM RecordType WHERE SObjectType = 'Meeting_Participant_MERC__c' AND DeveloperName = 'Service_Provider_MERC'].ID;

		ApexPages.StandardController standardController = new ApexPages.StandardController(newMeetingParticipant);
		MERC_MeetingParticipantNewEditController controller = new MERC_MeetingParticipantNewEditController(standardController);

		system.assertEquals(null, (String)controller.mySobject.get('Id'));

		controller.mySobject.put('Id', 'foo');
		controller.save();

		System.assert(!ApexPages.getMessages().isEmpty(),'Error message not passed back to page.');
		System.assert(ApexPages.getMessages()[0].getDetail().contains('Record ID: id value of incorrect type: foo'));
		system.debug(ApexPages.getMessages());

		controller.mySobject.put('Id', null);

		controller.mySobject.put('Account_MERC__c', accounts.get(0).Id);

		controller.save();

		system.assertEquals(1, [SELECT count() FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings.get(0).Id]);
	}

    private class WebServiceMockImpl implements WebServiceMock {
		public void doInvoke(
		    Object stub, Object request, Map<String, Object> response,
		    String endpoint, String soapAction, String requestName,
		    String responseNS, String responseName, String responseType) {
            system.debug('----------> CALLOUT ATTEMPT!! '+request);
          //  if(request instanceof sobjectPartnerSoapSforceCom.describeLayout_element) {
          //      sobjectPartnerSoapSforceCom.describeLayoutResponse_element el = new sobjectPartnerSoapSforceCom.describeLayoutResponse_element();
          //      el.result = new sobjectPartnerSoapSforceCom.DescribeLayoutResult();
		        //response.put('response_x', el);
          //  }
            sobjectPartnerSoapSforceCom.describeLayoutResponse_element el = new sobjectPartnerSoapSforceCom.describeLayoutResponse_element();
            el.result = new sobjectPartnerSoapSforceCom.DescribeLayoutResult();
	        response.put('response_x', el);
		    return;
		}
	}

	@isTest static void testEditMeetingParticipant() {
		system.assertEquals(0, [SELECT count() FROM Meeting_Participant_MERC__c]);

		PageReference ref = Page.MERC_MeetingParticipantNewEdit;
		Test.setCurrentPage(ref);

		Meeting_Participant_MERC__c existingMeetingParticipant = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts)[0];

		ApexPages.StandardController standardController = new ApexPages.StandardController(existingMeetingParticipant);

		Test.startTest();
		Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
		MERC_MeetingParticipantNewEditController controller = new MERC_MeetingParticipantNewEditController(standardController);
		Test.stopTest();
		system.assertNotEquals(null, (String)controller.mySobject.get('Id'));

		PageReference p = controller.ajaxUpdate();
		System.assert(ApexPages.getMessages().isEmpty(),'Error message that is not supposed to be there!');


		//controller.mySobject.put('Id', 'foo');
		//controller.save();

		//System.assert(!ApexPages.getMessages().isEmpty(),'Error message not passed back to page.');
		//System.assert(ApexPages.getMessages()[0].getDetail().contains('Record ID: id value of incorrect type: foo'));
		//system.debug(ApexPages.getMessages());

		//controller.mySobject.put('Id', null);

		//controller.mySobject.put('Account_MERC__c', accounts.get(0).Id);
		
		//controller.save();

		//system.assertEquals(1, [SELECT count() FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings.get(0).Id]);
	}

	
}