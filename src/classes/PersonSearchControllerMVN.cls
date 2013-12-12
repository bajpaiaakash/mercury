/*
* PersonSearchControllerMVN
* Created By: Vincent Reeder
* Created Date: January 9, 2012
* Last Modified Date: April 9, 2013
* Description: Controller for Person Search in Service Cloud.
*/
public with sharing class PersonSearchControllerMVN {
    private static String acctPrefix = Schema.SObjectType.Account.getKeyPrefix();
    private static String addrPrefix = Schema.SObjectType.Address_GLBL__c.getKeyPrefix();
    private static Integer SEARCHLIMIT = (Integer) Service_Cloud_Settings_MVN__c.getInstance().Knowledge_Search_Max_Results_MVN__c; // can never be greater than 200 due to sosl limits
    private static String ACCOUNTORDERBY = ' order by LastName, FirstName';
    private static String ADDRESSORDERBY = ' order by Account_GLBL__r.LastName, Account_GLBL__r.FirstName';
    private static String ACCOUNTFIELDS = 'Id, FirstName, LastName, Mdl_Nm_GLBL__c, RecordTypeId';
    private static String ADDRESSFIELDS = 'Id, Name, Line_1_Adrs_Txt_GLBL__c, City_GLBL__c, toLabel(St_Cd_GLBL__c), Zip_Postal_Code_GLBL__c, toLabel(Adrs_Cntry_Cd_GLBL__c), Account_GLBL__c, Account_GLBL__r.LastName, Account_GLBL__r.FirstName, Account_GLBL__r.Mdl_Nm_GLBL__c, Account_GLBL__r.RecordTypeId';

    public String actId {get;set;}
    public String refId {get;set;}
    public String addId {get;set;}
    public String recordTypeText {get;set;}
    public Case cs {get; set;}
    public Address_GLBL__c searchAddress {get;set;}
    public Address_GLBL__c createAddress {get;set;}
    public Account searchAccount {get;set;}
    public Account createAccount {get;set;}
    
    public String employeeRecordTypeName {get;set;}
    public Id employeeRecordTypeId {get; set;}
    public String hcpRecordTypeName {get;set;}
    public Id hcpRecordTypeId {get; set;}
    public List<SelectOption> recordTypeSelectOptions{get; set;}
    public List<PersonSearchResultMockMVN> searchResults {get;set;}
    public Map<String,String> recordTypeTranslations {get;set;}

    public Boolean didInsertSucceed {get;set;}
    public Boolean didSearch {get;set;}
    public Boolean didTryCreate {get;set;}
    public Boolean showNewButton {get;set;}
    public Boolean createReferredBy{get; set;}
    public Boolean removeAccountError{get; set;}
    public Boolean standAloneSearch{get; set;}

    private Service_Cloud_Settings_MVN__c settings;
    private List<Id> validRecordTypeIds;
    private ApexPages.StandardController ctrl;
    private String phoneSearch = ApexPages.currentPage().getParameters().get('phoneSearch');
    
    public PersonSearchControllerMVN(ApexPages.StandardController controller){
        recordTypeText = 'All';
        settings = Service_Cloud_Settings_MVN__c.getInstance();
        employeeRecordTypeName = settings.Employee_Record_Type_MVN__c;
        hcpRecordTypeName = settings.HCP_Record_Type_MVN__c;
        removeAccountError = false;
        
        validRecordTypeIds = new List<Id>();

        cs = (Case) controller.getRecord();
        
        if(cs.Id != null){
            getCaseValues();
            standAloneSearch = false;
        } else
            standAloneSearch = true;
        
        employeeRecordTypeId = [select Id from RecordType where SObjectType='Account' and DeveloperName = :employeeRecordTypeName].Id;
        hcpRecordTypeId = [select Id from RecordType where SObjectType='Account' and DeveloperName = :hcpRecordTypeName].Id;

        createReferredBy = false;

        clearSearch();

        searchResults = new List<PersonSearchResultMockMVN>();

        didSearch = false;
        didTryCreate = false;
        didInsertSucceed = false;
        showNewButton = false;

        Set<String> countrySet = new Set<String>();
        for(Schema.PicklistEntry countryPicklistValue:Address_GLBL__c.Adrs_Cntry_Cd_GLBL__c.getDescribe().getPicklistValues()){
            countrySet.add(countryPicklistValue.getValue());
        }

        User runningUser = [Select Country from User where Id = :UserInfo.getUserId()];
        if(!settings.Do_Not_Default_Country_MVN__c && countrySet.contains(runningUser.Country)){
            searchAddress.Adrs_Cntry_Cd_GLBL__c = runningUser.Country;
        }
        
        initializeRecordTypeSelectOptions();

        if(phoneSearch != null) {
            searchAccount.Phone = phoneSearch;
            doSearch();
        }

    }

    public List<SelectOption> initializeRecordTypeSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Map<String,RecordType> recordTypes = recordTypeMap();
        recordTypeTranslations = new Map<String,String>();
        List<String> usedRecordTypes = settings.Person_Search_Record_Types_MVN__c.deleteWhiteSpace().split(',');

        for(String rtOption : usedRecordTypes) {
            validRecordTypeIds.add(recordTypes.get(rtOption).Id);
        }

        List<RecordTypeLocalization> recordTypeLocalization = [SELECT Value, Id, ParentId from RecordTypeLocalization WHERE Language = :UserInfo.getLanguage()
                AND ParentId in :validRecordTypeIds];

        for(String rtOption : usedRecordTypes) {
            RecordType rt = recordTypes.get(rtOption);
            String transLabel = rt.Name;

            for(RecordTypeLocalization rtl : recordTypeLocalization){
                if(rtl.ParentID == rt.Id) {
                    transLabel = rtl.Value;
                }
            }

            if(phoneSearch == null || phoneSearch == ''){
                if(rtOption == settings.Person_Search_Default_Record_Type_MVN__c) {
                    recordTypeText = rt.Id;
                }
            }else{
                if(rtOption == settings.Phone_Search_Default_Record_Type_MVN__c) {
                    recordTypeText = rt.Id;
                }
            }

            options.add(new SelectOption(rt.Id,transLabel));
            recordTypeTranslations.put(rt.Id,transLabel);
        }

        recordTypeSelectOptions = options;

        return options;
    }

    public Map<String,RecordType> recordTypeMap(){
        Map<String,RecordType> recordTypes = new Map<String,RecordType>();
        for(RecordType rt : [SELECT Id, Name, DeveloperName, IsActive, IsPersonType FROM RecordType WHERE sObjectType = 'Account' AND IsPersonType = TRUE]){
            recordTypes.put(rt.DeveloperName,rt);
        }
        return recordTypes;
    }

    public void getCaseValues() {
        cs = [select Id, AccountId, Account.Name, Account.Salutation, Referred_By_GLBL__c, Referred_By_GLBL__r.Name from Case where Id = :cs.Id];
    }

    public PageReference removeRequester(){
        cs.AccountId = null;
        cs.ContactId = null;
        cs.Address_GLBL__c = null;
        cs.Account_Email_GLBL__c = null;
        cs.City_GLBL__c = null;
        cs.AddressLine1_GLBL__c = null;
        cs.AddressLine2_GLBL__c = null;
        cs.State_GLBL__c = null;
        cs.Postal_Code_GLBL__c = null;
        cs.Account_Phone_GLBL__c = null;
        cs.Account_Fax_GLBL__c = null;
        
   		try{
            update cs;
        }catch(Exception e){
            ApexPages.addMessages(e);
            removeAccountError = true;
        }
        getCaseValues();
        
        return null;
    }

    public PageReference removeReferredBy(){
        cs.Referred_By_GLBL__c = null;
        
        try{     
            update cs;  
        }catch(Exception e){
            ApexPages.addMessages(e);
            removeAccountError = true;
        }
        getCaseValues();
        
        return null;
    }

    public PageReference addReferredBy(){
        cs.Referred_By_GLBL__c = refId;
        try{    
            update cs;
        }catch(Exception e){
            ApexPages.addMessages(e);
        }
        
        getCaseValues();
        
        return null;
    }

    public PageReference changeRecordType() {
        showNewButton = false;
        createAccount.Fax = null;
        return null;
    }

    public PageReference updateNewPerson() {        
        createAddress = searchAddress;
        createAccount = searchAccount;
        if(recordTypeText != 'All') {
           createAccount.RecordTypeId = recordTypeText;
        } else {
            createAccount.RecordTypeId = null;
        }
        

        List<String> fNames = new List<String>{'City_GLBL__c','Zip_Postal_Code_GLBL__c'};
        for(String field : fNames) {
            String value = (String) createAddress.get(field);
            if(!String.isBlank(value)) {
                createAddress.put(field,value.replaceAll('\\*',''));
            }
        }

        fNames = new List<String>{'FirstName','LastName','Mdl_Nm_GLBL__c','Phone'};
        for(String field : fNames) {
            String value = (String) createAccount.get(field);
            if(!String.isBlank(value)) {
                createAccount.put(field,value.replaceAll('\\*',''));
            }
        }
        return null;
    }

    public PageReference updateCase(){
        Account selectedAccount = [SELECT FirstName, LastName, PersonEmail, Phone, Fax from Account where Id = :actId];
        Address_GLBL__c selectedAddress = new Address_GLBL__c();
        List<Address_GLBL__c> getAddresses = [SELECT Name, Line_2_Adrs_Txt_GLBL__c, City_GLBL__c, St_Cd_GLBL__c, Zip_Postal_Code_GLBL__c, Adrs_Cntry_Cd_GLBL__c FROM Address_GLBL__c WHERE Id = :addId];
        if(getAddresses.size() > 0) {
            selectedAddress = getAddresses[0];
        }

        cs.AccountId = selectedAccount.Id;
        cs.Address_GLBL__c = selectedAddress.Id;
        cs.Account_Email_GLBL__c = selectedAccount.PersonEmail;
        cs.Account_Phone_GLBL__c = selectedAccount.Phone;
        cs.Account_Fax_GLBL__c = selectedAccount.Fax;
        
        try{
            update cs;
        }catch(Exception e){
            ApexPages.addMessages(e);
        }
        getCaseValues();

        return null;
    }
    
    public PageReference enterAccount() {
        removeAccountError = false;
        didInsertSucceed = false;
        didTryCreate = true;
        
        if(createAccount.RecordTypeId == employeeRecordTypeId){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, System.Label.Please_Select_Requester_or_Referred_By_MVN));
            
            return null;
        }
        
        return createAccount();
    }
    
    public PageReference createAccount() {
        removeAccountError = false;
        didInsertSucceed = false;
        didTryCreate = true;

        if(createAccount.RecordTypeId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Create_Person_Record_Type_Required_MVN));
            return null;
        }

        //Creation
        SavePoint sp = Database.setSavePoint();

        try {
            if(!String.isBlank(createAccount.Phone)) {
                createAccount.Phone = createAccount.Phone.replaceAll('[^0-9]', '');
            }
            if(!String.isBlank(createAccount.Fax)) {
                createAccount.Fax = createAccount.Fax.replaceAll('[^0-9]', '');
            }
            if(createAccount.PersonEmail != null && createAccount.PersonEmail != '' && !Pattern.matches('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})', createAccount.PersonEmail)){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, Label.Invalid_Email_Address_MVN));
                return null;
            }
            
            insert createAccount;
            
            createAddress.Account_GLBL__c = createAccount.Id;

            if((createAddress.Name != null && !String.isBlank(createAddress.Name))
                || (createAddress.Line_2_Adrs_Txt_GLBL__c != null && !String.isBlank(createAddress.Line_2_Adrs_Txt_GLBL__c))
                || (createAddress.City_GLBL__c != null && !String.isBlank(createAddress.City_GLBL__c))
                || (createAddress.St_Cd_GLBL__c != null && !String.isBlank(createAddress.St_Cd_GLBL__c))){
                insert createAddress;
            }
            
            if(!standAloneSearch){
                if(!createReferredBy){
                    cs.AccountId = createAccount.Id;
                    cs.Address_GLBL__c = createAddress.Id;
                    cs.Account_Fax_GLBL__c = createAccount.Fax;
                    cs.Account_Phone_GLBL__c = createAccount.Phone;
                    cs.Account_Email_GLBL__c = createAccount.PersonEmail;
                }else{
                    cs.Referred_By_GLBL__c = createAccount.Id;
                }
                
                createReferredBy = false;

                update cs;
                getCaseValues();
            }

            clearSearch();
            
            didInsertSucceed = true;
        }
        catch (Exception e) {
            //need to clone failed account and address records to clear id field
            createAccount = createAccount.clone(false,true,false,false);
            createAddress = createAddress.clone(false,true,false,false);
            getCaseValues();
            
            ApexPages.addMessages(e);
            Database.rollback(sp);
        }
        return null;
    }

    public PageReference clearSearch() {
        removeAccountError = false;
        
        createAddress = new Address_GLBL__c();
        searchAddress = new Address_GLBL__c();
        createAccount = new Account();
        searchAccount = new Account();
        searchResults = new List<PersonSearchResultMockMVN>();
        didSearch = false;

        return null;
    }

    public PageReference doSearch(){
        removeAccountError = false;
        
        searchAccount.FirstName = searchAccount.FirstName != null ? (searchAccount.FirstName.length() > 0 ? String.escapeSingleQuotes(searchAccount.FirstName.trim()) : '') : '';
        searchAccount.LastName = searchAccount.LastName != null ? (searchAccount.LastName.length() > 0 ? String.escapeSingleQuotes(searchAccount.LastName.trim()) : '') : '';
        searchAccount.Mdl_Nm_GLBL__c = searchAccount.Mdl_Nm_GLBL__c != null ? (searchAccount.Mdl_Nm_GLBL__c.length() > 0 ? String.escapeSingleQuotes(searchAccount.Mdl_Nm_GLBL__c.trim()) : '') : '';
        searchAccount.Phone = searchAccount.Phone != null ? (searchAccount.Phone.length() > 0 ? String.escapeSingleQuotes(searchAccount.Phone.trim()) : '') : '';
        searchAddress.City_GLBL__c = searchAddress.City_GLBL__c != null ? (searchAddress.City_GLBL__c.length() > 0 ? String.escapeSingleQuotes(searchAddress.City_GLBL__c.trim()) : '') : '';
        searchAddress.Zip_Postal_Code_GLBL__c = searchAddress.Zip_Postal_Code_GLBL__c != null ? (searchAddress.Zip_Postal_Code_GLBL__c.length() > 0 ? String.escapeSingleQuotes(searchAddress.Zip_Postal_Code_GLBL__c.trim()) : '') : '';
        
        searchResults = new List<PersonSearchResultMockMVN>();
        
        //Make sure something is filled out
        didTryCreate = false;
        if (String.isBlank(searchAccount.FirstName) && String.isBlank(searchAccount.LastName) && String.isBlank(searchAccount.Mdl_Nm_GLBL__c) && String.isBlank(searchAccount.Phone) && String.isBlank(searchAddress.City_GLBL__c) && String.isBlank(searchAddress.St_Cd_GLBL__c) && String.isBlank(searchAddress.Zip_Postal_Code_GLBL__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, System.Label.Search_Term_Required_MVN));
            return null;
        }

        //Pick search path: Only Accounts, Addresses, SOSL Phone
        if (!String.isBlank(searchAccount.Phone)) {
            searchResults = buildPhoneSearchResults();
        } else if (String.isBlank(searchAddress.City_GLBL__c) && String.isBlank(searchAddress.St_Cd_GLBL__c) && String.isBlank(searchAddress.Zip_Postal_Code_GLBL__c)) {
            searchResults = buildAccountSearchResults();
        } else {
            searchResults = buildAddressSearchResults();
        }

        if(searchResults == null) {
            searchResults = new List<PersonSearchResultMockMVN>();
            return null;
        }

        if (searchResults.size() >= SEARCHLIMIT) {
            searchResults = new List<PersonSearchResultMockMVN>();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, System.Label.Too_Many_Results_MVN));
        } else if (searchResults.size() == 0 ) {
            searchResults = new List<PersonSearchResultMockMVN>();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, System.Label.No_Search_Results_MVN));
        }

        if(searchResults == null) searchResults = new List<PersonSearchResultMockMVN>();
        didSearch = true;
        showNewButton = true;
        return null;
    }

    public List<PersonSearchResultMockMVN> buildAddressSearchResults() {
        List<PersonSearchResultMockMVN> resultList = new List<PersonSearchResultMockMVN>();
        String qString = 'SELECT ' + ADDRESSFIELDS;
        qString += ' FROM Address_GLBL__c ' + buildAddressWhereClause() + ADDRESSORDERBY + ' LIMIT ' + SEARCHLIMIT;

        List<Address_GLBL__c> addressList = database.query(qString);
        for(Address_GLBL__c a : addressList) {
                Account acct = new Account(Id = a.Account_GLBL__c);
                acct.FirstName = a.Account_GLBL__r.FirstName;
                acct.LastName = a.Account_GLBL__r.LastName;
                acct.Mdl_Nm_GLBL__c = a.Account_GLBL__r.Mdl_Nm_GLBL__c;
                acct.RecordTypeId = a.Account_GLBL__r.RecordTypeId;
    
                resultList.add(new PersonSearchResultMockMVN(acct,a));
        }
        
        return resultList;
    }

    public List<PersonSearchResultMockMVN> buildAccountSearchResults() {
        List<PersonSearchResultMockMVN> resultList = new List<PersonSearchResultMockMVN>();

        String qString = 'SELECT ' + ACCOUNTFIELDS;
        qString += ',(SELECT ' + ADDRESSFIELDS + ' FROM Addresses_GLBL__r)';
        qString += ' FROM Account ' + buildAccountWhereClause() + ACCOUNTORDERBY + ' LIMIT ' + SEARCHLIMIT;

        String translatedCountryValue = null;
        if(searchAddress.Adrs_Cntry_Cd_GLBL__c != null && searchAddress.Adrs_Cntry_Cd_GLBL__c != ''){
            for(Schema.PicklistEntry countryPicklistVal:Schema.sObjectType.Address_GLBL__c.fields.Adrs_Cntry_Cd_GLBL__c.getPicklistValues()){
                if(countryPicklistVal.getValue() == searchAddress.Adrs_Cntry_Cd_GLBL__c){
                    translatedCountryValue = countryPicklistVal.getLabel();
                }
            }
        }
        
        List<Account> accountList = database.query(qString);
        for(Account a : accountList ) {
            if(a.Addresses_GLBL__r.size() > 0) {
                for(Address_GLBL__c addr : a.Addresses_GLBL__r) {
                    if(translatedCountryValue != null &&
                        translatedCountryValue != addr.Adrs_Cntry_Cd_GLBL__c){
                        continue;
                    }
                    resultList.add(new PersonSearchResultMockMVN(a,addr));
                }
            } else {
                resultList.add(new PersonSearchResultMockMVN(a));
            }
        }

        return resultList;
    }

    public List<PersonSearchResultMockMVN> buildPhoneSearchResults () {

        //Do initial query
        String queryString = buildSOSLString();
        if(queryString == null) {
            return null;
        }

        LIST<LIST<SObject>> soslResult;
        try {
            system.debug('>>>>>>> ' + queryString);
            soslResult = search.query(queryString);
        } catch (exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, e.getMessage()));
            return null;
        }

        //Set up Maps and lists needed
        LIST<LIST<SObject>> results = soslResult;
        List<Account> acctResults = new List<Account>();
        List<Address_GLBL__c> addrResults = new List<Address_GLBL__c>();
        //AccountId_AddressId to the Mock Result
        Map<String,PersonSearchResultMockMVN> uResults = new Map<String,PersonSearchResultMockMVN>();
        
        Map<Id,Account> acctIds = new Map<Id,Account>();

        //Separate out what kind each list is
        for(List<SObject> oneKind : results) {
            if(oneKind.size() > 0) {
                String typeId = oneKind[0].Id;
                if(typeId.startsWith(acctPrefix)) {
                    acctResults = (List<Account>) oneKind;
                } else if(typeId.startsWith(addrPrefix)) {
                    addrResults = (List<Address_GLBL__c>) oneKind;
                }
            }
        }

        //Get related Addresses
        for(Account a : acctResults) {
            acctIds.put(a.Id,a);
            if (String.isBlank(searchAddress.City_GLBL__c) && String.isBlank(searchAddress.St_Cd_GLBL__c) && String.isBlank(searchAddress.Zip_Postal_Code_GLBL__c)) {
                uResults.put(a.Id,new PersonSearchResultMockMVN(a));
            }
        }

        Set<Id> idSet = acctIds.keySet();
        String qString = 'SELECT ' + ADDRESSFIELDS + ' FROM Address_GLBL__c ' + buildAddressWhereClause() + ' AND Account_GLBL__c in :idSet' + ADDRESSORDERBY + ' LIMIT ' + SEARCHLIMIT;
        List<Address_GLBL__c> subAddrs = database.query(qString);
        addrResults.addAll(subAddrs);

        for(Address_GLBL__c addr : addrResults) {
            Account acct = new Account(Id = addr.Account_GLBL__c);
            acct.FirstName = addr.Account_GLBL__r.FirstName;
            acct.LastName = addr.Account_GLBL__r.LastName;
            acct.Mdl_Nm_GLBL__c = addr.Account_GLBL__r.Mdl_Nm_GLBL__c;
            acct.RecordTypeId = addr.Account_GLBL__r.RecordTypeId;

            String key = acct.Id + '_' + addr.Id;
            if (!uResults.containsKey(key)) {
                if(uResults.containsKey(acct.Id)) {
                    PersonSearchResultMockMVN psr = uResults.remove(acct.Id);
                    psr.setAddress(addr);
                    uResults.put(key,psr);
                } else {
                    uResults.put(key,new PersonSearchResultMockMVN(acct,addr));
                }
            }
        }

        return uResults.values();
    }

    public String buildSOSLString(){
        //Put together final query and error check it
        String qString = 'FIND {';
        String findString = '';

        //Cannot search for phone numbers with punctuation
        findString = searchAccount.Phone.replaceAll('[^0-9]', '');
        if (findString.length() < 2) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, System.Label.SOSL_Phone_Search_Min_Char_MVN + ' ' + findString));
            return null;
        }

        qString += findString + '} IN PHONE FIELDS RETURNING ';
        qString += ' Address_GLBL__c (' + ADDRESSFIELDS;
        qString += buildAddressWhereClause();
        qString += ADDRESSORDERBY;
        qString += '), ';
        qString += ' Account (' + ACCOUNTFIELDS;
        qString += buildAccountWhereClause();
        qString += ACCOUNTORDERBY;
        qString += ') ';

        return qString;
    }

    public String buildAccountWhereClause() {
        String acctString = '';
        acctString +=' WHERE IsDeleted = false ';

        Map<String,String> fieldMap = new Map<String,String>();
        fieldMap.put('LastName like',searchAccount.LastName);
        fieldMap.put('FirstName like',searchAccount.FirstName);
        fieldMap.put('Mdl_Nm_GLBL__c like',searchAccount.Mdl_Nm_GLBL__c);

        for(String field : fieldMap.keySet()) {
            String sTerm = fieldMap.get(field);
            if(sTerm != null && !String.isBlank(sTerm)){
                acctString += ' AND (' + field + ' \'' + sTerm.replaceAll('\\*', '%') + '\')';
            }
        }

        if(recordTypeText == 'All') {
            acctString += ' AND (RecordTypeId in :validRecordTypeIds)';
        } else {
            acctString += ' AND (RecordTypeId = \'' + recordTypeText + '\')';
        }

        return acctString;
    }

    public String buildAddressWhereClause() {
        String addrString = ' WHERE IsDeleted = false ';

        Map<String,String> fieldMap = new Map<String,String>();
        fieldMap.put('City_GLBL__c like',searchAddress.City_GLBL__c);
        fieldMap.put('St_Cd_GLBL__c =',searchAddress.St_Cd_GLBL__c);
        fieldMap.put('Zip_Postal_Code_GLBL__c like',searchAddress.Zip_Postal_Code_GLBL__c);
        fieldMap.put('Adrs_Cntry_Cd_GLBL__c =',searchAddress.Adrs_Cntry_Cd_GLBL__c);
        fieldMap.put('Account_GLBL__r.LastName like',searchAccount.LastName);
        fieldMap.put('Account_GLBL__r.FirstName like',searchAccount.FirstName);
        fieldMap.put('Account_GLBL__r.Mdl_Nm_GLBL__c like',searchAccount.Mdl_Nm_GLBL__c);

        for(String field : fieldMap.keySet()) {
            String sTerm = fieldMap.get(field);
            if(sTerm != null && !String.isBlank(sTerm)){
                addrString += ' AND (' + field + ' \'' + sTerm.replaceAll('\\*', '%') + '\')';
            }
        }

        if(recordTypeText == 'All') {
            addrString += ' AND (Account_GLBL__r.RecordTypeId in :validRecordTypeIds)';
        } else {
            addrString += ' AND (Account_GLBL__r.RecordTypeId = \'' + recordTypeText + '\')';
        }

        return addrString;
    }
}