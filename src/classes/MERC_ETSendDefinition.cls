public with sharing class MERC_ETSendDefinition {
    public MERC_ETSendDefinition() {}

    public MERC_ETSendDefinition(String dataExtensionId,
                                 Boolean deduplicateByEmail,
                                 String description, Integer emailId,
                                 String key,
                                 String name,
                                 String emailSubject,
                                 String sendClassificationId,
                                 String senderProfileId) {
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
        this.sendClassificationId = sendClassificationId;
        this.senderProfileId = senderProfileId;
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
    public String sendClassificationId;
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
}