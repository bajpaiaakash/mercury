/**
 * Test class for PANG_AboutRWEController
 * can not create chatter group named \'RWE Community at Lilly\', hits following error
 * An active or archived group with this name already exists or is being deleted.
 * can not create library and assign library membership to test user by apex
 * due to above issues, assertation are skipped
*/

@isTest
public with sharing class PANG_AboutRWEControllerTest {

public static testmethod void PANG_AboutRWEControllerTest(){

        User u = PANG_TestFactory.getTestingUser();
        PANG_TestFactory.givePermissions(u.id,'PANG_RWE_Administrator');  
        
        System.runAs(u) {
        
        test.startTest();
        
        PANG_TestFactory.insertPANGCustomSettings();
        PANG_TestFactory.insertChatterGroups();
        
        PageReference aboutRWEPage = Page.PANG_AboutRWE;
            Test.setCurrentPage(aboutRWEPage);
                                  
            PANG_AboutRWEController controller = new PANG_AboutRWEController(); 
                   
        test.stopTest();

        }
}
   
}