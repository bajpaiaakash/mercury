/** 
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class test_createTestsForTester {

    static testMethod void SingleAdd() {
         User tstuser = [select id from user where isActive=true LIMIT 1];
         //insert template record
        MICO_test_templates__c TT = new MICO_Test_templates__c(
            );
        insert TT;
        
        MICO_test_template_steps__c TTS = new MICO_test_template_steps__c(
        Test_Script__c = TT.id
        );
        insert TTS;
         
         
        MICO_Tester__c tster = new MICO_Tester__c(
            Test_Template__c = tt.id, 
            User__c = tstuser.id, 
            Test_Phase__c = 'Unit');
            
        insert tster;
         
         
    }
      static testMethod void MultiAdd() {
      List<User> tstuser = [select id from user where isActive=true AND Profile.Name = 'System Administrator' LIMIT 2];
        MICO_test_templates__c TT = new MICO_Test_templates__c(
            
            );
        insert TT;
        
        MICO_test_template_steps__c TTS = new MICO_test_template_steps__c(
        Test_Script__c = TT.id
        );
        insert TTS;
        
        list<MICO_Tester__c> tster = new List<MICO_Tester__c>();
            for(User u : tstuser){
                tster.add(new MICO_Tester__c(
                Test_Template__c = tt.id, 
                User__c = u.id, 
                Test_Phase__c = 'Unit'));
            }
        insert tster;
        
         
    }
}