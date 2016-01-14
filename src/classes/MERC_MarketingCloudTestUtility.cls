/*
* MERC_MarketingCloudTestUtility
* Description: Utility for MarketingCloud Test Classes
* Author: David Helmer
* Modified By: 
* Modified Date: Dec. 14th 2015
*/
@isTest
public with sharing class MERC_MarketingCloudTestUtility {
    public static final String CONFIG_USERNAME = 'username@test.test';
    public static final String CONFIG_PASSWORD = 'atestpassword';
    public static final String CONFIG_AUTH_API_URL = 'https://webservice-auth.s9.test.com/Authentication/Auth.svc';
    public static final String CONFIG_ROOT_REST_API_URL = 'https://rest.s9.test.com';
    public static final String CONFIG_ROOT_THUMBNAIL_API_URL = 'https://mc.s9.test.com';
    public static final String CONFIG_ROOT_SOAP_API_URL = 'https://webservice.s6.test.com/Service.asmx';
    public static final String CONFIG_INTEGRATION_TYPE_ENTERPRISE = 'Enterprise2.0';
    public static final String CONFIG_INTEGRATION_TYPE_DEFAULT = 'testintegrationtype';
    public static final String CONFIG_URL_ROOT = 'mc';
    public static final String CONFIG_URL_PART = 'cloud';

    public static final String BUSINESS_UNIT_ID = '55555555';
    public static final String BUSINESS_UNIT_NAME = 'testbusinessunitname';

    public static final String SETTING_APPLICATION_ID = 'testapplicationid';

    private static final String POST_METHOD = 'POST';
    private static final String GET_METHOD = 'GET';
    private static final String SOAP_ACTION_KEY = 'SOAPAction';
    private static final String CONTENT_TYPE_KEY = 'Content-Type';
    private static final String ACCEPT_TYPE_KEY = 'Accept';
    private static final String XML_CHARSET_TYPE = 'text/xml; charset=UTF-8';
    private static final String JSON_TYPE = 'application/json';
    private static final String JSON_CHARSET_TYPE =  'application/json; charset=UTF-8';
    private static final String AUTHORIZATION_KEY = 'authorization';
    private static final String UPDATE_ACTION = 'Update';
    private static final String RETRIEVE_ACTION = 'Retrieve';

    public static final String USER_OAUTH_TOKEN = 'testuseroauthtoken';
    public static final String USER_MARKETING_CLOUD_USER_NAME = 'testuser';
    public static final String USER_EMAIL = 'testuseremail@test.test';
    public static final String USER_ALIAS = 'mctest';
    public static final String USER_EMAIL_ENCODING_KEY = 'UTF-8';
    public static final String USER_LAST_NAME = 'testlastname';
    public static final String USER_LOCALE_KEY = 'en_US';
    public static final String USER_LOCALED_SID_KEY = 'en_US';
    public static final String USER_TIME_ZONE_SID_KEY = 'America/Los_Angeles';
    public static final String USER_USER_NAME = 'marketing_cloud_user@test.test';

    public static final String SOAP_OAUTH_TOKEN = 'validsoaptoken';

    public static final String FUEL_CLIENT_ID = 'samplefuelclientid';
    public static final String FUEL_SECRET = 'samplefueldsecret';
    public static final String FUEL_AUTH_URL = 'https://auth.exacttargetapis.test.com';
    public static final String FUEL_ROOT_URL = 'https://www.exacttargetapis.test.com';
    public static final String FUEL_ACCESS_TOKEN = 'validfuelaccesstoken';

    public static final String PROFILE_DEFAULT_NAME = 'Standard User';

    private static Integer UserCount = 0;
    private static Map<String, Profile> ProfileMap = new Map<String, Profile>();

    public static et4ae5__Business_Unit__c insertBusinessUnit(){
        et4ae5__Business_Unit__c businessUnit = new et4ae5__Business_Unit__c(
            et4ae5__Business_Unit_ID__c = BUSINESS_UNIT_ID,
            Name = BUSINESS_UNIT_NAME,
            et4ae5__Enabled__c = true);
        insert businessUnit;

        return businessUnit;
    }

	public static et4ae5__configuration__c insertConfiguration(Boolean isEnterprise){
        et4ae5__configuration__c configuration = new et4ae5__configuration__c(
            et4ae5__UserName__c = CONFIG_USERNAME,
            et4ae5__Password__c = CONFIG_PASSWORD, 
            et4ae5__Auth_API_URL__c = CONFIG_AUTH_API_URL,
            et4ae5__Root_Rest_API_URL__c = CONFIG_ROOT_REST_API_URL,
            et4ae5__Root_SOAP_API_URL__c = CONFIG_ROOT_SOAP_API_URL,
            et4ae5__integration_type__c = (isEnterprise ? CONFIG_INTEGRATION_TYPE_ENTERPRISE : CONFIG_INTEGRATION_TYPE_DEFAULT),
            et4ae5__url_root__c = CONFIG_URL_ROOT,
            et4ae5__url_part__c = CONFIG_URL_PART);
        insert configuration;

        return configuration;
    }

    public static Mercury_Marketing_Cloud_Settings_MERC__c insertSettings(){
        Mercury_Marketing_Cloud_Settings_MERC__c settings = new Mercury_Marketing_Cloud_Settings_MERC__c(
            Enterprise_Integration_Type_MERC__c = CONFIG_INTEGRATION_TYPE_DEFAULT,
            Business_Unit_Name_MERC__c  = BUSINESS_UNIT_NAME,
            Fuel_API_Client_ID_MERC__c = FUEL_CLIENT_ID,
            Fuel_API_Client_Secret_MERC__c = FUEL_SECRET,
            Fuel_API_Auth_Root_URL_MERC__c = FUEL_AUTH_URL,
            Fuel_API_Root_URL_MERC__c = FUEL_ROOT_URL,
            Application_ID_MERC__c = SETTING_APPLICATION_ID
        );

        insert settings;

        return settings;
    }

    public static User insertUser(){
        return insertUser(PROFILE_DEFAULT_NAME);
    }

    public static User insertUser(String profileName){
        User marketingCloudUser = new User(
            et4ae5__exacttarget_oauth_token__c = USER_OAUTH_TOKEN,
            et4ae5__exactTargetUsername__c = USER_MARKETING_CLOUD_USER_NAME,
            Email = USER_EMAIL, 
            Alias = USER_ALIAS,
            EmailEncodingKey = USER_EMAIL_ENCODING_KEY, 
            LastName = USER_LAST_NAME, 
            LanguageLocaleKey = USER_LOCALE_KEY, 
            LocaleSidKey= USER_LOCALED_SID_KEY, 
            ProfileId = GetProfile(profileName).Id, 
            TimeZoneSidKey = USER_TIME_ZONE_SID_KEY, 
            UserName = USER_USER_NAME);

        insert marketingCloudUser;

        return marketingCloudUser;
    }

    public static Profile getProfile(String profileName){
        if (!ProfileMap.containsKey(profileName)) {
            Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];
            ProfileMap.put(profileName, profile);
        }
        return ProfileMap.get(profileName);
    }

    public static MERC_MockHttpResponseService withDefaultMockService(User testUser){
        MERC_MockHttpResponseService mockService = new MERC_MockHttpResponseService();

        mockService.addResponse(MERC_MarketingCloudTestUtility.getMockSoapAuthRequest(testUser, true));
        mockService.addResponse(MERC_MarketingCloudTestUtility.getMockSoapAuthRequest(testUser, false));
        mockService.addResponse(MERC_MarketingCloudTestUtility.getMockFuelAuthRequest());

        return mockService;
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getMockSoapAuthRequest(User user, Boolean withScope){
        String scope = null;
        if(withScope){
            scope = 'scope=' + user.et4ae5__exacttarget_oauth_token__c;
        }
        String requestBody = getSoapAuthTokenRequestXML(CONFIG_USERNAME, CONFIG_PASSWORD, SETTING_APPLICATION_ID, scope);
        String responseBody = getSoapAuthTokenResponseXML(SOAP_OAUTH_TOKEN);

        MERC_MockHttpResponseService.BasicMockPostResponse mockResponse = new MERC_MockHttpResponseService.BasicMockPostResponse(
            CONFIG_AUTH_API_URL,
            XML_CHARSET_TYPE,
            null,
            requestBody,
            responseBody);

        return (MERC_MockHttpResponseService.MockResponseInterface)mockResponse;
    }

    private static String getSoapAuthTokenRequestXML(String userName, String password, String applicationId, String scope){
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

    private static String getSoapAuthTokenResponseXML(String accessToken){
         return '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' + 
                   '<s:Header>' + 
                       '<ActivityId CorrelationId="9d0bf765-9b54-4b11-b260-f829d1ab310d" xmlns="http://schemas.microsoft.com/2004/09/ServiceModel/Diagnostics">5b748660-10b5-44b6-9b58-c44d9c158825</ActivityId>' + 
                       '<o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">' + 
                           '<u:Timestamp u:Id="_0">' + 
                               '<u:Created>2015-12-22T21:16:01.495Z</u:Created>' + 
                               '<u:Expires>2015-12-22T21:21:01.495Z</u:Expires>' + 
                           '</u:Timestamp>' + 
                       '</o:Security>' + 
                   '</s:Header>' + 
                   '<s:Body>' + 
                       '<OAuthLoginResponse xmlns="urn:authentication.exacttarget.com/2010/06/11">' + 
                           '<OAuthLoginResult xmlns:i="http://www.w3.org/2001/XMLSchema-instance">' + 
                               '<Endpoints>' + 
                                   '<Endpoint>' + 
                                       '<Url>https://members.s6.exacttarget.com</Url>' + 
                                       '<Name>Application</Name>' + 
                                   '</Endpoint>' + 
                                   '<Endpoint>' + 
                                       '<Url>https://webservice-auth.s6.exacttarget.com/Authentication/Auth.svc</Url>' + 
                                       '<Name>Authentication</Name>' + 
                                   '</Endpoint>' + 
                                   '<Endpoint>' + 
                                       '<Url>ftp://ftp.s6.exacttarget.com</Url>' + 
                                       '<Name>Ftp</Name>' + 
                                   '</Endpoint>' + 
                                   '<Endpoint>' + 
                                       '<Url>https://rest.s6.exacttarget.com</Url>' + 
                                       '<Name>Rest</Name>' + 
                                   '</Endpoint>' + 
                                   '<Endpoint>' + 
                                       '<Url>https://webservice.s6.exacttarget.com/Service.asmx</Url>' + 
                                       '<Name>SoapAsync</Name>' + 
                                   '</Endpoint>' + 
                                   '<Endpoint>' + 
                                       '<Url>https://etappx.s6.exacttarget.com/Service.asmx</Url>' + 
                                       '<Name>SoapSalesForceSync</Name>' + 
                                   '</Endpoint>' + 
                                   '<Endpoint>' + 
                                       '<Url>https://webservice.s6.exacttarget.com/Service.asmx</Url>' + 
                                       '<Name>SoapSync</Name>' + 
                                   '</Endpoint>' + 
                                   '<Endpoint>' + 
                                       '<Url>http://api.s6.exacttarget.com/api/integrate.aspx</Url>' + 
                                       '<Name>XmlSync</Name>' + 
                                   '</Endpoint>' + 
                               '</Endpoints>' + 
                               '<ValidNoLongerThan>' + 
                                   '<Created>2015-12-22T21:16:01.4959732Z</Created>' + 
                                   '<Expires>2015-12-23T21:16:01.4959732Z</Expires>' + 
                               '</ValidNoLongerThan>' + 
                               '<OAuthToken xmlns:a="urn:authentication.exacttarget.com/2011/03/11">' + 
                                   '<a:AccessToken>' + accessToken + '</a:AccessToken>' + 
                                   '<a:ExpiryDateTime>2015-12-22T21:36:01.4959732Z</a:ExpiryDateTime>' + 
                                   '<a:RefreshToken>0VAtWuamgfHpRRo0YyL1rHPL6cep-6o6p1cOyRP2JKwTWKoEOJ2YBY_idMoc4Dxrr5pB1KgYe9W5u5DiLvYSmkCNN0PuNGFisH0wQNsMtxoB02aoRsNS-bFv0qncJddWt98xQKc5BhFaTfdfSo_IH-g</a:RefreshToken>' + 
                                   '<a:ExpiresIn>1200</a:ExpiresIn>' + 
                               '</OAuthToken>' + 
                               '<HasError>false</HasError>' + 
                               '<Error i:nil="true"/>' + 
                           '</OAuthLoginResult>' + 
                       '</OAuthLoginResponse>' + 
                   '</s:Body>' + 
              '</s:Envelope>'; 
    }

    public static String getFuelAuthTokenRequestJSON(String clientId, String clientSecret, String scope){
        return  '   {  '  + 
                '       "scope": "' + scope + '",  ' +
                '       "clientSecret": "' + clientSecret + '",  '  +  
                '       "clientId": "' + clientId + '"  '  + 
                '   }  ' ; 
    }
    public static String getFuelAuthTokenResponseJSON(String accessToken){
        return  '   {  '  + 
                '     "accessToken": "' + accessToken + '",  '  + 
                '     "expiresIn": 1200,  '  + 
                '     "legacyToken": "0oQdz6T0ywdkB-PJLylmCEsQV5YpUFaNh4UzQlzi_nwJJiwKeEZC2b75g7YPwaNnRO2K1CRnbq9CaJ5gxQFU7nnVRdWFehpc59f0UdXzBtEe2Cg66Tefhov1lGK4e46edUUk9BYeTTzQ5rniFn3Xn6TVR9y6nBs-CCUcrJ6Mw6bKV8D-DZjgVXORXvyI2QyzuwamRn9XzwUy0NZsFrWp6hVWYKjhjtrlvNYc2RdcV7Qpt3MuIq4g4ljJOlZ0NFPTx"  '  + 
                '   }  ' ; 
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getMockFuelAuthRequest(){
        String requestBody = getFuelAuthTokenRequestJSON(FUEL_CLIENT_ID, FUEL_SECRET, SOAP_OAUTH_TOKEN);
        String responseBody = getFuelAuthTokenResponseJSON(FUEL_ACCESS_TOKEN);
        String requestURL = FUEL_AUTH_URL + '/v1/requestToken?legacy=1';

        MERC_MockHttpResponseService.BasicMockPostResponse mockResponse = new MERC_MockHttpResponseService.BasicMockPostResponse(
            requestURL,
            JSON_TYPE,
            JSON_TYPE,
            requestBody,
            responseBody);

        return (MERC_MockHttpResponseService.MockResponseInterface)mockResponse;
    }

    public static String getGetEmailFoldersResponseJSON(){
        return  '   {  '  + 
                '     "startIndex": 0,  '  + 
                '     "itemsPerPage": 50,  '  + 
                '     "totalResults": 2,  '  + 
                '     "entry": [  '  + 
                '       {  '  + 
                '         "id": "20690",  '  + 
                '         "type": "shared_item",  '  + 
                '         "lastUpdated": "2016-01-05T21:27:25.287Z",  '  + 
                '         "createdBy": 0,  '  + 
                '         "parentId": "0",  '  + 
                '         "name": "Shared Items",  '  + 
                '         "description": "",  '  + 
                '         "iconType": "shared_item"  '  + 
                '       },  '  + 
                '       {  '  + 
                '         "id": "23172",  '  + 
                '         "type": "email",  '  + 
                '         "lastUpdated": "2016-01-05T21:27:25.287Z",  '  + 
                '         "createdBy": 0,  '  + 
                '         "parentId": "0",  '  + 
                '         "name": "my emails",  '  + 
                '         "description": "",  '  + 
                '         "iconType": "email"  '  + 
                '       }  '  + 
                '     ]  '  + 
                '  }  ' ;
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getMockGetEmailFoldersRequest(String folderId){
        String responseBody = getGetEmailFoldersResponseJSON();
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/folder/' + folderId + '/children/?oauth_token='+SOAP_OAUTH_TOKEN+'&where=allowedtypes+in+(\'email\',\'shared_type\',\'global+email\',\'shared_email\',\'shared_item\')';

        MERC_MockHttpResponseService.BasicMockGetResponse mockResponse = new MERC_MockHttpResponseService.BasicMockGetResponse(
            requestURL,
            JSON_TYPE, JSON_TYPE,
            responseBody);

        return mockResponse;
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getMockGetEmailFoldersAllRequest(){
        String responseBody = getGetEmailFoldersResponseJSON();
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/folder/?oauth_token='+SOAP_OAUTH_TOKEN+'&where=allowedtypes+in+(\'email\',\'shared_type\',\'global+email\',\'shared_email\',\'shared_item\')';

        MERC_MockHttpResponseService.BasicMockGetResponse mockResponse = new MERC_MockHttpResponseService.BasicMockGetResponse(
            requestURL,
            JSON_TYPE, JSON_TYPE,
            responseBody);

        return mockResponse;
    }

    public static String getGetEmailsResponseJSON(){
        return  '   {  '  + 
                '     "startIndex": 0,  '  + 
                '     "itemsPerPage": 50,  '  + 
                '     "totalResults": 2,  '  + 
                '     "entry": [  '  + 
                '       {  '  + 
                '         "id": "37238",  '  + 
                '         "name": "TBD - Text Email for Testing Send",  '  + 
                '         "categoryId": "31850",  '  + 
                '         "email": {  '  + 
                '           "id": "37238",  '  + 
                '           "type": "ExactTarget.APIImplementations.Folder.Rest.Impl.EmailContentEntity",  '  + 
                '           "createdDate": "2015-07-17T16:25:07Z",  '  + 
                '           "lastUpdated": "2015-07-17T16:25:20Z",  '  + 
                '           "status": {  '  + 
                '             "key": "Status",  '  + 
                '             "value": "New"  '  + 
                '           },  '  + 
                '           "name": "TBD - Text Email for Testing Send",  '  + 
                '           "subject": "TBD - Text Email for Testing Send",  '  + 
                '           "categoryId": "31850",  '  + 
                '           "customerKey": "8B75E42B-2EE0-4BE8-B036-A0EB4C42A1F3",  '  + 
                '           "sampleAudienceOnly": false,  '  + 
                '           "preheader": "",  '  + 
                '           "emailType": "1",  '  + 
                '           "messageId": "0"  '  + 
                '         }  '  + 
                '       },  '  + 
                '       {  '  + 
                '         "id": "40340",  '  + 
                '         "name": "CMS-Meeting Participant-Confirmed Travel Itineraries",  '  + 
                '         "categoryId": "31850",  '  + 
                '         "email": {  '  + 
                '           "id": "40340",  '  + 
                '           "type": "ExactTarget.APIImplementations.Folder.Rest.Impl.EmailContentEntity",  '  + 
                '           "createdDate": "2015-09-10T21:05:57Z",  '  + 
                '           "lastUpdated": "2015-09-11T12:14:37Z",  '  + 
                '           "status": {  '  + 
                '             "key": "Status",  '  + 
                '             "value": "New"  '  + 
                '           },  '  + 
                '           "name": "CMS-Meeting Participant-Confirmed Travel Itineraries",  '  + 
                '           "subject": "CMS-Meeting Participant-Confirmed Travel Itineraries",  '  + 
                '           "categoryId": "31850",  '  + 
                '           "customerKey": "FE8D8B43-6A52-452D-8CB8-B642A1EF4CCB",  '  + 
                '           "sampleAudienceOnly": false,  '  + 
                '           "preheader": "",  '  + 
                '           "emailType": "0",  '  + 
                '           "messageId": "0"  '  + 
                '         }  '  + 
                '       }  '  + 
                '     ]  '  + 
                '  }  ' ; 
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getMockGetEmailsRequest(String folderId){
        String responseBody = getGetEmailFoldersResponseJSON();
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/folder/' + folderId + '/contents/?oauth_token='+SOAP_OAUTH_TOKEN+'&where=type+eq+\'email\'';

        MERC_MockHttpResponseService.BasicMockGetResponse mockResponse = new MERC_MockHttpResponseService.BasicMockGetResponse(
            requestURL,
            JSON_TYPE, JSON_TYPE,
            responseBody);

        return mockResponse;
    }

    public static String getGetClassificationsResponseJSON(){
        return  '   {  '  + 
                '     "startIndex": 0,  '  + 
                '     "itemsPerPage": 50,  '  + 
                '     "totalResults": 3,  '  + 
                '     "entry": [  '  + 
                '       {  '  + 
                '         "id": "RG50VkVFaW9FZVNWRkt3V0xiR1lCQTo0OTow",  '  + 
                '         "key": "Default Commercial",  '  + 
                '         "createdDate": "2014-09-30T13:46:00Z",  '  + 
                '         "lastUpdated": "2014-09-30T13:46:00Z",  '  + 
                '         "name": "Default Commercial",  '  + 
                '         "description": "Default Commercial Send Classification",  '  + 
                '         "senderProfileId": "Q0lDeDhVaW9FZVNWRkt3V0xiR1lCQTo0Nzow",  '  + 
                '         "deliveryProfileId": "RG50VkQwaW9FZVNWRkt3V0xiR1lCQTo0ODow",  '  + 
                '         "classificationType": {  '  + 
                '           "id": "2",  '  + 
                '           "name": "Default Commercial"  '  + 
                '         }  '  + 
                '       },  '  + 
                '       {  '  + 
                '         "id": "RG50VkVVaW9FZVNWRkt3V0xiR1lCQTo0OTow",  '  + 
                '         "key": "Default Transactional",  '  + 
                '         "createdDate": "2014-09-30T13:46:00Z",  '  + 
                '         "lastUpdated": "2014-09-30T13:46:00Z",  '  + 
                '         "name": "Default Transactional",  '  + 
                '         "description": "Default Transactional Send Classification",  '  + 
                '         "honorListLevelOptOut": false,  '  + 
                '         "senderProfileId": "Q0lDeDhVaW9FZVNWRkt3V0xiR1lCQTo0Nzow",  '  + 
                '         "deliveryProfileId": "RG50VkQwaW9FZVNWRkt3V0xiR1lCQTo0ODow",  '  + 
                '         "classificationType": {  '  + 
                '           "id": "1",  '  + 
                '           "name": "Default Transactional"  '  + 
                '         }  '  + 
                '       },  '  + 
                '       {  '  + 
                '         "id": "TkJoemdFc2FFZVNWRkt3V0xiR1lCQTo0OTow",  '  + 
                '         "key": "Mercury Transactional",  '  + 
                '         "createdDate": "2014-10-03T16:28:00Z",  '  + 
                '         "lastUpdated": "2014-10-15T18:27:00Z",  '  + 
                '         "name": "Mercury Transactional",  '  + 
                '         "description": "Used for the Mercury SFDC ET Integration",  '  + 
                '         "honorListLevelOptOut": false,  '  + 
                '         "senderProfileId": "QklZQkpVc2FFZVNWRkt3V0xiR1lCQTo0Nzow",  '  + 
                '         "deliveryProfileId": "N0RLOXgxUnlFZVNWRkt3V0xiR1lCQTo0ODow",  '  + 
                '         "classificationType": {  '  + 
                '           "id": "1",  '  + 
                '           "name": "Default Transactional"  '  + 
                '         }  '  + 
                '       }  '  + 
                '     ]  '  + 
                '  }  ' ; 
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getClassificationsRequest(){
        String responseBody = getGetClassificationsResponseJSON();
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/messaging/sendclassification/?oauth_token='+SOAP_OAUTH_TOKEN;

        MERC_MockHttpResponseService.BasicMockGetResponse mockResponse = new MERC_MockHttpResponseService.BasicMockGetResponse(
            requestURL,
            JSON_TYPE, JSON_TYPE,
            responseBody);

        return mockResponse;
    }

    public static String getGetSenderProfilesResponseJSON(){
        return  '   {  '  + 
                '     "startIndex": 0,  '  + 
                '     "itemsPerPage": 50,  '  + 
                '     "totalResults": 4,  '  + 
                '     "entry": [  '  + 
                '       {  '  + 
                '         "id": "ZDVNQ0prZFVFZVdWRkt3V0xiR1lCQTo0Nzow",  '  + 
                '         "key": "3221",  '  + 
                '         "createdDate": "8/20/2015 10:00:00 AM",  '  + 
                '         "lastUpdated": "2015-08-20T16:00:00Z",  '  + 
                '         "profileName": "1440086382728gso_noreply@lilly.com",  '  + 
                '         "fromEmail": "gso_noreply@lilly.com",  '  + 
                '         "fromName": "gso_noreply@lilly.com"  '  + 
                '       },  '  + 
                '       {  '  + 
                '         "id": "Z0NKc2ZrZFdFZVdWRkt3V0xiR1lCQTo0Nzow",  '  + 
                '         "key": "3222",  '  + 
                '         "createdDate": "8/20/2015 10:14:00 AM",  '  + 
                '         "lastUpdated": "2015-08-20T16:14:00Z",  '  + 
                '         "profileName": "1440087255733null",  '  + 
                '         "fromEmail": "%%recordOwnerEmail%%",  '  + 
                '         "fromName": "%%recordOwnerName%%"  '  + 
                '       },  '  + 
                '       {  '  + 
                '         "id": "cWdQbVRrZ0JFZVdWRkt3V0xiR1lCQTo0Nzow",  '  + 
                '         "key": "3227",  '  + 
                '         "createdDate": "8/21/2015 6:40:00 AM",  '  + 
                '         "lastUpdated": "2015-08-21T12:40:00Z",  '  + 
                '         "profileName": "1440160772071gso_noreply@lilly.com",  '  + 
                '         "fromEmail": "gso_noreply@lilly.com",  '  + 
                '         "fromName": "gso_noreply@lilly.com"  '  + 
                '       },  '  + 
                '       {  '  + 
                '         "id": "RXJCMGlpNzdFZVdWRkt3V0xiR1lCQTo0Nzow",  '  + 
                '         "key": "3140",  '  + 
                '         "createdDate": "7/20/2015 10:19:00 AM",  '  + 
                '         "lastUpdated": "2015-07-20T16:19:00Z",  '  + 
                '         "profileName": "tmburton@lilly.com2015-07-20 17:19:28",  '  + 
                '         "fromEmail": "tmburton@lilly.com",  '  + 
                '         "fromName": "Tom Burton"  '  + 
                '       }  '  + 
                '     ]  '  + 
                '  }  ' ; 
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getSenderProfilesRequest(){
        String responseBody = getGetSenderProfilesResponseJSON();
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/messaging/senderprofile/?oauth_token='+SOAP_OAUTH_TOKEN;

        MERC_MockHttpResponseService.BasicMockGetResponse mockResponse = new MERC_MockHttpResponseService.BasicMockGetResponse(
            requestURL,
            JSON_TYPE, JSON_TYPE,
            responseBody);

        return mockResponse;
    }

    public static String getCreateSendDefinitionRequestJSON(MERC_MarketingCloudClient.SendDefinition sendDefinition){
        return  '   {  '  + 
                '       "type":"' + sendDefinition.type + '",  '  + 
                '       "senderProfileId":"' + sendDefinition.senderProfileId + '",  '  + 
                '       "sendClassificationId":"' + sendDefinition.sendClassificationId + '",  '  + 
                '       "name":"' + sendDefinition.name + '",  '  + // LillySendDef1984-01-31 07:08:16a1y11000000euYLAAY
                '       "key":"' + sendDefinition.key + '",  '  + //444380896000
                '       "isWrapped":' + sendDefinition.isWrapped + ',  '  + 
                '       "isMultipart":' + sendDefinition.isMultipart + ',  '  + 
                '       "emailSubject":"' + sendDefinition.emailSubject + '",  '  + 
                '       "emailId":' + sendDefinition.emailId + ',  '  + 
                '       "description":"' + sendDefinition.description + '",  '  + 
                '       "deduplicateByEmail":' + sendDefinition.deduplicateByEmail + ',  '  + 
                '       "dataExtensionId":"' + sendDefinition.dataExtensionId + '"  '  + 
                '  }  ' ;
    }

    public static String getCreateSendDefinitionResponseJSON(){
        return '{"id":"OVdFVXRyVm9FZVdXYll6YzFMZmFMUTo1MDow"}';
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getCreateSendDefinitionRequest(MERC_MarketingCloudClient.SendDefinition sendDefinition){
        String requestBody = getCreateSendDefinitionRequestJSON(sendDefinition);
        String responseBody = getCreateSendDefinitionResponseJSON();
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/messaging/senddefinition/instance/?oauth_token=' + SOAP_OAUTH_TOKEN;

        MERC_MockHttpResponseService.BasicMockPostResponse mockResponse = new MERC_MockHttpResponseService.BasicMockPostResponse(
            requestURL,
            JSON_TYPE,
            JSON_TYPE,
            requestBody,
            responseBody);

        mockResponse.withAuthorization('Bearer ' + SOAP_OAUTH_TOKEN);

        return (MERC_MockHttpResponseService.MockResponseInterface)mockResponse;
    }

    public static String getStartSendDefinitionResponseJSON(){
        return '{"id":"b61461f5-68b5-e511-966d-8cdcd4b7da2d","statusMessage":"EmailSendDefinition Executed","jobId":1219555,"clientId":6272686}';
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getStartSendDefinitionRequest(String sendDefinitionId){
        String responseBody = getStartSendDefinitionResponseJSON();
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/messaging/senddefinition/instance/' + EncodingUtil.urlEncode(sendDefinitionId,'UTF-8') + '/?action=start&oauth_token=' + SOAP_OAUTH_TOKEN;

        MERC_MockHttpResponseService.BasicMockGetResponse mockResponse = new MERC_MockHttpResponseService.BasicMockGetResponse(
            requestURL,
            JSON_TYPE, JSON_TYPE,
            responseBody);

        return mockResponse;
    }

    public static String getSendDefinitionStatusResponseJSON(){
        return '{"id":"MTIxOTU1NTo1MDow","sendStatus":"Processing","jobId":1219555,"clientId":6272686}';
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getSendDefinitionStatusRequest(String sendDefinitionId){
        String responseBody = getSendDefinitionStatusResponseJSON();
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/messaging/senddefinition/instance/' + EncodingUtil.urlEncode(sendDefinitionId,'UTF-8') + '/job/?oauth_token=' + SOAP_OAUTH_TOKEN;

        MERC_MockHttpResponseService.BasicMockGetResponse mockResponse = new MERC_MockHttpResponseService.BasicMockGetResponse(
            requestURL,
            JSON_TYPE, JSON_TYPE,
            responseBody);

        return mockResponse;
    }

    public static String getGetThumbnailResponseJSON(){
        return  '   { ' +
                '       "data": "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAEsASwDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD378KPwrIuNRuIbiRAyBFJA+XJHFCX904bdJEpHUbGbH5ZoA1/wo/CskX8xTIvLbcMdUYAg0gv5wDuvLbOOMI2OtAGv+FH4Vlm7uVVWe4gUHOMxsP6cU0XtyRu+025XuAjd/woA1vwo/Cshr64VsG7tcjA+4x5pxvLjcFW7tjkZyUYUAav4UfhWUb6cYH2m33YPBRhQb2fBZbq2xuxyjUAav4UfhWR9uueAbu25/6ZtmlF5cHazXduFIzxGxP+fagDW/Cj8Kykvbhjzc25wATtRuM/hSfb5sZ+1W3IJHyNkfUYoA1vwo/Cso30xyy3Ntt5Ayrdfy6Un264yf8ASbc46gI3fjPT1oA1vwo/Csk30y5X7XbFgefkbGPrSC/nwCby157BG/yKANSQzceUqH13sR/IU8bto3AZxzg1k/bp8M32u2Cg/wDPNuKT+0JgObmAHGc7G5HtxQBr/hR+FZP2+cMQbu1JAyQqsaf/AGhJGMNPbucZJwwxn8DQBp/hR+FUPt7AnLQj0+9g/pTRqfAzJByC2AW6e/HFAGj+FH4VnDUiQT5lvwSDhm/wpj6hKQStxboBwchjz+VAGp+FH4Vn/bCdubuNSwyP3Rx096QX6E/8fsZ9hEc0AaP4UfhWd9uCsytexkj0iP8Ak0q3mQG+1oV25z5Lc/SgDQ/Cj8Kyzfyl8R3FsRnurZP6Un9oS9rq2O4ZX5WyPwxQBq/hR+FZX26YcG6t8k8HY3+FBvpwo/0m2+8Ru2tjPp0/rQBq/hQTgZxWS1/LhQl5bEkfxI2Tj2pWvpiRsurYfLk7lb8e1AGX/wAIdaO5/wCJlroLEn/j8YCtWHQ44IxHHeX4UDvcEk/iadHeSPkm6hAHGVjZue/0q9BMssQdX3g99pH6VCpxWyOiWLry0lK5g3MavfTsCAwfnJ6elV49vmBjnb3x3q1dW6NeSnz41Jbp82f5UyS3RkCC5iGOoYMP6euas5x/2DcM+dbDdjhpMke1SrpFwYQEmjIY8kMSD+lVre2jJAWeNicfwsc/htrYTTlD5byyM5ICEf1oAof2LO2d8kbZORyeKcNHuNvMse7PvyK2ERY12oMD0p1AGKukXCs2x4lDYBOSSB7cUi6NcdZHicg8ZJ6Vt0UAYZ0Wcpt8yMZIz1p76PIWyrKADkfMcn9K2aKAMRdGnRgwlTK/d68H1p8WjzZ/eTIMchkB3ZrYooAyf7EHP+ktg9Rt60v9iJsAEzZzknb3rVooAyf7E9bkkYwRs/8Ar046P8m0XG0d8J1Pqea1KKAMuPRUjBxO+49DjpTRogTGy4wB6p/9etaigDKXRgrKwuDkdfl6+nelOj5BH2g7SckbO/51qUUAZUeiojE+cxz6LjBoTRVTH7/ocn5OtatFAGZ/Y4C7RcMMdDjnr9ab/Yv7pkF0w3HJIT861aKAMoaIqnKzFfolKNFRYtgmOcnDbecenvWpRQBk/wBinaR9qbJ77ef50v8AYo2hftDFQMKCvStWigDKXRAuMXByOny/Xr60p0ZcYWd1HpjitSigDJXRNoI+0sScc7e4/GlGigAD7Qeu4/IOTWrRQBl/2LGWyZOCMYC4pv8AYgxzcsSep2/pWtRQBlf2Kv8Az8N1yMr0oGirlS05baQcFfetWigCi+k27vuJkz7NVi2to7WHy492M5yxyTU1FAHP3FtK15KwikIJbop5zUU9rM4VjFKWI7Icf5/wrpaKAOetIbiOVdsJUju6Nge9b0fmbf3gUH/ZOafRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQB//2Q=="' +
                '   }';
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getThumbnailRequest(String emailId, String height, String width){
        String responseBody = getGetThumbnailResponseJSON();
        String requestURL = CONFIG_ROOT_THUMBNAIL_API_URL + '/' + CONFIG_URL_PART + '/utilities/ImageThumbnailSecure.ashx/?h=' + height + '&w=' + width + '&emailid=' + emailid+ '&oauth_token=' + SOAP_OAUTH_TOKEN;

        MERC_MockHttpResponseService.BasicMockGetResponse mockResponse = new MERC_MockHttpResponseService.BasicMockGetResponse(
            requestURL,
            JSON_TYPE, JSON_TYPE,
            responseBody);

        return mockResponse;
    }

    public static String getCreateDataExtensionRequestJSON(MERC_MarketingCloudClient.DataExtension dataExtension) {
        return  '   {     '  + 
                '       "sendableDataExtensionField":"SubscriberKey",  '  + 
                '       "retentionPolicy":  '  + 
                '           [  '  + 
                '               {  '  + 
                '                   "RowBasedRetention":' + dataExtension.retentionPolicy[0].RowBasedRetention + ',  '  + 
                '                   "RetainUntil":"' + dataExtension.retentionPolicy[0].RetainUntil + '",  '  + 
                '                   "ResetRetentionPeriodOnImport":' + dataExtension.retentionPolicy[0].ResetRetentionPeriodOnImport+ ',  '  + 
                '                   "DeleteAtEndOfRetentionPeriod":' + dataExtension.retentionPolicy[0].DeleteAtEndOfRetentionPeriod + '  '  + 
                '               }  '  + 
                '           ],  '  + 
                '       "key":"' + dataExtension.key + '",  '  + 
                '       "isTestable":' + dataExtension.isTestable + ',  '  + 
                '       "isSendable":' + dataExtension.isSendable + ',  '  + 
                '       "isPublic":' + dataExtension.isPublic + ',  '  + 
                '       "field":  '  + 
                '           [     '  + 
                '               {  '  + 
                '                   "scale":null,  '  + 
                '                   "nullable":false,  '  + 
                '                   "length":"100",  '  + 
                '                   "isTemplateField":null,  '  + 
                '                   "isPrimaryKey":true,  '  + 
                '                   "id":null,  '  + 
                '                   "fieldType":"0",  '  + 
                '                   "fieldName":"SubscriberKey"  '  + 
                '               },  '  + 
                '               {  '  + 
                '                   "scale":null,  '  + 
                '                   "nullable":true,  '  + 
                '                   "length":"255",  '  + 
                '                   "isTemplateField":null,  '  + 
                '                   "isPrimaryKey":false,  '  + 
                '                   "id":null,  '  + 
                '                   "fieldType":"0",  '  + 
                '                   "fieldName":"AccountId"  '  + 
                '               },  '  + 
                '               {  '  + 
                '                   "scale":null,  '  + 
                '                   "nullable":true,  '  + 
                '                   "length":"255",  '  + 
                '                   "isTemplateField":null,  '  + 
                '                   "isPrimaryKey":false,  '  + 
                '                   "id":null,  '  + 
                '                   "fieldType":"0",  '  + 
                '                   "fieldName":"MeetingId"  '  + 
                '               },  '  + 
                '               {  '  + 
                '                   "scale":null,  '  + 
                '                   "nullable":true,  '  + 
                '                   "length":"255",  '  + 
                '                   "isTemplateField":null,  '  + 
                '                   "isPrimaryKey":false,  '  + 
                '                   "id":null,  '  + 
                '                   "fieldType":"0",  '  + 
                '                   "fieldName":"MeetingParticipantId"  '  + 
                '               },  '  + 
                '               {  '  + 
                '                   "scale":null,  '  + 
                '                   "nullable":true,  '  + 
                '                   "length":"2000",  '  + 
                '                   "isTemplateField":null,  '  + 
                '                   "isPrimaryKey":false,  '  + 
                '                   "id":null,  '  + 
                '                   "fieldType":"0",  '  + 
                '                   "fieldName":"AdditionalInformationHTML"  '  + 
                '               },  '  + 
                '               {  '  + 
                '                   "scale":null,  '  + 
                '                   "nullable":true,  '  + 
                '                   "length":"2000",  '  + 
                '                   "isTemplateField":null,  '  + 
                '                   "isPrimaryKey":false,  '  + 
                '                   "id":null,  '  + 
                '                   "fieldType":"0",  '  + 
                '                   "fieldName":"AdditionalInformationText"  '  + 
                '               },  '  + 
                '               {  '  + 
                '                   "scale":null,  '  + 
                '                   "nullable":false,  '  + 
                '                   "length":"200",  '  + 
                '                   "isTemplateField":null,  '  + 
                '                   "isPrimaryKey":false,  '  + 
                '                   "id":null,  '  + 
                '                   "fieldType":"4",  '  + 
                '                   "fieldName":"EmailAddress"  '  + 
                '               }  '  + 
                '           ],  '  + 
                '       "description":"' + dataExtension.description + '",  '  + 
                '       "dataExtensionName":"' + dataExtension.dataExtensionName + '"  '  + 
                '   }  ' ; 
    }

    public static String getCreateDataExtensionResponseJSON(){
        return '{"id":"OVdFVXRiVm9FZVdXYll6YzFMZmFMUTo0NTow"}';
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getCreateDataExtensionRequest(MERC_MarketingCloudClient.DataExtension dataExtension){
        String requestBody = getCreateDataExtensionRequestJSON(dataExtension);
        String responseBody = getCreateDataExtensionResponseJSON();
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/object/?oauth_token=' + SOAP_OAUTH_TOKEN;

        MERC_MockHttpResponseService.BasicMockPostResponse mockResponse = new MERC_MockHttpResponseService.BasicMockPostResponse(
            requestURL,
            JSON_TYPE,
            JSON_TYPE,
            requestBody,
            responseBody);

        mockResponse.withAuthorization('Bearer ' + SOAP_OAUTH_TOKEN);

        return (MERC_MockHttpResponseService.MockResponseInterface)mockResponse;
    }

    public static String getDataExtensionEntryResponseJSON(
        Id meetingId,
        String additionalInformationHTML,
        String additionalInformationText,
        Meeting_Participant_MERC__c meetingParticipant,
        Account personAccount){
        return  '   {    '  + 
                '       "keys": {  '  + 
                '           "subscriberKey":"' + personAccount.PersonContactId + '"  '  + 
                '       },  '  + 
                '       "values":{  '  + 
                '           "accountId":"' + meetingParticipant.Account_MERC__c + '",  '  + 
                '           "meetingId":"' + meetingId + '",  '  + 
                '           "meetingParticipantId":"' + meetingParticipant.Id + '",  '  + 
                '           "additionalInformationHTML":"' + additionalInformationHTML + '",  '  + 
                '           "additionalInformationText":"' + additionalInformationText + '",  '  + 
                '           "emailAddress":"' + personAccount.PersonEmail + '"  '  + 
                '       }  '  + 
                '  }  ' ; 
    }

    public static String getDataExtensionEntriesResponseJSON(
        Id meetingId,
        String additionalInformationHTML,
        String additionalInformationText,
        List<Meeting_Participant_MERC__c> meetingParticipants,
        Map<Id, Account> personAccountMap){
        List<String> dataExtensionEntryResponses = new List<String>();

        for(Meeting_Participant_MERC__c meetingParticipant : meetingParticipants){
            if(!personAccountMap.containsKey(meetingParticipant.Account_MERC__c)){
                throw new MERC_MarketingCloudTestUtilityException('meetingParticipant.Account_MERC__c of ' + meetingParticipant.Account_MERC__c + ' not in personAccountMap:\n' + personAccountMap);
            }

            dataExtensionEntryResponses.add(getDataExtensionEntryResponseJSON(
                meetingId,
                additionalInformationHTML,
                additionalInformationText,
                meetingParticipant,
                personAccountMap.get(meetingParticipant.Account_MERC__c)));
        }

        return '[' + String.join(dataExtensionEntryResponses, ',') + ']';
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getCreateDataExtensionEntriesRequest(
        MERC_MarketingCloudClient.DataExtension dataExtension,
        Id meetingId,
        String additionalInformationHTML,
        String additionalInformationText,
        List<Meeting_Participant_MERC__c> meetingParticipants,
        Map<Id, Account> personAccountMap){
        String requestBody = getDataExtensionEntriesResponseJSON(
            meetingId,
            additionalInformationHTML,
            additionalInformationText,
            meetingParticipants,
            personAccountMap);
        String responseBody = '';
        String requestURL = FUEL_ROOT_URL + '/hub/v1/dataevents/key:' + EncodingUtil.urlEncode(dataExtension.key, 'UTF-8') + '/rowset';

        MERC_MockHttpResponseService.BasicMockPostResponse mockResponse = new MERC_MockHttpResponseService.BasicMockPostResponse(
            requestURL,
            JSON_TYPE,
            JSON_TYPE,
            requestBody,
            responseBody);

        mockResponse.withAuthorization('Bearer ' + FUEL_ACCESS_TOKEN);

        return (MERC_MockHttpResponseService.MockResponseInterface)mockResponse;
    }

    public static String getSubscriberUpdateRequestXML(MERC_MarketingCloudClient.Subscriber subscriber){
        return '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
                    + '<s:Header>'
                        + '<oAuth xmlns="http://exacttarget.com">'
                            + '<oAuthToken>' + SOAP_OAUTH_TOKEN + '</oAuthToken>'
                        + '</oAuth>'
                        + '<o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
                        + '<u:Timestamp u:Id="0">'
                            + '<u:Created>1984-01-31T07:08:16Z</u:Created>'
                            + '<u:Expires>1984-01-31T07:13:16Z</u:Expires>'
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
    }

    public static String getSubscriberUpdateResponseXML(){
         return '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' + 
                   '<s:Header>' + 
                   '</s:Header>' + 
                   '<s:Body>' + 
                        '<OverallStatus>OK</OverallStatus>' +
                   '</s:Body>' + 
              '</s:Envelope>';
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getMockSubscriberUpdateRequest(MERC_MarketingCloudClient.Subscriber subscriber){
        String requestBody = getSubscriberUpdateRequestXML(subscriber);
        String responseBody = getSubscriberUpdateResponseXML();
        String requestURL = CONFIG_ROOT_SOAP_API_URL;

        MERC_MockHttpResponseService.BasicMockPostResponse mockResponse = new MERC_MockHttpResponseService.BasicMockPostResponse(
            CONFIG_ROOT_SOAP_API_URL,
            XML_CHARSET_TYPE,
            null,
            requestBody,
            responseBody);

        mockResponse.withAction(UPDATE_ACTION);

        return (MERC_MockHttpResponseService.MockResponseInterface)mockResponse;
    }

    public static String getSubscribersRequestXML(List<String> subscriberKeys){
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

        return '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
                + '<s:Header>'
                    + '<oAuth xmlns="http://exacttarget.com">'
                        + '<oAuthToken>' + SOAP_OAUTH_TOKEN + '</oAuthToken>'
                    + '</oAuth>'
                    + '<o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
                        + '<u:Timestamp u:Id="0">'
                            + '<u:Created>1984-01-31T07:08:16Z</u:Created>'
                            + '<u:Expires>1984-01-31T07:13:16Z</u:Expires>'
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
    }

    public static String getSubscribersResponseXML(List<MERC_MarketingCloudClient.Subscriber> subscribers){
        String results = '';

        for(MERC_MarketingCloudClient.Subscriber subscriber : subscribers){
            results += '<Results xsi:type="Subscriber">'
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
                       + '</Results>';
        }

        return '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' + 
                   '<s:Header>' + 
                   '</s:Header>' + 
                   '<s:Body>' + 
                    '<OverallStatus>OK</OverallStatus>' + results +
                   '</s:Body>' + 
              '</s:Envelope>';
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getMockSubscribersRequest(List<MERC_MarketingCloudClient.Subscriber> subscribers){
        List<String> subscriberKeys = new List<String>();

        for(MERC_MarketingCloudClient.Subscriber subscriber : subscribers){
            subscriberKeys.add(subscriber.SubscriberKey);
        }

        String requestBody = getSubscribersRequestXML(subscriberKeys);
        String responseBody = getSubscribersResponseXML(subscribers);
        String requestURL = CONFIG_ROOT_SOAP_API_URL;

        MERC_MockHttpResponseService.BasicMockPostResponse mockResponse = new MERC_MockHttpResponseService.BasicMockPostResponse(
            CONFIG_ROOT_SOAP_API_URL,
            XML_CHARSET_TYPE,
            null,
            requestBody,
            responseBody);

        mockResponse.withAction(RETRIEVE_ACTION);

        return (MERC_MockHttpResponseService.MockResponseInterface)mockResponse;
    }

    public class MERC_MarketingCloudTestUtilityException extends Exception { }
}