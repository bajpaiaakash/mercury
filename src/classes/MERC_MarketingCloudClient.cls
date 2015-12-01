public with sharing class MERC_MarketingCloudClient {
    private static final et4ae5__Configuration__c Configuration;
    private static final et4ae5__Business_Unit__c BusinessUnit;
    private static final Mercury_Marketing_Cloud_Settings_MERC__c MarketingCloudSettings;
    private static final String ScopedAuthToken;
    private static final SoapClient soapClient;
    private static final RestClient restClient;
    private static final FuelClient fuelClient;
    
    private static final Integer DefaultTimeout = 120000;
    private static final Integer ShorterTimeout = 5;
    private static final String PostMethod = 'POST';
    private static final String GetMethod = 'GET';
    private static final String SoapAction = 'SOAPAction';
    private static final String ContentType = 'Content-Type';
    private static final String AcceptType = 'Accept';
    private static final String XMLType = 'text/xml; charset=UTF-8';
    private static final String JsonType = 'application/json';
    private static final String JsonCharsetType =  'application/json; charset=UTF-8';
    private static final String Authorization = 'authorization';

    private static final Integer StatusCodeSuccess = 200;
    private static final Integer StatusCodeRedirect = 300;

    static {
        MarketingCloudSettings = Mercury_Marketing_Cloud_Settings_MERC__c.getInstance();
        Configuration = [SELECT et4ae5__UserName__c,
                                et4ae5__Password__c, 
                                et4ae5__Auth_API_URL__c,
                                et4ae5__Root_Rest_API_URL__c,
                                et4ae5__integration_type__c,
                                et4ae5__url_root__c
                           FROM et4ae5__Configuration__c
                       ORDER BY LastModifiedDate DESC
                          LIMIT 1];
        List<et4ae5__Business_Unit__c> businessUnits = [SELECT et4ae5__Business_Unit_ID__c 
                                                          FROM et4ae5__Business_Unit__c 
                                                         WHERE Name = :MarketingCloudSettings.Business_Unit_Name_MERC__c 
                                                         LIMIT 1];
        if(businessUnits != null && !businessUnits.isEmpty()){
            BusinessUnit = businessUnits[0];
        }

        soapClient = new SoapClient();
        fuelClient = new FuelClient(soapClient.authToken);
        restClient = new RestClient(soapClient.requestScopedAuthToken());
    }

    public static List<SenderProfile> getSenders(){
        return restClient.requestSenders();
    }

    public static List<SenderProfile> getSendersById(String senderProfileId){
        return restClient.requestSendersById(senderProfileId);
    }

    public static List<SendClassification> getClassifications(){
        return restClient.requestClassifications();
    }

    public static List<FolderedEmail> getEmails(String parentFolderId){
        return restClient.requestEmails(parentFolderId);
    }

    public static List<EmailFolder> getEmailFolders(){
        return restClient.requestEmailFolders();
    }

    public static List<EmailFolder> getEmailFolders(String parentFolderId){
        return restClient.requestEmailFolders(parentFolderId);
    }

    public static void createDataExtensionEntries(DataExtension dataExtension, List<DataExtensionEntry> entries){
        fuelClient.postDataExtensionEntries(dataExtension, entries);
    }

    public static DataExtensionResponse createDataExtension(DataExtension dataExtension){
        return restClient.postDataExtension(dataExtension);
    }

    public static String getThumbnail(Meeting_Email_Send_MERC__c meetingEmailSend){
        return restClient.requestThumbnail(meetingEmailSend);
    }

    public static List<Subscriber> getSubscribers(List<String> subscriberKeys){
        return soapClient.requestSubscribers(subscriberKeys);
    }

    public static String updateSubscriber(Subscriber subscriber){
        return soapClient.postSubscriberUpdate(subscriber);
    }
	
    private class FuelClient {
        private final String ClientId = 'jsemj72hixy2qx1yp27lb59o';
        private final String ClientSecret = 'DRfQ1K3NzeOxxdJEXDOUK4n2';
        private final String AuthURL = 'https://auth.exacttargetapis.com';
        private final String RootURL = 'https://www.exacttargetapis.com';

        private final String SoapAuthToken;

        public FuelClient(String soapAuthToken){
            SoapAuthToken = soapAuthToken;
        }

        public String authToken {
            get {
                if(authToken == null || authToken  == '') {
                    authToken = requestAuthToken();
                }
                return authToken;
            }
            private set;
        }

        public void postDataExtensionEntries(DataExtension dataExtension, List<DataExtensionEntry> entries){
            String requestPath = '/hub/v1/dataevents/key:' + EncodingUtil.urlEncode(dataExtension.key, 'UTF-8') + '/rowset';
            String requestBody = SerializeDataExtensionEntries(entries);
            HttpResponse httpResponse = PostToUrl(requestPath, requestBody);
            Integer statusCode = httpResponse.getStatusCode();

            if(!(statusCode >= 200 && statusCode < 300)){
                throw new MarketingCloudClientException('There was an error populating the data extension with key : ' + dataExtension.key + '\n' + requestBody + ' Status Code : ' + statusCode);
            }
        }

        private String SerializeDataExtensionEntries(List<DataExtensionEntry> entries){
            JSONGenerator jsonGenerator = JSON.createGenerator(true);

            jsonGenerator.writeStartArray();
            for (DataExtensionEntry dataExtensionEntry : entries) {
                jsonGenerator.writeStartObject();
                jsonGenerator.writeFieldName('keys');
                jsonGenerator.writeStartObject();
                jsonGenerator.writeStringField(dataExtensionEntry.keys.fieldName, dataExtensionEntry.keys.fieldValue);
                jsonGenerator.writeEndObject();
                jsonGenerator.writeFieldName('values');
                jsonGenerator.writeStartObject();
                for (FieldEntry fieldEntry : dataExtensionEntry.values) {
                    if (fieldEntry.fieldValue != null) {
                        jsonGenerator.writeStringField(fieldEntry.fieldName, fieldEntry.fieldValue);
                    } else {
                        jsonGenerator.writeStringField(fieldEntry.fieldName, '');
                    }
                }
                jsonGenerator.writeEndObject();
                jsonGenerator.writeEndObject();
            }
            jsonGenerator.writeEndArray();

            return jsonGenerator.getAsString();
        }

        private String requestAuthToken(){
            FuelRequestBody requestBody = new FuelRequestBody(ClientId, ClientSecret, SoapAuthToken);
            String requestUrl = AuthURL + '/v1/requestToken?legacy=1';

            HttpRequest request = new HttpRequest();
            request.setEndpoint(requestUrl);
            request.setTimeout(DefaultTimeout);
            request.setMethod(PostMethod);
            request.setHeader(ContentType, JsonType);
            request.setHeader(AcceptType, JsonType);
            request.setBody(JSON.serialize(requestBody));

            Http http = new Http();
            HttpResponse response = http.send(request);

            String authToken = '';
            if (response.getStatusCode() >= StatusCodeSuccess && response.getStatusCode() < StatusCodeRedirect) {
                FuelResponseBody fuelResBody = (FuelResponseBody)JSON.deserialize(response.getBody(), FuelResponseBody.class);
                authToken = fuelResBody.accessToken;
            } else {
                System.debug('soapAuthToken: ' + soapAuthToken);
                System.debug(LoggingLevel.WARN, 'Failed to get FuelAuthToken ('
                    + response.getStatusCode() + '):\n\nRequest:\n' 
                + JSON.serialize(requestBody) + '\n\nResponse:\n' + response.getBody());
            }

            return authToken;
        }

        private HttpResponse PostToUrl(String requestPath, String body){
            Http httpClient = new Http();
            HttpRequest httpRequest = new HttpRequest();
            String requestUrl = Configuration.et4ae5__Root_Rest_API_URL__c + requestPath;

            httpRequest.setTimeout(DefaultTimeout);
            httpRequest.setEndpoint(requestUrl);
            httpRequest.setMethod(PostMethod);
            httpRequest.setHeader(ContentType, JsonType);
            httpRequest.setHeader(AcceptType, JsonType);
            httpRequest.setHeader(Authorization, 'Bearer ' + authToken);
            httpRequest.setBody(body);

            HttpResponse response = new HttpResponse();
            try
            {
                response = httpClient.send(httpRequest);
            }
            catch(Exception ex){
                System.debug(ex);
            }
            return response;
        }

    }

    @TestVisible //TODO: rewrite test class so this isn't necessary.
    private class RestClient {
        public String AuthToken;

        public RestClient(String soapAuthToken){
            System.debug(LoggingLevel.FINE, 'RestClient (AuthToken):\n\n\t' + AuthToken);
            AuthToken = soapAuthToken;
            System.debug(LoggingLevel.FINE, 'RestClient (AuthToken):\n\n\t' + AuthToken);
        }

        public List<SenderProfile> requestSenders(){
            String requestPath = '/rest/beta/messaging/senderprofile/?oauth_token=' + AuthToken;
            HttpResponse httpResponse = getFromUrl(requestPath);

            try {
                SenderProfileResponse parsedResponse = (SenderProfileResponse)JSON.deserialize(
                    httpResponse.getBody(),
                    SenderProfileResponse.class);
                return parsedResponse.entry;
            } catch(JSONException ex){
                System.debug('JSONException:\n' + ex.getMessage());
                return null;
            } catch(Exception ex){
                System.debug('Exception:\n' + ex.getMessage());
                return null;
            }
        }

        public List<SenderProfile> requestSendersById(String senderProfileId){
            String requestPath = '/rest/beta/messaging/senderprofile/?oauth_token=' + AuthToken + '&where=id+eq+\'' + senderProfileId + '\'';
            HttpResponse httpResponse = getFromUrl(requestPath);

            try {
                SenderProfileResponse parsedResponse = (SenderProfileResponse)JSON.deserialize(
                    httpResponse.getBody(),
                    SenderProfileResponse.class);
                return parsedResponse.entry;
            } catch(JSONException ex){
                System.debug('JSONException:\n' + ex.getMessage());
                return null;
            } catch(Exception ex){
                System.debug('Exception:\n' + ex.getMessage());
                return null;
            }
        }

        public List<SendClassification> requestClassifications(){
            String requestPath = '/rest/beta/messaging/sendclassification/?oauth_token=' + AuthToken;
            HttpResponse httpResponse = getFromUrl(requestPath);

            try {
                SendClassificationResponse parsedResponse = (SendClassificationResponse)JSON.deserialize(
                    httpResponse.getBody(),
                    SendClassificationResponse.class);
                return parsedResponse.entry;
            } catch(JSONException ex){
                System.debug('JSONException:\n' + ex.getMessage());
                return null;
            } catch(Exception ex){
                System.debug('Exception:\n' + ex.getMessage());
                return null;
            }
        }

        public SendClassification requestClassification(String classificationKey){
            String requestPath = '/rest/beta/messaging/sendclassification/?oauth_token=' + AuthToken + '&where=key+eq+\'' + classificationKey + '\'';
            HttpResponse httpResponse = getFromUrl(requestPath);

            try {
                SendClassificationResponse parsedResponse = (SendClassificationResponse)JSON.deserialize(
                    httpResponse.getBody(),
                    SendClassificationResponse.class);
                return parsedResponse.entry[0];
            } catch(JSONException ex){
                System.debug('JSONException:\n' + ex.getMessage());
                return null;
            } catch(Exception ex){
                System.debug('Exception:\n' + ex.getMessage());
                return null;
            }
        }

        public List<FolderedEmail> requestEmails(String parentFolderId){
            String requestPath = '/rest/beta/folder/'+parentFolderId+'/contents/?oauth_token='+AuthToken+'&where=type+eq+\'email\'';
            HttpResponse httpResponse = getFromUrl(requestPath);

            try {
                EmailResponse parsedResponse = (EmailResponse)JSON.deserialize(
                    httpResponse.getBody(),
                    EmailResponse.class);
                return parsedResponse.entry;
            } catch(JSONException ex){
                System.debug('JSONException:\n' + ex.getMessage());
                return null;
            } catch(Exception ex){
                System.debug('Exception:\n' + ex.getMessage());
                return null;
            }
        }

        public List<EmailFolder> requestEmailFolders(){
            System.debug(LoggingLevel.FINE, 'RestClient.requestEmailFolders (AuthToken):\n\n\t' + AuthToken);
            String requestPath = '/rest/beta/folder/?oauth_token='+AuthToken+'&where=allowedtypes+in+(\'email\',\'shared_type\',\'global+email\',\'shared_email\',\'shared_item\')';
            HttpResponse httpResponse = getFromUrl(requestPath);

            try {
                EmailFolderResponse parsedResponse = (EmailFolderResponse)JSON.deserialize(
                    httpResponse.getBody(),
                    EmailFolderResponse.class);
                return parsedResponse.entry;
            } catch(JSONException ex){
                System.debug('JSONException:\n' + ex.getMessage());
                return null;
            } catch(Exception ex){
                System.debug('Exception:\n' + ex.getMessage());
                return null;
            }
        }

        public List<EmailFolder> requestEmailFolders(String parentFolderId){
            String requestPath = '/rest/beta/folder/'+parentFolderId+'/children/?oauth_token='+AuthToken+'&where=allowedtypes+in+(\'email\',\'shared_type\',\'global+email\',\'shared_email\',\'shared_item\')';
            HttpResponse httpResponse = getFromUrl(requestPath);

            try {
                EmailFolderResponse parsedResponse = (EmailFolderResponse)JSON.deserialize(
                    httpResponse.getBody(),
                    EmailFolderResponse.class);
                return parsedResponse.entry;
            } catch(JSONException ex){
                System.debug('JSONException:\n' + ex.getMessage());
                return null;
            } catch(Exception ex){
                System.debug('Exception:\n' + ex.getMessage());
                return null;
            }
        }

        public String requestThumbnail(Meeting_Email_Send_MERC__c meetingEmailSend){
            String requestPathFormat = '/{0}/utilities/ImageThumbnailSecure.ashx/?h={1}&w={2}&emailid={3}&oauth_token={4}';
            String requestPath = String.format(requestPathFormat,
                                        new List<String> { 
                                            Configuration.et4ae5__url_part__c, 
                                            '700', 
                                            '700', 
                                            meetingEmailSend.ET_Email_Id_MERC__c, 
                                            AuthToken 
                                        });
            String requestRoot = Configuration.et4ae5__Root_Rest_API_URL__c.replace('rest', Configuration.et4ae5__url_root__c);
            HttpResponse httpResponse = getFromUrl(requestRoot, requestPath, ShorterTimeout);

            try {
                ImageThumbnailSecureResponse parsedResponse = (ImageThumbnailSecureResponse)JSON.deserialize(
                    httpResponse.getBody(),
                    ImageThumbnailSecureResponse.class);
                return parsedResponse.data;
            } catch(JSONException ex){
                System.debug('JSONException:\n' + ex.getMessage());
                return null;
            } catch(Exception ex){
                System.debug('Exception:\n' + ex.getMessage());
                return null;
            }
        }

        public DataExtensionResponse postDataExtension(DataExtension dataExtension){
            String requestPath = '/rest/beta/object/?oauth_token='+AuthToken;
            String requestBody = JSON.serialize(dataExtension);
            HttpResponse httpResponse = PostToUrl(requestPath, requestBody);

            try {
                return (DataExtensionResponse)JSON.deserialize(httpResponse.getBody(), DataExtensionResponse.class);
            } catch(JSONException ex){
                System.debug('JSONException:\n' + ex.getMessage());
                return null;
            } catch(Exception ex){
                System.debug('Exception:\n' + ex.getMessage());
                return null;
            }
        }

        public CreateSendDefinitionResponse postSendDefition(SendDefinition sendDefinition){
            String requestPath = '/rest/beta/messaging/senddefinition/instance/?oauth_token=' + AuthToken;
            String requestBody = JSON.serialize(sendDefinition);
            HttpResponse httpResponse = PostToUrl(requestPath, requestBody);

            try {
                return (CreateSendDefinitionResponse)JSON.deserialize(httpResponse.getBody(), CreateSendDefinitionResponse.class);
            } catch(JSONException ex){
                System.debug('JSONException:\n' + ex.getMessage());
                return null;
            } catch(Exception ex){
                System.debug('Exception:\n' + ex.getMessage());
                return null;
            }
        }

        public StartSendDefinitionResponse getStartSendDefinition(String sendDefinitionId){
            String requestPath = '/rest/beta/messaging/senddefinition/instance/' + EncodingUtil.urlEncode(sendDefinitionId,'UTF-8') + '/?action=start&oauth_token=' + AuthToken;
            HttpResponse httpResponse = getFromUrl(requestPath);

            try {
                return (StartSendDefinitionResponse)JSON.deserialize(
                            httpResponse.getBody(),
                            StartSendDefinitionResponse.class);
            } catch(JSONException ex){
                System.debug('JSONException:\n' + ex.getMessage());
                return null;
            } catch(Exception ex){
                System.debug('Exception:\n' + ex.getMessage());
                return null;
            }
        }

        public CheckSendDefinitionStatusResponse getSendDefinitionStatus(String sendDefinitionId){
            String requestPath = '/rest/beta/messaging/senddefinition/instance/' + EncodingUtil.urlEncode(sendDefinitionId,'UTF-8') + '/job/?oauth_token=' + AuthToken;
            HttpResponse httpResponse = getFromUrl(requestPath);

            try {
                return (CheckSendDefinitionStatusResponse)JSON.deserialize(
                            httpResponse.getBody(),
                            CheckSendDefinitionStatusResponse.class);
            } catch(JSONException ex){
                System.debug('JSONException:\n' + ex.getMessage());
                return null;
            } catch(Exception ex){
                System.debug('Exception:\n' + ex.getMessage());
                return null;
            }
        }

        private HttpResponse getFromUrl(String requestRoot, String requestPath, Integer timeOut){
            Http httpClient = new Http();
            HttpRequest httpRequest = new HttpRequest();
            String requestUrl = requestRoot + requestPath;
            System.debug(LoggingLevel.FINE, 'RestClient GET from URL:\n' + requestUrl);

            httpRequest.setTimeout(timeOut);
            httpRequest.setMethod(GetMethod);
            httpRequest.setEndpoint(requestUrl);
            httpRequest.setHeader(ContentType, JsonType);
            httpRequest.setHeader(AcceptType, JsonType);

            HttpResponse response = new HttpResponse();
            try
            {
                response = httpClient.send(httpRequest);
                if(response.getStatusCode() == 200){
                    System.debug(LoggingLevel.FINE, 'RestClient GET from Response:\n\n' + response.getBody());
                }
            }
            catch(Exception ex){
                System.debug(ex);
            }
            return response;
        }

        private HttpResponse getFromUrl(String requestPath){
            return getFromUrl(Configuration.et4ae5__Root_Rest_API_URL__c, requestPath, DefaultTimeout);
        }

        private HttpResponse PostToUrl(String requestPath, String body){
            Http httpClient = new Http();
            HttpRequest httpRequest = new HttpRequest();
            String requestUrl = Configuration.et4ae5__Root_Rest_API_URL__c + requestPath;

            httpRequest.setTimeout(DefaultTimeout);
            httpRequest.setEndpoint(requestUrl);
            httpRequest.setMethod(PostMethod);
            httpRequest.setHeader(ContentType, JsonCharsetType);
            httpRequest.setHeader(AcceptType, JsonType);
            httpRequest.setBody(body);

            HttpResponse response = new HttpResponse();
            try
            {
                response = httpClient.send(httpRequest);
            }
            catch(Exception ex){
                System.debug(ex);
            }
            return response;
        }
    }

    @TestVisible //TODO: rewrite test class so this isn't necessary.
    private class SoapClient {
        private final String SOAPApplicationId = '6C7F3A46-9BFD-40E9-87EE-456577D4FFE7'; // why is this hardcoded?
        private final String soapAPIUrl = 'https://webservice.s6.exacttarget.com/Service.asmx';
        private final String RetrieveAction = 'Retrieve';
        private final String UpdateAction = 'Update';

        public String authToken {
            get {
                if(authToken == null || authToken  == '') {
                    authToken = requestAuthToken(null);
                }
                return authToken;
            }
            private set;
        }

        public String getScope(){
            String token = [SELECT et4ae5__exacttarget_oauth_token__c 
                              FROM User 
                             WHERE id = :UserInfo.getUserId() 
                             LIMIT 1].et4ae5__exacttarget_oauth_token__c;

            String scope = 'scope=' + token;
            if(Configuration.et4ae5__integration_type__c == MarketingCloudSettings.Enterprise_Integration_Type_MERC__c){
                if(BusinessUnit == null){
                    System.debug(LoggingLevel.ERROR, 'There is no BusinessUnit specified for this Exact Target enterprise configuration.');
                    return scope;
                }
                return 'memberid=' + BusinessUnit.et4ae5__Business_Unit_ID__c + ',' + scope;
            }

            return scope;
        }

        public String requestScopedAuthToken(){
            return requestAuthToken(getScope());
        }

        private String requestAuthToken(String scope){
            String requestXML = getAuthTokenRequestXML(Configuration.et4ae5__UserName__c,
                                                       Configuration.et4ae5__Password__c,
                                                       SOAPApplicationId,
                                                       scope);

            HttpRequest request = new HttpRequest();
            request.setEndpoint(Configuration.et4ae5__Auth_API_URL__c);
            request.setTimeout(DefaultTimeout);
            request.setMethod(PostMethod);
            request.setHeader(SoapAction, 'urn:authentication.exacttarget.com/2010/06/11/Auth/OAuthLogin');
            request.setHeader(ContentType, XMLType);
            request.setBody(requestXML);

            System.debug(LoggingLevel.Fine, 'SoapClient.requestAuthToken (requestXML)\n\n\t' + requestXML);

            Http http = new Http();
            HttpResponse response = http.send(request);

            String parsedToken = '';
            if(response.getStatusCode() >= StatusCodeSuccess && response.getStatusCode() < StatusCodeRedirect){

                System.debug(LoggingLevel.Fine, 'SoapClient.requestAuthToken (responseBody)\n\n\t' + response.getBody());
                //List<String> splits = response.getBody().split('<a:AccessToken>');
                //splits = splits[1].split('</a:AccessToken>');
                //parsedToken = splits[0];
                try {
                    DOM.XMLNode accessTokenNode = response.getBodyDocument().getRootElement().getChildElement('AccessToken', null);
                    if(accessTokenNode != null){
                        parsedToken = accessTokenNode.getText();
                    }
                } catch(XmlException ex){
                    throw new MarketingCloudClientException('Failed to parse AccessToken response:\n\n' + response.getBody() + '\n\n' + ex);
                }
            }

            System.debug(LoggingLevel.Fine, 'SoapClient.requestAuthToken (parsedToken)\n\n\t' + parsedToken);
            return parsedToken;
        }

        private String getAuthTokenRequestXML(String userName, String password, String applicationId, String scope){
            String bodyXML = '';
            bodyXML = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                        + '<SOAP-ENV:Header>'
                            + '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
                                + '<wsse:UsernameToken xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
                                    + '<wsse:Username>' + userName + '</wsse:Username>'
                                    + '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + password + '</wsse:Password>'
                                + '</wsse:UsernameToken>'
                            + '</wsse:Security>'
                        + '</SOAP-ENV:Header>'
                        + '<SOAP-ENV:Body>'
                            + '<OAuthLogin xmlns="urn:authentication.exacttarget.com/2010/06/11">'
                                + '<applicationId>' + applicationId + '</applicationId>'
                                + '<customerSecret> Not used currently </customerSecret>'
                                + (String.isBlank(scope) ? '<scopeToken />' : '<scopeToken>' + scope + '</scopeToken>')
                            + '</OAuthLogin>'
                        + '</SOAP-ENV:Body>'
                    + '</SOAP-ENV:Envelope>';
            return bodyXML;
        }

        public List<Subscriber> requestSubscribers(List<String> subscriberKeys){
            String requestBody = getSubscribersRequestXML(subscriberKeys);

            HttpResponse httpResponse = PostSoapAction(requestBody, RetrieveAction);

            return parseSubscribers(httpResponse.getBody());
        }

        private String getSubscribersRequestXML(List<String> subscriberKeys){
            String filterOperator;
            if (subscriberKeys.size() == 1) {
                filterOperator = '<SimpleOperator>equals</SimpleOperator>';
            } else if (subscriberKeys.size() > 1) {
                filterOperator = '<SimpleOperator>IN</SimpleOperator>';
            } else {
                return null;
            }

            String subscriberKeyRange = '';
            for (String key : subscriberKeys) {
                subscriberKeyRange += '<Value>' + key + '</Value>';
            }

            DateTime currentDateTime = System.now();

            String bodyXML = '';
            bodyXML = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
                    + '<s:Header>'
                        + '<oAuth xmlns="http://exacttarget.com">'
                            + '<oAuthToken>' + authToken + '</oAuthToken>'
                        + '</oAuth>'
                        + '<o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
                            + '<u:Timestamp u:Id="0">'
                                + '<u:Created>' + currentDateTime.format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') + '</u:Created>'
                                + '<u:Expires>' + currentDateTime.addMinutes(5).format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') + '</u:Expires>'
                            + '</u:Timestamp>'
                            + '<o:UsernameToken>'
                                + '<o:Username>*</o:Username>'
                                + '<o:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">*</o:Password>'
                            + '</o:UsernameToken>'
                        + '</o:Security>'
                    + '</s:Header>'
                    + '<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
                        + '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'
                            + '<RetrieveRequest>'
                                + '<ObjectType>Subscriber</ObjectType>'
                                + '<Properties>EmailAddress</Properties>'
                                + '<Properties>SubscriberKey</Properties>'
                                + '<Properties>ID</Properties>'
                                + '<Filter xsi:type="SimpleFilterPart">'
                                    + '<Property>SubscriberKey</Property>'
                                    + filterOperator
                                    + subscriberKeyRange
                                + '</Filter>'
                            + '</RetrieveRequest>'
                        + '</RetrieveRequestMsg>'
                    + '</s:Body>'
                + '</s:Envelope>';

            return bodyXML;
        }

        private List<Subscriber> parseSubscribers(String responseBody){
            List<Subscriber> retrievedSubscribers = new List<Subscriber>();
            if (responseBody.subStringBetween('<OverallStatus>', '</OverallStatus>') == 'OK') {
                List<String> splitResponseBody = responseBody.split('<Results xsi:type="Subscriber">', 0);
                
                if (splitResponseBody.size() != 1) {
                    for (Integer i = 1; i < splitResponseBody.size(); i += 1) {
                        Subscriber subscriber = new Subscriber(
                            splitResponseBody[i].subStringBetween('<SubscriberKey>', '</SubscriberKey>'),
                            splitResponseBody[i].subStringBetween('<Name>LLYSubscriberKey</Name><Value>', '</Value>'),
                            splitResponseBody[i].subStringBetween('<EmailAddress>', '</EmailAddress>'),
                            splitResponseBody[i].subStringBetween('<Name>SubscriberType</Name><Value>', '</Value>')
                        );
                        retrievedSubscribers.add(subscriber);
                    }
                }
            } else {
                System.Debug(LoggingLevel.ERROR,'ERROR in Subscriber retrieval: ' + responseBody.subStringBetween('<StatusMessage>', '</StatusMessage>'));
            }
            return retrievedSubscribers;
        }

        public String postSubscriberUpdate(Subscriber subscriber){
            String requestBody = getSubscriberUpdateXML(subscriber);

            HttpResponse httpResponse = PostSoapAction(requestBody, UpdateAction);

            return parseSubscriberUpdateResponse(httpResponse.getBody());
        }

        private String getSubscriberUpdateXML(Subscriber subscriber){
            DateTime currentDateTime = System.now();
            String bodyXML;
            bodyXML = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
                    + '<s:Header>'
                        + '<oAuth xmlns="http://exacttarget.com">'
                            + '<oAuthToken>' + authToken + '</oAuthToken>'
                        + '</oAuth>'
                        + '<o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
                        + '<u:Timestamp u:Id="0">'
                            + '<u:Created>' + currentDateTime.format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') + '</u:Created>'
                            + '<u:Expires>' + currentDateTime.addMinutes(5).format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') + '</u:Expires>'
                        + '</u:Timestamp>'
                        + '<o:UsernameToken>'
                            + '<o:Username>*</o:Username>'
                            + '<o:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">*</o:Password>'
                        + '</o:UsernameToken>'
                        + '</o:Security>'
                    + '</s:Header>'
                    + '<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
                        + '<UpdateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
                            + '<Objects xsi:type="Subscriber">'
                                + '<SubscriberKey>' + subscriber.SubscriberKey + '</SubscriberKey>'
                                + '<EmailAddress>' + subscriber.EmailAddress + '</EmailAddress>'
                                + '<Attributes>'
                                    + '<Name>LLYSubscriberKey</Name>'
                                    + '<Value>' + subscriber.LLYSubscriberKey + '</Value>'
                                + '</Attributes>'
                                + '<Attributes>'
                                    + '<Name>SubscriberType</Name>'
                                    + '<Value>' + subscriber.SubscriberType + '</Value>'
                                + '</Attributes>'
                            + '</Objects>'
                        + '</UpdateRequest>'
                    + '</s:Body>'
                + '</s:Envelope>';
            return bodyXML;
        }

        private String parseSubscriberUpdateResponse(String responseBody){
            String result;
            if (responseBody.subStringBetween('<OverallStatus>', '</OverallStatus>') == 'ERROR') {
                result = responseBody.subStringBetween('<StatusMessage>', '</StatusMessage>');
                System.Debug('ERROR in Subscriber retrieval: ' + result);
                return result;
            } else {
                return '';
            }
        }

        private HttpResponse PostSoapAction(String body, String action){
            Http httpClient = new Http();
            HttpRequest httpRequest = new HttpRequest();

            httpRequest.setTimeout(DefaultTimeout);
            httpRequest.setEndpoint(soapAPIUrl);
            httpRequest.setMethod(PostMethod);
            httpRequest.setHeader(ContentType, XMLType);
            httpRequest.setHeader(SoapAction, action);
            httpRequest.setBody(body);

            HttpResponse response = new HttpResponse();
            try
            {
                response = httpClient.send(httpRequest);
            }
            catch(Exception ex){
                System.debug(ex);
            }
            return response;
        }
    }

    @TestVisible
    private class FuelRequestBody {
        public String clientId { get; private set; }
        public String clientSecret { get; private set; }
        public String scope {
            get {
                return 'cas:' + scope;
                //return scope;
            }
            private set;
        }

        public FuelRequestBody(String cId, String cSecret, String s) {
            this.clientId = cId;
            this.clientSecret = cSecret;
            this.scope = s;
        }
    }

    // private class to simplify deserializing the fuel authorization response
    @TestVisible
    private class FuelResponseBody {
        public String accessToken { get; set;}
        public Integer expiresIn { get; set;}
        public String legacyToken { get; set;}
    }

    public virtual class Entry
    {
        public String id { get; set;}
        public String name { get; set;}
        public String description { get; set;}
    }

    public virtual class ListResponse
    {
        public Integer startIndex { get; set;}
        public Integer itemsPerPage { get; set;}
        public Integer totalResults { get; set;}
    }

    public class KeyValue {
        public String key { get; set;}
        public String value { get; set;}
    }

    public class EmailFolderResponse extends ListResponse {
        public List<EmailFolder> entry { get; set;}
    }
    
    public class EmailFolder extends Entry
    {
        public String type { get; set;}
        public String lastUpdated { get; set;}
        public String createdBy { get; set;}
        public String parentId { get; set;}
        public String iconType { get; set;}
        public List<EmailFolder> subfolders { get; set;}
        public List<FolderedEmail> emails { get; set;}
    }

    public class EmailResponse extends ListResponse {
        public List<FolderedEmail> entry { get; set;}
    }

    public class FolderedEmail {
        public String id { get; set; }
        public String name { get; set { name = value; encodedName = (name == null ? null : EncodingUtil.urlEncode(name,'UTF-8')); } }
        public String encodedName { get; set; }
        public String subject { 
            get { 
                if(subject == null && email != null){
                    subject = email.subject;
                }
                return subject;
            } 
            set; 
        }
        public String encodedSubject { 
            get { 
                if(encodedSubject == null && email != null && email.subject != null){
                    encodedSubject = EncodingUtil.urlEncode(email.subject,'UTF-8');
                }
                return encodedSubject;
            } 
            private set;
        }
        public String categoryId { get; set; }
        public Email email { get; set; }
     
        //constructor required for comparable interface implementation - no code inside required
        public FolderedEmail(){ 
        }
      
        public Integer compareTo(Object compareTo){
            try
            {
                return name.toUpperCase().compareTo(((FolderedEmail) compareTo).name.toUpperCase());
            }
            catch (exception e)
            {
                return 0;
            }
       }
    }

    public class Email {
        public String id { get; set; }
        public String type { get; set; }
        public KeyValue status { get; set; }
        public String name { get; set; }
        public String subject { get; set; }
        public String categoryId { get; set; }
        public String customerKey { get; set; }
        public Boolean sampleAudienceOnly { get; set; }
        public String preheader { get; set; }
        public Integer emailType { get; set; }
        public Integer messageId { get; set; }
    }

    public class EntryType extends Entry
    {

    }

    public class SendClassification extends Entry
    {
        public String key { get; set; }
        public Boolean honorListLevelOptOut { get; set; }
        public String senderProfileId { get; set; }
        public String deliveryProfileId { get; set; }
        public EntryType classificationType { get; set; }
    }

    public class SendClassificationResponse extends ListResponse
    {
        public List<SendClassification> entry { get; set; }
    }
    
    public class SenderProfile extends Entry
    {
        public String key { get; set; }
        public String profileName { get; set; }
        public String fromEmail { get; set; }
        public String fromName { get; set; }
    }

    public class SenderProfileResponse extends ListResponse
    {
        public List<SenderProfile> entry { get; set; }
    }

    public class DataExtension {
        public DataExtension() {}

        public DataExtension(String name, String des, String key, Datetime expireIn) {
            this.dataExtensionName = name;
            this.description = des;
            this.key = key;

            this.isPublic = true;
            this.isSendable = true;
            this.isTestable = true;

            this.field = new List<Field>();
            this.retentionPolicy = new List<RetentionPolicy>();
            this.retentionPolicy.add(new RetentionPolicy(false, false, String.valueOf(expireIn), false));
        }

        public String dataExtensionName { get; set; }
        public String description { get; set; }
        public List<Field> field { get; set; }
        public Boolean isPublic { get; set; }
        public Boolean isSendable { get; set; }
        public Boolean isTestable { get; set; }
        public String key { get; set; }
        public List<RetentionPolicy> retentionPolicy { get; set; }
        public String sendableDataExtensionField { get; set; }
    }

    public class Field {
        public String fieldName { get; set; }
        public String fieldType { get; set; }
        public Object id { get; set; }
        public Boolean isPrimaryKey { get; set; }
        public Boolean isTemplateField { get; set; }
        public String length { get; set; }
        public Boolean nullable { get; set; }
        public Object scale { get; set; }
    }

    public class FieldEntry {
        public String fieldName { get; set; }
        public String fieldValue { get; set; }
    }

    public class RetentionPolicy {
        public RetentionPolicy(Boolean deleteAtEnd, Boolean resetOnImport, String until, Boolean rowBased) {
            this.DeleteAtEndOfRetentionPeriod = deleteAtEnd;
            this.ResetRetentionPeriodOnImport = resetOnImport;
            this.RetainUntil = until;
            this.RowBasedRetention = rowBased;
        }
        public Boolean DeleteAtEndOfRetentionPeriod { get; set; }
        public Boolean ResetRetentionPeriodOnImport { get; set; }
        public String RetainUntil { get; set; }
        public Boolean RowBasedRetention { get; set; }
    }

    public class DataExtensionResponse {
        public String id { get; set; }
    }

    public class DataExtensionEntry {
        public FieldEntry keys { get; set; }
        public List<FieldEntry> values { get; set; }
    }

    public class MarketingCloudClientException extends Exception {}

    public class ImageThumbnailSecureResponse {
        public String data { get; set; }
    }

    public class SendDefinition {
        public SendDefinition() {}

        public SendDefinition(String dataExtensionId,
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

        public String dataExtensionId { get; set; }
        public Boolean deduplicateByEmail { get; set; }
        public String description { get; set; }
        public Integer emailId { get; set; }
        public Boolean isMultipart { get; set; }
        public Boolean isWrapped { get; set; }
        public String key { get; set; }
        public String name { get; set; }
        public String type { get; set; }
        public String emailSubject { get; set; }
        public String sendClassificationId { get; set; }
        public String senderProfileId { get; set; }
    }

    public class CreateSendDefinitionResponse {
        public String id { get; set; }
    }

    public class StartSendDefinitionResponse {
        public String id { get; set; }
        public String statusMessage { get; set; }
        public String jobId { get; set; }
        public String clientId { get; set; }
    }

    public class CheckSendDefinitionStatusResponse {
        public String id { get; set; }
        public String sendStatus { get; set; }
        public String jobId { get; set; }
        public String clientId { get; set; }
    }

    public class Subscriber {

        public String SubscriberKey { get; set; }
        public String LLYSubscriberKey { get; set; }
        public String EmailAddress { get; set; }
        public String SubscriberType { get; set; }

        public Subscriber(String subKey, String LLYkey, String email, String subType) {
            this.SubscriberKey = subKey;
            this.LLYSubscriberKey = LLYkey;
            this.EmailAddress = email;
            this.SubscriberType = subType;
        }

    }
}