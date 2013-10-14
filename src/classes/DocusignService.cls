public with sharing class DocusignService {

	String username;
	String password;
	String integratorKey;
	String accountId;
	String baseUrl = 'https://demo.docusign.net/restapi/v2/';
    String boundaryName = 'MYBOUNDARY';
    String boundaryMarker = '--'+boundaryName;
    String boundaryMarkerEnd = '--'+boundaryName+'--';
	public LoginInformation loginInfo { get; private set; }

	public DocusignService() {
    	Docusign_Settings_EVNT__c settings = Docusign_Settings_EVNT__c.getValues('default');
		this.username 		= settings.Username_EVNT_MVN__c;
		this.password 		= settings.Password_EVNT_MVN__c;
		this.integratorKey 	= settings.Integrator_Key_EVNT_MVN__c;
		this.accountId 		= settings.Account_ID_EVNT_MVN__c;
	}

    String authHeader { 
    	get {
	        //we're using xml here because the docusign api doesn't like when we send creds via json
	        return  '<DocuSignCredentials>'+
	        			'<Username>'+this.username+'</Username>'+
	        			'<Password>'+this.password+'</Password>'+
	                    '<IntegratorKey>'+this.integratorKey+'</IntegratorKey>'+
	                '</DocuSignCredentials>';
	    }
    }

    // void parseResponse(String responseBody, String type) {
    // 	JSONParser parse = JSON.createParser(responseBody);
    // 	EnvResponse envstat = (EnvResponse)parse.readValueAs(EnvResponse.class);
    // }

    public void login() {
    	Http httpProtocol = new Http();
    	HttpRequest request = new HttpRequest();
    	String endpoint = this.baseUrl + 'login_information';
		request.setEndPoint(endpoint);
		request.setMethod('GET');
		request.setHeader('Content-Type', 'application/json'); 
		request.setHeader('Accept', 'application/json');
		request.setHeader('X-DocuSign-Authentication', this.authHeader);
		HttpResponse response1 = httpProtocol.send(request);
		JSONParser parser = JSON.createParser(response1.getBody());
		this.loginInfo = (LoginInformation)parser.readValueAs(LoginInformation.class);
    }
    
    public EnvelopeResponse requestSignature(List<RequiredSigner> requiredSigners, String pdfBytes) {
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = this.baseUrl + 'accounts/' + this.accountId + '/envelopes';
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'multipart/form-data; boundary=MYBOUNDARY'); 
        request.setHeader('Accept', 'application/json');
        request.setHeader('X-DocuSign-Authentication', this.authHeader);

        String documentId = '1';
        String fileName = 'contract.pdf';

        String postBody = '';
        postBody += boundaryMarker;
        postBody += lineBreak;
        postBody += 'Content-Type: application/json';
        postBody += lineBreak;
        postBody += 'Content-Disposition: form-data';
        postBody += lineBreak;
        postBody += lineBreak;
        postBody += getEnvelope(requiredSigners);
        postBody += lineBreak;
        postBody += boundaryMarker;
        postBody += lineBreak;
        postBody += 'Content-Type: application/pdf';
        postBody += lineBreak;
        postBody += 'Content-Disposition: file; filename="'+fileName+'"; documentid='+documentId;
        postBody += lineBreak;
        postBody += 'Content-Transfer-Encoding: base64';
        postBody += lineBreak;
        postBody += lineBreak;
        postBody += pdfBytes;
        postBody += lineBreak;
        postBody += lineBreak;
        postBody += boundaryMarkerEnd;
        postBody += lineBreak;
        postBody += lineBreak;

        system.debug(postBody);
        
        request.setBody(postBody);
        HttpResponse response = httpProtocol.send(request);
        String responseBody = response.getBody();
        System.debug('response =>'+responseBody);
        
        JSONParser parser = JSON.createParser(responseBody);
        EnvelopeResponse envelopeStatus = (EnvelopeResponse)parser.readValueAs(EnvelopeResponse.class);
        system.debug(envelopeStatus);
        return envelopeStatus;
    }

    String lineBreak {
        get {
            return '\r\n';
        }
    }

    String getEnvelope(List<RequiredSigner> requiredSigners) {
        //set up documents to be signed
        Document d = new Document();
        d.name = 'contract.pdf';
        d.documentId = '1';
        d.order = '1';
        List<Document> docs = new List<Document>();
        docs.add(d);

        //set location(s) for signature
        List<SignHereTab> sts = new List<SignHereTab>{ new SignHereTab('1', '1', '1', '1') };
        Tab t = new Tab();
        t.signHereTabs = sts;

        List<Signer> signers = new List<Signer>();
        
        for (RequiredSigner rs : requiredSigners) {
            //add signers
            Signer s = new Signer(rs.acc.PersonEmail, rs.acc.Name, String.valueOf(rs.order), String.valueOf(rs.order));
            s.tabs = t;
            signers.add(s);
        }

        Recipient r = new Recipient();
        r.signers = signers;

        Envelope e = new Envelope();
        e.status = 'sent';
        e.emailBlurb = 'hi';
        e.emailSubject = 'hi there';
        e.documents = docs;
        e.recipients = r;

        String envelopeJson = JSON.serializePretty(e);
        //system.debug(envelopeJson);
        return envelopeJson;
    }

    public class LoginInformation {
    	public List<LoginAccount> loginAccounts;
    }

    public class LoginAccount {
    	public String name;
    	public String accountId;
    	public String baseUrl;
    	public String isDefault;
    	public String userName;
    	public String userId;
    	public String email;
    	public String siteDescription;
    	public LoginAccount(String name, String accountId, String baseUrl, String isDefault, String userName, String userId, String email, String sd) {
    	    this.name = name;
    	    this.accountId = accountId;
    	    this.baseUrl = baseUrl;
    	    this.isDefault = isDefault;
    	    this.userName = userName;
    	    this.userId = userId;
    	    this.email = email;
    	    this.siteDescription = sd;     
    	}
    }

    public class Envelope {
        public String status;
        public String emailBlurb;
        public String emailSubject;
        public List<Document> documents;
        public Recipient recipients;
    }

    public class Document {
        public String name;
        public String documentId;
        public String order;
    }

    public class Recipient {
        public List<Signer> signers;
    }

    public class RequiredSigner {
        public Account acc;
        public Integer order;
    }
    
    public class Signer {
        public String email;
        public String name;
        public String recipientId;
        public String routingOrder;
        public Tab tabs;
        
        public Signer(String emailAddr, String nam, String recpId, String routId) {
            email = emailAddr;
            name = nam;
            recipientId = recpId;
            routingOrder = routId;      
        }   
    }

    public class Tab {
        public List<SignHereTab> signHereTabs;
    }

    public class SignHereTab {
        public String xPosition;
        public String yPosition;
        public String documentId;
        public String pageNumber;
        
        public SignHereTab(String x, String y, String id, String pn) {
            xPosition = x;
            yPosition = y;
            documentid = id;
            pageNumber = pn;
        }

    }
    
    public class EnvelopeResponse {
        public String envelopeId;
        public String status;
        public String statusDateTime;
        public String uri;
    }
}