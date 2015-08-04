/**
 * Test class for PANG_SelectReportController
*/

@isTest
public with sharing class PANG_SelectReportControllerTest {
	static User testUser = PANG_TestFactory.getTestingUser();
	
	@isTest
	static void test_main(){
		System.runAs(testUser){	
			PageReference selectReportPage = Page.PANG_SelectReport;
			Test.setCurrentPage(selectReportPage);
			
			Test.startTest();			
			PANG_SelectReportController controller = new PANG_SelectReportController();
			List<SelectOption> options = controller.getCustomReports();
			System.assert(options.size() > 0);
			
			controller.SelectedReport = options[0].getValue();
			PageReference pr1 = controller.gotoReport();
			System.assertNotEquals(null,pr1);
			
			PageReference pr2 = controller.cancel();
			System.assertNotEquals(null,pr2);
			Test.stopTest();
		}
	}	
}