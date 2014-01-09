@isTest
private class MERC_AgendaItemNewEditControllerTest {
	
	static List<Meeting_MERC__c> mtgs;

	static {
		MERC_TestFactory.loadTimeZoneFieldMapSettings();
		mtgs = MERC_TestFactory.insertMeetings(1);
	}

	@isTest static void test_new_edit_form() {
		Meeting_MERC__c mtg = mtgs.get(0);
		Agenda_Item_MERC__c agendaItem = new Agenda_Item_MERC__c();
		agendaItem.Meeting_MERC__c = mtg.Id;

		PageReference agendaItemNewEditPage = Page.MERC_AgendaItemNewEdit;
		Test.setCurrentPage(agendaItemNewEditPage);
		Test.startTest();

		ApexPages.StandardController stdController = new ApexPages.StandardController(agendaItem);
		MERC_AgendaItemNewEditController controller = new MERC_AgendaItemNewEditController(stdController);
		controller.setTimeZones();

		agendaItem.Name = 'foo';
		agendaItem.Agenda_Item_Description_MERC__c = 'foo';
		agendaItem.Session_Type_MERC__c = 'foo';
		agendaItem.Start_Time_MERC__c = Datetime.now();
		agendaItem.End_Time_MERC__c = DateTime.now();

		PageReference p = controller.save();
		system.debug('p is: >>>>>> '+p);
		Test.stopTest();

		system.assertEquals(1, [SELECT count() FROM Agenda_Item_MERC__c WHERE Meeting_MERC__c = :mtg.Id]);
		system.assertNotEquals(null, [SELECT Start_Time_in_Meeting_Time_Zone_MERC__c FROM Agenda_Item_MERC__c WHERE Meeting_MERC__c = :mtg.Id].Start_Time_in_Meeting_Time_Zone_MERC__c);
	}

	@isTest static void test_agenda_builder() {
		Meeting_MERC__c mtg = mtgs.get(0);
		
		PageReference agendaBuilder = Page.MERC_AgendaBuilder;
		agendaBuilder.getParameters().put('id', mtg.Id);

		Test.setCurrentPage(agendaBuilder);

		Test.startTest();

		ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(new List<Agenda_Item_MERC__c>());
		MERC_AgendaBuilderController controller = new MERC_AgendaBuilderController(stdController);
		controller.add();

		system.assertEquals(1, controller.children.size());

		GLBL_GenericRelatedListController.GenericSobjectWrapper sw = controller.children.get(0);
		sw.so.put('Name','foo');
		sw.so.put('Start_Time_MERC__c', DateTime.now());
		sw.so.put('End_Time_MERC__c', DateTime.now());
		controller.save();
		
		Test.stopTest();

		system.assertNotEquals(null, [SELECT Start_Time_in_Meeting_Time_Zone_MERC__c FROM Agenda_Item_MERC__c WHERE Meeting_MERC__c = :mtg.Id].Start_Time_in_Meeting_Time_Zone_MERC__c);
	}
	
}