@isTest (SeeAllData=false)
public class GLBL_GenericRelatedListControllerTest {
	
	static ApexPages.StandardSetController setController;

	@isTest static void test_opportunities_for_accounts() {
		List<Account> accounts = MERC_TestFactory.insertBusinessAccounts(1, [SELECT ID FROM RecordType WHERE SObjectType = 'Account' and DeveloperName = 'Vendor_GLBL'].ID);
		Id accountId = accounts.get(0).Id;
		List<Opportunity> existingOpps = MERC_TestFactory.insertOpportunities(1, accountId);

		PageReference testPage = Page.Get_Started;
		testPage.getParameters().put('id', accountId);
		Test.setCurrentPage(testPage);

		setController = new ApexPages.StandardSetController(new List<Opportunity>());
		GLBL_GenericRelatedListController controller = new GLBL_GenericRelatedListController(
																				setController,
																				'Account',
																				'Opportunity',
																				'AccountId',
																				new List<String>{'Id','Name'},
																				new List<String>{'Name','Amount','StageName','CloseDate'},
																				'Name');

		
		system.assertEquals(accountId, controller.parent.Id);

		system.assertEquals(1, controller.children.size());

		controller.add();

		system.assertEquals(2, controller.children.size());

		controller.add();

		system.assertEquals(3, controller.children.size());

		controller.clientHash = controller.children.get(1).hash;
		controller.remove();

		system.assertEquals(2, controller.children.size());

		GLBL_GenericRelatedListController.GenericSobjectWrapper opp = controller.children.get(1);
		opp.so.put('Name', 'My Cool Opportunity');
		opp.so.put('Amount', 500);
		opp.so.put('StageName', 'Reviewing');
		opp.so.put('CloseDate', Date.today().addDays(5));


		PageReference p = controller.save();

		system.debug('save result ref ---> '+p);
		system.debug(ApexPages.getMessages());

		system.assertEquals(2, [SELECT count() FROM Opportunity WHERE AccountId = :accountId]);

		////this facilitates ajax, but no assertions needed
		controller.goToServer();

	}
}