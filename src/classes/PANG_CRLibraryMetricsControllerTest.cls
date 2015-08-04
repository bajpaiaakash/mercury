/**
 * Test class for PANG_CRLibraryMetricsController
 * can not create library and assign library membership to test user by apex
 * due to above issue, assertation is skipped
*/

@isTest
public with sharing class PANG_CRLibraryMetricsControllerTest {
    
    @isTest
    static void test_main(){
    User testUser = PANG_TestFactory.getTestingUser();
        System.runAs(testUser){ 
            PageReference metricsPage = Page.PANG_CRLibraryMetrics;
            Test.setCurrentPage(metricsPage);
            
            Test.startTest();           
            PANG_CRLibraryMetricsController controller = new PANG_CRLibraryMetricsController();
            List<SelectOption> options = controller.getLibraries();
            
            List<String> fileIds = PANG_CRLibraryMetricsController.getContentDocIds('058b0000000HgIL');      
            Test.stopTest();
        }
    }   
}