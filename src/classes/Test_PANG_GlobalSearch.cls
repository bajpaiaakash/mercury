/****************************************************************************************************************************************** 
 * Class Name   : Test_PANG_GlobalSearch
 * Description  : Test Class for PANG_GlobalSearch
 * Created By   : Deloitte Consulting
 * 
 *****************************************************************************************************************************************/
@isTest(SeeAllData=false)

public class Test_PANG_GlobalSearch {

/* 
* @Method Name                    :  globalSearch
* @Description                    :  test method for PANG_GlobalSearch
* @Return Type                    :  void
* @Parameters                     :  None
*/ 
    static testMethod void globalSearch() {
    User u = PANG_TestFactory.getTestingUser();
    PANG_TestFactory.givePermissions(u.id,'PANG_RWE_Administrator');
    System.runAs(u) {
    
        List<PANG_Project__c> lProjects = PANG_TestFactory.returnStudies(100);
        List<PANG_Request__c> lRequests = PANG_TestFactory.returnRequests(1000,1000);
        List<PANG_Data_Asset__c> lDataAsset = PANG_TestFactory.returnDataAssets(500);
        
        Insert lProjects;
        Insert lRequests;
        Insert lDataAsset;
        
        system.assertEquals(lProjects.size(),100);
        system.assertEquals(lRequests.size(),2000);
        system.assertEquals(lDataAsset.size(),500);
        
        PageReference pageRef = new pageReference('/apex/PANG_Global_Search?DataAssets=true&Partnerships=true&Requests=true&searchWord=test&Studies=true');
        Test.setCurrentPage(pageRef);

        Test.startTest(); 
                
         PANG_GlobalSearch a = new PANG_GlobalSearch();
         
         List<PANG_GlobalSearch.wStudyObject> lTherapeuticArea = a.mStudyObjectStructure.get('TherapeuticArea');
         List<PANG_GlobalSearch.wStudyObject> lRegion = a.mStudyObjectStructure.get('Region__c');
         
         lRegion[0].isSelected=true;
         a.Query();
         lTherapeuticArea[0].isSelected=true;
         a.Query();
         
         //Unchecking and cheching last modified by filter
         a.mTimeFrameFilter.put('Previous Years',true);
         a.Query();
         a.mTimeFrameFilter.put('This Week',true);
         a.Query();
         a.mTimeFrameFilter.put('This Month',true);
         a.Query();
         a.mTimeFrameFilter.put('This Quarter',true);
         a.Query();
         a.mTimeFrameFilter.put('This Year',true);
         a.Query();
         a.mTimeFrameFilter.put('Previous Years',false);
         a.Query();        
         a.mTimeFrameFilter.put('This Year', false);
         a.mTimeFrameFilter.put('This Quarter', false);         
         a.mTimeFrameFilter.put('This Month', false);   
         a.Query(); 
         a.mTimeFrameFilter.put('This Month',true);
         a.Query();   
         a.mTimeFrameFilter.put('This Quarter',true);
         a.Query();    
         a.mTimeFrameFilter.put('This Year',true);        
         a.Query();                      
        
         a.sLocalSearch='100';
         a.Query();
         
         system.assertEquals(a.sLocalSearch,'100');
         
         a.isRequests = false;
         a.Query();
         
           
       Test.stopTest();  
    }
    
    }
    
    }