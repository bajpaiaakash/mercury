/**
 * @author Joseph Ferraro
 *
 * Tests GLBL_GenericRelatedListController
 */

@isTest (SeeAllData=false)
public class GLBL_GenericRelatedListControllerTest {

	static ApexPages.StandardSetController setController;
	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();

	@isTest static void test_meeting_day_for_meeting() {
		System.runAs(testUser) {
			Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
			List<Meeting_Day_MERC__c> participants = MERC_TestFactory.insertMeetingDays(meeting.Id, 1);
			RecordType rt = [SELECT DeveloperName FROM RecordType WHERE DeveloperName = 'Completed' AND SObjectType = 'Meeting_MERC__c'];

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

			////this facilitates ajax, but no assertions needed
			controller.goToServer();
		}
	}

	@isTest static void test_meeting_budget_for_meeting() {
		System.runAs(testUser) {

			Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);

			Id budgetRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'MERC_Budget_Final' LIMIT 1].Id;
			Budget_MERC__c budget = new Budget_MERC__c(Meeting_MERC__c = meeting.Id, RecordTypeId = budgetRecordTypeId);
			insert budget;

			List<Budget_MERC__c> budgets = new List<Budget_MERC__c> {budget};

			PageReference testPage = Page.Get_Started;
			testPage.getParameters().put('id', meeting.Id);
			testPage.getParameters().put('rtdn', 'MERC_Budget_Final');
			Test.setCurrentPage(testPage);

			setController = new ApexPages.StandardSetController(new List<Meeting_MERC__c>());
			GLBL_GenericRelatedListController controller = new GLBL_GenericRelatedListController(
																					setController,
																					'Meeting_MERC__c',
																					'Budget_MERC__c',
																					'Meeting_MERC__c',
																					new List<String>{'Id','Name'},
																					new List<String>{'Name', 'Budget_Date_MERC__c', 'RecordTypeId'},
																					'Budget_Date_MERC__c');


			system.assertEquals(meeting.Id, controller.parent.Id);

			system.assertEquals(1, controller.children.size());

			controller.add();

			system.assertEquals(1, controller.children.size());

			GLBL_GenericRelatedListController.GenericSobjectWrapper md = controller.children.get(0);
			md.so.put('Budget_Date_MERC__c', Date.today().addDays(1));

			PageReference p = controller.save();

			system.debug('save result ref ---> '+p);
			system.debug(ApexPages.getMessages());

			system.assertEquals(1, [SELECT count() FROM Budget_MERC__c WHERE Meeting_MERC__c = :meeting.Id]);

			////this facilitates ajax, but no assertions needed
			controller.goToServer();
		}
	}
}