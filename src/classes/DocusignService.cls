public with sharing class DocusignService {

	String username;
	String password;
	String integratorKey;
	String accountId;
	String baseUrl = 'https://demo.docusign.net/restapi/v2/';
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

    void parseResponse(String responseBody, String type) {
    	JSONParser parse = JSON.createParser(responseBody);
    	EnvResponse envstat = (EnvResponse)parse.readValueAs(EnvResponse.class);
    }

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

    // void prepareRequest() {
    // 	Http httpProtocol = new Http();
    // 	HttpRequest request = new HttpRequest();
    // 	String endpoint = '/accounts/'+accKey+'/envelopes';
    // 	request.setEndPoint(endpoint);
    // 	request.setMethod('POST');
    // 	request.setHeader('Accept', 'application/json');
    // 	request.setHeader('X-DocuSign-Authentication', passString);
    // 	request.setHeader('content-type', 'multipart/form-data;boundary=myBoundary'); 
    // }

    // //Call Create and send envelope method
    // public static Pagereference processDocument(Id ctrId) {
    //     //Account Id
    //     String accId = Docusign_Settings_EVNT__c.getValues('accountId').value__c;
    //     //Create Draft Envelope
    //     String envstatus = creatAndSendEnvelope(accId, ctrId);
    //     System.debug('Env Status = '+envstatus);
    //     return new Pagereference('/'+ctrId);
    // }
    
    //Create And Send Envelope - Creates Dynamic PDF Document, Create Recipient, Tabs and Sends for singature in one step
    public String creatAndSendEnvelope(String accKey, Id ctrId) {
        String passString = authHeader;                   
        //MyBoundary - used to indicate benging/end of document in multi-part request
        String contentType = '\r\n--myBoundary'+'\r\n'+'Content-Type:application/octet-stream'+ '\r\n'+
                                'Content-Transfer-Encoding: base64'+'\r\n'+'Content-Disposition:attachment; '+'filename=\"contract.pdf\";'+
                                'documentid=1 '+'\r\n\r\n\r\n';
        String cheader = '\r\n--myBoundary'+'\r\n'+' Content-Type: application/json'+ '\r\n'+' Content-Disposition: form-data'+ '\r\n'+'\r\n';
        String envelop = createJSONString(ctrId);
        System.debug('request body => '+envelop);
        String envEOF = '\r\n'+'--myBoundary--';                    
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = 'https://demo.docusign.net/restapi/v2/accounts/'+accKey+'/envelopes';
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        request.setHeader('X-DocuSign-Authentication', passString);
        request.setHeader('content-type', 'multipart/form-data;boundary=myBoundary'); 
        
        //Generate PDF
        PageReference pageRef = new PageReference('/apex/contractpdf');
        pageRef.getParameters().put('id',ctrId);
        String bcontent = EncodingUtil.base64Encode(pageRef.getContentaspdf());
        request.setHeader('content-length', String.valueOf(bcontent.length()));
        
        //Body
        request.setBody(cheader+''+envelop+'\r\n'+contentType+'\r\n'+bcontent+'\r\n'+envEOF);
        System.debug('Request Body = '+cheader+''+envelop+'\r\n'+contentType+'\r\n'+bcontent+'\r\n'+envEOF);
        HttpResponse response1 = httpProtocol.send(request);
        System.debug('response1 =>'+response1.getBody());
        JSONParser parse = JSON.createParser(response1.getBody());
        EnvResponse envstat = (EnvResponse)parse.readValueAs(EnvResponse.class);
        System.debug('De-Serialized class is envstats => '+envstat);
        return envstat.status;
    }
    
    //Util helper for constructing JSON request for createandsend all in one method 
    public String createJSONString(String ctrId) {    
        List<Signers> recipient1 = new List<Signers>{new Signers('rpachaiyappan@gmail.com', 'Ram', '1', '1') };
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('emailBlurb', 'Please Sign Contracts ASAP!');
        gen.writeStringField('emailSubject', 'Docusign Contracts');
        //document
        gen.writeFieldName('documents');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('documentId', '1');
        gen.writeStringField('name', 'contract.pdf');
        gen.writeEndObject();
        gen.writeEndArray(); //end of doc
        //srat recip
        gen.writeFieldName('recipients');
        //signer -1
        gen.writeStartObject();
        //array of singers
        gen.writeFieldName('signers');
        gen.writeStartArray();
        //gen.writeObject(new Signers('rpachaiyappan@gmail.com', 'Ram', '1', '1') );
        gen.writeStartObject();
        gen.writeObjectField('email', 'rpachaiyappan@gmail.com');
        gen.writeObjectField('name', 'rpachaiyappan');
        gen.writeObjectField('recipientId', '1');
        gen.writeObjectField('routingOrder', '1');
        //start tab
        gen.writeFieldName('tabs');
        gen.writeStartObject();
        //start sign here
        gen.writeFieldName('signHereTabs');
        gen.writeStartArray();
        gen.writeObject(new Tab('CustSignInsert'));
        gen.writeEndArray();
        //end sign here
        
        //date tab
        gen.writeFieldName('dateSignedTabs');
        gen.writeStartArray();
        gen.writeObject(new Tab('CustDate'));
        gen.writeEndArray();
        //date tab end
        
        //title tab
        gen.writeFieldName('titleTabs');
        gen.writeStartArray();
        gen.writeObject(new Tab('CustTitle'));
        gen.writeEndArray();
        //end sign here
        gen.writeEndObject(); //end tab
        gen.writeEndObject();
        
        //signer -2
        gen.writeStartObject();
        gen.writeObjectField('email', 'ramanathanp82@yahoo.com');
        gen.writeObjectField('name', 'pachaiyappan');
        gen.writeObjectField('recipientId', '2');
        gen.writeObjectField('routingOrder', '2');
        //start tab
        gen.writeFieldName('tabs');
        gen.writeStartObject();
        //start sign here
        gen.writeFieldName('signHereTabs');
        gen.writeStartArray();
        gen.writeObject(new Tab('SellSignInsert'));
        gen.writeEndArray();
        
        gen.writeFieldName('titleTabs');
        gen.writeStartArray();
        gen.writeObject(new Tab('SellerTitle'));
        gen.writeEndArray();
        //end sign here
        
        gen.writeEndObject();
        
        gen.writeEndObject();
        
        gen.writeEndArray(); 
        gen.writeEndObject();//end recip
        gen.writeStringField('status', 'sent');
        gen.writeFieldName('customFields');
        gen.writeStartObject();
        gen.writeFieldName('textCustomFields');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeObjectField('name', 'ContractId');
        gen.writeObjectField('show', 'true');
        gen.writeObjectField('required', 'False');
        gen.writeObjectField('value', ctrId);
        gen.writeObjectField('customFieldType', 'text');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.writeEndObject();
        System.debug('JSON String => '+gen.getAsString());
        return gen.getAsString();
    }
    
    
    
    //Lengthy Method call -Process Document for sending to Docusign
    public Pagereference processDocument2(Id ctrId) {
        //Create Draft Envelope
        String envId = createEnvelope(this.accountId);
        if(envId!=null) {
            //Attach Document
            attachDocToDS(envId, ctrId, this.accountId);
            //Send envelope
            sendToDS(envId, this.accountId);
        }
        return new Pagereference('/'+ctrId);
    }
    
    //Lengthy Method call -Create Draft Envelope Method 
    public String createEnvelope(String accKey) {
        String passString = authHeader;                   
        //MyBoundary - used to indicate benging/end of document in multi-part request
        String contentType = '\r\n--myBoundary'+'\r\n'+' Content-Type: application/json'+ '\r\n'+' Content-Disposition: form-data'+'\r\n\r\n';
        String envelop = createJSONString2();
        System.debug('request body => '+envelop);
        String envEOF = '\r\n'+'--myBoundary--';                    
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = 'https://demo.docusign.net/restapi/v2/accounts/'+accKey+'/envelopes';
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        request.setHeader('X-DocuSign-Authentication', passString);
        request.setHeader('content-type', 'multipart/form-data;boundary=myBoundary'); 
        System.debug('Request Body = '+contentType+''+envelop+''+envEOF);
        request.setBody(contentType+''+envelop+''+envEOF);
        HttpResponse response1 = httpProtocol.send(request);
        System.debug('response1 =>'+response1.getBody());
        JSONParser parse = JSON.createParser(response1.getBody());
        EnvResponse envstat = (EnvResponse)parse.readValueAs(EnvResponse.class);
        System.debug('De-Serialized class is envstats => '+envstat);
        return envstat.envelopeId;
    }
    
    
    //Lengthy Method call - Attach Document to Draft Envelope
    public void attachDocToDS(String envId, Id ctrId, String accKey) {
        String passString = authHeader;
        Http httpProtocol = new Http();
        String endpoint = 'https://demo.docusign.net/restapi/v2/accounts/'+accKey+'/envelopes/'+envid+'/documents/1';
        System.debug('End Point => '+endpoint);
        //Send PDF
        PageReference pageRef = new PageReference('/apex/contractpdf');
        //Contract Id for PDF
        pageRef.getParameters().put('id',ctrId);
        Blob b = pageRef.getContentaspdf();
        // Create HTTP request to send.
        HttpRequest request2 = new HttpRequest();
        request2.setEndPoint(endpoint);
        // Set the HTTP verb to GET.
        request2.setMethod('PUT');
        request2.setHeader('Accept', 'application/json');
        request2.setHeader('X-DocuSign-Authentication', passString);
        request2.setHeader('content-length', String.valueOf(b.size()));
        request2.setHeader('content-type', 'application/pdf;Content-Disposition: file; filename=contract.pdf; documentid=1; fileExtension=pdf');
        request2.setHeader('Content-Disposition', 'file; filename=contract.pdf; documentid=1; fileExtension=pdf');
        request2.setBodyAsBlob(b);
        HttpResponse response2 = httpProtocol.send(request2);
        System.debug('response2 header =>'+response2.getStatus()+', Body=> '+response2.getBody());
    }
    
    
    //Lengthy Method call - Send Document for Signing
    public void sendToDS(String envId, String accKey) {
        String passString = authHeader;
        Http httpProtocol = new Http();
        String endpoint = 'https://demo.docusign.net/restapi/v2/accounts/'+accKey+'/envelopes/'+envid;
        System.debug('End Point => '+endpoint);
        HttpRequest request2 = new HttpRequest();
        request2.setEndPoint(endpoint);
        // Set the HTTP verb to GET.
        request2.setMethod('PUT');
        request2.setHeader('Accept', 'application/json');
        request2.setHeader('X-DocuSign-Authentication', passString);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('status', 'sent');
        gen.writeEndObject();
        String  body = gen.getAsString();
        System.debug('body => '+body);
        request2.setBody(body);
        HttpResponse response2 = httpProtocol.send(request2);
        System.debug('response2 header =>'+response2.getStatus()+', Body=> '+response2.getBody());
    }
    
    
    //Lengthy Method call - Util helper for constructing JSON request 
    public String createJSONString2() {   
        List<Signers> recipients = new List<Signers>{new Signers('rpachaiyappan@gmail.com', 'Ram', '1', '1') };
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('emailBlurb', 'Please Sign Contracts ASAP!');
        gen.writeStringField('emailSubject', 'Docusign Contracts');
        gen.writeFieldName('recipients');
        gen.writeStartObject();
        gen.writeObjectField('signers',recipients);
        gen.writeEndObject();
        gen.writeStringField('status', 'created');
        gen.writeEndObject();
        System.debug('JSON String => '+gen.getAsString());
        return gen.getAsString();
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
    
    //Signer Class
    public class Signers {
        String email;
        String name;
        String recipientId;
        String routingOrder;
        
        public Signers(String emailAddr, String nam, String recpId, String routId) {
            email = emailAddr;
            name = nam;
            recipientId = recpId;
            routingOrder = routId;      
        }   
    }
    
    public class Tab {
        String name;
        String anchorString;
        public Tab(String n) {
            name =n;
            anchorString = n;
        }
    }
    
    //Envelope Data Class
    public class EnvResponse {
        String envelopeId;
        String  status;
        String statusDateTime;
        String uri;
    }
}