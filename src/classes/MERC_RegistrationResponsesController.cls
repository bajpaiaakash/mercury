/*
    Name: MERC_RegistrationResponsesController
    Created By: Kyle Thornton, Mavens Consulting
    Created Date: April 15, 2015
    Modified By:
    Modifed Date:
    Description: This class is a controller for the MERC_RegistrationResponses page. It consists of
                 A constructor that calls private helper methods. It also has two inner classes,
                 Question and Answer which facilitate reconciling Registration_Question_MERC__c,
                 Answer_MERC__c and Response_MERC__c records and displaying them properly on the page.

                When saving responses, all prior responses for the active meeting participant will
                be removed and new responses created.
*/
public with sharing class MERC_RegistrationResponsesController {

    public List<Question> questions        { get; private set; }
    public Boolean      initializationError { get; private set; } //if true, most of VF page won't render

    //static variables are available to Inner Classes
    public static String TEXT    { get { return Label.Registration_Questions_Text; }}
    public static String SINGLE   { get { return Label.Registration_Questions_Select_One; }}
    public static String MULTIPLE { get { return Label.Registration_Questions_Select_Many; }}

    public static Map<Id, List<Response_MERC__c>> questionIdToResponses { get; private set;}

    private String participantId;
    private String developerName;
    private Meeting_Participant_MERC__c participant;


    public MERC_RegistrationResponsesController() {
        initialize();
    }

    private void initialize() {
        //start true, set to false at the end of the constructor
        initializationError = true;
        questions          = new List<Question>();
        participantId      =  ApexPages.currentPage().getParameters().get('id');

        //must have a participant
        if (String.isBlank(participantId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Registration_Questions_No_Participant_Id));
            return;
        }

        //query for participant based on given Id
        try {
            participant = getParticipant(participantId);
        } catch (System.exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Registration_Questions_Invalid_Participant));
            return;
        }

        try {
            developerName = getDeveloperName(participant.RecordTypeId);
        } catch (exception ex){
            ApexPages.addMessages(ex);
        }

        //get all questions, answers and responses for this meeting
        //no need to wrap this in a try-catch as there are only two variables being passed in and by this point both MUST be valid
        List<Registration_Question_Merc__c> regQuestions = getQuestionsAnswersAndResponses(participant.Meeting_MERC__c, participant.Id);

        //create a mapping of questions to responses for this participant
        mapQustionIdsToResponses(regQuestions);

        //wrap the questions for use on the VF page and add to the questions list
        for (Registration_Question_MERC__c question : regQuestions) {
            questions.add(new Question(question));
        }

        initializationError = false;
    }

    //allow the user to escape the page without having to save
    public PageReference cancelForm() {
        return new PageReference('/' + participantId);
    }

    public PageReference saveResponses() {
        List<Response_MERC__c> responses = new List<Response_MERC__c>();

        //for each question, get the responses
        Boolean missingRequiredResponse = false;
        for (Question question : questions) {
            //reset styleClass
            question.styleClass = '';
            List<Response_MERC__c> questionResponses = question.getResponses();
            if (questionResponses.isEmpty()) {
                if (question.detail.Answer_Type_MERC__c == SINGLE || question.detail.Answer_Type_MERC__c == MULTIPLE) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.Registration_Questions_Answer_Required + ': ' + question.detail.Question_MERC__c));
                    missingRequiredResponse = true;
                    question.styleClass='highlight';
                }
            } else {
                responses.addAll(question.getResponses());
            }
        }

        if (missingRequiredResponse) {
            return null;
        }
        //Set a save point to roll back to in case of an error deleting or inserting responses
        System.savePoint savePoint = Database.setSavePoint();

        //remove all responses for the current participant for this meeting
        try {
            deleteResponses();
        } catch (System.Exception ex) {
            Database.rollback(savePoint);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Registration_Questions_Error_Deleting_Responses));
            return null;
        }

        //insert the new responses
        try {
            insert responses;
        } catch (System.Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Registration_Questions_Error_Inserting_Responses));
            Database.rollback(savePoint);
            return null;
        }

        return new PageReference('/' + participantId);
    }

    public PageReference clearResponses() {
        try {
            deleteResponses();
        } catch (System.exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Registration_Questions_Error_Deleting_Responses));
            return null;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Registration_Questions_Cleared_Responses));
        initialize();
        return null;
    }

    private void deleteResponses() {
        delete [SELECT Id
                FROM Response_MERC__c
                WHERE Meeting_Participant_MERC__c = :participantId];
    }

    public String getPageSubTitle() {
        return Label.Registration_Questions_Responses_For + ' ' + participant.Account_MERC__r.Name + ' (' + participant.Name + ')';
    }

    public String getPageTitle() {
        return  Schema.SObjectType.Meeting_MERC__c.fields.Name.getLabel() + ': ' + participant.Meeting_MERC__r.Name;
    }

    public String getClearResponseMessage() {
        return Label.Registration_Questions_Confirm_Delete + ' ' + participant.Account_MERC__r.Name + ' (' + participant.Name + ')';
    }

    private Meeting_Participant_MERC__c getParticipant(String participantId) {
        return  [SELECT Id,
                        Name,
                        Meeting_MERC__c,
                        Meeting_MERC__r.Name,
                        Account_MERC__r.Name,
                        RecordTypeId
                   FROM Meeting_Participant_MERC__c
                  WHERE Id = :participantId];
    }

    private String getDeveloperName(Id partRecordTypeId) {
        String result =  [SELECT DeveloperName 
                            FROM RecordType
                           WHERE Id = :partRecordTypeId LIMIT 1].DeveloperName;
        return result;
    }

    private List<Registration_Question_MERC__C> getQuestionsAnswersAndResponses(String meetingId, String participantId) {

        String recordTypeFilter;
        String soql = '';

        if (developerName == 'MERC_Consulting') {
            recordTypeFilter = 'Consulting_MERC__c = ';
        } else if (developerName == 'MERC_Delegate') {
            recordTypeFilter = 'Delegate_MERC__c = ';
        } else if (developerName == 'MERC_Individual_Sponsorship') {
            recordTypeFilter = 'Individual_Sponsorship_MERC__c = ';
        } else if (developerName == 'MERC_Service_Provider') {
            recordTypeFilter = 'Service_Provider_MERC__c = ';
        } else {
            recordTypeFilter = '';
        }

        soql += 'SELECT Id, ';
        soql += '       Meeting_MERC__c, ';
        soql += '       Answer_Type_MERC__c, ';
        soql += '       Order_Number_MERC__c, ';
        soql += '       Question_MERC__c, ';
        soql += '       (SELECT Id, ';
        soql += '               Answer_Text_MERC__c ';
        soql += '          FROM Answers__r ';
        soql += '       ORDER BY Order_Number_MERC__c), ';
        soql += '       (SELECT Id, ';
        soql += '               Answer_MERC__c, ';
        soql += '               Meeting_Participant_MERC__c, ';
        soql += '               Registration_Question_MERC__c, ';
        soql += '               Response_Text_MERC__c ';
        soql += '        FROM Responses__r ';
        soql += '       WHERE Meeting_Participant_MERC__c = \'' + participantId + '\') ';
        soql += '  FROM Registration_Question_MERC__C ';
        soql += ' WHERE Meeting_MERC__c = \'' + String.escapeSingleQuotes(meetingId) + '\' ';
        if(recordTypeFilter != '') {
            soql += '   AND ' + String.escapeSingleQuotes(recordTypeFilter) + 'TRUE ';
        }
        soql += ' ORDER BY Order_Number_MERC__c ';

        System.debug('#### soql statements = ' + soql);
        return Database.query(soql);
    }

    //Map of question ids to responses.
    private void mapQustionIdsToResponses(List<Registration_Question_MERC__c> questions){
        questionIdToResponses = new Map<Id, List<Response_MERC__c>>();
        for (Registration_Question_MERC__c question : questions) {
            for (Response_MERC__c response : question.Responses__r) {
                if (questionIdToResponses.containsKey(response.Registration_Question_MERC__c)) {
                    questionIdToResponses.get(response.Registration_Question_MERC__c).add(response);
                } else {
                    questionIdToResponses.put(response.Registration_Question_MERC__c, new List<Response_MERC__c>{response});
                }
            }
        }
    }


    public class Question {
        public Registration_Question_MERC__c detail  { get; set; }
        public String textAnswer    { get; set; } // for TEXT answer quesitons
        public Id selectedAnswerId  { get; set; } // for storing reponse id of SINGLE answer questions
        public List<Answer> answers { get; set; } // for SINGLE and MULTIPLE answer questions
        public String styleClass    { get; set; } // for styling the quesiton if necessary

        public Question(Registration_Question_MERC__c question) {
            this.detail = question;
            answers = new List<Answer>();

            if (question.Answer_Type_MERC__c == MERC_RegistrationResponsesController.TEXT) {
                if (MERC_RegistrationResponsesController.questionIdToResponses.containsKey(question.Id)) {
                    textAnswer = MERC_RegistrationResponsesController.questionIdToResponses.get(question.Id)[0].Response_Text_MERC__c;
                } else {
                    textAnswer = '';
                }
            } else {
                answers = wrapAnswersForQuestion(question);
                //for single type answers find the currently selected answer (if any) and set selectedAnswerId
                if (question.Answer_Type_MERC__c == MERC_RegistrationResponsesController.SINGLE) {
                    for (Answer answer : answers) {
                        if (answer.selected) {
                            selectedAnswerId = answer.detail.id;
                            break;
                        }
                    }
                }
            }
        }

        public List<SelectOption> getAnswerOptions() {
            List<SelectOption> options = new List<SelectOption>();
            for(Answer answer : answers) {
                options.add(new SelectOption(answer.detail.id, answer.getAnswerText()));
            }
            return options;
        }

        public List<Response_MERC__c> getResponses() {
            String participantId = ApexPages.currentPage().getParameters().get('id');
            List<Response_MERC__c> responses = new List<Response_MERC__c>();

            if (this.detail.Answer_Type_MERC__c == MERC_RegistrationResponsesController.TEXT) {
                if (String.isNotBlank(this.textAnswer)) {
                    responses.add(
                        new Response_MERC__c(
                            Registration_Question_MERC__c = this.detail.id,
                            Response_Text_MERC__c        = this.textAnswer,
                            Meeting_Participant_MERC__c   = participantId
                    ));
                }
            } else if (this.detail.Answer_Type_MERC__c == MERC_RegistrationResponsesController.SINGLE) {
                if (String.isNotBlank(this.selectedAnswerId)) {
                    responses.add(
                        new Response_MERC__c(
                            Registration_Question_MERC__c = this.detail.id,
                            Answer_MERC__c              = selectedAnswerId,
                            Meeting_Participant_MERC__c   = participantId
                    ));
                }
            } else if (this.detail.Answer_Type_MERC__c == MERC_RegistrationResponsesController.MULTIPLE) {
                for (Answer answer : answers) {
                    if (answer.selected) {
                        responses.add(
                            new Response_MERC__c(
                                Registration_Question_MERC__c = this.detail.id,
                                Answer_MERC__c              = answer.detail.id,
                                Meeting_Participant_MERC__c   = participantId
                        ));
                    }
                }
            }
            return responses;
        }

        private List<Answer> wrapAnswersForQuestion(Registration_Question_MERC__c question) {
            Map<Id, Response_MERC__c> answerIdToResponse = new Map<Id, Response_MERC__c>();
            List<Answer>              answers           = new List<Answer>();

            //map resonses to this question to the answers they are bound to
            for (Response_MERC__c response : question.Responses__r) {
                answerIdToResponse.put(response.Answer_MERC__c, response);
            }

            for (Answer_MERC__c answer : question.Answers__r) {
                if (answerIdToResponse.containsKey(answer.id)) {
                    //we have a response
                    answers.add( new Answer(answer, true));
                } else {
                    //create a basic answer with no information
                    answers.add( new Answer(answer));
                }
            }

            return answers;
        }
    }

    public class Answer {
        public Answer_MERC__c detail     { get; private set; }
        public Boolean      selected   { get; set; }

        public String getAnswerText() {
            return this.detail.Answer_Text_MERC__c;
        }

        public Answer(Answer_MERC__c answer) {
            this.detail  = answer;
            this.selected   = false;
        }

        public Answer(Answer_MERC__c answer, Boolean selected) {
            this.detail  = answer;
            this.selected   = selected;
        }
    }
}