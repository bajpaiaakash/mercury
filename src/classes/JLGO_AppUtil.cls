public with sharing class JLGO_AppUtil {
	// insert Error
    public static void InsertError(exception e,string className){
        List<MICO_App__c> micoApp = [Select id from MICO_App__c where App_Code__c ='JLGO'];
        GLBL_Error_Log__c ge = new GLBL_Error_Log__c();
		ge.Error_Datetime__c=system.now();
        ge.Error_Message__c = e.getMessage();
        ge.Stack_Trace__c = e.getStackTraceString();
        ge.Running_User__c = userInfo.getuserid();
        ge.App__c=micoApp.size() > 0 ?  micoApp[0].id : null;
        ge.Additional_Information__c = className;
        insert ge;
    }
    /*
     * Cutting String Between str1 to str2
     */
    public static string GetBetweenStrings(string str1, string str2, string orgStr)
    {
        //isBlank
        if(string.isBlank(orgStr)) return '';
        //str1、str2 isBlank
        if(string.isBlank(str1) && string.isBlank(str2)) return orgStr;
        //str1、str2 not found orgStr
        if(orgStr.IndexOf(str1)==-1 || orgStr.IndexOf(str2)==-1){
 			 return '';
        }
        //str1 Length
        integer str1Len = 0;
        if(!string.isBlank(str1)) str1Len = str1.length();
        //str2 Length
        integer str2Len = 0;
        //if(!string.isBlank(str2)) str2Len = str2.length();
        //integer str1Num = orgStr.IndexOf(str1); 
        //str2Len = 0;
        string s = '';
        if (!string.isBlank(str1)){
             s = orgStr.Substring(orgStr.IndexOf(str1) + str1Len);
        }
        if (!string.isBlank(str2)){
             if(string.isBlank(str1)) s = orgStr;
             integer str2Num = s.IndexOf(str2); 
             s = s.Substring(0,str2Num + str2Len);
        }
        return s;
    }
}