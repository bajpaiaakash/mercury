@isTest
public class MERC_ETAccountEmailTriggerImpl_Test {

    @isTest
    static void Test_AccountTrigger_EmailNotChanged() {
		Account testAcct = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('PersonAccount', 1)[0];
		insert testAcct;
		
        Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator());
		Test.startTest();
			testAcct = [SELECT Id, PersonEmail FROM Account WHERE FirstName = 'unittest' LIMIT 1];
			update testAcct;
		Test.stopTest();
		
        testAcct = [SELECT Id, PersonEmail FROM Account WHERE FirstName = 'unittest' LIMIT 1];
		
		System.assert(testAcct.PersonEmail == 'test@testy.com', 'PersonEmail should equal "test@testy.com", not ' + testAcct.PersonEmail);
    }
    
    @isTest
    static void Test_AccountTrigger_EmailChanged() {
        Account testAcct = MERC_ETTestUtils.CreatePersonAccountsWithRecordType('PersonAccount', 1)[0];
        insert testAcct;
        
        Test.setMock(HttpCalloutMock.class, new MERC_ETMockHttpResponseGenerator()); 
        Test.startTest();
	        testAcct = [SELECT Id, PersonEmail FROM Account WHERE FirstName = 'unittest' LIMIT 1];
	        testAcct.PersonEmail = 'updated@testy.com';
	        update testAcct;
        Test.stopTest();
        
        testAcct = [SELECT Id, PersonEmail FROM Account WHERE FirstName = 'unittest' LIMIT 1];
        
        System.assert(testAcct.PersonEmail == 'updated@testy.com', 'PersonEmail should equal "updated@testy.com", not ' + testAcct.PersonEmail);
    }
}