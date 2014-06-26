/**
 * @author Joseph Ferraro
 *
 * Mock/Unit Test to test the dynamic layout describe via sobjectPartnerSoapSforceCom
 */

@IsTest
private with sharing class GLBL_DescribeLayoutTest {

	@isTest static void testDescribeLayout() {
		Test.setMock(WebServiceMock.class, new GLBL_Describe_WebServiceMockImpl());
		Test.startTest();
		Account a = new Account();
		GLBL_BaseEditController controller = new GLBL_BaseEditController(new ApexPages.StandardController(a), Account.SobjectType);
		List<GLBL_BaseEditController.PageBlockSection> sections = controller.sections;
		system.assertEquals(1, sections.size());
		Test.stopTest();
	}
}