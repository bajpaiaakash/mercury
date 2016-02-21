/*
* MERC_MarketingCloudTestUtility
* Description: Utility for MarketingCloud Test Classes
* Author: David Helmer
* Modified By: 
* Modified Date: Dec. 14th 2015
*/
@isTest
public with sharing class MERC_MarketingCloudTestUtility {
    public static DateTime BASIC_DATE_TIME = DateTime.newInstanceGmt(1984, 1, 31, 7, 8, 16);

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

    private static final String SENDER_PROFILE_PREFIX = 'TESTPREFIX_';

    public static final String THUMBNAIL_HEIGHT = '666';
    public static final String THUMBNAIL_WIDTH = '420';

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

    public static final String EMAIL_SEND_FROM_NAME = 'testfromname';
    public static final String EMAIL_SEND_FROM_EMAIL = 'testfromemail@test.test';
    public static final Boolean EMAIL_SEND_DEDUPE = false;
    public static final String EMAIL_SEND_EMAIL_ID_AS_STRING = '123';
    public static final Integer EMAIL_SEND_EMAIL_ID = 123;
    public static final String EMAIL_SEND_SUBJECT = 'testemailsubject';
    public static final Boolean EMAIL_SEND_SYNC_COMPLETE = true;
    public static final Boolean EMAIL_SEND_TRACKING_DISABLED = false;
    public static final String EMAIL_SEND_SYNC_ID_PREFIX = 'emailsendsync_';

    public static final String EMAIL_ID = '55555';
    public static final String EMAIL_CATEGORY = 'testcategory';
    public static final String EMAIL_TYPE = 'testemailtype';
    public static final String EMAIL_STATUS_KEY = 'Status';
    public static final String EMAIL_STATUS_VALUE = 'New';
    public static final String EMAIL_CUSTOMER_KEY = 'testemailcustomerkey';
    public static final Boolean EMAIL_SAMPLE_AUDIENCE_ONLY = false;
    public static final String EMAIL_PRE_HEADER = '';
    public static final Integer EMAIL_EMAIL_EMAIL_TYPE = 0;
    public static final Integer EMAIL_MESSAGE_ID = 0;
    public static final String EMAIL_SEND_TIME = 'now';

    public static final String SEND_DEFINITION_ID = 'testsenddefinitionid';
    public static final String SEND_DEFINITION_DESCRIPTION = 'testsenddefinition description';
    public static final String SEND_DEFINITION_KEY = '444380896000';
    public static final String SEND_DEFINITION_NAME = 'LillySendDef1984-01-31 07:08:16a1y11000000euYLAAY';
    public static final String SEND_DEFINITION_SENDER_PROFILE_ID = 'testsenderprofileid';
    public static final String SEND_DEFINITION_CLASSIFICATION_ID = 'testclassificationid';

    public static final String DATA_EXTENSION_NAME = 'testdataextension name';
    public static final String DATA_EXTENSION_DESCRIPTION = 'testdataextension subject';
    public static final String DATA_EXTENSION_KEY = 'testdataextensionkey';
    public static DateTime DATA_EXTENSION_EXPIRATION = BASIC_DATE_TIME.addDays(3);
    public static final String DATA_EXTENSION_EXPIRATION_STRING = '1984-02-03 07:08:16';
    public static final String BASIC_DATE_TIME_FORMATTED = '19840131T070816000';
    public static final String DATA_EXTENSION_DEFAULT_DESCRIPTION = 'Used for sending meeting from Salesforce.com';

    public static final String EMAIL_ADDITIONAL_INFORMATION_HTML = '<div>test additional html</div>';
    public static final String EMAIL_ADDITIONAL_INFORMATION_TEXT = 'test additional text';

    public static final String SUBSCRIBER_KEY_PREFIX = 'subscribertest_key_';
    public static final String SUBSCRIBER_LILLYKEY_PREFIX = 'subscribertest_name_';
    public static final String SUBSCRIBER_LILLYKEY_DEFAULT = '-1';
    public static final String SUBSCRIBER_EMAIL_PREFIX = 'subscribertestemail@test.test';
    public static final String SUBSCRIBER_TYPE = 'testubscribertype';
    public static final String SUBSCRIBER_TYPE_HCP = 'HCP';
    public static final String SUBSCRIBER_TYPE_EMPLOYEE = 'Employee';
    public static final String SUBSCRIBER_TYPE_BUSINESS_CONTACT = 'Business Contact';

    public static final String MEETING_NAME_PREFIX = 'Test Meeting ';
    public static final String MEETING_CITY = 'test city';
    public static final String MEETING_VENUE = 'test venue';
    public static Datetime MEETING_START = BASIC_DATE_TIME;
    public static Datetime MEETING_END = MEETING_START.addDays(5);
    public static final String MEETING_EVENT_ID_PREFIX = 'Test Event ';
    public static final String MEETING_RECORD_TYPE = 'Ad_Hoc_Consulting';
    public static final String MEETING_OBJECT_TYPE = 'Meeting_MERC__c';

    public static final String RECORD_TYPE_STRING_HCP = 'HCP_GLBL';
    public static final String RECORD_TYPE_STRING_EMPLOYEE = 'Employee_GLBL';
    public static final String RECORD_TYPE_STRING_INDIVIDUAL = 'Designated_Individual_GLBL';
    public static final String RECORD_TYPE_STRING_NON_HCP = 'Non_HCP_MERC';

    public static final String PARTICIPANT_RECORD_TYPE_DELEGATE = 'MERC_Delegate';
    public static final String PARTICIPANT_RECORD_TYPE_CONSULTING = 'MERC_Consulting'; 

    public static final String PROFILE_DEFAULT_NAME = 'GSO Basic User_Salesforce';
    public static final String PERMISSION_SET_MERCURY_MEETINGS_NAME = 'Mercury_Customer_Meeting_Services_Edit';
    public static final String PERMISSION_SET_EMAILS = 'Mercury_Meeting_ExactTarget_Email_MERC';

    public static final String EMAIL_FOLDER_TYPE = 'email';
    public static final String EMAIL_FOLDER_LAST_UPDATED = '1984-01-31T07:08:16.000Z';
    public static final String EMAIL_FOLDER_CREATED_BY = '0';
    public static final String EMAIL_FOLDER_PARENT_ID = '0';
    public static final String EMAIL_FOLDER_ICON_TYPE = 'email';
    public static final String EMAIL_FOLDER_VALID_EXPAND_ID = '8';
    public static final List<String> EMAIL_FOLDER_ROOT_IDS = new List<String> { '1', '2', '3' };
    public static final List<String> EMAIL_FOLDER_2_IDS = new List<String> { '4', '5' };
    public static final List<String> EMAIL_FOLDER_3_IDS = new List<String> { '6', '7', '8' };

    public static final String PERSON_ACCOUNT_FIRST_NAME = 'Testfirst';
    public static final String PERSON_ACCOUNT_LAST_NAME_PREFIX = 'PA_';
    public static final String PERSON_ACCOUNT_STREET = 'Test street';
    public static final String PERSON_ACCOUNT_POSTAL_CODE = '12345';
    public static final String PERSON_ACCOUNT_CITY = 'SFO';
    public static final String PERSON_ACCOUNT_HOME_PHONE = '3015551234';
    public static final String PERSON_ACCOUNT_MOBILE_PHONE = '3015551234';
    public static final String PERSON_ACCOUNT_COMMUNICATION_PREFERENCE = 'E-Mail';
    public static final String PERSON_ACCOUNT_COMMUNICATION_CHANNEL = 'E-Mail';
    public static final String PERSON_ACCOUNT_COUNTRY = 'GB';
    public static final String PERSON_ACCOUNT_LANGUAGE = 'English';
    public static final String PERSON_ACCOUNT_EMAIL = 'test@test.test';
    public static final String PERSON_ACCOUNT_CUSTOMER_ID_PREFIX = 'custid_';
    public static final String PERSON_ACCOUNT_PERSONAL_ID_PREFIX = 'pn_';

    public static final String PROCESS_TYPE_TRAVEL_PROPOSAL = 'Travel Proposal';
    public static final String PROCESS_TYPE_REGISTRATION = 'Registration';
    public static final String PROCESS_TYPE_PRE_MEETING = 'Pre-Meeting Information';

    public static final String ITINERARY_ACCEPTED = 'Accepted';
    public static final String ITINERARY_REJECTED = 'Rejected';

    public static final String TASK_STATUS_COMPLETED = 'Completed - Process Complete';
    public static final String TASK_STATUS_CANCELLED = 'Completed - Process Cancelled';
    public static final String TASK_STATUS_INCOMPLETE = 'Incomplete';

    public static final String ERROR_DEFAULT = 'test if cleared';

    private static Integer UserCount = 0;
    private static Map<String, Profile> ProfileMap = new Map<String, Profile>();
    private static Map<String, PermissionSet> PermissionSetMap = new Map<String, PermissionSet>();

    private static Integer SubscriberCount = 0;
    private static Integer MeetingCount = 0;
    private static Integer AccountCount = 0;

    /*
     * Test Data Generation
     */
    public static void adjustTime(){
        BASIC_DATE_TIME = DateTime.newInstanceGmt(1984, 1, 31, 7, 8, 16);
        DATA_EXTENSION_EXPIRATION = BASIC_DATE_TIME.addDays(3);
        MEETING_START = BASIC_DATE_TIME;
        MEETING_END = MEETING_START.addDays(5);
    }

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
            Application_ID_MERC__c = SETTING_APPLICATION_ID,
            Sender_Profile_Prefix_Filter_MERC__c = SENDER_PROFILE_PREFIX,
            Thumbnail_Height_MERC__c = Integer.valueOf(THUMBNAIL_HEIGHT),
            Thumbnail_Width_MERC__c = Integer.valueOf(THUMBNAIL_WIDTH)
        );

        insert settings;

        return settings;
    }

    public static User insertUser(){
        User user = insertUser(PROFILE_DEFAULT_NAME);
        assignPermissionSet(user, PERMISSION_SET_MERCURY_MEETINGS_NAME);
        assignPermissionSet(user, PERMISSION_SET_EMAILS);
        return user;
    }

    public static User insertUser(String profileName){
        User marketingCloudUser = getUser(profileName);
        insert marketingCloudUser;
        return marketingCloudUser;
    }

    public static User getUser(){
        return getUser(PROFILE_DEFAULT_NAME);
    }

    public static User getUser(String profileName){
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

        return marketingCloudUser;
    }

    public static Profile getProfile(String profileName){
        if (!ProfileMap.containsKey(profileName)) {
            Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];
            ProfileMap.put(profileName, profile);
        }
        return ProfileMap.get(profileName);
    }

    public static void assignPermissionSet(User user, String permissionSetName){
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(
            PermissionSetId = getPermissionSet(permissionSetName).Id, 
            AssigneeId = user.Id);
        insert permissionSetAssignment;  
    }

    public static PermissionSet getPermissionSet(String permissionSetName){
        if (!PermissionSetMap.containsKey(permissionSetName)) {
            PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName];
            PermissionSetMap.put(permissionSetName, permissionSet);
        }
        return PermissionSetMap.get(permissionSetName);
    }

    public static MERC_MarketingCloudClient.SendDefinition getSendDefinition(){
        return new MERC_MarketingCloudClient.SendDefinition(  
            SEND_DEFINITION_ID, EMAIL_SEND_DEDUPE, SEND_DEFINITION_DESCRIPTION,
            EMAIL_SEND_EMAIL_ID, SEND_DEFINITION_KEY, SEND_DEFINITION_NAME,
            EMAIL_SEND_SUBJECT, SEND_DEFINITION_CLASSIFICATION_ID,
            SEND_DEFINITION_SENDER_PROFILE_ID
        );
    }

    public static MERC_MarketingCloudClient.DataExtension getDataExtension(Id meetingId){
        String dataExtensionName = 'SalesforceMeeting-' + meetingId + '-' + EMAIL_SEND_SUBJECT + '-' + BASIC_DATE_TIME_FORMATTED;
        String dataExtensionDescription = DATA_EXTENSION_DEFAULT_DESCRIPTION;
        String dataExtensionKey = String.valueOf(meetingId) + BASIC_DATE_TIME_FORMATTED;
        MERC_MarketingCloudClient.DataExtension dataExtension = new MERC_MarketingCloudClient.DataExtension(
            dataExtensionName,
            dataExtensionDescription,
            dataExtensionKey,
            DATA_EXTENSION_EXPIRATION);
        dataExtension.sendableDataExtensionField = 'SubscriberKey';
        dataExtension.field = getDataExtensionFields();

        return dataExtension;
    }

    public static MERC_MarketingCloudClient.DataExtension getDataExtension(){
        MERC_MarketingCloudClient.DataExtension dataExtension = new MERC_MarketingCloudClient.DataExtension(
            DATA_EXTENSION_NAME,
            DATA_EXTENSION_DESCRIPTION,
            DATA_EXTENSION_KEY,
            DATA_EXTENSION_EXPIRATION);
        dataExtension.sendableDataExtensionField = 'SubscriberKey';
        dataExtension.field = getDataExtensionFields();

        return dataExtension;
    }

    private static List<MERC_MarketingCloudClient.Field> getDataExtensionFields(){
        List<MERC_MarketingCloudClient.Field> fields = new List<MERC_MarketingCloudClient.Field>();

        MERC_MarketingCloudClient.Field fSubscriberKey = new MERC_MarketingCloudClient.Field();
        fSubscriberKey.fieldName = 'SubscriberKey';
        fSubscriberKey.fieldType = '0';
        fSubscriberKey.length = '100';
        fSubscriberKey.nullable = false;
        fSubscriberKey.isPrimaryKey = true;
        fields.add(fSubscriberKey);

        List<String> fieldNames = new List<String> {'AccountId', 'MeetingId', 'MeetingParticipantId'};

        for (String fieldName : fieldNames) {
            MERC_MarketingCloudClient.Field field = new MERC_MarketingCloudClient.Field();
            field.fieldName = fieldName;
            field.fieldType = '0'; //Text
            field.length = '255';
            field.nullable = true;
            field.isPrimaryKey = false;
            fields.add(field);
        }

        MERC_MarketingCloudClient.Field additionalInformationHTMLField = new MERC_MarketingCloudClient.Field();
        additionalInformationHTMLField.fieldName = 'AdditionalInformationHTML';
        additionalInformationHTMLField.fieldType = '0'; //Text
        additionalInformationHTMLField.length = '2000';
        additionalInformationHTMLField.nullable = true;
        additionalInformationHTMLField.isPrimaryKey = false;
        fields.add(additionalInformationHTMLField);

        MERC_MarketingCloudClient.Field additionalInformationTextField = new MERC_MarketingCloudClient.Field();
        additionalInformationTextField.fieldName = 'AdditionalInformationText';
        additionalInformationTextField.fieldType = '0'; //Text
        additionalInformationTextField.length = '2000';
        additionalInformationTextField.nullable = true;
        additionalInformationTextField.isPrimaryKey = false;
        fields.add(additionalInformationTextField);

        MERC_MarketingCloudClient.Field emailAddressField = new MERC_MarketingCloudClient.Field();
        emailAddressField.fieldName = 'EmailAddress';
        emailAddressField.fieldType = '4'; //EmailAddress
        emailAddressField.length = '200';
        emailAddressField.nullable = false;
        emailAddressField.isPrimaryKey = false;
        fields.add(emailAddressField);

        return fields;
    }

    public static List<MERC_MarketingCloudClient.DataExtensionEntry> getDataExtensionEntries(
        Id meetingId,
        String additionalInformationHTML,
        String additionalInformationText,
        List<Meeting_Participant_MERC__c> meetingParticipants,
        Map<Id, Account> personAccounts,
        MERC_MarketingCloudClient.DataExtension dataExtension){
        List<MERC_MarketingCloudClient.DataExtensionEntry> dataExtensionEntries = new List<MERC_MarketingCloudClient.DataExtensionEntry>();

        for (Meeting_Participant_MERC__c meetingParticipant : meetingParticipants) {
            // -> set data extension fields
            MERC_MarketingCloudClient.DataExtensionEntry entry = new MERC_MarketingCloudClient.DataExtensionEntry();
            entry.keys = new MERC_MarketingCloudClient.FieldEntry();
            entry.keys.fieldName = 'SubscriberKey';
            System.assertNotEquals(null, String.valueOf(personAccounts.get(meetingParticipant.Account_MERC__c).PersonContactId));
            entry.keys.fieldValue = String.valueOf(personAccounts.get(meetingParticipant.Account_MERC__c).PersonContactId);

            entry.values = new List<MERC_MarketingCloudClient.FieldEntry>();

            MERC_MarketingCloudClient.FieldEntry accountId = new MERC_MarketingCloudClient.FieldEntry();
            accountId.fieldName = 'AccountId';
            accountId.fieldValue = meetingParticipant.Account_MERC__c;
            entry.values.add(accountId);

            MERC_MarketingCloudClient.FieldEntry meetingIdField = new MERC_MarketingCloudClient.FieldEntry();
            meetingIdField.fieldName = 'MeetingId';
            meetingIdField.fieldValue = meetingId;
            entry.values.add(meetingIdField);

            MERC_MarketingCloudClient.FieldEntry meetingParticipantId = new MERC_MarketingCloudClient.FieldEntry();
            meetingParticipantId.fieldName = 'MeetingParticipantId';
            meetingParticipantId.fieldValue = meetingParticipant.Id;
            entry.values.add(meetingParticipantId);

            MERC_MarketingCloudClient.FieldEntry additionalInfoFieldEntry = new MERC_MarketingCloudClient.FieldEntry();
            additionalInfoFieldEntry.fieldName = 'AdditionalInformationHTML';
            additionalInfoFieldEntry.fieldValue = additionalInformationHTML;
            entry.values.add(additionalInfoFieldEntry);

            MERC_MarketingCloudClient.FieldEntry additionalInfoTextFieldEntry = new MERC_MarketingCloudClient.FieldEntry();
            additionalInfoTextFieldEntry.fieldName = 'AdditionalInformationText';
            additionalInfoTextFieldEntry.fieldValue = additionalInformationText;
            entry.values.add(additionalInfoTextFieldEntry);

            MERC_MarketingCloudClient.FieldEntry emailAddress = new MERC_MarketingCloudClient.FieldEntry();
            emailAddress.fieldName = 'EmailAddress';
            emailAddress.fieldValue = personAccounts.get(meetingParticipant.Account_MERC__c).PersonEmail;
            entry.values.add(emailAddress);

            dataExtensionEntries.add(entry);
        }

        return dataExtensionEntries;
    }

    public static List<Id> getPersonContactIds(List<Account> accounts){
        List<Id> personContactIds = new List<Id>();

        accounts = [SELECT Id, PersonContactId FROM Account WHERE Id IN :accounts];
        for(Account personContactAccount : accounts){
            personContactIds.add(personContactAccount.PersonContactId);
        }
        return personContactIds;
    }

    public static Map<Id, Account> getPersonAccountMap(List<Account> accounts){
        return new Map<Id,Account>(
            [SELECT Id,
                    PersonContactId,
                    PersonEmail
               FROM Account
              WHERE Id IN :accounts]);
    }

    public static List<Account> queryPersonAccounts(List<Account> accounts){
        return [SELECT Id,
                       RecordTypeId,
                       FirstName,
                       LastName,
                       PersonMailingStreet,
                       PersonMailingPostalCode,
                       PersonMailingCity,
                       PersonHomePhone,
                       PersonMobilePhone,
                       Communication_Preference_MERC__c,
                       Communication_Channel_MERC__c,
                       Country_of_Residence_GLBL__c,
                       Prfrd_Lang_Cd_GLBL__c,
                       PersonEmail,
                       PersonContactId,
                       Cust_Id_GLBL__c,
                       Prsnl_Nbr_GLBL__c,
                       Update_Subscriber_Error_ET_MERC__c
                  FROM Account
                 WHERE Id IN :accounts];
    }

    public static Account getPersonAccount(String recordTypeName){
        AccountCount++;
        RecordType recordType = MERC_ETTestUtils.GetRecordType(recordTypeName, 'Account');
        return new Account(
            RecordTypeId = recordType.Id,
            FirstName = PERSON_ACCOUNT_FIRST_NAME,
            LastName = PERSON_ACCOUNT_LAST_NAME_PREFIX + AccountCount,
            PersonMailingStreet = PERSON_ACCOUNT_STREET,
            PersonMailingPostalCode = PERSON_ACCOUNT_POSTAL_CODE,
            PersonMailingCity = PERSON_ACCOUNT_CITY,
            PersonHomePhone = PERSON_ACCOUNT_HOME_PHONE,
            PersonMobilePhone = PERSON_ACCOUNT_MOBILE_PHONE,
            Communication_Preference_MERC__c = PERSON_ACCOUNT_COMMUNICATION_PREFERENCE,
            Communication_Channel_MERC__c = PERSON_ACCOUNT_COMMUNICATION_CHANNEL,
            Country_of_Residence_GLBL__c = PERSON_ACCOUNT_COUNTRY,
            Prfrd_Lang_Cd_GLBL__c = PERSON_ACCOUNT_LANGUAGE,
            PersonEmail = PERSON_ACCOUNT_EMAIL
        );
    }

    public static Account getSubscriberAccount(String recordTypeName){
        return getSubscriberAccount(
            recordTypeName,
            PERSON_ACCOUNT_CUSTOMER_ID_PREFIX + (AccountCount + 1),
            PERSON_ACCOUNT_PERSONAL_ID_PREFIX + (AccountCount + 1));
    }

    public static Account getSubscriberAccount(
        String recordTypeName,
        String customerId,
        String personalNumber){
        Account subscriberAccount = getPersonAccount(recordTypeName);
        subscriberAccount.Cust_Id_GLBL__c = customerId;
        subscriberAccount.Prsnl_Nbr_GLBL__c = personalNumber;
        subscriberAccount.Update_Subscriber_Error_ET_MERC__c = ERROR_DEFAULT;
        return subscriberAccount;
    }

    public static List<Account> getDefaultSubscriberAccounts(){
        return new List<Account>{
            getSubscriberAccount(RECORD_TYPE_STRING_HCP),
            getSubscriberAccount(RECORD_TYPE_STRING_INDIVIDUAL),
            getSubscriberAccount(RECORD_TYPE_STRING_EMPLOYEE),
            getSubscriberAccount(RECORD_TYPE_STRING_NON_HCP)
        };
    }

    public static MERC_MarketingCloudClient.Subscriber getSubscriber(){
        return getSubscriber(SUBSCRIBER_KEY_PREFIX + (SubscriberCount), 
                             SUBSCRIBER_LILLYKEY_PREFIX + SubscriberCount,
                             SUBSCRIBER_EMAIL_PREFIX + SubscriberCount,
                             SUBSCRIBER_TYPE);
    }

    public static MERC_MarketingCloudClient.Subscriber getSubscriber(String subscriberKey){
        return getSubscriber(subscriberKey, 
                             SUBSCRIBER_LILLYKEY_PREFIX + SubscriberCount,
                             SUBSCRIBER_EMAIL_PREFIX + SubscriberCount,
                             SUBSCRIBER_TYPE);
    }

    public static MERC_MarketingCloudClient.Subscriber getSubscriber(
        String key,
        String lillyKey,
        String email,
        String type){
        SubscriberCount++;
        return new MERC_MarketingCloudClient.Subscriber(key, lillyKey, email, type);
    }


    public static List<MERC_MarketingCloudClient.Subscriber> getSubscribers(Integer count){
        List<MERC_MarketingCloudClient.Subscriber> subscribers = new List<MERC_MarketingCloudClient.Subscriber>();
        for(Integer subscriberIndex = 0; subscriberIndex < count; subscriberIndex++){
            subscribers.add(getSubscriber());
        }
        return subscribers;
    }

    public static List<MERC_MarketingCloudClient.Subscriber> getPersonContactSubscribers(List<Id> personContactIds){
        List<MERC_MarketingCloudClient.Subscriber> subscribers = new List<MERC_MarketingCloudClient.Subscriber>();
        for(Id personContactId : personContactIds){
            MERC_MarketingCloudClient.Subscriber subscriber = getSubscriber(personContactId);
            subscribers.add(subscriber);
        }

        return subscribers;
    }

    public static List<MERC_MarketingCloudClient.Subscriber> getExpectedSubscribers(List<Account> personAccounts){
        List<MERC_MarketingCloudClient.Subscriber> subscribers = new List<MERC_MarketingCloudClient.Subscriber>();
        for(Account personAccount : personAccounts){
            String lillyKey = SUBSCRIBER_LILLYKEY_DEFAULT;
            String type = SUBSCRIBER_TYPE_BUSINESS_CONTACT;
            if(personAccount.RecordTypeId == MERC_ETTestUtils.GetRecordType(RECORD_TYPE_STRING_HCP, 'Account').Id){
                lillyKey = personAccount.Cust_Id_GLBL__c;
                type = SUBSCRIBER_TYPE_HCP;
            } else if(personAccount.RecordTypeId == MERC_ETTestUtils.GetRecordType(RECORD_TYPE_STRING_EMPLOYEE, 'Account').Id){
                lillyKey = personAccount.Prsnl_Nbr_GLBL__c;
                type = SUBSCRIBER_TYPE_EMPLOYEE;
            }
            subscribers.add(getSubscriber(
                personAccount.PersonContactId,
                lillyKey,
                personAccount.PersonEmail,
                type));
        }

        return subscribers;
    }

    public static List<String> getSubscriberKeys(List<MERC_MarketingCloudClient.Subscriber> subscribers){
        List<String> subscriberKeys = new List<String>();

        for(MERC_MarketingCloudClient.Subscriber subscriber : subscribers){
            subscriberKeys.add(subscriber.SubscriberKey);
        }

        return subscriberKeys;
    }

    public static Id getDefaultMeetingRecordTypeId(){
        return MERC_ETTestUtils.GetRecordType(MEETING_RECORD_TYPE, MEETING_OBJECT_TYPE).Id;
    }

    public static Meeting_MERC__c insertMeeting(){
        Meeting_MERC__c meeting = getMeeting();
        insert meeting;
        return meeting;
    }

    public static Meeting_MERC__c getMeeting(){
        MeetingCount++;
        return new Meeting_MERC__c(
            Name = MEETING_NAME_PREFIX + MeetingCount,
            //RecordTypeId = getDefaultMeetingRecordTypeId(),
            City_of_Meeting_MERC__c = MEETING_CITY,
            Preferred_Venue_MERC__c = MEETING_VENUE,
            Date_of_Event_MERC__c = MEETING_START.date(),
            End_Date_of_Event_MERC__c = MEETING_END.date(),
            Start_Time_of_Meeting_MERC__c = MEETING_START,
            End_Time_of_Meeting_MERC__c = MEETING_END,
            Event_Id_MERC__c = MEETING_EVENT_ID_PREFIX + MeetingCount
        );
    }

    public static List<Meeting_MERC__c> getMeetings(Integer count){
        List<Meeting_MERC__c> meetings = new List<Meeting_MERC__c>();
        for(Integer meetingIndex = 0; meetingIndex < count; meetingIndex++){
            meetings.add(getMeeting());
        }
        return meetings;
    }

    public static MERC_MarketingCloudClient.EmailFolder getEmailFolder(String folderId){
        return getEmailFolder(folderId, new List<MERC_MarketingCloudClient.EmailFolder>());
    }    

    public static MERC_MarketingCloudClient.EmailFolder getEmailFolder(
        String folderId, 
        List<MERC_MarketingCloudClient.EmailFolder> subfolders){
        MERC_MarketingCloudClient.EmailFolder emailFolder = new MERC_MarketingCloudClient.EmailFolder();
        emailFolder.id = folderId;
        emailFolder.type = EMAIL_FOLDER_TYPE;
        emailFolder.lastUpdated = EMAIL_FOLDER_LAST_UPDATED;
        emailFolder.createdBy = EMAIL_FOLDER_CREATED_BY;
        emailFolder.parentId = EMAIL_FOLDER_PARENT_ID;
        emailFolder.iconType = EMAIL_FOLDER_ICON_TYPE;

        emailFolder.subfolders = subfolders;
        emailFolder.emails = new List<MERC_MarketingCloudClient.FolderedEmail>();

        return emailFolder;
    }

    public static List<MERC_MarketingCloudClient.EmailFolder> getEmailFolders(){
        List<MERC_MarketingCloudClient.EmailFolder> emailFoldersFor2 = new List<MERC_MarketingCloudClient.EmailFolder>();
        List<MERC_MarketingCloudClient.EmailFolder> emailFoldersFor3 = new List<MERC_MarketingCloudClient.EmailFolder>();
        List<MERC_MarketingCloudClient.EmailFolder> emailFoldersRoot = new List<MERC_MarketingCloudClient.EmailFolder>();

        for(Integer index = 0; index < EMAIL_FOLDER_2_IDS.size(); index++){
            String folderId = EMAIL_FOLDER_2_IDS.get(index);
            emailFoldersFor2.add(getEmailFolder(folderId));
        }

        for(Integer index = 0; index < EMAIL_FOLDER_3_IDS.size(); index++){
            String folderId = EMAIL_FOLDER_3_IDS.get(index);
            emailFoldersFor3.add(getEmailFolder(folderId));
        }

        for(Integer index = 0; index < EMAIL_FOLDER_ROOT_IDS.size(); index++){
            String folderId = EMAIL_FOLDER_ROOT_IDS.get(index);

            if(folderId == '2'){
                emailFoldersRoot.add(getEmailFolder(folderId, emailFoldersFor2));
            } else if(folderId == '3'){
                emailFoldersRoot.add(getEmailFolder(folderId, emailFoldersFor3));
            } else {
                emailFoldersRoot.add(getEmailFolder(folderId));
            }
        }

        return emailFoldersRoot;
    }

    public static MERC_MarketingCloudClient.FolderedEmail getFolderedEmail(){
        MERC_MarketingCloudClient.Email email = new MERC_MarketingCloudClient.Email();
        email.Id = EMAIL_ID;
        email.type = EMAIL_TYPE;
        email.status = new MERC_MarketingCloudClient.KeyValue(EMAIL_STATUS_KEY,EMAIL_STATUS_VALUE);
        email.name = EMAIL_SEND_SUBJECT;
        email.subject = EMAIL_SEND_SUBJECT;
        email.categoryId = EMAIL_CATEGORY;
        email.customerKey = EMAIL_CUSTOMER_KEY;
        email.sampleAudienceOnly = EMAIL_SAMPLE_AUDIENCE_ONLY;
        email.preheader = EMAIL_PRE_HEADER;
        email.emailType = EMAIL_EMAIL_EMAIL_TYPE;
        email.messageId = EMAIL_MESSAGE_ID;

        MERC_MarketingCloudClient.FolderedEmail folderedEmail = new MERC_MarketingCloudClient.FolderedEmail();
        folderedEmail.id = EMAIL_ID;
        folderedEmail.name = EMAIL_SEND_SUBJECT;
        folderedEmail.categoryId = EMAIL_CATEGORY;
        folderedEmail.email = email;

        return folderedEmail;
    }

    public static Meeting_Email_Send_MERC__c getEmailSend(Id meetingId){
        Meeting_Email_Send_MERC__c meetingEmailSend = new Meeting_Email_Send_MERC__c();
        meetingEmailSend.Meeting_MERC__c = meetingId;

        // Populate fields that will be placed on the email send
        meetingEmailSend.ET_Data_Extension_Id_MERC__c = DATA_EXTENSION_KEY;
        meetingEmailSend.ET_Sync_Id_MERC__c = EMAIL_SEND_SYNC_ID_PREFIX + DateTime.now();
        meetingEmailSend.ET_Business_Unit_MERC__c = BUSINESS_UNIT_ID;
        meetingEmailSend.ET_Recipients_Opted_In_MERC__c = true;
        meetingEmailSend.ET_Sender_Profile_Id_MERC__c = SEND_DEFINITION_SENDER_PROFILE_ID;
        meetingEmailSend.ET_Send_Classification_Id_MERC__c = SEND_DEFINITION_CLASSIFICATION_ID;
        meetingEmailSend.ET_Dedupe_Subscribers_MERC__c = EMAIL_SEND_DEDUPE;
        meetingEmailSend.ET_Individual_Tracking_Disabled_MERC__c = EMAIL_SEND_TRACKING_DISABLED;
        meetingEmailSend.ET_Email_ID_MERC__c = EMAIL_ID;
        meetingEmailSend.ET_Email_Name_MERC__c = EMAIL_SEND_SUBJECT;
        meetingEmailSend.ET_Subject_MERC__c = EMAIL_SEND_SUBJECT;
        meetingEmailSend.ET_Subject_Line_MERC__c = EMAIL_SEND_SUBJECT;
        meetingEmailSend.Additional_Information_MERC__c = EMAIL_ADDITIONAL_INFORMATION_HTML;
        meetingEmailSend.Additional_Information_Plain_Text_MERC__c = EMAIL_ADDITIONAL_INFORMATION_TEXT;

        return meetingEmailSend;
    }

    /*
     * Mock Request Responses
     */
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
                '         "id": "8",  '  + 
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

    public static MERC_MockHttpResponseService.MockResponseInterface getMockGetEmptyEmailFoldersRequest(){
        String responseBody = getEmptyListResponseJSON();
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/folder/?oauth_token='+SOAP_OAUTH_TOKEN+'&where=allowedtypes+in+(\'email\',\'shared_type\',\'global+email\',\'shared_email\',\'shared_item\')';

        MERC_MockHttpResponseService.BasicMockGetResponse mockResponse = new MERC_MockHttpResponseService.BasicMockGetResponse(
            requestURL,
            JSON_TYPE, JSON_TYPE,
            responseBody);

        return mockResponse;
    }

    public static String getEmptyListResponseJSON(){
        return  '   {  '  + 
                '     "startIndex": 0,  '  + 
                '     "itemsPerPage": 50,  '  + 
                '     "totalResults": 0,  '  + 
                '     "entry": [ ]  '  + 
                '  }  ' ; 
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

    public static void assertSenderProfileLabelById(String id, String label){
        if(id == 'ZDVNQ0prZFVFZVdWRkt3V0xiR1lCQTo0Nzow'){
            System.assertEquals('gso_noreply@lilly.com <gso_noreply@lilly.com>', label);
        } else if(id == 'Z0NKc2ZrZFdFZVdWRkt3V0xiR1lCQTo0Nzow'){
            System.assertEquals('%%recordOwnerName%% <%%recordOwnerEmail%%>', label);
        } else if(id == 'cWdQbVRrZ0JFZVdWRkt3V0xiR1lCQTo0Nzow'){
            System.assertEquals('gso_noreply@lilly.com <gso_noreply@lilly.com>', label);
        } else if(id == 'RXJCMGlpNzdFZVdWRkt3V0xiR1lCQTo0Nzow'){
            System.assertEquals('Tom Burton <tmburton@lilly.com>', label);
        } else {
            System.assert(false, 'The following id is not an expected test Id:\n' + id);
        }
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
                '         "profileName": "' + SENDER_PROFILE_PREFIX + '1440086382728gso_noreply@lilly.com",  '  + 
                '         "fromEmail": "gso_noreply@lilly.com",  '  + 
                '         "fromName": "gso_noreply@lilly.com"  '  + 
                '       },  '  + 
                '       {  '  + 
                '         "id": "Z0NKc2ZrZFdFZVdWRkt3V0xiR1lCQTo0Nzow",  '  + 
                '         "key": "3222",  '  + 
                '         "createdDate": "8/20/2015 10:14:00 AM",  '  + 
                '         "lastUpdated": "2015-08-20T16:14:00Z",  '  + 
                '         "profileName": "' + SENDER_PROFILE_PREFIX + '1440087255733null",  '  + 
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
                '         "profileName": "' + SENDER_PROFILE_PREFIX + 'tmburton@lilly.com2015-07-20 17:19:28",  '  + 
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

    public static MERC_MockHttpResponseService.MockResponseInterface getEmptySenderProfilesRequest(){
        String responseBody = getEmptyListResponseJSON();
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

    public static String getCreateSendDefinitionResponseJSON(String sendDefinitionId){
        return '{"id":"' + sendDefinitionId + '"}';
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getCreateSendDefinitionRequest(String sendDefinitionId, MERC_MarketingCloudClient.SendDefinition sendDefinition){
        String requestBody = getCreateSendDefinitionRequestJSON(sendDefinition);
        String responseBody = getCreateSendDefinitionResponseJSON(sendDefinitionId);
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/messaging/senddefinition/instance/?oauth_token=' + SOAP_OAUTH_TOKEN;

        MERC_MockHttpResponseService.BasicMockPostResponse mockResponse = new MERC_MockHttpResponseService.BasicMockPostResponse(
            requestURL,
            JSON_CHARSET_TYPE,
            JSON_TYPE,
            requestBody,
            responseBody);

        return (MERC_MockHttpResponseService.MockResponseInterface)mockResponse;
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getCreateSendDefinitionRequest(String sendDefinitionId){
        String responseBody = getCreateSendDefinitionResponseJSON(sendDefinitionId);
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/messaging/senddefinition/instance/?oauth_token=' + SOAP_OAUTH_TOKEN;

        CreateSendDefinitionMockResponse mockResponse = new CreateSendDefinitionMockResponse(
            requestURL,
            JSON_CHARSET_TYPE,
            JSON_TYPE,
            responseBody);

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

    public static String getSendDefinitionStatusResponseJSON(String status){
        return '{"id":"MTIxOTU1NTo1MDow","sendStatus":"' + status + '","jobId":1219555,"clientId":6272686}';
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getSendDefinitionStatusRequest(String sendDefinitionId, String status){
        String responseBody = getSendDefinitionStatusResponseJSON(status);
        String requestURL = CONFIG_ROOT_REST_API_URL + '/rest/beta/messaging/senddefinition/instance/' + EncodingUtil.urlEncode(sendDefinitionId,'UTF-8') + '/job/?oauth_token=' + SOAP_OAUTH_TOKEN;

        MERC_MockHttpResponseService.BasicMockGetResponse mockResponse = new MERC_MockHttpResponseService.BasicMockGetResponse(
            requestURL,
            JSON_TYPE, JSON_TYPE,
            responseBody);

        return mockResponse;
    }

    public static String getGetThumbnailResponseJSON(){
        return  '   { ' +
                '       "data": "' + getThumbnail() + '"' +
                '   }';
    }

    public static String getThumbnail(){
        return '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAEsASwDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD378KPwrIuNRuIbiRAyBFJA+XJHFCX904bdJEpHUbGbH5ZoA1/wo/CskX8xTIvLbcMdUYAg0gv5wDuvLbOOMI2OtAGv+FH4Vlm7uVVWe4gUHOMxsP6cU0XtyRu+025XuAjd/woA1vwo/Cshr64VsG7tcjA+4x5pxvLjcFW7tjkZyUYUAav4UfhWUb6cYH2m33YPBRhQb2fBZbq2xuxyjUAav4UfhWR9uueAbu25/6ZtmlF5cHazXduFIzxGxP+fagDW/Cj8Kykvbhjzc25wATtRuM/hSfb5sZ+1W3IJHyNkfUYoA1vwo/Cso30xyy3Ntt5Ayrdfy6Un264yf8ASbc46gI3fjPT1oA1vwo/Csk30y5X7XbFgefkbGPrSC/nwCby157BG/yKANSQzceUqH13sR/IU8bto3AZxzg1k/bp8M32u2Cg/wDPNuKT+0JgObmAHGc7G5HtxQBr/hR+FZP2+cMQbu1JAyQqsaf/AGhJGMNPbucZJwwxn8DQBp/hR+FUPt7AnLQj0+9g/pTRqfAzJByC2AW6e/HFAGj+FH4VnDUiQT5lvwSDhm/wpj6hKQStxboBwchjz+VAGp+FH4Vn/bCdubuNSwyP3Rx096QX6E/8fsZ9hEc0AaP4UfhWd9uCsytexkj0iP8Ak0q3mQG+1oV25z5Lc/SgDQ/Cj8Kyzfyl8R3FsRnurZP6Un9oS9rq2O4ZX5WyPwxQBq/hR+FZX26YcG6t8k8HY3+FBvpwo/0m2+8Ru2tjPp0/rQBq/hQTgZxWS1/LhQl5bEkfxI2Tj2pWvpiRsurYfLk7lb8e1AGX/wAIdaO5/wCJlroLEn/j8YCtWHQ44IxHHeX4UDvcEk/iadHeSPkm6hAHGVjZue/0q9BMssQdX3g99pH6VCpxWyOiWLry0lK5g3MavfTsCAwfnJ6elV49vmBjnb3x3q1dW6NeSnz41Jbp82f5UyS3RkCC5iGOoYMP6euas5x/2DcM+dbDdjhpMke1SrpFwYQEmjIY8kMSD+lVre2jJAWeNicfwsc/htrYTTlD5byyM5ICEf1oAof2LO2d8kbZORyeKcNHuNvMse7PvyK2ERY12oMD0p1AGKukXCs2x4lDYBOSSB7cUi6NcdZHicg8ZJ6Vt0UAYZ0Wcpt8yMZIz1p76PIWyrKADkfMcn9K2aKAMRdGnRgwlTK/d68H1p8WjzZ/eTIMchkB3ZrYooAyf7EHP+ktg9Rt60v9iJsAEzZzknb3rVooAyf7E9bkkYwRs/8Ar046P8m0XG0d8J1Pqea1KKAMuPRUjBxO+49DjpTRogTGy4wB6p/9etaigDKXRgrKwuDkdfl6+nelOj5BH2g7SckbO/51qUUAZUeiojE+cxz6LjBoTRVTH7/ocn5OtatFAGZ/Y4C7RcMMdDjnr9ab/Yv7pkF0w3HJIT861aKAMoaIqnKzFfolKNFRYtgmOcnDbecenvWpRQBk/wBinaR9qbJ77ef50v8AYo2hftDFQMKCvStWigDKXRAuMXByOny/Xr60p0ZcYWd1HpjitSigDJXRNoI+0sScc7e4/GlGigAD7Qeu4/IOTWrRQBl/2LGWyZOCMYC4pv8AYgxzcsSep2/pWtRQBlf2Kv8Az8N1yMr0oGirlS05baQcFfetWigCi+k27vuJkz7NVi2to7WHy492M5yxyTU1FAHP3FtK15KwikIJbop5zUU9rM4VjFKWI7Icf5/wrpaKAOetIbiOVdsJUju6Nge9b0fmbf3gUH/ZOafRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQB//2Q==';
    }

    public static MERC_MockHttpResponseService.MockResponseInterface getThumbnailRequest(String height, String width){
        String responseBody = getGetThumbnailResponseJSON();
        String requestURL = CONFIG_ROOT_THUMBNAIL_API_URL + '/' + CONFIG_URL_PART + '/utilities/ImageThumbnailSecure.ashx/\\?h=' + height + '&w=' + width + '&emailid=[^&=]+&oauth_token=' + SOAP_OAUTH_TOKEN;
        Pattern requestURLPattern = Pattern.compile(requestURL);
        MERC_MockHttpResponseService.BasicMockGetResponse mockResponse = new MERC_MockHttpResponseService.BasicMockGetResponse(
            requestURLPattern,
            JSON_TYPE, JSON_TYPE,
            responseBody);

        return mockResponse;
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
            JSON_CHARSET_TYPE,
            JSON_TYPE,
            requestBody,
            responseBody);

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
                '           "SubscriberKey":"' + personAccount.PersonContactId + '"  '  + 
                '       },  '  + 
                '       "values":{  '  + 
                '           "AccountId":"' + meetingParticipant.Account_MERC__c + '",  '  + 
                '           "MeetingId":"' + meetingId + '",  '  + 
                '           "MeetingParticipantId":"' + meetingParticipant.Id + '",  '  + 
                '           "AdditionalInformationHTML":"' + additionalInformationHTML + '",  '  + 
                '           "AdditionalInformationText":"' + additionalInformationText + '",  '  + 
                '           "EmailAddress":"' + personAccount.PersonEmail + '"  '  + 
                '       }  '  + 
                '  }  ' ; 
    }

    public static String getDataExtensionEntriesRequestJSON(
        Id meetingId,
        String additionalInformationHTML,
        String additionalInformationText,
        List<Meeting_Participant_MERC__c> meetingParticipants,
        Map<Id, Account> personAccountMap){
        List<String> dataExtensionEntryResponses = new List<String>();
        meetingParticipants.sort();
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
        String requestBody = getDataExtensionEntriesRequestJSON(
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

    public static MERC_MockHttpResponseService.MockResponseInterface getMockSubscriberUpdateRequest(
        MERC_MarketingCloudClient.Subscriber subscriber){

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

    public static MERC_MockHttpResponseService.MockResponseInterface getMockSubscribersRequest(
        List<MERC_MarketingCloudClient.Subscriber> subscribers,
        List<String> subscriberKeys){

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

    public class CreateSendDefinitionMockResponse implements MERC_MockHttpResponseService.MockResponseInterface {
        private String expectedEndpoint;
        private String contentType;
        private String acceptType;
        private String responseBody;
        private String authorization;
        private String action;

        public CreateSendDefinitionMockResponse(String expectedEndpoint,
                                                String contentType,
                                                String acceptType,
                                                String responseBody) {
            this.expectedEndpoint = expectedEndpoint;
            this.contentType = contentType;
            this.acceptType = acceptType;
            this.responseBody = responseBody;
        }

        public void withAuthorization(String authorization){
            this.authorization = authorization;
        }

        public void withAction(String action){
            this.action = action;
        }

        public Boolean shouldRespond(HttpRequest request) {
            Boolean methodMatch = request.getMethod() == POST_METHOD;
            Boolean endpointMatch = expectedEndpoint.equals(request.getEndpoint());
            if(methodMatch && endpointMatch){
                System.debug(LoggingLevel.FINE, POST_METHOD + ' to ' + expectedEndpoint + ' MATCHES: Checking header');
                Boolean contentTypeMatch = (contentType == null || contentType.equals(request.getHeader(MERC_MockHttpResponseService.CONTENT_TYPE_KEY)));
                Boolean acceptTypeMatch = (acceptType == null || acceptType.equals(request.getHeader(MERC_MockHttpResponseService.ACCEPT_TYPE_KEY)));
                Boolean authorizationMatch = (authorization == null || authorization.equals(request.getHeader(MERC_MockHttpResponseService.AUTHORIZATION_KEY)));
                Boolean actionMatch = (action == null || action.equals(request.getHeader(MERC_MockHttpResponseService.SOAP_ACTION)));    
                if(contentTypeMatch && acceptTypeMatch && authorizationMatch && actionMatch){
                    System.debug(LoggingLevel.FINE, 'Header MATCHES: Checking body');
                    String requestBody = request.getBody();
                    System.debug(LoggingLevel.FINE, 'Header MATCHES: Checking body');
                    try{
                        MERC_MarketingCloudClient.SendDefinition sendDefinition = 
                            (MERC_MarketingCloudClient.SendDefinition)JSON.deserialize(
                                    requestBody, MERC_MarketingCloudClient.SendDefinition.class);
                        if(String.isNotBlank(sendDefinition.emailSubject)){
                            return true;
                        } else {
                            System.debug(LoggingLevel.FINE,'Email Subject blank in parsed sendDefinition:\n' + requestBody);
                        }
                    } catch(JSONException jsonException){
                        System.debug(LoggingLevel.FINE, 'Body did not deserialize to a SendDefinition:\n' + requestBody);
                    }
                } else {
                    if(!contentTypeMatch){
                        System.debug(LoggingLevel.FINE, 'Content-Type mis-matched: ' + contentType + ' vs ' + request.getHeader(MERC_MockHttpResponseService.CONTENT_TYPE_KEY));
                    }
                    if(!acceptTypeMatch){
                        System.debug(LoggingLevel.FINE, 'Accept-Type mis-matched: ' + acceptType + ' vs ' + request.getHeader(MERC_MockHttpResponseService.ACCEPT_TYPE_KEY));
                    }
                    if(!authorizationMatch){
                        System.debug(LoggingLevel.FINE, 'Authorization mis-matched: ' + authorization + ' vs ' + request.getHeader(MERC_MockHttpResponseService.AUTHORIZATION_KEY));
                    }
                    if(!actionMatch){
                        System.debug(LoggingLevel.FINE, 'Action mis-matched: ' + action + ' vs ' + request.getHeader(MERC_MockHttpResponseService.SOAP_ACTION));
                    }
                }
            } else {
                System.debug(LoggingLevel.FINE, request.getMethod() + ' to ' + request.getEndpoint() + 
                    '\ndid not match\n' + POST_METHOD + ' to ' + expectedEndpoint);
            }

            return false;
        }
        
        public HttpResponse respond(){
            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setStatusCode(200);
            mockResponse.setBody(responseBody);
            if(acceptType != null){
                mockResponse.setHeader(CONTENT_TYPE_KEY, acceptType);
            }
            return mockResponse;
        }

        public String handlerName(){
            return 'CreateSendDefinition_' + expectedEndpoint + '_' + contentType + '_' + acceptType;
        }
    }

    public static MERC_MockHttpResponseService MockRequestsForEmailSendAttempt(
        User testUser,
        Meeting_MERC__c meeting,
        List<Meeting_Participant_MERC__c> participants,
        List<Account> personAccounts){
        MERC_MarketingCloudClient.DataExtension dataExtension = MERC_MarketingCloudTestUtility.getDataExtension(meeting.Id);
        MERC_MockHttpResponseService mockResponseService = MERC_MarketingCloudTestUtility.withDefaultMockService(testUser);
   
        MockThumbnailRequest(mockResponseService);
        MockSendDefinitionRequests(mockResponseService);
        MockDataExtensionRequests(
            mockResponseService,
            dataExtension,
            meeting.Id,
            participants,
            personAccounts);

        return mockResponseService;
    }


    public static void MockThumbnailRequest(MERC_MockHttpResponseService mockResponseService){
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getThumbnailRequest(MERC_MarketingCloudTestUtility.EMAIL_ID,
                MERC_MarketingCloudTestUtility.THUMBNAIL_HEIGHT, MERC_MarketingCloudTestUtility.THUMBNAIL_WIDTH));  
    }

    public static void MockDataExtensionRequests(
        MERC_MockHttpResponseService mockResponseService,
        MERC_MarketingCloudClient.DataExtension dataExtension,
        Id meetingId,
        List<Meeting_Participant_MERC__c> meetingParticipants,
        List<Account> personAccounts){
        Map<Id, Account> personAccountMap = MERC_MarketingCloudTestUtility.getPersonAccountMap(personAccounts);  

        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getCreateDataExtensionRequest(dataExtension)); 
          
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getCreateDataExtensionEntriesRequest(
                dataExtension,
                meetingId,
                MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_HTML,
                MERC_MarketingCloudTestUtility.EMAIL_ADDITIONAL_INFORMATION_TEXT,
                meetingParticipants,
                personAccountMap)); 
    }

    public static void MockSendDefinitionRequests(MERC_MockHttpResponseService mockResponseService){
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getCreateSendDefinitionRequest(
            MERC_MarketingCloudTestUtility.SEND_DEFINITION_ID));
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getStartSendDefinitionRequest(
            MERC_MarketingCloudTestUtility.SEND_DEFINITION_ID));
        mockResponseService.addResponse(MERC_MarketingCloudTestUtility.getSendDefinitionStatusRequest(
            MERC_MarketingCloudTestUtility.SEND_DEFINITION_ID,
            MERC_MarketingCloudService.StatusCompleted));
    }

    public static Set<Id> getParticipantIdsAsSet(List<Meeting_Participant_MERC__c> participants){
        Set<Id> participantIds = new Set<Id>();

        for(Meeting_Participant_MERC__c participant : participants){
            participantIds.add(participant.Id);
        }

        return participantIds;
    }

    public static Meeting_Process_MERC__c getMeetingProcess(Id participantId, String type){
        Meeting_Process_MERC__c meetingProcess = new Meeting_Process_MERC__c();
        meetingProcess.Meeting_Participant_MERC__c = participantId;
        meetingProcess.Process_Type_MERC__c = type;
        return meetingProcess;
    }

    public static Meeting_Process_MERC__c insertMeetingProcess(Id participantId, String type){
        Meeting_Process_MERC__c meetingProcess = getMeetingProcess(participantId, type);
        insert meetingProcess;
        return meetingProcess;
    }

    public static Travel_Itinerary_MERC__c getItinerary(Meeting_Participant_MERC__c participant, String status){
        Travel_Itinerary_MERC__c itinerary = new Travel_Itinerary_MERC__c();
        itinerary.Meeting_Participant_MERC__c = participant.Id;
        itinerary.Account_MERC__c = participant.Account_MERC__c;
        itinerary.Status_MERC__c = status;
        return itinerary;
    }

    public static Travel_Itinerary_MERC__c insertItinerary(Meeting_Participant_MERC__c participant, String status){
        Travel_Itinerary_MERC__c itinerary = getItinerary(participant, status);
        insert itinerary;
        return itinerary;
    }

    public static Meeting_Tasks_MERC__c getTask(Id processId, String status){
        Meeting_Tasks_MERC__c task = new Meeting_Tasks_MERC__c();
        task.Meeting_Process_MERC__c = processId;
        task.Task_Status_MERC__c = status;
        task.Due_Date_MERC__c = Date.today();
        return task;
    }

    public static Meeting_Tasks_MERC__c insertTask(String processId, String status){
        Meeting_Tasks_MERC__c task = getTask(processId, status);
        insert task;
        return task;
    }

    public class MERC_MarketingCloudTestUtilityException extends Exception { }
}