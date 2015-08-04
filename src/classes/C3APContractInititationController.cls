/*
* @Name: ContractInititationController
* @Desciption: developed for the customized functionality of Contract Initiation and Pre-Defined introductory Questions
* @date Latest:Aug 26, 2014
* @author Ketan Prakash Singh
*/

public with sharing class C3APContractInititationController{

public list<Attachment> lstAttachmentOfMoreInfoQues = new list<Attachment>();
public list<sampleWrapper> lstSampleWrapper {get;set;} {lstSampleWrapper = new list<sampleWrapper>();}
public list<sampleWrapper> lstSampleWrapperAll {get;set;} {lstSampleWrapperAll = new list<sampleWrapper>();}
public list<sampleWrapper> lstSampleWrapperLegal {get;set;} {lstSampleWrapperLegal = new list<sampleWrapper>();}
public C3AP_Affiliate__c affiliate = new C3AP_Affiliate__c();
public C3AP_Contract_Request__c contractRequest { get; set; }
public List<C3AP_Contract_Request_Answer__c> existingAnswers = new List<C3AP_Contract_Request_Answer__c>();
public List<Id> existingAnswersIds = new List<Id>();
public Set<Id> setQuesIdWithMoreInfo = new Set<Id>();
public String affiliateId {get;set;}
public String contractId { get; set; }
public String informationText {get;set;}
public  boolean showLegalQues {get;set;}
public  boolean showInfoQues {get;set;}
public Map<Id,C3AP_Affiliate_Questions__c> questions = null;
public Map<Id,Attachment> mapMoreInfoQuesIdAttachmnt = new Map<Id,Attachment>();
public Boolean displayLocalText {get;set;}

private final String CONTRACT_INITIATION_URL = '/apex/C3AP_Contract_Initiation';
    /***********
        * Method name  : sampleWrapper
        * Description  : Wrapper class for yes/no response
        * Return Type  : None.
        * Parameters   : None.
    ***********/
    public class sampleWrapper{
        public C3AP_Contract_Request_Answer__c answer{get;set;} 
        public C3AP_Affiliate_Questions__c question{get;set;}
        public Boolean disable{get;set;}
        public attachment attachment{get;set;}
        public C3AP_Affiliate_Questions__c previousQuestion  {get; set;}
        public String userSelection {get; set;}
        public sampleWrapper(C3AP_Contract_Request_Answer__c answer, C3AP_Affiliate_Questions__c question,
            Boolean disable, Attachment attachment, C3AP_Affiliate_Questions__c previousQuestion){
            this.answer = answer;
            this.question = question;
            //at any time, only one question should have disable=true
            //this helps identify the question that hasn't been answered yet
            this.disable = disable;
            this.attachment = attachment;
            this.previousQuestion = previousQuestion;

            //Assign an appropriate value explicitly for the 
            //userSelection field which controls the selected
            //value on the front-end for the radio buttons
            if (answer.C3AP_Answer__c == null) {
                this.userSelection = '';
            } else if (answer.C3AP_Answer__c == True) {
                this.userSelection = 'True';
            } else if (answer.C3AP_Answer__c == False) {
                this.userSelection = 'False';
            }
        }
    }

    //For the amend functionality:
    //  if contractId exists, then this is definitely amend
    //  show all questions with their correct answers selected
    //  and let the user do the redo flow (should work automatically)

    public C3APContractInititationController(ApexPages.StandardController cont){
        if(ApexPages.currentPage().getParameters().containsKey('affiliateId')){
            affiliateId = ApexPages.currentPage().getParameters().get('affiliateId');
        }
        if (ApexPages.currentPage().getParameters().containsKey('contractId')) {
            contractId = ApexPages.currentPage().getParameters().get('contractId');
        }
        showLegalQues = false;
        showInfoQues = false;
        displayLocalText = false;
        List<C3AP_Affiliate_Questions__c> lstQuesSort1 = new List<C3AP_Affiliate_Questions__c>();

        if (contractId != null) {
            //Why do we need contractRequest object?
            //what operations do we hope to perform on it?
            // 1. Get answers so that we can show when updating answers
            // 2. update such answers and save them to the object

            existingAnswers = [SELECT c.id, c.Name, c.C3AP_Question__c, c.C3AP_Answer__c, c.C3AP_Contract_Request__c,c.C3AP_Latest__c 
                FROM C3AP_Contract_Request_Answer__c c WHERE c.C3AP_Contract_Request__c = :contractId 
                AND c.C3AP_Question__r.C3AP_Type__c = 'Introductory'
                AND c.C3AP_Latest__c = true ORDER BY c.C3AP_Question__r.C3AP_Sort_Order__c];
        }

        if(affiliateId != null){
            affiliate = [SELECT Id, Name, C3AP_Home_Page__c, C3AP_Local_Home_Page__c, Local_Language__c, Local_Language_ISO_Code__c 
                    FROM C3AP_Affiliate__c WHERE Id = :affiliateId Limit 1];
                             
            questions = new Map<Id,C3AP_Affiliate_Questions__c>(
                [SELECT q.C3AP_Affiliate__c,q.C3AP_Type__c, q.C3AP_Next_Question_If_No__c, 
                q.C3AP_Next_Question_If_Yes__c, q.C3AP_Question__c, q.C3AP_Sort_Order__c,
                q.C3AP_Is_Optional__c, q.C3AP_Controlling_Question__c, q.C3AP_Question_Locale__c, q.C3AP_More_Information__c 
                FROM C3AP_Affiliate_Questions__c q
                WHERE q.C3AP_Affiliate__c = :affiliateId ]
            );
        
            //To display the Question in English or Local language based on the Logged in Users's & Affiliate's Language 
            if(affiliate.Local_Language_ISO_Code__c != NULL && affiliate.Local_Language_ISO_Code__c != ''){
                if(UserInfo.getLanguage() == affiliate.Local_Language_ISO_Code__c && affiliate.Local_Language_ISO_Code__c != 'en_US'){
                    displayLocalText = true;
                }
                else{
                    displayLocalText = false;
                }
            }
        
            sampleWrapper wrappObjAll = null;
            for(C3AP_Affiliate_Questions__c question: questions.values()){
                if(question.C3AP_Sort_Order__c == 1){
                    lstQuesSort1.add(question);  
                }
                if(question.C3AP_More_Information__c == true){
                    Attachment attachment = [SELECT a.ParentId, a.Id FROM Attachment a where a.ParentId = :question.Id order by LastModifiedDate desc LIMIT 1];
                    mapMoreInfoQuesIdAttachmnt.put(attachment.ParentId, attachment);
                }
            }
            if (existingAnswers.size() > 0) {
                for (C3AP_Contract_Request_Answer__c answer: existingAnswers) {
                    existingAnswersIds.add(answer.Id);
                    lstSampleWrapper.add(
                        new sampleWrapper(answer, questions.get(answer.C3AP_Question__c), true, 
                            mapMoreInfoQuesIdAttachmnt.get(answer.C3AP_Question__c), null)
                    );
                }
                showLegalQues = true;
            } else {
                sampleWrapper wrappObj = null;
                for(C3AP_Affiliate_Questions__c ques: lstQuesSort1){
                    wrappObj = new sampleWrapper(new C3AP_Contract_Request_Answer__c(),ques,false,mapMoreInfoQuesIdAttachmnt.get(ques.Id), null);
                    wrappObj.userSelection = null;
                    lstSampleWrapper.add(wrappObj);
                }
            }
        }
    } 
    
  
    
    /* 
     * Method name : onLoad
     * Description :  This methods is called on page load to create a new Contract Request record
     * Param :  None
     * Returns :  None
    */

    
    public Id insertContract(){
        
        C3AP_Contract_Request__c conReqObj;
        try{            
            if(affiliateId != null){
                conReqObj = new C3AP_Contract_Request__c();
                conReqObj.C3AP_Affiliate__c = affiliateId;            
            }        
            insert conReqObj;            
        }
        catch(Exception e){
            System.debug('Error insert failed:'+e.getMessage());
            //String aId = [Select id from MICO_App__c where name=:System.Label.C3AP_Application_Name].id;               
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(   Error_Datetime__c= DateTime.Now(),
                                                                Error_Message__c= e.getMessage(),
                                                                Running_User__c = UserInfo.getUserId() ,
                                                                Stack_Trace__c = e.getStackTraceString(),
                                                                Additional_Information__c = 'Error insert failed: c3APContractInititationController - onLoad'
                                                               // App__c = aId 
                                                                );  
            insert errlog;
            return null;            
        }
        return conReqObj.Id;
    }
    
 
    
     /* 
     * Method name : getNextQuestion
     * Description :  This methods holds the logic for:
                        1. Generation of the next question 
                        2. Answer record creation and mapping with the Contract Request record along with looged in User as the response provider.
     * Param :  None
     * Returns :  None
    */
    
    public void getNextQuestion() {
        sampleWrapper wrappObj1 = null;
        showLegalQues = false;
        String activeQuestionId = System.currentPageReference().getParameters().get('activeQuestionId');
        
        List<sampleWrapper> lstSampleWrapperTemp = new List<sampleWrapper>();
        Integer index = 0, activeQuestionIndex;
    
        for (sampleWrapper sWrap: lstSampleWrapper) {
            sWrap.answer.C3AP_Answer__c = Boolean.valueOf(sWrap.userSelection);
            //Two possible question flows here:
            //1. The normal flow where the user keeps on answering questions
            //2. The "redo" flow where the user changes an earlier answer
            if (sWrap.question.Id == activeQuestionId) {
                //For both normal and redo flow, we need to figure out the next question

                //Set up next question
                C3AP_Affiliate_Questions__c nextQuestion;
                if (sWrap.answer.C3AP_Answer__c == True) {
                    nextQuestion = questions.get(sWrap.question.C3AP_Next_Question_If_Yes__c);
                } else if (sWrap.answer.C3AP_Answer__c == False) {
                    nextQuestion = questions.get(sWrap.question.C3AP_Next_Question_If_No__c);
                }

                //Add this question to the list for display
                if(nextQuestion.C3AP_Type__c == 'Introductory') {  
                    sampleWrapper wrap = new sampleWrapper(new C3AP_Contract_Request_Answer__c(), nextQuestion,
                        false, mapMoreInfoQuesIdAttachmnt.get(nextQuestion.Id), sWrap.question);
                    wrap.userSelection = null;
                    lstSampleWrapperTemp.add(wrap);
                }
                // If a question has Legal as its next question
                // means the end of the introductory questions
                // and we can proceed to the contract details page
                else if(nextQuestion.C3AP_Type__c == 'Legal') { 
                    showLegalQues = true;
                }
                // At the end of the process; show information if any
                else if(nextQuestion.C3AP_Type__c == 'Information') {
                    showInfoQues = true;
                    if(displayLocalText == true) {
                        informationText = nextQuestion.C3AP_Question_Locale__c;
                    }
                    else {
                        informationText = nextQuestion.C3AP_Question__c;
                    }
                }

                if (sWrap.disable) {
                    //Must be the redo flow, make note of this question's index
                    activeQuestionIndex = index;
                }
                
                sWrap.disable = true;
                break;
            }
            index++;
        }

        //If this is the redo flow and we have figured out the index 
        //of the question that was changed, remove any subsequent
        //questions from the list of questionanswer wrappers
        if (activeQuestionIndex != null) {
            for (Integer i=lstSampleWrapper.size()-1; i > activeQuestionIndex; i--) {
                lstSampleWrapper.remove(i);
            }
        }
        lstSampleWrapper.addAll(lstSampleWrapperTemp);
    }
  
    
     /* 
     * Method name : getResponses
     * Description :  Method to capture the YES/NO response for the respective questions
     * Param :  None
     * Returns :  List<SelectOption>
    */
    
    public List<SelectOption> getResponses() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('True',System.Label.C3AP_YES)); 
        options.add(new SelectOption('False',System.Label.C3AP_NO)); 
        return options; 
    }
    
    
    
    /* 
     * Method name : reset
     * Description :   Method holds the logic for Reset functionality along with proper redirection and new Contract Request record creation
     * Param :  None
     * Returns :  PageReference 
    */
    
    public PageReference reset() {
        String URL = CONTRACT_INITIATION_URL;        
        lstSampleWrapper.clear();
        URL = URL + '?' + (affiliateId != null ? '&affiliateId=' + affiliateId : '') + 
            (contractId != null ? '&contractId=' + contractId : '');
        pageReference pg =  new pageReference(URL );
        pg.setRedirect(true);
        return pg;
    }
    
   
    
    /* 
     * Method name : showContractDetails
     * Description : Methods for proceeding to Contract Request form
     * Param :  None
     * Returns :  PageReference 
    */
    public PageReference showContractDetails() {
            String URL;

            if (contractId == null) {
               contractId = insertContract();
            }

            if(contractId != null){
                List<C3AP_Contract_Request_Answer__c> answers = new List<C3AP_Contract_Request_Answer__c >();

                URL = '/apex/C3AP_Contract_Request_Form?contractId='+contractId+'&affiliateId='+affiliateId;
            
                //Collect the answers from the wrapper and insert
                for (sampleWrapper sWrap: lstSampleWrapper) {
                    C3AP_Contract_Request_Answer__c answer = new C3AP_Contract_Request_Answer__c();
                    answer.C3AP_Answer__c = sWrap.answer.C3AP_Answer__c ;
                    answer.C3AP_Question__c = sWrap.question.Id;
                    answer.C3AP_User__c = UserInfo.getUserId();
                    if (answer.C3AP_Contract_Request__c == null) {
                        answer.C3AP_Contract_Request__c = contractId;
                    }
                    answer.C3AP_Latest__c = true;
                    answers.add(answer);
                }
                try {
                    insert answers;
                }
                catch (Exception e) {
                    System.debug('Error insert failed:'+e.getMessage());                  
                    GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(   
                        Error_Datetime__c = DateTime.Now(),
                        Error_Message__c = e.getMessage(),
                        Running_User__c = UserInfo.getUserId() ,
                        Stack_Trace__c = e.getStackTraceString(),
                        Additional_Information__c = 'Error insert failed: c3APContractInititationController - processing'
                    );
                    insert errlog;
                }

                if (existingAnswers.size() > 0) {
                    //Fetch the saved batch of answers
                    List<C3AP_Contract_Request_Answer__c> existingAnswersList = 
                        [SELECT Id, C3AP_Latest__c FROM C3AP_Contract_Request_Answer__c WHERE Id in :existingAnswersIds];
                    //Loop through them and update the Latest flag
                    for(C3AP_Contract_Request_Answer__c existAns : existingAnswersList){
                        existAns.C3AP_Latest__c = false;
                    }
                    update existingAnswersList;
                }
            } else {
                URL = CONTRACT_INITIATION_URL + '?affiliateId='+affiliateId;
            }
            pageReference pg =  new pageReference(URL);
            pg.setRedirect(true);

            return pg;
    }
}