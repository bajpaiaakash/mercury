/**
 * Created by: Eric Montelibano (PwC)- 21/05/2015
 * Application: Quality in Design User Experience (QDUX)
 * 
 * Description: Test Methods for QDUX Controller and Classes
*/

@isTest
public class QDUX_Test_Class1 {
    //retrieve Record Type Id
    public static id commLinksRTId = [Select Id from RecordType where sobjecttype='GLBL_Application_Link__c' 
                                      and Name =: Label.QDUX_ApplicationLinkRecordTypeLabel].id;
    public static id procRTId = [Select Id from RecordType where sobjecttype='GLBL_Application_Link__c' 
                                 and Name =: Label.QDUX_ProcessLinkRTLabel].id;
    
    public static GLBL_Application_Link__c applinks;
    
    public static CollaborationGroup chatterGroups;
    
    
    public static testMethod void setUpApplicationLinks() {
        List <GLBL_Application_Link__c> appList = new List <GLBL_Application_Link__c>();
        //insert common links
        for (integer i = 0; i < 5; i++){
            GLBL_Application_Link__c app = new GLBL_Application_Link__c();
            app.Active__c = true;
            app.Link_Name__c = 'Common Links ' +i;
            app.Link_Description__c = 'Common Links' +i;
            app.Link_URL__c = 'www.LinkTest.com/' +i;
            app.RecordTypeId = commLinksRTId;
            app.Application_Code__c = Label.QDUX_Application_Link_App_Code;
            appList.add(app);
        }
        
        //insert process links
        for (integer i = 0; i < 5; i++){
            GLBL_Application_Link__c app = new GLBL_Application_Link__c();
            app.Active__c = true;
            app.Link_Name__c = 'Process Links Test  ' +i;
            app.Link_Description__c = 'Process Links Test ' +i;
            app.Link_URL__c = 'www.ProcessLinksTEst.com/' +i;
            app.RecordTypeId = procRTId;
            app.Application_Code__c = Label.QDUX_Application_Link_App_Code;
            appList.add(app);
        }
        insert appList;
        system.debug('APP LIST ' +appList);
        
        List<CollaborationGroup> chList = new List <CollaborationGroup>();
        for (integer i = 0; i<5; i++){
            CollaborationGroup ch = new CollaborationGroup();
            ch.Name = 'Chatter Group ' +i;
            ch.Description = 'Chatter Group Description Test ' +i;
            ch.CollaborationType = 'Public';
            chList.add(ch);
        }
        
        insert chList;
    }
    
    public static testMethod void testAppLinkCon(){
        setUpApplicationLinks();
        QDUX_ApplicationLinkController con = new QDUX_ApplicationLinkController();
        con.getApplicationLinks();
    }
    
    //test for SearchResult
    public static testMethod void testSearhResult1(){
        setUpApplicationLinks();
        QDUX_SearchPageResultController res = new QDUX_SearchPageResultController();
        Apexpages.currentPage().getParameters().put('search', 'Test');
        res.component = 'CollabGroup';
        res.init();
        res.getCommonProcedures();
        
    }
    public static testMethod void testNegativeSearch(){
        setUpApplicationLinks();
        QDUX_SearchPageResultController res = new QDUX_SearchPageResultController();
        Apexpages.currentPage().getParameters().put('search', 'T');
        res.component = 'CollabGroup';
        res.init();
        res.getCommonProcedures();
    }
    
    public static testMethod void testMissingCharacterts(){
        setUpApplicationLinks();
        QDUX_SearchPageResultController res = new QDUX_SearchPageResultController();
        Apexpages.currentPage().getParameters().put('search', 'T');
        res.strSearch = 'T';
        res.component = 'CollabGroup';
        res.search();
        system.assertequals('T', res.strSearch);
        res.getCommonProcedures();
    }
    
    
    public static testmethod void testMyDoc(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('QDUX_JSONTestFile4');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        PageReference pageRef = Page.QDUX_MyDocDashboard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Library','My Documents');
        QDUX_VVMyDocController myDocs = new QDUX_VVMyDocController();
        myDocs.vaultName = Label.QDUX_Quality_Docs_Label;
        myDocs.initialize();
        
    }
    public static testmethod void testMyDocETMF(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('QDUX_JSONTestFile4');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        PageReference pageRef = Page.QDUX_MyDocDashboard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Library','My Documents');
        QDUX_VVMyDocController myDocs = new QDUX_VVMyDocController();
        myDocs.vaultName= Label.QDUX_ETMF_Label;
        //myDocs.refresh();
        myDocs.filter = 'My Documents';
        myDocs.initialize();
        
    }
    
    public static testmethod void testNoDocs(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('QDUX_JSONTestFile5');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        //QDUX_VVMyDocController.setvaultName(Label.QDUX_Quality_Docs_Label);
        PageReference pageRef = Page.QDUX_MyDocDashboard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Library','Favorites');
        QDUX_VVMyDocController myDocs = new QDUX_VVMyDocController();
        myDocs.vaultName= Label.QDUX_ETMF_Label;
        myDocs.initialize();
    }
    
    public static testmethod void testVVError(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('QDUX_JSONTestFile3');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock); 
        //QDUX_VVMyDocController.setvaultName(Label.QDUX_Quality_Docs_Label);
        PageReference pageRef = Page.QDUX_MyDocDashboard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Library','Favorites');
        QDUX_VVMyDocController myDocs = new QDUX_VVMyDocController();
        myDocs.initialize();
        myDocs.vaultName= Label.QDUX_ETMF_Label;
        
    }
    //Search
    @isTest static void testCalloutQDSearchResult() {
        // Set mock callout class 
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('QDUX_JSONTestFile1');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mock);
        QDUX_SearchPageResultController res = new QDUX_SearchPageResultController();
        Apexpages.currentPage().getParameters().put('search', 'Test');
        res.component = Label.QDUX_Quality_Docs_Label;
        res.init();
        res.getCommonProcedures();
        
    }
    
    @isTest static void testCalloutETMFSearchResult() {
        // Set mock callout class
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('QDUX_JSONTestFile1');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mock);
        QDUX_SearchPageResultController res = new QDUX_SearchPageResultController();
        Apexpages.currentPage().getParameters().put('search', 'Test');
        res.component=Label.QDUX_ETMF_Label;
        res.init();
        
        res.getCommonProcedures();
        
    }
    
    @isTest static void testCalloutError() {
        // Set mock callout class
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('QDUX_JSONTestFile2');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mock);
        QDUX_SearchPageResultController res = new QDUX_SearchPageResultController();
        Apexpages.currentPage().getParameters().put('search', 'Test');
        res.component=Label.QDUX_Quality_Docs_Label;
        res.init();
        res.getCommonProcedures();
        
    }
    
    @isTest static void testCalloutError2() {
        // Set mock callout class
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('QDUX_JSONTestFile3');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mock);
        QDUX_SearchPageResultController res = new QDUX_SearchPageResultController();
        Apexpages.currentPage().getParameters().put('search', 'Test');
        res.component=Label.QDUX_Quality_Docs_Label;
        res.init();
        res.getCommonProcedures();
        
    }
    
    @isTest static void testCOVaultId() {
        // Set mock callout class
        String vaultHttps = 'https://';
        String strQ ='SELECT id, user_name__v, salesforce_user_name__v FROM users where salesforce_user_name__v = \'' +UserInfo.getUserName() +'\'';
        string endpoint1 = vaultHttps +Label.QDUX_VaultQualityDocs_Prefix +label.QDUX_VV_BaseURL +label.QDUX_VV_Query_URL_Suffix +EncodingUtil.urlEncode(strQ , 'UTF-8');
        system.debug('endpoint 1?????' +endpoint1);
        String strQ2 = 'select workflow_id__v ,workflow_status__v, task_id__v, task_name__v, task_status__v, task_assignee_name__v, task_assignee__v, task_dueDate__v, workflow_document_id__v ';
        strQ2+='from workflows where task_assignee__v = \'285309\' and task_dueDate__v > \'2000-01-01\' ORDER BY task_dueDate__v ASC limit 5';
        String endpoint2 = vaultHttps +Label.QDUX_VaultQualityDocs_Prefix +label.QDUX_VV_BaseURL +label.QDUX_VV_Query_URL_Suffix +EncodingUtil.urlEncode(strQ2 , 'UTF-8');
        
        String strQ3 = 'select workflow_id__v ,workflow_status__v, task_id__v, task_name__v, task_status__v, task_assignee_name__v, task_assignee__v, task_dueDate__v, workflow_document_id__v ';
        strQ3+='from workflows where task_assignee__v = \'285309\' and task_dueDate__v > \'2000-01-01\' ORDER BY task_dueDate__v ASC limit 5';
        String endpoint3 = vaultHttps +Label.QDUX_VaultETMF_Prefix +label.QDUX_VV_BaseURL +label.QDUX_VV_Query_URL_Suffix +EncodingUtil.urlEncode(strQ3 , 'UTF-8');
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        //multimock.setStaticResource(url, staticResourceName)
        multimock.setStaticResource(endpoint1, 'QDUX_JSONTestFile6');
        multimock.setStaticResource(endpoint2, 'QDUX_JSONTestFile7');
        multimock.setStaticResource(endpoint3, 'QDUX_JSONTestFile7');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, multimock);
        QDUX_VVMyAlertsController myAlert = new QDUX_VVMyAlertsController();
        myAlert.strVVId = '11111';
        myAlert.notificationAlert();
        
        
    }
    
    @isTest static void testCOVaultId2() {
        // Set mock callout class
        String vaultHttps = 'https://';
        String strQ ='SELECT id, user_name__v, salesforce_user_name__v FROM users where salesforce_user_name__v = \'' +UserInfo.getUserName() +'\'';
        string endpoint1 = vaultHttps +Label.QDUX_VaultQualityDocs_Prefix +label.QDUX_VV_BaseURL +label.QDUX_VV_Query_URL_Suffix +EncodingUtil.urlEncode(strQ , 'UTF-8');
        system.debug('endpoint 1?????' +endpoint1);
        String strQ2 = 'select workflow_id__v ,workflow_status__v, task_id__v, task_name__v, task_status__v, task_assignee_name__v, task_assignee__v, task_dueDate__v, workflow_document_id__v ';
        strQ2+='from workflows where task_assignee__v = \'285309\' and task_dueDate__v > \'2000-01-01\' ORDER BY task_dueDate__v ASC limit 5';
        String endpoint2 = vaultHttps +Label.QDUX_VaultQualityDocs_Prefix +label.QDUX_VV_BaseURL +label.QDUX_VV_Query_URL_Suffix +EncodingUtil.urlEncode(strQ2 , 'UTF-8');
        
        String strQ3 = 'select workflow_id__v ,workflow_status__v, task_id__v, task_name__v, task_status__v, task_assignee_name__v, task_assignee__v, task_dueDate__v, workflow_document_id__v ';
        strQ3+='from workflows where task_assignee__v = \'285309\' and task_dueDate__v > \'2000-01-01\' ORDER BY task_dueDate__v ASC limit 5';
        String endpoint3 = vaultHttps +Label.QDUX_VaultETMF_Prefix +label.QDUX_VV_BaseURL +label.QDUX_VV_Query_URL_Suffix +EncodingUtil.urlEncode(strQ3 , 'UTF-8');
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        //multimock.setStaticResource(url, staticResourceName)
        multimock.setStaticResource(endpoint1, 'QDUX_JSONTestFile6');
        multimock.setStaticResource(endpoint2, 'QDUX_JSONTestFile7');
        multimock.setStaticResource(endpoint3, 'QDUX_JSONTestFile7');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, multimock);
        QDUX_VVMyAlertsController2 vvMyAlert = new QDUX_VVMyAlertsController2();
        //vvMyAlert.strVVId = '285309';
        vvMyAlert.getMyNotificationAlert();
    }
    
    @isTest static void testUtilErroClass() {
        QDUX_HTTPRestUtilsClass qc = new QDUX_HTTPRestUtilsClass();
        qc.createErrorMessage('TestClassMessage', 'Test Stack Trace', 'Test Info');
        
            
    }

}