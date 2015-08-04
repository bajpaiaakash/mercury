/****************************************************************************************************************************************** 
* Class Name   : PANG_TestFactory
* Description  : Utility Class for Creating Test Data for PANG
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
@isTest
public with sharing class PANG_TestFactory {
    public static void insertPANGCustomSettings(){
        List<PANG_Settings__c> settings = new List<PANG_Settings__c>();
        settings.add(new PANG_Settings__c(Name = 'Training Material Library',Setting_Value__c = 'Pangaea Training Material'));
        settings.add(new PANG_Settings__c(Name = 'Default Chatter Group',Setting_Value__c = 'RWE Community at Lilly'));
        insert settings;
    }
    
     /* 
    * @Method Name                    :  givePermissions
    * @Description                    :  Assigning Permission Set to a User
    * @Return Type                    :  void
    * @Parameters                     :  UserID,PSetName
    */   
    public static void givePermissions(id UserID, string PSetName){   
        PermissionSet ps = [Select id From PermissionSet WHERE Name = :PSetName];          
        PermissionSetAssignment psAssignments = new PermissionSetAssignment(AssigneeId = UserID,PermissionSetId = ps.id);
        insert psAssignments;
    }
    
    /* 
    * @Method Name                    :  assignGroup
    * @Description                    :  Assigning Public Group to a User
    * @Return Type                    :  void
    * @Parameters                     :  UserID,gname
    */   
     public static void assignGroup(id UserID, string gname){   
         //Get the groups that the user should be added to
        Group g=[select Id from Group Where DeveloperName = :gname];

         List<User> users=[Select Id,Name from user Where Id = :UserID];

         List<GroupMember>listGroupMember =new List<GroupMember>();  
         // loop the users that have been created
         for (User user : users){
         GroupMember gm= new GroupMember(); 
         gm.GroupId=g.id;
         gm.UserOrGroupId = user.id;
         listGroupMember.add(gm);   
         } 
         insert listGroupMember;
        }
        
     /* 
    * @Method Name                    :  insertChatterGroups
    * @Description                    :  Inserting Chatter Groups
    * @Return Type                    :  void
    * @Parameters                     :  None
    */ 
    public static void insertChatterGroups(){
    
        CollaborationGroup cg = new CollaborationGroup(Name = 'RWE Community at Lilly', CollaborationType = 'Public');
        database.insert(cg,false); 
    }

     /* 
    * @Method Name                    :  getTestingUser
    * @Description                    :  Creates a Test User
    * @Return Type                    :  User
    * @Parameters                     :  None
    */ 
    public static User getTestingUser(){
    
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = dateString + randomInt;
    
            User u;
            String pId = [select Id from Profile where Name = 'GSO Basic User_Platform'].Id;
            String rId = [select id from UserRole where Name = 'Lilly Employee'].Id;
            u = new User(profileId = pId, userRoleId = rId,  email = uniqueName + '@test' + uniqueName+ '.org',
                        Username = uniqueName + '@test' + uniqueName + '.org',
                        alias='utusr', lastname='lastname', emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                        languagelocalekey = 'en_US', timezonesidkey = 'GMT');
            
            insert u; 
            return u;         

    } 
    
     /* 
    * @Method Name                    :  returnStudies
    * @Description                    :  returns a list of Studies
    * @Return Type                    :  List
    * @Parameters                     :  count
    */ 
    public static list<PANG_Project__c> returnStudies(integer count){
        list<PANG_Project__c> lStudies = new list<PANG_Project__c>();
        for(integer i=0;i<count;i++){
            PANG_Project__c oStudy = new PANG_Project__c();
           
            oStudy.Name='test'+i;
            oStudy.Project_Lead_Owner__c=userinfo.getUserID();
            oStudy.Functional_Area__c='MEDICAL';
            oStudy.Project_Status__c='Archived';
            oStudy.TPO_Activity__c='YES';
            oStudy.TPO__c='Test';
            oStudy.Business_Unit_Primary__c='EMBU';
            oStudy.Therapeutic_Area_Primary__c='Alzheimer’s & NDD';
            //oStudy.Region__c='US';
            lStudies.add(oStudy);       
        }       
        return lStudies;
    }
    
     /* 
    * @Method Name                    :  returnDataAssets
    * @Description                    :  returns a list of Data Assets
    * @Return Type                    :  List
    * @Parameters                     :  count
    */
    public static list<PANG_Data_Asset__c> returnDataAssets(integer count){
        list<PANG_Data_Asset__c> lDataAssets = new list<PANG_Data_Asset__c>();
        for(integer i=0;i<count;i++){
            PANG_Data_Asset__c oDataAsset = new PANG_Data_Asset__c();
            oDataAsset.name='test'+i;
            oDataAsset.Business_Unit_Primary__c='EMBU';
            oDataAsset.Asset_Status__c = 'Licensed Corporately';
            oDataAsset.Asset_Sub_Status__c ='multi-use data asset';
            oDataAsset.Documentation_Link__c = 'www.google.com';
            oDataAsset.Relationship_Type__c = 'Vendor';
            oDataAsset.Relevant_Therapeutic_Area__c= 'Alzheimer’s & NDD';
            oDataAsset.Type_of_Database__c = 'Claims';
            oDataAsset.Access_Method__c = 'Data Broker';
            lDataAssets.add(oDataAsset);    
        }       
        return lDataAssets;
    }
    
     /* 
    * @Method Name                    :  returnRequests
    * @Description                    :  returns a list of Requests
    * @Return Type                    :  List
    * @Parameters                     :  partnershipCount,DataMartcount
    */
    public static list<PANG_Request__c> returnRequests(integer partnershipCount,integer DataMartcount){
    map<string,id> mRecordTypes = new map<string,id>();
        list<PANG_Request__c> lRequests = new list<PANG_Request__c>();
        for (RecordType oRecType: [SELECT id, developername FROM RecordType WHERE SobjectType = 'PANG_Request__c']) {
                mRecordTypes.put(oRecType.developername, oRecType.id);
        }
        system.debug('@@@@'+mRecordTypes);
        for(integer i=0;i<partnershipCount;i++){
            PANG_Request__c oReq = new PANG_Request__c();
            oReq.name='test'+i;
            oReq.Requestor__c=userinfo.getUserID();
            oReq.Requestor_Functional_Area__c='MEDICAL';
            oReq.RecordtypeId=mRecordTypes.get('RWE_Partnership_Exploration');
            oReq.Business_Unit_Primary__c='EMBU';
            oReq.Therapeutic_Area_Primary__c='Cardiovascular';
            oReq.Proposed_Due_Date__c = system.today()+10;
            oReq.Partnership_Sponsor__c= 'GPORWE';
            oReq.Partnership_Status__c= 'Exploring';
            oReq.Region__c='US';
            oReq.Type_of_Partner__c='Payer;Non-profit';
            lRequests.add(oReq);    
        } 
        for(integer i=0;i<DataMartcount;i++){
            PANG_Request__c oReq = new PANG_Request__c();
            oReq.name='test'+i;
            oReq.Requestor__c=userinfo.getUserID();
            oReq.Requestor_Functional_Area__c='MEDICAL';
            oReq.RecordtypeId=mRecordTypes.get('Internal_Real_World_Data_Analysis');
            oReq.Business_Unit_Primary__c='EMBU';
            oReq.Proposed_Due_Date__c = system.today()+10;
            oReq.Therapeutic_Area_Primary__c='Cardiovascular';
            //oReq.Region__c='US';
            lRequests.add(oReq);    
        }       
        return lRequests;
    } 
    
    
      
}