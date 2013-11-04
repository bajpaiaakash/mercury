@isTest
private class GLBL_RollupSummaryUtilityTest {
	
	// common master records for the test case
	static Account acc1, acc2;
	// common bunch of detail records for the test case
	static Opportunity[] detailRecords;
	
	
	/*
	 creates the common seed data using Opportunity and Account objects. 
	 */
	static void prepareData() {
		 acc1 =  new Account(Name = 'Acc1');
         acc2 =  new Account(Name = 'Acc2');
         insert new Account[] {acc1, acc2};
           
         Opportunity o1Acc1 = new Opportunity( 
 												Name = 'o1Acc1', 
                                                AccountId = acc1.Id,
                                                Amount = 100.00,
                                                CloseDate = System.today(),
                                                StageName = 'test'
         									);
         Opportunity o2Acc1 = new Opportunity(
 												Name = 'o2Acc1',
                                                AccountId = acc1.Id,
                                                Amount = 300.00,
                                                CloseDate = System.today().addMonths(1),
                                                StageName = 'test'
         									);

         Opportunity o3Acc1 = new Opportunity(
 												Name = 'o3Acc1',
                                                AccountId = acc1.Id,
                                                Amount = 50.00,
                                                CloseDate = System.today().addMonths(-1),
                                                StageName = 'test'
         									);

         Opportunity o1Acc2 = new Opportunity(
 												Name = 'o1Acc2',
                                                AccountId = acc2.Id,
                                                Amount = 200.00,
                                                CloseDate = System.today().addMonths(2),
                                                StageName = 'test'
         									);
         
         Opportunity o2Acc2 = new Opportunity(
 												Name = 'o2Acc2',
                                                AccountId = acc2.Id,
                                                Amount = 400.00,
                                                CloseDate = System.today().addMonths(3),
                                                StageName = 'test'
         									);

         Opportunity o3Acc2 = new Opportunity(
 												Name = 'o3Acc2',
                                                AccountId = acc2.Id,
                                                Amount = 300.00,
                                                CloseDate = System.today().addMonths(4),
                                                StageName = 'test'
         									);
         detailRecords = new Opportunity[] {o1Acc1, o2Acc1, o3Acc1, o1Acc2, o2Acc2, o3Acc2};
         insert detailRecords;			
	}		

	
	/*
		Tests sum and max operations on currency and date fields
	*/
    static testMethod void testSumOperation() {
    	// create seed data 
         prepareData();
         
         List<GLBL_RollupSummaryUtility.fieldDefinition> fieldDefinitions = 
			new List<GLBL_RollupSummaryUtility.fieldDefinition> {
		            new GLBL_RollupSummaryUtility.fieldDefinition(
		            	'SUM', 'Amount', 'AnnualRevenue')
		        };
		         
        GLBL_RollupSummaryUtility.rollUpTrigger(fieldDefinitions, detailRecords, 
        'Opportunity', 'AccountId', 'Account', '');

         System.assertEquals(450.00, [Select AnnualRevenue FROM Account WHERE Id = :acc1.Id].AnnualRevenue);
         System.assertEquals(900.00, [Select AnnualRevenue FROM Account WHERE Id = :acc2.Id].AnnualRevenue);
                  
    }
    

}