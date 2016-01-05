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

    public static final String USER_OAUTH_TOKEN = 'testuseroauthtoken';
    public static final String USER_MARKETING_CLOUD_USER_NAME = 'testuser';
    public static final String USER_EMAIL = 'testuseremail@test.test';
    public static final String USER_EMAIL_ENCODING_KEY = 'UTF-8';
    public static final String USER_LAST_NAME = 'testlastname';
    public static final String USER_LOCALE_KEY = 'en_US';
    public static final String USER_LOCALED_SID_KEY = 'en_US';
    public static final String USER_TIME_ZONE_SID_KEY = 'America/Los_Angeles';
    public static final String USER_USER_NAME = 'marketing_cloud_user';

    public static final String SOAP_OAUTH_TOKEN = 'validsoaptoken';

    public static final String FUEL_CLIENT_ID = 'samplefuelclientid';
    public static final String FUEL_SECRET = 'samplefueldsecret';

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
            et4ae5__integration_type__c = (isEnterprise ? CONFIG_INTEGRATION_TYPE_ENTERPRISE : CONFIG_INTEGRATION_TYPE_DEFAULT),
            et4ae5__url_root__c = CONFIG_URL_ROOT,
            et4ae5__url_part__c = CONFIG_URL_PART);
        insert configuration;

        return configuration;
    }

    public static Mercury_Marketing_Cloud_Settings_MERC__c insertSettings(){
        Mercury_Marketing_Cloud_Settings_MERC__c settings = new Mercury_Marketing_Cloud_Settings_MERC__c(
            Enterprise_Integration_Type_MERC__c = CONFIG_INTEGRATION_TYPE_ENTERPRISE,
            Business_Unit_Name_MERC__c  = BUSINESS_UNIT_NAME
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

    public static MERC_MockHttpResponseService withDefaultMockService(){
        MERC_MockHttpResponseService mockService = new MERC_MockHttpResponseService();


        return mockService;
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getMockSoapAuthRequest(User user){
        String requestBody = getSoapAuthTokenRequestXML(CONFIG_USERNAME, CONFIG_PASSWORD, SETTING_APPLICATION_ID, user.et4ae5__exacttarget_oauth_token__c);
        String responseBody = getSoapAuthTokenResponseXML(SOAP_OAUTH_TOKEN);

        MERC_MockHttpResponseService.BasicMockPostResponse mockResponse = new MERC_MockHttpResponseService.BasicMockPostResponse(
            CONFIG_ROOT_SOAP_API_URL,
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

    public static MERC_MockHttpResponseService.MockResponseInterface getMockFuelAuthRequest(String soapAuthToken){
        String requestBody = getFuelAuthTokenRequestXML(FUEL_CLIENT_ID, FUEL_SECRET, soapAuthToken);
        String responseBody = getFuelAuthTokenResponseXML('');

        MERC_MockHttpResponseService.BasicMockPostResponse mockResponse = new MERC_MockHttpResponseService.BasicMockPostResponse(
            CONFIG_ROOT_SOAP_API_URL,
            XML_CHARSET_TYPE,
            null,
            requestBody,
            responseBody);

        return (MERC_MockHttpResponseService.MockResponseInterface)mockResponse;
    }

    private static String getFuelAuthTokenRequestXML(String clientId, String secret, String scope){
        return '';
    }

    private static String getFuelAuthTokenResponseXML(String expectedAccessToken){
        return '';
    }
}