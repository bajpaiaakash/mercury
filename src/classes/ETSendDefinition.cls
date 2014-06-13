public with sharing class ETSendDefinition {
    public ETSendDefinition() {}

    public ETSendDefinition(String dataExtensionId, Boolean deduplicateByEmail, String description, Integer emailId, String key, String name, String emailSubject) {
        this.dataExtensionId = dataExtensionId;
        this.deduplicateByEmail = deduplicateByEmail;
        this.description = description;
        this.emailId = emailId;
        this.isMultipart = true;
        this.isWrapped = true;
        this.key = key;
        this.name = name;
        this.type = 'GENERICEXTENSIONSEND';
        this.emailSubject = emailSubject;
        //todo: add
        //this.senderProfileId = senderProfileId;
    }

    public String dataExtensionId;
    public Boolean deduplicateByEmail;
    public String description;
    public Integer emailId;
    public Boolean isMultipart;
    public Boolean isWrapped;
    public String key;
    public String name;
    public String type;
    public String emailSubject;
    public String senderProfileId;

    public class CreateResponse {
        public String id;
    }

    public class StartResponse {
        public String id;
        public String statusMessage;
        public String jobId;
        public String clientId;
    }

    public class CheckStatusResponse {
        public String id;
        public String sendStatus;
        public String jobId;
        public String clientId;
    }

    public class SenderProfileCreate {
        public String key { get; set; }
        public String profileName { get; set; }
        public String description { get; set; }
        public String fromName { get; set; }
        public String fromEmail { get; set; }

        public SenderProfileCreate(String fromName, String fromEmail)
        {
            String key = 'SFDCLilly' + datetime.now().getTime();
            this.key = key;
            this.profileName = key;
            this.description = 'Default sender policy used for the SFDC Lilly Integration';
            this.fromName = fromName;
            this.fromEmail = fromEmail;
        }
    }

    public class CreateSenderProfileResponse{
        public String id;
    }
}