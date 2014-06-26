/**
 * @author Joseph Ferraro
 *
 * Tests GLBL_GenericRelatedListController
 */

@isTest (SeeAllData=false)
public class GLBL_GenericRelatedListControllerTest {

	static ApexPages.StandardSetController setController;
	static User testUser = MERC_TestFactory.getRunningUser();

	@isTest static void test_meeting_day_for_meeting() {
		System.runAs(testUser) {
			Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
			List<Meeting_Day_MERC__c> participants = MERC_TestFactory.insertMeetingDays(meeting.Id, 1);

			PageReference testPage = Page.Get_Started;
			testPage.getParameters().put('id', meeting.Id);
			Test.setCurrentPage(testPage);

			setController = new ApexPages.StandardSetController(new List<Meeting_MERC__c>());
			GLBL_GenericRelatedListController controller = new GLBL_GenericRelatedListController(
																					setController,
																					'Meeting_MERC__c',
																					'Meeting_Day_MERC__c',
																					'Meeting_MERC__c',
																					new List<String>{'Id','Name'},
																					new List<String>{'Name','Date_MERC__c','Daily_Ground_Trans_Amount_MERC__c'},
																					'Date_MERC__c');


			system.assertEquals(meeting.Id, controller.parent.Id);

			system.assertEquals(1, controller.children.size());

			controller.add();

			system.assertEquals(2, controller.children.size());


			controller.add();

			system.assertEquals(3, controller.children.size());

			controller.clientHash = controller.children.get(1).hash;
			controller.remove();

			system.assertEquals(2, controller.children.size());

			GLBL_GenericRelatedListController.GenericSobjectWrapper md = controller.children.get(1);
			md.so.put('Name', 'My Cool Meeting Day');
			md.so.put('Date_MERC__c', Date.today().addDays(1));
			md.so.put('Daily_Ground_Trans_Amount_MERC__c', 100.0);

			PageReference p = controller.save();

			system.debug('save result ref ---> '+p);
			system.debug(ApexPages.getMessages());

			system.assertEquals(2, [SELECT count() FROM Meeting_Day_MERC__c WHERE Meeting_MERC__c = :meeting.Id]);

			testPage.getParameters().put('notify','1');
			testPage.getParameters().put('msg', 'hello');
			Test.setCurrentPage(testPage);
			System.assertEquals(null, controller.save());
			System.assert(ApexPages.getMessages().get(0).getSummary().contains('hello'));

			testPage = Page.Get_Started;
			testPage.getParameters().put('id', meeting.Id);
			testPage.getParameters().put('retNull','1');
			System.assertEquals(null, controller.save());

			////this facilitates ajax, but no assertions needed
			controller.goToServer();

			Test.setReadOnlyApplicationMode(true);
			controller.save();
			System.assertEquals(2, ApexPages.getMessages().size(), ApexPages.getMessages());
		}
	}

	@isTest static void testGenericSobjectWrapper() {
		GLBL_GenericRelatedListController.GenericSobjectWrapper wrapper1 = new GLBL_GenericRelatedListController.GenericSobjectWrapper('Account', MERC_TestFactory.vendorRecordTypeId);
		GLBL_GenericRelatedListController.GenericSobjectWrapper wrapper2 = new GLBL_GenericRelatedListController.GenericSobjectWrapper('Account', MERC_TestFactory.vendorRecordTypeId);

		wrapper1.index=1;
		wrapper2.index=2;
		System.assertEquals(-1, wrapper1.compareTo(wrapper2));
		wrapper2.index=1;
		System.assertEquals(0, wrapper1.compareTo(wrapper2));
		wrapper2.index=0;
		System.assertEquals(1, wrapper1.compareTo(wrapper2));

	}
}