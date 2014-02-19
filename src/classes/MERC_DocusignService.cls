/**
 * @author Joseph Ferraro
 *
 * Apex wrapper for Docusign API
 */

public with sharing class MERC_DocusignService {

	String username;
	String password;
	String integratorKey;
	String accountId;
	String baseUrl = 'https://demo.docusign.net/restapi/v2/'; //todo: custom setting
    String boundaryName = 'MYBOUNDARY';
    String boundaryMarker = '--'+boundaryName;
    String boundaryMarkerEnd = '--'+boundaryName+'--';
    String hcpSignatureAnchorString = '[DOCUSIGN-HCP-SIGN]';
    String lillySignatureAnchorString = '[DOCUSIGN-LILLY-SIGN]'; //todo: custom setting

    //String signatureAnchorString = 'THIS-WILL-NOT-BE-FOUND'; //for testing only
	public LoginInformation loginInfo { get; private set; }

	public MERC_DocusignService() {
    	Docusign_Settings_MERC__c settings = Docusign_Settings_MERC__c.getValues('default');
		this.username 		= settings.Username_MERC__c;
		this.password 		= settings.Password_MERC__c;
		this.integratorKey 	= settings.Integrator_Key_MERC__c;
		this.accountId 		= settings.Account_ID_MERC__c;
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
        return requestSignature(requiredSigners, pdfBytes, false);
    }

    public TagAndSendResponse getTagAndSendUrl(EnvelopeResponse r, String returnUrl) {
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = this.baseUrl + 'accounts/' + this.accountId + '/envelopes/'+r.envelopeId+'/views/sender';
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json'); 
        request.setHeader('Accept', 'application/json');
        request.setHeader('X-DocuSign-Authentication', this.authHeader);
        request.setBody('{ "returnUrl" : "'+returnUrl+'" }');

        HttpResponse response = httpProtocol.send(request);
        String responseBody = response.getBody();
        System.debug('response =>'+responseBody);
        
        JSONParser parser = JSON.createParser(responseBody);
        TagAndSendResponse tasResponse = (TagAndSendResponse)parser.readValueAs(TagAndSendResponse.class);
        system.debug(tasResponse);
        return tasResponse;
    }

    public EnvelopeResponse requestSignature(List<RequiredSigner> requiredSigners, String pdfBytes, Boolean isDraft) {
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
        postBody += getEnvelope(requiredSigners, isDraft);
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

    String getEnvelope(List<RequiredSigner> requiredSigners, Boolean isDraft) {
        //set up documents to be signed
        Document d = new Document();
        d.name = 'contract.pdf';
        d.documentId = '1';
        d.order = '1';
        List<Document> docs = new List<Document>();
        docs.add(d);

        //set location(s) for Lilly signature
        List<SignHereTab> lillySignHereTabs = new List<SignHereTab> { 
            new SignHereTab(this.lillySignatureAnchorString, '0', '10', '1') 
        };
        Tab lillyTab = new Tab();
        lillyTab.signHereTabs = lillySignHereTabs;

        //set location(s) for HCP signature
        List<SignHereTab> hcpSignHereTabs = new List<SignHereTab>{ 
            new SignHereTab(this.hcpSignatureAnchorString, '0', '10', '2') 
        };
        Tab hcpTab = new Tab();
        hcpTab.signHereTabs = hcpSignHereTabs;

       
        
        List<Signer> signers = new List<Signer>();
        
        for (RequiredSigner rs : requiredSigners) {
            //add signers
            Signer s = new Signer(rs.acc.PersonEmail, rs.acc.Name, String.valueOf(rs.order), String.valueOf(rs.order));
            if (rs.isLilly) {
                if (!isDraft) 
                    s.tabs = lillyTab;
            } else {
                if (!isDraft) 
                    s.tabs = hcpTab;
            }
            signers.add(s);
        }

        Recipient r = new Recipient();
        r.signers = signers;

        Envelope e = new Envelope();
        e.status = (isDraft) ? 'created' : 'sent';
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
        public Boolean isLilly;
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
        public String documentId;
        public String anchorString; //example: "<--DOCUSIGN SIGNATURE MARKER-->"
        public String anchorXOffset; //example: "1"
        public String anchorYOffset; //example: "0"
        public String anchorIgnoreIfNotPresent; //if "false", error thrown when it cant find anchorstring
        public String anchorUnits; //example: "inches", "pixels", "mms", "cms"

        public SignHereTab(String anchor, String x, String y, String id) {
            documentid = id;
            anchorString = anchor;
            anchorXOffset = x;
            anchorYOffset = y;
            anchorIgnoreIfNotPresent = 'false';
            anchorUnits = 'pixels';
        }

    }

    public class TagAndSendResponse {
        public String url;
    }
    
    public class EnvelopeResponse {
        public String envelopeId;
        public String status;
        public String statusDateTime;
        public String uri;
        public String errorCode;
        public String message;
    }
}