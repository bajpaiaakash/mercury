/**
 * @author Joseph Ferraro
 *
 * Tests for MERC_AgendaBuilderController
 */

@isTest
private class MERC_AgendaBuilderControllerTest {
	
	static List<Meeting_MERC__c> meetings;

	static {
		meetings = MERC_TestFactory.insertMeetings(1);
	}

	@isTest static void testShouldInsertNewAgendaItems() {
		
		Id meetingId = meetings.get(0).Id;
		Meeting_MERC__c meeting = meetings.get(0);

		PageReference agendaBuilderPage = Page.MERC_AgendaBuilder;
		agendaBuilderPage.getParameters().put('id', meetingId);
		agendaBuilderPage.getParameters().put('notify', '1');
		agendaBuilderPage.getParameters().put('msg', 'Hello world!');
		Test.setCurrentPage(agendaBuilderPage);


		ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Agenda_Item_MERC__c>());
		MERC_AgendaBuilderController controller = new MERC_AgendaBuilderController(setController);
		system.assertEquals(0, controller.children.size());

		controller.setTimeZones();

		controller.add();
		system.assertEquals(1, controller.children.size());

		controller.children.get(0).so.put('Name', 'A Cool Agenda Item');
		controller.children.get(0).so.put('Agenda_Item_Description_MERC__c', 'wooo fun!');
		controller.children.get(0).so.put('Session_Type_MERC__c', 'Breakout Session');

		System.assertEquals(meeting.Start_Time_of_Meeting_MERC__c, (DateTime)controller.children.get(0).so.get('Start_Time_MERC__c'));
		
		controller.add();
		system.assertEquals(2, controller.children.size());

		System.assertEquals(meeting.Start_Time_of_Meeting_MERC__c.addHours(1), (DateTime)controller.children.get(1).so.get('Start_Time_MERC__c'));

		controller.children.get(1).so.put('Name', 'Lunch time');
		controller.children.get(1).so.put('Agenda_Item_Description_MERC__c', 'have fun at lunch!');
		controller.children.get(1).so.put('Session_Type_MERC__c', 'Lunch');

		controller.save();
		system.assertEquals(2, [SELECT count() FROM Agenda_Item_MERC__c WHERE Meeting_MERC__c = :meetingId]);
	}

	@isTest static void testShouldManageExistingAgendaItems() {
		
		Id meetingId = meetings.get(0).Id;
		Meeting_MERC__c meeting = meetings.get(0);

		Agenda_Item_MERC__c agendaItem1 = new Agenda_Item_MERC__c();
		agendaItem1.Meeting_MERC__c = meetingId;
		agendaItem1.Start_Time_MERC__c = meeting.Start_Time_of_Meeting_MERC__c;
		agendaItem1.End_Time_MERC__c = meeting.Start_Time_of_Meeting_MERC__c.addHours(1);
		agendaItem1.Name = 'foo';
		agendaItem1.Agenda_Item_Description_MERC__c = 'foo bar';
		insert agendaItem1;

		Agenda_Item_MERC__c agendaItem2 = new Agenda_Item_MERC__c();
		agendaItem2.Meeting_MERC__c = meetingId;
		agendaItem2.Start_Time_MERC__c = meeting.Start_Time_of_Meeting_MERC__c.addHours(1);
		agendaItem2.End_Time_MERC__c = meeting.Start_Time_of_Meeting_MERC__c.addHours(2);
		agendaItem2.Name = 'foo 2';
		agendaItem2.Agenda_Item_Description_MERC__c = 'foo bar 2';
		insert agendaItem2;

		system.assertEquals(2, [SELECT count() FROM Agenda_Item_MERC__c WHERE Meeting_MERC__c = :meetingId]);

		PageReference agendaBuilderPage = Page.MERC_AgendaBuilder;
		agendaBuilderPage.getParameters().put('id', meetingId);
		agendaBuilderPage.getParameters().put('notify', '1');
		agendaBuilderPage.getParameters().put('msg', 'Hello world!');
		Test.setCurrentPage(agendaBuilderPage);

		ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Agenda_Item_MERC__c>());
		MERC_AgendaBuilderController controller = new MERC_AgendaBuilderController(setController);
		system.assertEquals(2, controller.children.size());

		controller.setTimeZones();

		controller.clientHash = controller.children.get(1).hash;
		controller.remove();

		system.assertEquals(1, [SELECT count() FROM Agenda_Item_MERC__c WHERE Meeting_MERC__c = :meetingId]);

		controller.add();
		system.assertEquals(2, controller.children.size());

		controller.children.get(1).so.put('Name', 'A Cool Agenda Item');
		controller.children.get(1).so.put('Agenda_Item_Description_MERC__c', 'wooo fun!');
		controller.children.get(1).so.put('Session_Type_MERC__c', 'Breakout Session');

		controller.save();
		system.assertEquals(2, [SELECT count() FROM Agenda_Item_MERC__c WHERE Meeting_MERC__c = :meetingId]);
	}
	
}