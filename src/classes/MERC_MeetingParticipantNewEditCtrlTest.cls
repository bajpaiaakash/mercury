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

<<<<<<< HEAD
		system.assertEquals(null, (String)controller.mySobject.get('Id'));

		controller.mySobject.put('Id', 'foo');
=======
		system.assertEquals(null, (String)controller.meetingParticipant.get('Id'));

		controller.meetingParticipant.put('Id', 'foo');
>>>>>>> 038d9c54d876da9a1530fddfc3f8fbb7b4bdc2f5
		controller.save();

		System.assert(!ApexPages.getMessages().isEmpty(),'Error message not passed back to page.');
		System.assert(ApexPages.getMessages()[0].getDetail().contains('Record ID: id value of incorrect type: foo'));
		system.debug(ApexPages.getMessages());

<<<<<<< HEAD
		controller.mySobject.put('Id', null);

		controller.mySobject.put('Account_MERC__c', accounts.get(0).Id);
=======
		controller.meetingParticipant.put('Id', null);

		controller.meetingParticipant.put('Account_MERC__c', accounts.get(0).Id);
>>>>>>> 038d9c54d876da9a1530fddfc3f8fbb7b4bdc2f5

		controller.save();

		system.assertEquals(1, [SELECT count() FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c = :meetings.get(0).Id]);
	}

<<<<<<< HEAD
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
=======
	@isTest static void testEditMeetingParticipant() {
		system.assertEquals(0, [SELECT count() FROM Meeting_Participant_MERC__c]);
		Meeting_Participant_MERC__c existingMeetingParticipant = MERC_TestFactory.insertParticipants(meetings.get(0).Id, accounts)[0];

		system.debug('meeting partiicpant id: '+existingMeetingParticipant.Id);

		PageReference ref = Page.MERC_MeetingParticipantNewEdit;
		ref.getParameters().put('id', existingMeetingParticipant.Id);
		Test.setCurrentPage(ref);

		ApexPages.StandardController standardController = new ApexPages.StandardController(existingMeetingParticipant);
		MERC_MeetingParticipantNewEditController controller = new MERC_MeetingParticipantNewEditController(standardController);

		system.assertNotEquals(null, controller.meetingParticipant.Id);

		controller.meetingParticipant.Air_Travel_Required_MERC__c = 'Yes';
		
		PageReference p = controller.save();
		system.debug('=====>');
		system.debug(controller.meetingParticipant);
		system.debug(ApexPages.getMessages());
		system.debug(p);

		system.assertEquals('Yes', [SELECT Air_Travel_Required_MERC__c FROM Meeting_Participant_MERC__c WHERE ID = :existingMeetingParticipant.Id].Air_Travel_Required_MERC__c);

		p = controller.ajaxUpdate();
		System.assert(ApexPages.getMessages().isEmpty(),'Error message that is not supposed to be there!');

>>>>>>> 038d9c54d876da9a1530fddfc3f8fbb7b4bdc2f5
	}

	
}