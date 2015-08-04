/*
* @Name: C3APLegalQuestionnaireController
* @Desciption: developed for the customized functionality of displaying the Legal Questions based on the answers given to the Introductory questions.
* @date Latest:Sep 09, 2014
* @author Ketan Prakash Singh
*/
public with sharing class C3APLegalQuestionnaireController{

public list<C3AP_Affiliate_Questions__c> lstQues {get;set;} {lstQues = new list<C3AP_Affiliate_Questions__c>();}
public list<sampleWrapper> lstSampleWrapperLegal {get;set;} {lstSampleWrapperLegal = new list<sampleWrapper>();}
public List<C3AP_Contract_Request_Answer__c> existingAnswers = new List<C3AP_Contract_Request_Answer__c >();
public List<Id> existingAnswersIds = new List<Id>();
public List<C3AP_Contract_Request_Answer__c> toUpdate = new List<C3AP_Contract_Request_Answer__c >();
public Map<Id,boolean> mapIntroQuesIdAns = new map<Id,boolean>();
public Map<Id,C3AP_Affiliate_Questions__c> mapAllQuestions = null;
public C3AP_Contract_Request__c contractRequest = new C3AP_Contract_Request__c();
public Map<Id,Attachment> mapMoreInfoQuesIdAttachmnt = new Map<Id,Attachment>();
public list<Attachment> lstAttachmentOfMoreInfoQues = new list<Attachment>();
public Set<Id> setQuesIdWithMoreInfo = new Set<Id>();
public C3AP_Affiliate__c affiliate = new C3AP_Affiliate__c();
public String contractId {get;set;}
public boolean legalQuesAnswered {get;set;}
public Boolean displayLocalText {get;set;}
public Integer size {get;set;}

/***********
        * Method name  : sampleWrapper
        * Description  : Wrapper class for yes/no response for questions along with boolean to make the responses disabled
        * Return Type  : None.
        * Parameters   : None.
***********/

    public class sampleWrapper{
        public C3AP_Contract_Request_Answer__c ansObj{get;set;} 
        public C3AP_Affiliate_Questions__c quesObj{get;set;}
        public boolean chkDisable{get;set;}
        public String moreInformationLink{get;set;}
        public attachment attachmentObj{get;set;}
        public String userSelection {get; set;}
                
        public sampleWrapper(C3AP_Contract_Request_Answer__c answer,C3AP_Affiliate_Questions__c quesObj2,boolean  chkDisable1, String moreInfoLink,attachment attachmentObj1){
            ansObj = answer;
            quesObj = quesObj2;
            chkDisable = chkDisable1;
            moreInformationLink = moreInfoLink;
            attachmentObj = attachmentObj1;                        
            if (answer.C3AP_Answer__c == True) {
                this.userSelection = 'True';
            } else if (answer.C3AP_Answer__c == False) {
                this.userSelection = 'False';
            }
        }
    }

    public C3APLegalQuestionnaireController(ApexPages.StandardController cont){
        if(ApexPages.currentPage().getParameters().containsKey('contractId')){
            contractId = ApexPages.currentPage().getParameters().get('contractId');
        }
        
        displayLocalText = false;
        legalQuesAnswered = false;
        List<C3AP_Affiliate_Questions__c> lstAllQuestions;
        
        if(contractId != null){
        
        contractRequest = [Select id, Name, OwnerId, C3AP_Affiliate__c, C3AP_Legal_Answered__c from C3AP_Contract_Request__c where id = :contractId Limit 1];
        
        affiliate = [Select id, Name, C3AP_Home_Page__c, C3AP_Local_Home_Page__c, Local_Language__c, Local_Language_ISO_Code__c 
                        from C3AP_Affiliate__c where id = :contractRequest.C3AP_Affiliate__c Limit 1];
       
        lstAllQuestions = new List<C3AP_Affiliate_Questions__c>(
            [SELECT q.C3AP_Affiliate__c, q.C3AP_Type__c, q.C3AP_Next_Question_If_No__c, q.C3AP_Next_Question_If_Yes__c, 
                q.C3AP_Question__c, q.C3AP_Sort_Order__c, q.C3AP_Legal_Required__c, q.C3AP_Is_Optional__c, 
                q.C3AP_Controlling_Question__c, q.C3AP_Question_Locale__c, q.C3AP_More_Information__c  
            FROM C3AP_Affiliate_Questions__c q
            WHERE q.C3AP_Affiliate__c = :contractRequest.C3AP_Affiliate__c AND q.C3AP_Type__c = 'Legal' 
            ORDER BY q.C3AP_Sort_Order__c]);
        }
        mapAllQuestions = new Map<Id, C3AP_Affiliate_Questions__c>(lstAllQuestions);

        //To display the Question in English or Local language based on the Logged in Users's & Affiliate's Language 
        //TODO: Move this to the utility class
        if(affiliate.Local_Language_ISO_Code__c != NULL && affiliate.Local_Language_ISO_Code__c != ''){
            if(UserInfo.getLanguage() == affiliate.Local_Language_ISO_Code__c && affiliate.Local_Language_ISO_Code__c != 'en_US'){
                displayLocalText = true;
            }
            else{
                displayLocalText = false;
            }
        }
        
        //To get all the  the Contract Request Answers associated with the current Contract record
        if(contractId != null){
            existingAnswers = [SELECT a.C3AP_Question__c, a.C3AP_Answer__c, a.C3AP_User__c, a.C3AP_Latest__c FROM C3AP_Contract_Request_Answer__c a 
                WHERE a.C3AP_Contract_Request__c = :contractId AND a.C3AP_Latest__c = true ORDER BY a.C3AP_Question__r.C3AP_Sort_Order__c];
        }
        for(C3AP_Contract_Request_Answer__c ans: existingAnswers){
            mapIntroQuesIdAns.put(ans.C3AP_Question__c,ans.C3AP_Answer__c);
        }
        
        for(C3AP_Affiliate_Questions__c ques:mapAllQuestions.values()) {
            if(ques.C3AP_More_Information__c == true){
                //setQuesIdWithMoreInfo.add(ques.Id);
                Attachment attachment = [SELECT a.ParentId, a.Id FROM Attachment a where a.ParentId = :ques.Id order by LastModifiedDate desc LIMIT 1];
                mapMoreInfoQuesIdAttachmnt.put(attachment.ParentId, attachment);
            }          
            
        }

        if (contractRequest.C3AP_Legal_Answered__c) {
            sampleWrapper wrap;
            for (C3AP_Contract_Request_Answer__c answer: existingAnswers) {
                existingAnswersIds.add(answer.Id);
                if (mapAllQuestions.get(answer.C3AP_Question__c) != null) {
                    wrap = new sampleWrapper(answer, mapAllQuestions.get(answer.C3AP_Question__c), true, 
                        System.Label.C3AP_More_Information, mapMoreInfoQuesIdAttachmnt.get(answer.C3AP_Question__c)
                    );
                    lstSampleWrapperLegal.add(wrap);
                }
            }
            if (wrap != null) {
                //Force the page to take the next action
                System.currentPageReference().getParameters().put('activeQuestionId', wrap.ansObj.C3AP_Question__c);
                getNextQuestion();
            }
        } else {
            //To add all the first Legal questions to the wrapper on load of the page
            sampleWrapper wrappObj = null;
            for(C3AP_Affiliate_Questions__c ques:lstAllQuestions){
                wrappObj = new sampleWrapper(new C3AP_Contract_Request_Answer__c(), ques, false, System.Label.C3AP_More_Information,
                    mapMoreInfoQuesIdAttachmnt.get(ques.Id));
                wrappObj.userSelection = null;
                lstSampleWrapperLegal.add(wrappObj);

                break;
            }     
        } 
    }
    
  
    
    /***********
        * Method name  : getNextQuestion
        * Description  : This methods holds the logic for:
                            1. Generation of the next question 
                            2. Answer record creation and mapping with the Contract Request record along with looged in User as the response provider.
        * Return Type  : None.
        * Parameters   : None.
***********/
    public void getNextQuestion() {
        List<sampleWrapper> lstSampleWrapperTemp = new List<sampleWrapper>();
        List<C3AP_Contract_Request_Answer__c> lstAnswerToLegal = new List<C3AP_Contract_Request_Answer__c >();
        String activeQuestionId = System.currentPageReference().getParameters().get('activeQuestionId');
        //Flag to denote if we are at the end of questions
        Boolean proceed;
        Integer index = 0, activeQuestionIndex;
        size = 0;
    
        for(sampleWrapper sWrap: lstSampleWrapperLegal){
            if (sWrap.quesObj.Id == activeQuestionId) {
                //Reinitialize the flag to false every time
                proceed = false;

                sWrap.ansObj.C3AP_Answer__c = Boolean.valueOf(sWrap.userSelection);

                //Set up next question
                C3AP_Affiliate_Questions__c nextQuestion;
                if (sWrap.ansObj.C3AP_Answer__c == True) {
                    nextQuestion = mapAllQuestions.get(sWrap.quesObj.C3AP_Next_Question_If_Yes__c);
                } else {
                    nextQuestion = mapAllQuestions.get(sWrap.quesObj.C3AP_Next_Question_If_No__c);
                }

                System.debug('--> nextQuestion: ' + nextQuestion);

                if (nextQuestion != null) {
                    if(nextQuestion.C3AP_Is_Optional__c == false || 
                        (nextQuestion.C3AP_Is_Optional__c == true && mapIntroQuesIdAns.get(nextQuestion.C3AP_Controlling_Question__c) == True)) {
                        sampleWrapper wrap = new sampleWrapper(new C3AP_Contract_Request_Answer__c(),nextQuestion,
                                false, System.Label.C3AP_More_Information, mapMoreInfoQuesIdAttachmnt.get(nextQuestion.Id));
                        wrap.userSelection = null;
                        lstSampleWrapperTemp.add(wrap);
                        proceed = true;
                    }
                }

                System.debug('--> size: ' + size);

                if(sWrap.chkDisable){
                    activeQuestionIndex = index;
                }
                sWrap.chkDisable = true;

                if (!proceed) {
                    size = 1;
                }
            }
            index++;
        }
        //If this is the redo flow and we have figured out the index 
        //of the question that was changed, remove any subsequent
        //questions from the list of questionanswer wrappers
        if (activeQuestionIndex != null) {
            for (Integer i=lstSampleWrapperLegal.size()-1; i > activeQuestionIndex; i--) {
                lstSampleWrapperLegal.remove(i);
            }
        }
        system.debug('@@@@@@@@@@@@@@@lstSampleWrapperLegal '+ lstSampleWrapperLegal);
        lstSampleWrapperLegal.addAll(lstSampleWrapperTemp);
    }
    
  
     
     /***********
        * Method name  : getResponses
        * Description  : Method to capture the YES/NO response for the respective questions
        * Return Type  : None.
        * Parameters   : List<SelectOption>
***********/
    
    public List<SelectOption> getResponses() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('True',System.Label.C3AP_YES)); 
        options.add(new SelectOption('False',System.Label.C3AP_NO)); 
        return options; 
    }
    
    
     
      /***********
        * Method name  : cancelLegalQues
        * Description  :  Method holds the logic for Cancel functionality along with proper redirection
        * Return Type  : None.
        * Parameters   : PageReference 
***********/
    
    public PageReference cancelLegalQues() {
        String URL = '/apex/C3AP_Legal_Questionnaire';
        
        if(contractId != null){
        URL = URL + '?contractId='+contractId;     
        }
        pageReference pg =  new pageReference(URL );
        pg.setRedirect(true);
        return pg;
    }
    
  
    
    
      /***********
        * Method name  : showContractDetails
        * Description  :  Methods for proceeding to Contract Request form
        * Return Type  : None.
        * Parameters   : PageReference 
***********/
    
    public PageReference showContractDetails() {
        List<C3AP_Contract_Request_Answer__c> lstAnswerLegal = new List<C3AP_Contract_Request_Answer__c >();
        
        for(sampleWrapper sWrap:lstSampleWrapperLegal){
            //add the answer object
            C3AP_Contract_Request_Answer__c answer = new C3AP_Contract_Request_Answer__c();
            answer.C3AP_Answer__c = sWrap.ansObj.C3AP_Answer__c ;
            answer.C3AP_Question__c = sWrap.quesObj.Id;
            answer.C3AP_User__c = UserInfo.getUserId();
            if (answer.C3AP_Contract_Request__c == null) {
                answer.C3AP_Contract_Request__c = contractId;
            }
            answer.C3AP_Latest__c = true;
            lstAnswerLegal.add(answer);
        }

        try{
            insert lstAnswerLegal;
        }
        catch(Exception e){
            System.debug('Error insert failed:'+e.getMessage());
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(   
                Error_Datetime__c = DateTime.Now(),
                Error_Message__c = e.getMessage(),
                Running_User__c = UserInfo.getUserId() ,
                Stack_Trace__c = e.getStackTraceString(),
                Additional_Information__c = 'Error while inserting Legal question answers: C3APLegalQuestionnaireController - showContractDetails'
            );  
            insert errlog;
        }

        try {
            //Insert the legal flags
            contractRequest.C3AP_Legal_Answered__c = true;

            update contractRequest;
        } catch (Exception e) {
            System.debug('Updating Contract Request Legal_Answered flag failed: ' + e.getMessage());
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(   
                Error_Datetime__c = DateTime.Now(),
                Error_Message__c = e.getMessage(),
                Running_User__c = UserInfo.getUserId() ,
                Stack_Trace__c = e.getStackTraceString(),
                Additional_Information__c = 'Error while updating Legal flag values: C3APLegalQuestionnaireController - showContractDetails'
            );  
            insert errlog;
        }

        if (existingAnswers.size() > 0) {
            List<C3AP_Contract_Request_Answer__c> existingAnswersList = 
                        [SELECT Id, C3AP_Latest__c FROM C3AP_Contract_Request_Answer__c WHERE Id in :existingAnswersIds and C3AP_Question_Type__c='Legal'];
            //Loop through them and update the Latest flag
            for(C3AP_Contract_Request_Answer__c existAns : existingAnswersList){
                existAns.C3AP_Latest__c = false;
            }
            update existingAnswersList;
        }

        String URL = '/apex/C3AP_Contract_Request_Form';
        if(contractId != null){
            URL = URL + '?contractId='+contractId;
        }
        pageReference pg =  new pageReference(URL );
        pg.setRedirect(true);
        return pg;
    }
}