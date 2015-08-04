/*
* @Name: Testc3APContractInititationController
* @Desciption: developed for testing the customized functionality of Contract Initiation and Pre-Defined Questions
* @date Latest:Sept 08, 2014
* @author Prem Kumar Gupta
*/

@isTest(SeeAllData=false)


public class Test_C3APContractInititationController{
  
  public static List<C3AP_Contract_Request__c> objConReqList;
  public static C3AP_Contract_Request_Answer__c objConReqAns;
  public static c3APContractInititationController c3apObj;
  public static C3AP_Affiliate_Questions__c objAffQues;
  public static String moreInformationLink;
  public static  attachment attachmentObj;
  public static Integer sortCount=0;
   
     public static testmethod void testc3APContractInititationController(){
         User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
         System.runAs(u) {    
             //Test_C3AP_TestData_Utility.createApp();   
             createObject();
             sortCount=0;
             //This section creates test data for Affiliate Questions 
             C3AP_Affiliate_Questions__c firstQuestion = putdata(true,System.Label.C3AP_Question_Type_Introductory);        
             C3AP_Affiliate_Questions__c SecondQuestion = putdata(true,System.Label.C3AP_Question_Type_Legal); 
             firstQuestion.C3AP_Next_Question_If_Yes__c = SecondQuestion.Id;      
             firstQuestion.C3AP_Next_Question_If_No__c = SecondQuestion.Id;   
             Test_C3AP_TestData_Utility.createAffQuesAttmnts(firstQuestion);   
             update firstQuestion;    
             C3AP_Affiliate_Questions__c thirdQuestion = putdata(true,System.Label.C3AP_Question_Type_Legal);
             SecondQuestion.C3AP_Next_Question_If_Yes__c = thirdQuestion.Id;
             SecondQuestion.C3AP_Next_Question_If_No__c = thirdQuestion.Id;
             Test_C3AP_TestData_Utility.createAffQuesAttmnts(SecondQuestion);   
             update SecondQuestion;
             C3AP_Affiliate_Questions__c fourthQuestion = putdata(true,System.Label.C3AP_Question_Type_Legal);
             thirdQuestion.C3AP_Next_Question_If_Yes__c = fourthQuestion.Id;
             thirdQuestion.C3AP_Next_Question_If_No__c = fourthQuestion.Id;
             objConReqAns= Test_C3AP_TestData_Utility.createC3APContractAnswer(1)[0];      
             moreInformationLink=System.Label.C3AP_More_Information;
             objConReqAns.C3AP_Contract_Request__c = objConReqList[0].Id;
             insert objConReqAns;
             attachmentObj=new attachment();
             attachmentObj.ParentId = objConReqAns.Id;
             attachmentObj.Body = Blob.ValueOf('Test Data');
             attachmentObj.Name = 'Test Data';
             insert attachmentObj;
             
             //Initializing the Controller
             c3APContractInititationController.sampleWrapper wrapperObj= new
              c3APContractInititationController.sampleWrapper(new C3AP_Contract_Request_Answer__c(),
              firstQuestion,false,attachmentObj,fourthQuestion);            
             ApexPages.standardController cont =  new ApexPages.StandardController(objConReqList[0]);
             //Initializing the page to set the parameters             
             PageReference myPage = Page.C3AP_Contract_Initiation;
             myPage.getParameters().put('affiliateId',objConReqList[0].C3AP_Affiliate__c);
             test.setCurrentPage(myPage);
             c3apObj = new c3APContractInititationController(cont);                    
             myPage.getParameters().put('activeQuestionId',c3apObj.lstSampleWrapper[0].question.Id);  
             c3apObj.insertContract();
             Test.StartTest();     
                 c3apObj.lstSampleWrapper[0].answer.C3AP_Answer__c=true;     
                 c3apObj.lstSampleWrapper[0].userSelection='true';  
                 c3apObj.getNextQuestion();
                 system.assertEquals(c3apObj.lstSampleWrapper[0].answer.C3AP_Answer__c,true); 
                 PageReference pgref=c3apObj.showContractDetails();  
                 System.assertNotEquals(pgref, null);  
                 List<SelectOption> listSec=c3apObj.getResponses();
                 system.assertEquals(listSec.isEmpty() ,false);
             Test.StopTest();       
         }    
    }

     public static testmethod void testc3APContractInititationControllerSecond(){
         User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
         System.runAs(u) {    
             //Test_C3AP_TestData_Utility.createApp();   
             createObject();
             sortCount=0;
             //This section creates test data for Affiliate Questions 
             C3AP_Affiliate_Questions__c firstQuestion = putdata(true,System.Label.C3AP_Question_Type_Introductory);        
             C3AP_Affiliate_Questions__c SecondQuestion = putdata(true,System.Label.C3AP_Question_Type_Information); 
             firstQuestion.C3AP_Next_Question_If_Yes__c = SecondQuestion.Id;      
             firstQuestion.C3AP_Next_Question_If_No__c = SecondQuestion.Id;   
             Test_C3AP_TestData_Utility.createAffQuesAttmnts(firstQuestion);   
             update firstQuestion;    
             C3AP_Affiliate_Questions__c thirdQuestion = putdata(true,System.Label.C3AP_Question_Type_Information);
             SecondQuestion.C3AP_Next_Question_If_Yes__c = thirdQuestion.Id;
             SecondQuestion.C3AP_Next_Question_If_No__c = thirdQuestion.Id;
             Test_C3AP_TestData_Utility.createAffQuesAttmnts(SecondQuestion);   
             update SecondQuestion;
             C3AP_Affiliate_Questions__c fourthQuestion = putdata(true,System.Label.C3AP_Question_Type_Information);
             thirdQuestion.C3AP_Next_Question_If_Yes__c = fourthQuestion.Id;
             thirdQuestion.C3AP_Next_Question_If_No__c = fourthQuestion.Id;
             objConReqAns= Test_C3AP_TestData_Utility.createC3APContractAnswer(1)[0];      
             moreInformationLink=System.Label.C3AP_More_Information;
             objConReqAns.C3AP_Contract_Request__c = objConReqList[0].Id;
             insert objConReqAns;
             attachmentObj=new attachment();
             attachmentObj.ParentId = objConReqAns.Id;
             attachmentObj.Body = Blob.ValueOf('Test Data');
             attachmentObj.Name = 'Test Data';
             insert attachmentObj;
             
             //Initializing the Controller
             c3APContractInititationController.sampleWrapper wrapperObj= new
              c3APContractInititationController.sampleWrapper(new C3AP_Contract_Request_Answer__c(),
              firstQuestion,false,attachmentObj,fourthQuestion);            
             ApexPages.standardController cont =  new ApexPages.StandardController(objConReqList[0]);
             //Initializing the page to set the parameters             
             PageReference myPage = Page.C3AP_Contract_Initiation;
             myPage.getParameters().put('affiliateId',objConReqList[0].C3AP_Affiliate__c);
             test.setCurrentPage(myPage);
             c3apObj = new c3APContractInititationController(cont);                    
             myPage.getParameters().put('activeQuestionId',c3apObj.lstSampleWrapper[0].question.Id);  
             c3apObj.insertContract();
             Test.StartTest();     
                 c3apObj.lstSampleWrapper[0].userSelection='false';  
                 c3apObj.getNextQuestion();
                 system.assertEquals(c3apObj.lstSampleWrapper[0].answer.C3AP_Answer__c,false); 
                 PageReference pgref=c3apObj.showContractDetails();  
                 System.assertNotEquals(pgref, null);  
                 List<SelectOption> listSec=c3apObj.getResponses();
                 system.assertEquals(listSec.isEmpty() ,false);
             Test.StopTest();       
         }    
    }
    
     public static testmethod void testc3APContractInititationController_ExisitingAnswersPresent(){
         User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
         System.runAs(u) {    
             //Test_C3AP_TestData_Utility.createApp();   
             createObject();
             sortCount=0;
             //This section creates test data for Affiliate Questions 
             C3AP_Affiliate_Questions__c firstQuestion = putdata(true,System.Label.C3AP_Question_Type_Introductory);        
             C3AP_Affiliate_Questions__c SecondQuestion = putdata(true,System.Label.C3AP_Question_Type_Introductory); 
             firstQuestion.C3AP_Next_Question_If_Yes__c = SecondQuestion.Id;      
             firstQuestion.C3AP_Next_Question_If_No__c = SecondQuestion.Id;   
             Test_C3AP_TestData_Utility.createAffQuesAttmnts(firstQuestion);   
             update firstQuestion;    
             C3AP_Affiliate_Questions__c thirdQuestion = putdata(true,System.Label.C3AP_Question_Type_Introductory);
             SecondQuestion.C3AP_Next_Question_If_Yes__c = thirdQuestion.Id;
             SecondQuestion.C3AP_Next_Question_If_No__c = thirdQuestion.Id;
             Test_C3AP_TestData_Utility.createAffQuesAttmnts(SecondQuestion);   
             update SecondQuestion;
             C3AP_Affiliate_Questions__c fourthQuestion = putdata(true,System.Label.C3AP_Question_Type_Introductory);
             thirdQuestion.C3AP_Next_Question_If_Yes__c = fourthQuestion.Id;
             thirdQuestion.C3AP_Next_Question_If_No__c = fourthQuestion.Id;
             //objConReqAns= Test_C3AP_TestData_Utility.createC3APContractAnswer(1)[0];      
             //moreInformationLink=System.Label.C3AP_More_Information;
             //objConReqAns.C3AP_Contract_Request__c = objConReqList[0].Id;
             //insert objConReqAns;
             
             //Initializing the Controller
             c3APContractInititationController.sampleWrapper wrapperObj= new
             c3APContractInititationController.sampleWrapper(new C3AP_Contract_Request_Answer__c(),
             firstQuestion,false,attachmentObj,fourthQuestion);            
             ApexPages.standardController cont =  new ApexPages.StandardController(objConReqList[0]);
             //Initializing the page to set the parameters             
             PageReference myPage = Page.C3AP_Contract_Initiation;
             myPage.getParameters().put('affiliateId',objConReqList[0].C3AP_Affiliate__c);             
             test.setCurrentPage(myPage);
             c3apObj = new c3APContractInititationController(cont);                    
             myPage.getParameters().put('activeQuestionId',c3apObj.lstSampleWrapper[0].question.Id); 
             c3apObj.lstSampleWrapper[0].answer.C3AP_Answer__c=true;     
             c3apObj.lstSampleWrapper[0].userSelection='true'; 
             PageReference pgref=c3apObj.showContractDetails();  
             C3AP_Contract_Request__c updatedContract = [Select Id,C3AP_Affiliate__c from C3AP_Contract_Request__c order by createddate desc limit 1];
             Test.StartTest();     
                ApexPages.standardController updatedCont =  new ApexPages.StandardController(updatedContract);
                //Initializing the page to set the parameters             
                PageReference updatedContractPage = Page.C3AP_Contract_Initiation;
                updatedContractPage.getParameters().put('affiliateId',updatedContract.C3AP_Affiliate__c);
                updatedContractPage.getParameters().put('contractId',updatedContract.Id);
                test.setCurrentPage(updatedContractPage);
                c3APContractInititationController updatedC3apObj = new c3APContractInititationController(updatedCont);           
                System.assertNotEquals(updatedC3apObj.existingAnswers.size(),0);
                updatedC3apObj.showContractDetails();
                System.assertEquals([Select Id from C3AP_Contract_Request_Answer__c where C3AP_Contract_Request__c= :updatedContract.Id and C3AP_Latest__c = true].size(),1);
             Test.StopTest();       
         }    
    }
     public static testmethod void codeBReakageTest(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
         System.runAs(u) {  
            Test.StartTest();     
                C3AP_Contract_Request__c newContractRequest = new C3AP_Contract_Request__c();               
                ApexPages.standardController updatedCont =  new ApexPages.StandardController(newContractRequest);
                //Initializing the page to set the parameters             
                PageReference updatedContractPage = Page.C3AP_Contract_Initiation;
                test.setCurrentPage(updatedContractPage);
                c3APContractInititationController updatedC3apObj = new c3APContractInititationController(updatedCont); 
                updatedC3apObj.insertContract();
                //System.assertEquals([Select Id from C3AP_Contract_Request_Answer__c where C3AP_Contract_Request__c= :updatedContract.Id and C3AP_Latest__c = true].size(),1);
             Test.StopTest();  
            
         }
     }
        
     public static C3AP_Affiliate_Questions__c putdata(Boolean input,String type){
        objAffQues=Test_C3AP_TestData_Utility.createC3APAffiliateQuestions(1)[0];
        objAffQues.C3AP_Affiliate__c=objConReqList[0].C3AP_Affiliate__c;
        objAffQues.C3AP_Sort_Order__c = sortCount++;
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

    
}