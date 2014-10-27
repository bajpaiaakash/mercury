/*****************************************************************************************
    Name    : ACED_Utility
    Desc    : This class is a utility class. It is written for storing static text, 
              quering recordtype and logging error logs in Error Log Object for 
              exception handling (ACE DD)      
                            
    Modification Log : 
    ---------------------------------------------------------------------------------------
    Developer                  Date                Description
    ----------------------------------------------------------------------------------------
    Venu Vemula                09/11/2014          Created

    Madhurupa Ghose Roy        09/19/2014          Updated with Error Log Code
    
    ******************************************************************************************/


public class ACED_Utility {
    public static String[] retiredStatuses=new String[]{'Retired', 'Under Construction', 'Planned'};  
    Public Static String oAssetName = 'ACED_Asset__c';
    Public Static String RetiredStatus = 'Retired';
    
    // Static varaiable of Asset status live 
    Public Static String sAssetLiveStatus = 'Live';
    
    //Utility class for getting recordtypename 
    public static Map<String,Id> mRecordType (String sObjectName){
        Map<String,Id> mRecordtype = new Map<String,Id>();
        for(Recordtype oRecordType : [Select id,DeveloperName  from recordtype where SObjectType = : oAssetName and Isactive =: True]){
            mRecordtype.put(oRecordType.DeveloperName,oRecordType.Id);
        }
        return mRecordtype;
    }
    
    //Error and Exception Logs
    public static void createErrorRecord(string exceptionMessage,string stackTrace, string runningUser){
         GLBL_Error_Log__c newErrorRecord = new GLBL_Error_Log__c();
         newErrorRecord.Error_Message__c = exceptionMessage;
         newErrorRecord.Stack_Trace__c = stackTrace;
         newErrorRecord.Running_User__c = runningUser;
         //newErrorRecord.App__c = 'ACED';
         Database.insert(newErrorRecord,false);
    }
}