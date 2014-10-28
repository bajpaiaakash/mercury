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
private class test_CreateBugLink {
    static testMethod void insertTest() {
        //insert new records
        list<MICO_Bug__c> newBugs = new List<MICO_Bug__c>();
        user assi = [select id from user where isActive = true limit 1];
        newBugs.add(new MICO_Bug__c(problem__c = 'test1', status__c = 'raised'));
        newBugs.add(new MICO_Bug__c(problem__c = 'test2', status__c = 'raised'));
        insert newBugs;
        MICO_Related_Bug__c link = new MICO_Related_Bug__c(Related_Bug__c=newBugs[0].id, Bug__c=newBugs[1].id);
        insert link;
        integer inte = [select count() from MICO_Related_Bug__c where Related_Bug__c = :newBugs[0].id or Bug__c=:newBugs[0].id];
        system.assert(inte==2);
    }
      
}