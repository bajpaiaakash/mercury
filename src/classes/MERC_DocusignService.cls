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
	String baseUrl;
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
        this.baseUrl        = settings.Server_Endpoint_MERC__c;
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

    private HttpRequest getRequest(String method, String endpoint) {
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('X-DocuSign-Authentication', this.authHeader);
        request.setEndpoint(endpoint);
        return request;
    }

    public void login() {
    	Http httpProtocol = new Http();
        String endpoint = this.baseUrl + 'login_information';
    	HttpRequest request = getRequest('GET', endpoint);
		HttpResponse response = httpProtocol.send(request);
		JSONParser parser = JSON.createParser(response.getBody());

        if (response.getStatusCode() < 300) {
            this.loginInfo = (LoginInformation)parser.readValueAs(LoginInformation.class);
        } else {
            DocusignServiceError error = (DocusignServiceError)parser.readValueAs(DocusignServiceError.class);
            throw new DocusignServiceException(error.errorCode, error.message);
        }
    }

    public EnvelopeResponse requestSignature(List<RequiredSigner> requiredSigners, String pdfBytes) {
        return requestSignature(requiredSigners, pdfBytes, false);
    }

    public EnvelopeDetailResponse getEnvelopeDetail(String envelopeId) {
        Http httpProtocol = new Http();
        String endpoint = this.baseUrl + 'accounts/' + this.accountId + '/envelopes/'+envelopeId;
        HttpRequest request = getRequest('GET', endpoint);

        HttpResponse response = httpProtocol.send(request);
        String responseBody = response.getBody();
        System.debug('EnvelopeDetailResponse =>'+responseBody);
        JSONParser parser = JSON.createParser(responseBody);
        if (response.getStatusCode() < 300) {
            EnvelopeDetailResponse tasResponse = (EnvelopeDetailResponse)parser.readValueAs(EnvelopeDetailResponse.class);
            system.debug(tasResponse);
            return tasResponse;
        } else {
            DocusignServiceError error = (DocusignServiceError)parser.readValueAs(DocusignServiceError.class);
            throw new DocusignServiceException(error.errorCode, error.message);
        }
    }

    public Boolean deleteSigner(String envelopeId, Signer signer) {
        Http httpProtocol = new Http();
        String endpoint = this.baseUrl + 'accounts/' + this.accountId + '/envelopes/'+envelopeId+'/recipients';
        HttpRequest request = getRequest('DELETE', endpoint);
        request.setBody('{ "signers" : [{ "recipientId" : "'+signer.recipientId+'" }] }');

        HttpResponse response = httpProtocol.send(request);
        String responseBody = response.getBody();
        System.debug('deleteSignerResponse =>'+responseBody);
        JSONParser parser = JSON.createParser(responseBody);

        if (response.getStatusCode() == 200) {
            return true;
        } else {
            DocusignServiceError error = (DocusignServiceError)parser.readValueAs(DocusignServiceError.class);
            throw new DocusignServiceException(error.errorCode, error.message);
        }
    }

    public Boolean updateSigner(String envelopeId, Signer signer) {
        Http httpProtocol = new Http();
        String endpoint = this.baseUrl + 'accounts/' + this.accountId + '/envelopes/'+envelopeId+'/recipients';
        HttpRequest request = getRequest('PUT', endpoint);
        request.setBody('{ "signers" : [{ "recipientId" : "'+signer.recipientId+'", "email" : "'+signer.email+'", "name" : "'+signer.name+'" }] }');

        HttpResponse response = httpProtocol.send(request);
        String responseBody = response.getBody();
        System.debug('deleteSignerResponse =>'+responseBody);
        JSONParser parser = JSON.createParser(responseBody);

        if (response.getStatusCode() == 200) {
            return true;
        } else {
            DocusignServiceError error = (DocusignServiceError)parser.readValueAs(DocusignServiceError.class);
            throw new DocusignServiceException(error.errorCode, error.message);
        }
    }

    public List<Signer> addSigner(String envelopeId, String signerName, String signerEmail, Boolean isRemote, Integer routingOrder, Tab t) {
        Http httpProtocol = new Http();
        String endpoint = this.baseUrl + 'accounts/' + this.accountId + '/envelopes/'+envelopeId+'/recipients';
        HttpRequest request = getRequest('POST', endpoint);

        Signer s;
        if (!isRemote) {
            s = new Signer(signerEmail, signerName, String.valueOf(routingOrder), String.valueOf(routingOrder));
        } else {
            s = new Signer(signerEmail, signerName, String.valueOf(routingOrder), String.valueOf(routingOrder), MERC_Util.generateRandomString(20));
        }

        if (t != null)
            s.tabs = t;

        List<Signer> signers = new List<Signer>();
        signers.add(s);

        Recipient r = new Recipient();
        r.signers = signers;

        System.debug('adding signer with payload =>'+r);

        String jsonPayload = JSON.serializePretty(r);
        //String jsonPayload = '{"signers":'+signersPayload+'}';
        request.setBody(jsonPayload);

        HttpResponse response = httpProtocol.send(request);
        String responseBody = response.getBody();
        System.debug('addSignerResponse =>'+responseBody);
        JSONParser parser = JSON.createParser(responseBody);

        if (response.getStatusCode() < 300) {
            Recipient recipientResponse = (Recipient)parser.readValueAs(Recipient.class);
            system.debug(recipientResponse);
            return recipientResponse.signers;
        } else {
            DocusignServiceError error = (DocusignServiceError)parser.readValueAs(DocusignServiceError.class);
            throw new DocusignServiceException(error.errorCode, error.message);
        }
    }

    public List<Signer> addSigner(String envelopeId, String accountId, Boolean isRemote, Integer routingOrder) {
        return addSigner(envelopeId, accountId, isRemote, routingOrder, null);
    }

    public List<Signer> addSigner(String envelopeId, String accountId, Boolean isRemote, Integer routingOrder, Tab t) {
        Account a = [SELECT PersonEmail, Name FROM Account WHERE ID = :accountId];
        return addSigner(envelopeId, a.Name, a.PersonEmail, isRemote, routingOrder, t);
    }

    public EnvelopeRecipientDetailResponse getEnvelopeRecipientDetails(String envelopeId) {
        Http httpProtocol = new Http();
        String endpoint = this.baseUrl + 'accounts/' + this.accountId + '/envelopes/'+envelopeId+'/recipients';
        HttpRequest request = getRequest('GET', endpoint);

        HttpResponse response = httpProtocol.send(request);
        String responseBody = response.getBody();
        System.debug('EnvelopeRecipientDetailResponse =>'+responseBody);
        JSONParser parser = JSON.createParser(responseBody);

        if (response.getStatusCode() < 300) {
            EnvelopeRecipientDetailResponse tasResponse = (EnvelopeRecipientDetailResponse)parser.readValueAs(EnvelopeRecipientDetailResponse.class);
            system.debug(tasResponse);
            return tasResponse;
        } else {
            DocusignServiceError error = (DocusignServiceError)parser.readValueAs(DocusignServiceError.class);
            throw new DocusignServiceException(error.errorCode, error.message);
        }
    }

    public TabResponse getTabsForRecipient(String envelopeId, String recipientId) {
        Http httpProtocol = new Http();
        String endpoint = this.baseUrl + 'accounts/' + this.accountId + '/envelopes/'+envelopeId+'/recipients/'+recipientId+'/tabs';
        HttpRequest request = getRequest('GET', endpoint);

        HttpResponse response = httpProtocol.send(request);
        String responseBody = response.getBody();
        System.debug('Tab response =>'+responseBody);
        JSONParser parser = JSON.createParser(responseBody);
        if (response.getStatusCode() < 300) {
            TabResponse tr = (TabResponse)parser.readValueAs(TabResponse.class);
            system.debug(tr);
            return tr;
        } else {
            DocusignServiceError error = (DocusignServiceError)parser.readValueAs(DocusignServiceError.class);
            throw new DocusignServiceException(error.errorCode, error.message);
        }

    }

    public TagAndSendResponse getTagAndSendUrl(EnvelopeResponse r, String returnUrl) {
        Http httpProtocol = new Http();
        String endpoint = this.baseUrl + 'accounts/' + this.accountId + '/envelopes/'+r.envelopeId+'/views/sender';
        HttpRequest request = getRequest('POST', endpoint);
        request.setBody('{ "returnUrl" : "'+returnUrl+'" }');

        HttpResponse response = httpProtocol.send(request);
        String responseBody = response.getBody();
        System.debug('response =>'+responseBody);
        JSONParser parser = JSON.createParser(responseBody);

        if (response.getStatusCode() < 300) {
            TagAndSendResponse tasResponse = (TagAndSendResponse)parser.readValueAs(TagAndSendResponse.class);
            system.debug(tasResponse);
            return tasResponse;
        } else {
            DocusignServiceError error = (DocusignServiceError)parser.readValueAs(DocusignServiceError.class);
            throw new DocusignServiceException(error.errorCode, error.message);
        }
    }

    public EmbeddedSignResponse getEmbeddedSignUrl(String envelopeId, Signer signer, String returnUrl) {
        Http httpProtocol = new Http();
        String endpoint = this.baseUrl + 'accounts/' + this.accountId + '/envelopes/'+envelopeId+'/views/recipient';
        HttpRequest request = getRequest('POST', endpoint);
        request.setBody('{ "returnUrl" : "'+returnUrl+'", "clientUserId" : "'+signer.clientUserId+'", "userName" : "'+signer.name+'", "email" : "'+signer.email+'", "AuthenticationMethod" : "None" }');

        HttpResponse response = httpProtocol.send(request);
        String responseBody = response.getBody();
        System.debug('EmbeddedSignResponse =>'+responseBody);
        JSONParser parser = JSON.createParser(responseBody);

        if (response.getStatusCode() < 300) {
            EmbeddedSignResponse tasResponse = (EmbeddedSignResponse)parser.readValueAs(EmbeddedSignResponse.class);
            system.debug(tasResponse);
            return tasResponse;
        } else {
            DocusignServiceError error = (DocusignServiceError)parser.readValueAs(DocusignServiceError.class);
            throw new DocusignServiceException(error.errorCode, error.message);
        }
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
        postBody += 'Content-Type: application/json; charset=utf-8';
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

        if (response.getStatusCode() < 300) {
            EnvelopeResponse envelopeStatus = (EnvelopeResponse)parser.readValueAs(EnvelopeResponse.class);
            system.debug(envelopeStatus);
            return envelopeStatus;
        } else {
            DocusignServiceError error = (DocusignServiceError)parser.readValueAs(DocusignServiceError.class);
            throw new DocusignServiceException(error.errorCode, error.message);
        }
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
            new SignHereTab(this.hcpSignatureAnchorString, '0', '10', '2')  //todo: do we need to use '1' for the document id??
        };
        Tab hcpTab = new Tab();
        hcpTab.signHereTabs = hcpSignHereTabs;



        List<Signer> signers = new List<Signer>();

        for (RequiredSigner rs : requiredSigners) {
            //add signers
            Signer s;
            if (rs.isLilly) {
                s = new Signer(rs.acc.PersonEmail, rs.acc.Name, String.valueOf(rs.order), String.valueOf(rs.order));
                if (!isDraft)
                    s.tabs = lillyTab;
            } else {
                //s = new Signer(rs.acc.PersonEmail, rs.acc.Name, String.valueOf(rs.order), String.valueOf(rs.order), 'hcp-'+MERC_Util.generateRandomString(20)); //TODO: if/when we decide to create HCP as embedded signer, we need to use this instantiation
                s = new Signer(rs.acc.PersonEmail, rs.acc.Name, String.valueOf(rs.order), String.valueOf(rs.order));
                if (!isDraft)
                    s.tabs = hcpTab;
            }
            signers.add(s);
        }

        Recipient r = new Recipient();
        r.signers = signers;

        Envelope e = new Envelope();
        e.status = (isDraft) ? 'created' : 'sent';
        e.emailBlurb = getEmailBlurb();
        e.emailSubject = 'Your Signature is Requested by Lilly';
        e.documents = docs;
        e.recipients = r;

        String envelopeJson = JSON.serializePretty(e);
        //system.debug(envelopeJson);
        return envelopeJson;
    }

    private String getEmailBlurb() {
        return 'Lilly is requesting that you review and sign the agreement accessible via the “Review Document” button.  Please contact Lilly Customer Meeting Service if you have any questions\n\n'+
        'Lilly bittet Sie, den Vertrag zu überprüfen und anschliessend zu unterzeichen. Den Zugang zu Ihrem Vertrag ermöglicht die „Review Document“ Taste. Bitte kontaktieren Lilly Customer Meeting Service, wenn Sie irgendwelche Fragen haben,\n\n'+
        'Lilly vous demande de revoir et signer votre contrat qui est accesible via le bouton „Review Document". Si vous avez des questions, merci de contacter Lilly Customer Meeting Service.\n\n'+
        'Lilly le solicita que revise y firme el contrato, el cuál se encuentra accessible a través del botón ‘Review Document“. Si tuviese alguna duda, por favor póngase en contacto con Lilly Customer Meeting Service\n\n'+
        'Lilly le richiede di leggere e firmare il contratto accessibile attraverso il bottone „Review Document“. Nel caso avesse domande la preghiamo di contattare il Lilly Customer Meeting Service\n\n'+
        'Customer Meeting Service contact details by country\n\n'+
        'Austria:   Lilly_Austria_CMS@lilly.com  01 2060 92473\n'+
        'Denmark:   Lilly_Denmark_CMS@lilly.com  43 31 48 39\n'+
        'Finland:   Lilly_Suomi_CMS@lilly.com  09 7252 2024\n'+
        'Germany:   Lilly_Deutschland_CMS@lilly.com  06 929  957 18 47\n'+
        'Ireland:   Lilly_Ireland_CMS@lilly.com  01 907 5754\n'+
        'Italy: Lilly_Italia_CMS@lilly.com  02 9129 4898\n'+
        'Norway:    Lilly_Norge_CMS@lilly.com  23 02 49 42\n'+
        'Spain: Lilly_Spain_CMS@lilly.com  910 507 247\n'+
        'Sweden:    Lilly_Sverige_CMS@lilly.com  08 593 665 55\n'+
        'Switzerland:   Lilly_Schweiz_CMS@lilly.com  022 761 45 11\n'+
        'Switzerland:   Lilly_Suisse_CMS@lilly.com  022 761 45 11\n'+
        'Switzerland:   Lilly_Svizzera_CMS@lilly.com  022 761 45 11\n'+
        'UK:    Lilly_UK_CMS@lilly.com  020 3684 0772\n';
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
        public String status;
        public Tab tabs;
        public String clientUserId; //if this is included, it signifies embedded signing [hcps only]

        public Signer(String emailAddr, String nam, String recpId, String routId) {
            email = emailAddr;
            name = nam;
            recipientId = recpId;
            routingOrder = routId;
        }

        public Signer(String emailAddr, String nam, String recpId, String routId, String cuId) {
            email = emailAddr;
            name = nam;
            recipientId = recpId;
            routingOrder = routId;
            clientUserId = cuId;
        }
    }

    public class Tab {
        public List<SignHereTab> signHereTabs;
    }

    public class TabResponse {
        public List<SignHereTabResponse> signHereTabs;
    }

    //public class E

    public class SignHereTabResponse {
        public String documentId;
        public String anchorString; //example: "<--DOCUSIGN SIGNATURE MARKER-->"
        public String anchorXOffset; //example: "1"
        public String anchorYOffset; //example: "0"
        public String anchorIgnoreIfNotPresent; //if "false", error thrown when it cant find anchorstring
        public String anchorUnits; //example: "inches", "pixels", "mms", "cms"
        public String name;
        public String tabLabel;
        public String scaleValue;
        public String optional;
        public String recipientId;
        public String pageNumber;
        public String xPosition;
        public String yPosition;
        public String tabId;
    }

    public class SignHereTab {
        public String documentId;
        public String anchorString; //example: "<--DOCUSIGN SIGNATURE MARKER-->"
        public String anchorXOffset; //example: "1"
        public String anchorYOffset; //example: "0"
        public String anchorIgnoreIfNotPresent; //if "false", error thrown when it cant find anchorstring
        public String anchorUnits; //example: "inches", "pixels", "mms", "cms"

        //use this constructor to create a "sign here tab" based on an anchor string
        public SignHereTab(String anchor, String x, String y, String id) {
            documentid = id;
            anchorString = anchor;
            anchorXOffset = x;
            anchorYOffset = y;
            anchorIgnoreIfNotPresent = 'false';
            anchorUnits = 'pixels';
        }
    }

    //public class SignHereExplicitTab {
    //    public String name;
    //    public String tabLabel;
    //    public String scaleValue;
    //    public String optional;
    //    public String recipientId;
    //    public String pageNumber;
    //    public String xPosition;
    //    public String yPosition;
    //    public String tabId;

    //    //use this constructor to create a "sign here tab" based on an anchor string
    //    public SignHereExplicitTab(String anchor, String x, String y, String id) {
    //        documentid = id;
    //        anchorString = anchor;
    //        anchorXOffset = x;
    //        anchorYOffset = y;
    //        anchorIgnoreIfNotPresent = 'false';
    //        anchorUnits = 'pixels';
    //    }
    //}


  //  "signHereTabs": [
  //  {
  //    "name": "Sign Here",
  //    "tabLabel": "Signature 2",
  //    "scaleValue": 1.0,
  //    "optional": "false",
  //    "documentId": "1",
  //    "recipientId": "2",
  //    "pageNumber": "1",
  //    "xPosition": "202",
  //    "yPosition": "48",
  //    "tabId": "3a56629a-3781-4751-afad-9aff68bc3098"
  //  }
  //]

    //public class TabResponse {
    //    public List<SignHereTabResponse> signHereTabs;
    //}

    //public class SignHereTabResponse {
    //    public String name;
    //    public String tabLabel;
    //    public String scaleValue;
    //    public String optional;
    //    public String documentid;
    //    public String recipientId;
    //    public String pageNumber;
    //    public String xPosition;
    //    public String yPosition;
    //    public String tabId;
    //}

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

    public class DocusignServiceError {
        public String errorCode;
        public String message;
    }

    public class EnvelopeRecipientDetailResponse {
        public List<Signer> signers;
        public String currentRoutingOrder;
        public String recipientCount;
    }

    public class EnvelopeDetailResponse {
        public String createdDateTime;
        public String status;
    }

    public class EmbeddedSignResponse {
        public String url;
    }

    public class DocusignServiceException extends Exception {
        public String errorCode;
        public String message;
        DocusignServiceException(String errorCode, String message) {
            this(errorCode+': '+message);
            this.errorCode = errorCode;
            this.message = message;
        }
    }
}