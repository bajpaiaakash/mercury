/*
* @Name: Test_C3APLegalQuestionnaireController
* @Desciption: Test class to test C3APLegalQuestionnaireController class
* @date Latest:Sep 09, 2014
* @author Shoumyabrata Chanda
*/


@isTest(seeAllData=false)

public with sharing class Test_C3APLegalQuestionnaireController{

    public static List <C3AP_Contract_Request__c> objConReqList;
    public static List <C3AP_Contract_Request_Answer__c> objConReqAns;
    public static List <C3AP_Contract_Request_Answer__c> obj_C3APCOntractAnswerList;
    public static C3APLegalQuestionnaireController c3apObj;
    public static C3AP_Affiliate_Questions__c objAffQues;
    public static List <C3AP_Affiliate_Questions__c> affQuesLst;
    public static String moreInformationLink;
    public static  attachment attachmentObj;
    public static Integer sortCount=0;
 
    //Test_C3AP_LegalQuestionnaireController test= new Test_C3AP_LegalQuestionnaireController();
             
    
    public static testmethod void checkLegalQuestionnaireController(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
        System.runAs(u) {       
            //Creates an instance of Mico_App__c
            //Test_C3AP_TestData_Utility.createApp();    
            createObject();
            sortCount=0; 
            affQuesLst = new List <C3AP_Affiliate_Questions__c>(); 
            objConReqAns = new List <C3AP_Contract_Request_Answer__c>();
            obj_C3APCOntractAnswerList = new List <C3AP_Contract_Request_Answer__c>();                               
            objConReqAns= createIntroAnswers();     
            insert objConReqAns; 
            moreInformationLink=System.Label.C3AP_More_Information;
            attachmentObj=new attachment(); 
            PageReference myPage = Page.C3AP_Legal_Questionnaire;
            myPage.getParameters().put('contractId',objConReqList[0].Id);             
            test.setCurrentPage(myPage);                  
             
            C3APLegalQuestionnaireController.sampleWrapper wrapperObj= new C3APLegalQuestionnaireController.sampleWrapper(new C3AP_Contract_Request_Answer__c(),new C3AP_Affiliate_Questions__c(),false,moreInformationLink,attachmentObj);            
            ApexPages.standardController cont =  new ApexPages.StandardController(objConReqList[0]);
            c3apObj = new C3APLegalQuestionnaireController(cont);         
            Test.StartTest();  
                List<SelectOption> listSec=c3apObj.getResponses();
                System.assertEquals(listSec.isEmpty() ,false);   
                //c3apObj.lstSampleWrapperLegal[0].ansObj.C3AP_Answer__c=true;
                c3apObj.lstSampleWrapperLegal[0].userSelection='true';                   
                myPage.getParameters().put('activeQuestionId',c3apObj.lstSampleWrapperLegal[0].quesObj.Id);
                c3apObj.getNextQuestion();
                System.assert(c3apObj.lstSampleWrapperLegal[0].ansObj.C3AP_Answer__c);
                PageReference pg=c3apObj.showContractDetails();  
                System.assertNotEquals(pg, null);    
                PageReference pgref=c3apObj.cancelLegalQues();  
                System.assertNotEquals(pgref, null);  
            Test.StopTest();       
            } 
     } 
     
     public static testmethod void checkLegalQuestionnaireController_UpdateOnAmend(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
        System.runAs(u) {       
            //Creates an instance of Mico_App__c
            //Test_C3AP_TestData_Utility.createApp();    
            createObject();
            sortCount=0; 
            affQuesLst = new List <C3AP_Affiliate_Questions__c>(); 
            objConReqAns = new List <C3AP_Contract_Request_Answer__c>();
            obj_C3APCOntractAnswerList = new List <C3AP_Contract_Request_Answer__c>();                               
            objConReqAns= createIntroAnswers();     
            insert objConReqAns; 
            moreInformationLink=System.Label.C3AP_More_Information;
            attachmentObj=new attachment(); 
            PageReference myPage = Page.C3AP_Legal_Questionnaire;
            myPage.getParameters().put('contractId',objConReqList[0].Id);             
            test.setCurrentPage(myPage);                  
             
            C3APLegalQuestionnaireController.sampleWrapper wrapperObj= new C3APLegalQuestionnaireController.sampleWrapper(new C3AP_Contract_Request_Answer__c(),new C3AP_Affiliate_Questions__c(),false,moreInformationLink,attachmentObj);            
            ApexPages.standardController cont =  new ApexPages.StandardController(objConReqList[0]);
            c3apObj = new C3APLegalQuestionnaireController(cont);     
            List<SelectOption> listSec=c3apObj.getResponses();
            System.assertEquals(listSec.isEmpty() ,false);
            c3apObj.lstSampleWrapperLegal[0].userSelection='true';                   
            myPage.getParameters().put('activeQuestionId',c3apObj.lstSampleWrapperLegal[0].quesObj.Id);
            c3apObj.getNextQuestion();
            System.assert(c3apObj.lstSampleWrapperLegal[0].ansObj.C3AP_Answer__c);
            PageReference pg=c3apObj.showContractDetails();  
            System.assertNotEquals(pg, null);    
            Test.StartTest();  
                C3AP_Contract_Request__c c3UpdatedContract = [Select Id from C3AP_Contract_Request__c where Id =:objConReqList[0].Id];
                PageReference legalUpdatePage = Page.C3AP_Legal_Questionnaire;
                legalUpdatePage.getParameters().put('contractId',objConReqList[0].Id);             
                test.setCurrentPage(legalUpdatePage);                  
                ApexPages.standardController updatedCont =  new ApexPages.StandardController(c3UpdatedContract);
                C3APLegalQuestionnaireController updatedContract = new C3APLegalQuestionnaireController(updatedCont);
                updatedContract.showContractDetails();
            Test.StopTest();       
            } 
     }              
     
     public static testmethod void codeBreakageTest(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
        System.runAs(u) {       
            //Creates an instance of Mico_App__c
            //Test_C3AP_TestData_Utility.createApp();    
            createObject();
            sortCount=0; 
            affQuesLst = new List <C3AP_Affiliate_Questions__c>(); 
            objConReqAns = new List <C3AP_Contract_Request_Answer__c>();
            obj_C3APCOntractAnswerList = new List <C3AP_Contract_Request_Answer__c>();                               
            objConReqAns= createIntroAnswers();     
            insert objConReqAns; 
            moreInformationLink=System.Label.C3AP_More_Information;
            attachmentObj=new attachment(); 
            PageReference myPage = Page.C3AP_Legal_Questionnaire;
            myPage.getParameters().put('contractId',objConReqList[0].Id);             
            test.setCurrentPage(myPage);                  
             
            C3APLegalQuestionnaireController.sampleWrapper wrapperObj= new C3APLegalQuestionnaireController.sampleWrapper(new C3AP_Contract_Request_Answer__c(),new C3AP_Affiliate_Questions__c(),false,moreInformationLink,attachmentObj);            
            ApexPages.standardController cont =  new ApexPages.StandardController(objConReqList[0]);
            c3apObj = new C3APLegalQuestionnaireController(cont);         
            Test.StartTest();  
                List<SelectOption> listSec=c3apObj.getResponses();
                System.assertEquals(listSec.isEmpty() ,false);   
                //c3apObj.lstSampleWrapperLegal[0].ansObj.C3AP_Answer__c=true;
                c3apObj.lstSampleWrapperLegal[0].userSelection='true';                   
                myPage.getParameters().put('activeQuestionId',c3apObj.lstSampleWrapperLegal[0].quesObj.Id);
                c3apObj.getNextQuestion();
                System.assert(c3apObj.lstSampleWrapperLegal[0].ansObj.C3AP_Answer__c);
                c3apObj.contractId = null;
                c3apObj.contractRequest = null;
                PageReference pg=c3apObj.showContractDetails();  
                System.assertNotEquals(pg, null);    
                PageReference pgref=c3apObj.cancelLegalQues();  
                System.assertNotEquals(pgref, null);  
            Test.StopTest();       
            } 
     }         


     public static C3AP_Affiliate_Questions__c putdata(Boolean input,String type){
         objAffQues=Test_C3AP_TestData_Utility.createC3APAffiliateQuestions(1)[0];
         objAffQues.C3AP_Affiliate__c=objConReqList[0].C3AP_Affiliate__c;
         objAffQues.C3AP_Sort_Order__c = ++sortCount;
         objAffQues.C3AP_Type__c=type;
         objAffQues.C3AP_More_Information__c=input;
         insert objAffQues;
         Attachment a = new Attachment();
         a.Body = Blob.valueOf('Hello');
         a.Name = 'Test File';
         a.ParentId = objAffQues.Id;
         insert a;
         return objAffQues;
     }
     
   
     public  static void createObject(){
         objConReqList =Test_C3AP_TestData_Utility.createContractReq(1);
         insert objConReqList ;            
     }
          
     public static List <C3AP_Contract_Request_Answer__c> createIntroAnswers() {
         C3AP_Affiliate_Questions__c firstQuestion = putdata(true,System.Label.C3AP_Question_Type_Introductory);        
         C3AP_Affiliate_Questions__c SecondQuestion = putdata(true,System.Label.C3AP_Question_Type_Information);
         affQuesLst.add(firstQuestion);
         affQuesLst.add(SecondQuestion);
         firstQuestion.C3AP_Next_Question_If_Yes__c = SecondQuestion.Id;      
         firstQuestion.C3AP_Next_Question_If_No__c = SecondQuestion.Id;   
         Test_C3AP_TestData_Utility.createAffQuesAttmnts(firstQuestion);   
         update firstQuestion;
         C3AP_Affiliate_Questions__c thirdQuestion = putdata(true,System.Label.C3AP_Question_Type_Introductory);
         SecondQuestion.C3AP_Next_Question_If_Yes__c = thirdQuestion.Id;
         SecondQuestion.C3AP_Next_Question_If_No__c = thirdQuestion.Id;
         Test_C3AP_TestData_Utility.createAffQuesAttmnts(SecondQuestion);   
         update SecondQuestion;
         affQuesLst.add(thirdQuestion);
         C3AP_Affiliate_Questions__c fourthQuestion = putdata(true,System.Label.C3AP_Question_Type_Legal);
         thirdQuestion.C3AP_Next_Question_If_Yes__c = fourthQuestion.Id;
         thirdQuestion.C3AP_Next_Question_If_No__c = fourthQuestion.Id;
         Test_C3AP_TestData_Utility.createAffQuesAttmnts(thirdQuestion);                
         update thirdQuestion;     
         affQuesLst.add(fourthQuestion);

         for(Integer i=0;i<affQuesLst.size();i++) {
                 C3AP_Contract_Request_Answer__c obj_C3APCOntractAnswer= new C3AP_Contract_Request_Answer__c();       
                 obj_C3APCOntractAnswer.C3AP_Answer__c=true;
                 obj_C3APCOntractAnswer.C3AP_Question__c=affQuesLst[i].id;
                 obj_C3APCOntractAnswer.C3AP_Contract_Request__c=objConReqList[0].id;
                 obj_C3APCOntractAnswerList.add(obj_C3APCOntractAnswer);
             }
        
         C3AP_Affiliate_Questions__c fifthQuestion = putdata(true,System.Label.C3AP_Question_Type_Legal);
         C3AP_Affiliate_Questions__c sixthQuestion = putdata(true,System.Label.C3AP_Question_Type_Legal);
         fourthQuestion.C3AP_Next_Question_If_Yes__c = fifthQuestion.Id;      
         fourthQuestion.C3AP_Next_Question_If_No__c = fifthQuestion.Id;  
         fourthQuestion.C3AP_Controlling_Question__c = secondQuestion.Id;
         fourthQuestion.C3AP_Is_Optional__c = true;
         Test_C3AP_TestData_Utility.createAffQuesAttmnts(fourthQuestion);   
         fifthQuestion.C3AP_Next_Question_If_Yes__c = sixthQuestion.Id;      
         fifthQuestion.C3AP_Next_Question_If_No__c = sixthQuestion.Id; 
         fifthQuestion.C3AP_Controlling_Question__c = secondQuestion.Id;
         fifthQuestion.C3AP_Is_Optional__c = true;                            
         update fourthQuestion;     
         update fifthQuestion;                   
         return obj_C3APCOntractAnswerList;     
     }       
          
          
          
}