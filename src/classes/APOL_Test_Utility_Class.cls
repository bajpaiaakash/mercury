/****************************************************************************************************************************************** 
* Class Name   : APOL_Test_Utility_Class
* Description  : test class for APOL_Utility method. 
* Created By   : Deloitte Consulting
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class APOL_Test_Utility_Class {

public static final string ApolAdmin = 'APOL_Application_Admin';
public static final string ApolProjectLead = 'APOL_Project_Lead';

    /* 
    * Method name : createProject.
    * Description :  This methods is used to create Project data
    * Param :  Integer 
    * Returns :  List<APOL_Project__c>
    */
    public static List<APOL_Project__c> createProjects(Integer noOfProjects){
    List<APOL_Project__c> ProjLst= new List<APOL_Project__c>();
    APOL_Project__c ProjObj;
    for(Integer i=0;i<noOfProjects;i++) {
        ProjObj= new APOL_Project__c();
        ProjObj.Name = label.APOL_ApollotestData;
        ProjObj.Project_Description__c = label.APOL_ApollotestData;
        projObj.Clinical_Innovation__c = true;
        projObj.Next_Generation_Development__c = true;
        projObj.TransCelerate__c = true;
        projObj.Project_Stakeholder_Groups__c = Label.APOL_patients + ';' + Label.APOL_investigators;
        ProjObj.Program_Name__c = label.APOL_ApollotestData;
        ProjObj.Problem_Statement__c = label.APOL_ApollotestData;
        ProjObj.The_One_Liner__c = label.APOL_ApollotestData;
        projObj.publish_to_chord__c = true;
        ProjLst.add(ProjObj);
    }
    
    insert ProjLst;   
    return ProjLst;
    }
    
    /* 
    * Method name : createApplied.
    * Description :  This methods is used to create Applied data
    * Param :  Integer , APOL_Project__c 
    * Returns :  List<APOL_Applied__c>
    */
    public static List<APOL_Applied__c> createApplied(Integer noOfApplied, APOL_Project__c prj){
        List<APOL_Applied__c> AppLst= new List<APOL_Applied__c>();
        APOL_Applied__c AppObj;
        List<APOL_Trial_Map__c> trialMapLst = createtrialMap(noOfApplied);
        for(Integer i=0;i<noOfApplied;i++) {
            AppObj= new APOL_Applied__c();
            appObj.Project_name__c = prj.Id;
            appObj.Trial_Alias1__c = trialMapLst[i].Id;
            AppObj.Business_Unit__c = label.APOL_ApollotestData;
            AppObj.Stage_Of_development__c = label.APOL_ApollotestData;
            AppLst.add(AppObj);
        }
        
        insert AppLst;   
        return AppLst;
    }
    
    /* 
    * Method name : createtrialMap.
    * Description :  This methods is used to create Trial Map data
    * Param :  Integer 
    * Returns :  List<APOL_Trial_Map__c>
    */
    public static List<APOL_Trial_Map__c> createtrialMap(Integer noOfTrial){
        List<APOL_Trial_Map__c> TrialLst= new List<APOL_Trial_Map__c>();
        APOL_Trial_Map__c TrialObj;
        for(Integer i=0;i<noOfTrial;i++) {
            TrialObj= new APOL_Trial_Map__c();
            TrialObj.Compound__c = label.APOL_ApollotestData;
            TrialObj.Therapeutic_Area__c = label.APOL_ApollotestData;
            TrialObj.Trial_Phase__c = label.APOL_ApollotestData;
            trialObj.Name = label.APOL_ApollotestData + i;
            TrialLst.add(TrialObj);
        }
        insert TrialLst;   
        return TrialLst;
    }
    
    /* 
    * Method name : CreateApolAdmin.
    * Description :  This methods is used to create Apollo Admin user. 
    * Returns :  User
    */   
    public static user CreateApolAdmin() {
        // Setup test data
        // This code runs as the Apollo Application Admin user
        PermissionSet ApolAdminUser = [SELECT ID From PermissionSet WHERE Name =: ApolAdmin];
        Profile p = [SELECT Id FROM Profile WHERE Name='GSO Basic User_Platform'];
        PermissionSetAssignment PSAssignmenTs = new PermissionSetAssignment();      
        User u = new User(Alias = 'adminu', Email='adminduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='apoladminuser@testorg.com');
        insert u;
        PSAssignmenTs.AssigneeId = u.id;
        PSAssignmenTs.PermissionSetId = APOLADMINUSER.ID;
        insert PSAssignmenTs;                         
        return u;
    }
    
        /* 
    * Method name : CreateApolProjectLead.
    * Description :  This methods is used to create Apollo Project Lead user. 
    * Returns :  User
    */   
    public static user CreateApolProjectLead() {
        // Setup test data
        // This code runs as the Apollo Application Admin user
        PermissionSet ApolProjectLeadPS = [SELECT ID From PermissionSet WHERE Name =: ApolProjectLead];
        Profile p = [SELECT Id FROM Profile WHERE Name='GSO Basic User_Platform'];
        PermissionSetAssignment PSAssignmenTs = new PermissionSetAssignment();      
        User u = new User(Alias = 'plead', Email='pleaduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='apolleaduser@testorg.com');
        insert u;
        PSAssignmenTs.AssigneeId = u.id;
        PSAssignmenTs.PermissionSetId = ApolProjectLeadPS.ID;
        insert PSAssignmenTs;                         
        return u;
    }
    
}