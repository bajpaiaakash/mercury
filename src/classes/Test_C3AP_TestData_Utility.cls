@isTest
public Class Test_C3AP_TestData_Utility{
 
    /* 
     * Method name : createAffiliate
     * Description :  This methods is used to create Affiliate data
     * Param :  Integer 
     * Returns :  List<C3AP_Affiliate__c>
    */
    public static List<C3AP_Affiliate__c> createAffiliate(Integer noOfAff){
        List<C3AP_Affiliate__c> objCreateAffList= new List<C3AP_Affiliate__c>();
        for(Integer i=0;i<noOfAff;i++) {
            C3AP_Affiliate__c objCreateAff= new C3AP_Affiliate__c();
            objCreateAff.name='Test_Affliate_'+noOfAff;
            
            objCreateAffList.add(objCreateAff);
        }
        return objCreateAffList;
    }
    
    
  
    /* 
     * Method name : createAffApprover
     * Description :  This methods is used to create Affiliate Approvers.
     * Param :  No. of Approvers(Integer),Type of Approver(String)
     * Returns :  List<C3AP_Affiliate_Approvers__c>
    */
    
    public static List<C3AP_Affiliate_Approvers__c> createAffApprover(Integer noOfApp,String type){
    
        List<C3AP_Affiliate__c> aff= Test_C3AP_TestData_Utility.createAffiliate(1);
        insert aff;
        List<C3AP_Affiliate_Approvers__c> objCreateAffList= new List<C3AP_Affiliate_Approvers__c>();
       
        for(Integer i=0;i<noOfApp;i++) {
           C3AP_Affiliate_Approvers__c objCreateApp= new C3AP_Affiliate_Approvers__c();
           objCreateApp.C3AP_Affiliate__c=aff[0].id;
            objCreateApp.C3AP_Approver_Name__c=UserInfo.getUserId();
            objCreateApp.Approver_Type__c=type;
            
            objCreateAffList.add(objCreateApp);
        }
         System.debug('after objCreateAffList----'+objCreateAffList);
        return objCreateAffList;
    }

    /* 
     * Method name : createAffApprOnly
     * Description :  This methods is used to create Affiliate Approvers using only Affiliate Id.
     * Param :  No. of Approvers(Integer),Type of Approver(String)
     * Returns :  List<C3AP_Affiliate_Approvers__c>
    */   

    public static C3AP_Affiliate_Approvers__c createAffApprOnly(String type,C3AP_Affiliate__c a ){

        List<C3AP_Affiliate_Approvers__c> objCreateAffList= new List<C3AP_Affiliate_Approvers__c>();
       
           C3AP_Affiliate_Approvers__c objCreateApp= new C3AP_Affiliate_Approvers__c();
           objCreateApp.C3AP_Affiliate__c=a.id;
            objCreateApp.C3AP_Approver_Name__c=UserInfo.getUserId();
            objCreateApp.Approver_Type__c=type;      
            objCreateAffList.add(objCreateApp);

        return objCreateApp;
    }
   
    /* 
     * Method name : createContractReq
     * Description :  This methods is used to create contract requests
     * Param :  No. of contract Requests(Integer)
     * Returns :  List<C3AP_Contract_Request__c>
    */
    
    public static List<C3AP_Contract_Request__c> createContractReq(Integer noOfConReq){
        List<C3AP_Contract_Request__c> objConReqList= new List<C3AP_Contract_Request__c>();
        List<C3AP_Affiliate__c> aff= Test_C3AP_TestData_Utility.createAffiliate(1); 
        List<C3AP_Affiliate_Approvers__c> affAppATC= Test_C3AP_TestData_Utility.createAffApprover(1,'ATC'); 
        List<C3AP_Affiliate_Approvers__c> affAppLegal= Test_C3AP_TestData_Utility.createAffApprover(1,'Legal'); 
        List<C3AP_Affiliate_Approvers__c> affAppATS= Test_C3AP_TestData_Utility.createAffApprover(1,'ATS'); 
        
        aff[0].Local_Language_ISO_Code__c='de';
        insert aff;
   
        for(Integer i=0;i<noOfConReq;i++) {
            C3AP_Contract_Request__c objConReq= new C3AP_Contract_Request__c();
            objConReq.C3AP_Affiliate__c=aff[0].id;
            objConReqList.add(objConReq);
        }
        return objConReqList; 
    }

    
   
     /* 
     * Method name : createC3APAffiliateQuestions
     * Description :  This methods is used to create C3AP Affiliate Questions
     * Param :  No. of Affiliate Questions(Integer)
     * Returns :  List<C3AP_Affiliate_Questions__c>
    */

    
        public static List<C3AP_Affiliate_Questions__c> createC3APAffiliateQuestions(Integer numOfAffQues) {
        List<C3AP_Affiliate_Questions__c> affQuesList = new List<C3AP_Affiliate_Questions__c>();
        List<C3AP_Affiliate__c> C3APAffliateList=Test_C3AP_TestData_Utility.createAffiliate(1);
        insert C3APAffliateList;
       
        for(Integer i=0;i<numOfAffQues;i++) {
            C3AP_Affiliate_Questions__c affQuesObj = new C3AP_Affiliate_Questions__c();         
            affQuesObj.C3AP_Affiliate__c=C3APAffliateList[0].id ;
            affQuesObj.C3AP_Question__c='Introductory Questions '+i;
            //affQuesObj.C3AP_Type__c='Introductory';
            affQuesList.add(affQuesObj);
        }    
        createAttachement(affQuesList[0]);
        return affQuesList;
      
    }
    
  
    /* 
     * Method name : createC3APContractAnswer
     * Description :  This methods is used to create C3AP Contract Request Answer
     * Param :  No. of Affiliate(Integer)
     * Returns :  List<C3AP_Contract_Request_Answer__c>
    */
    
        public static List<C3AP_Contract_Request_Answer__c> createC3APContractAnswer(Integer numOfAffiliate) {
        List<C3AP_Contract_Request_Answer__c> obj_C3APCOntractAnswerList= new List<C3AP_Contract_Request_Answer__c>();
        List<C3AP_Affiliate_Questions__c> affQuesList =Test_C3AP_TestData_Utility.createC3APAffiliateQuestions(1);
        List<C3AP_Contract_Request__c> objConReqList =Test_C3AP_TestData_Utility.createContractReq(1);
        
        for(Integer i=0;i<numOfAffiliate;i++) {
            C3AP_Contract_Request_Answer__c obj_C3APCOntractAnswer= new C3AP_Contract_Request_Answer__c();         
            obj_C3APCOntractAnswer.C3AP_Question__c=affQuesList[0].id;
            obj_C3APCOntractAnswer.C3AP_Contract_Request__c=objConReqList[0].id;
            obj_C3APCOntractAnswerList.add(obj_C3APCOntractAnswer);
        }    
        return obj_C3APCOntractAnswerList;
      
    }
    
   
    /* 
     * Method name : createAffliateContracts
     * Description :  This methods is used to create C3AP Affiliate Contracts
     * Param :  C3AP_Affiliate__c obj for which Contract is created
     * Returns :  List<C3AP_Affiliate_Contracts__c>
    */
        public static List<C3AP_Affiliate_Contracts__c> createAffliateContracts(C3AP_Affiliate__c Aff){
             List<C3AP_Affiliate_Contracts__c> affList = new List<C3AP_Affiliate_Contracts__c>();
             for(Integer i =0; i<5; i++){
               C3AP_Affiliate_Contracts__c anAffCont = new C3AP_Affiliate_Contracts__c();
               anAffCont.C3AP_Affiliate__c = Aff.id;
               anAffCont.C3AP_Department__c = 'General';
               affList.add(anAffCont);
             }
             return affList;
        
        }
        
    /* 
     * Method name : createAttachement
     * Description :  This methods is used to create Attachments
     * Param :  C3AP_Affiliate_Questions__c instance
     * Returns :  List<Attachment>    
     */
        
       public static List<Attachment> createAttachement(C3AP_Affiliate_Questions__c objAff){
           List<Attachment> attachmentList=new List<Attachment>();
           System.debug('check affliate object--'+objAff);
            for(Integer i =0; i<5; i++){
               Attachment anAffCont = new Attachment();
               anAffCont.ParentId = objAff.C3AP_Affiliate__c;
               anAffCont.Name= 'Question '+i;
               anAffCont.Body=Blob.valueof('HI');
               attachmentList.add(anAffCont);
             }
            insert attachmentList;
            return attachmentList;
       }
       
     
     /* 
     * Method name : createContractAttachments
     * Description :  This methods is used to create Contract Attachments
     * Param :  C3AP_Contract_Request__c instance
     * Returns :  List<Attachment>    
     */
       
       public static List<Attachment> createContractAttachments(C3AP_Contract_Request__c conR){
          List<Attachment> conAttachmentList=new List<Attachment>();
           for(Integer i =0; i<3; i++){
              Attachment cAttach = new Attachment();
              cAttach.Name= 'ContractDocumentaion '+i;
              cAttach.Body=Blob.valueof('Information');
              System.debug('Checking'+conR.id);
              cAttach.ParentId=conR.id;
              cAttach.OwnerId=Userinfo.getUserId();
              conAttachmentList.add(cAttach);
            }
           return conAttachmentList;
       }

    
       
    /* 
     * Method name : createAffAttachments
     * Description :  This methods is used to create Affiliate Attachments
     * Param :  C3AP_Affiliate__c  instance
     * Returns :  List<Attachment>    
     */
     
       public static List<Attachment> createAffAttachments(C3AP_Affiliate__c aff){
          List<Attachment> conAttachmentList=new List<Attachment>();
           for(Integer i =0; i<3; i++){
              Attachment cAttach = new Attachment();
              cAttach.Name= 'AffiliateLink '+i;
              cAttach.Body=Blob.valueof('Additional Guidance INformation');
              cAttach.ParentId=aff.id;
              conAttachmentList.add(cAttach);
            }
           return conAttachmentList;
       }
       
    /* 
     * Method name : createAffQuesAttmnts
     * Description :  This methods is used to create More Information links for affiliate questions
     * Param :  C3AP_Affiliate__c  instance
     * Returns :  List<Attachment>    
     */
     
       public static void createAffQuesAttmnts(C3AP_Affiliate_Questions__c affQues){
           Attachment cAttach = new Attachment();
           cAttach.Name= 'AffiliateQuesLink' ;
           cAttach.Body=Blob.valueof('More Information Checklist');
           cAttach.ParentId=affQues.id;
           insert cAttach;  
       }       
       
       
       
     /* 
     * Method name : createUser
     * Description :  This method is used to create a User to log in as
     * Param :  None
     * Returns :  User  
     */      
       
       public static User createUser(String prof) {
           Profile p = [SELECT Id FROM Profile WHERE Name=:prof]; 
           User u = new User(Alias = 'standt', Email='contractinitiator@testorg.com', LocaleSidKey='en_US',
           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',ProfileId = p.Id, 
           TimeZoneSidKey='America/Los_Angeles', UserName='contractinitiator'+String.valueOf(math.random()*math.random())+'@testorg.com');  
           insert u;      
           PermissionSet ps = [Select id From PermissionSet WHERE Name = 'C3AP_Contract_Initiator'];
           PermissionSetAssignment PSAssignments = new PermissionSetAssignment();
           PSAssignments=new PermissionSetAssignment(AssigneeId = u.id,PermissionSetId = ps.id);
           insert PSAssignments;                 
           return u;
       }
       
     /* 
     * Method name : createApp
     * Description :  This method is used to create the App C3, an instance of the Mico_App__c object for error logging
     * Param :  None
     * Returns :  User  
     */ 
     /*      
       public static void createApp() {
       Mico_App__c appTest=new Mico_App__c(Name='C3');
       insert appTest;
       System.debug('&&'+appTest);
       
       }
       */
       
       
       
}