/**
 * @author Kyle Thornton
 *
 * Unit test for GLBL_AsyncApexJobsSelector
 */
@isTest
private class GLBL_AsyncApexJobsSelectorTest {

	@isTest static void test_exerise_methods() {
		GLBL_AsyncApexJobsSelector controller = new GLBL_AsyncApexJobsSelector();
		System.assertEquals('CreatedDate', controller.getOrderBy());

		System.assertEquals(0, controller.selectById(new set<Id>{'001000000000000'}).size());
		System.assertEquals(false, controller.jobsExecuting(new Set<String>{'aclassname'}));
	}
}