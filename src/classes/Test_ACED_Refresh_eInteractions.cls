/* Class Name  : Test_ACED_Refresh_eInteractions 
* Description  : Test Class for ACED_Refresh_eInteractions 
* Created By   : Deloitte Consulting
* Created Date :
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/
@isTest(seealldata = false)

Public class Test_ACED_Refresh_eInteractions {

    //Test method for callout to Webtrends
    static testMethod void webTrendsTest() {
        User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
        System.runAs(runAsUser) {

            //Inserting the Integration console for Username and pswd of webtrends
            ACED_Integration_Console__c oIntConsole = new ACED_Integration_Console__c(Metrics__c = 'ga:newUsers,ga:users,ga:sessions', Web_UserName__c = 'tets@tet.com', RightNow_Admin_Email__c = 'uet@yryr.com', WebTrends_Admin_Email__c = '777@77.com', Web_Password__c = '8888', WebTrends_Service_URL__c = 'yryryr@uerur.com');
            oIntConsole.RN_UserName__c = 'tetete';
            oIntConsole.RN_Password__c = '12334';
            insert oIntConsole;
            //Inserting the notes for above intconsole for storing privatekey
            Note notes = new Note(title = 'Google Analytics Private Key', body = '-----BEGIN PRIVATE KEY-----\nMIICcwIBAD3d\u003d\n-----END PRIVATE KEY-----\n', parentID = oIntConsole.ID);
            insert notes;

            //Inserting an Asset record with Profile ID
            ACED_Asset__c ast = ACED_DataFactory.createAssets(1)[0];
            ast.profileid__c = '12345678';
            Update Ast;

            //Inserting a delivery actual and associating corresponding delivery with above asset
            list < ACED_Delivery_Actuals__c > delAct = ACED_DataFactory.createDeliveryActuals(1);
            delact[0].month__c = 'March';
            update delact;
            ACED_Delivery_Actuals__c delActual = [SELECT id, Delivery__c from ACED_Delivery_Actuals__c Where id = : delAct[0].ID];
            ACED_Deliveries__c del = [SELECT id, StandAlone_Asset__c from ACED_Deliveries__c Where id = : delActual.Delivery__c];
            del.StandAlone_Asset__c = ast.id;
            Update del;

            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('ACED_RepsonseForSingleWebtrendsID');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock);
            ApexPages.StandardController sc = new ApexPages.StandardController(delActual);
            //  Test.setCurrentPage(Page.ACED_Refresh_eInteractions);
            ACED_Refresh_eInteractions refresh = new ACED_Refresh_eInteractions(sc);

            Test.setCurrentPageReference(new PageReference('Page.ACED_Refresh_eInteractions'));

            System.currentPageReference().getParameters().put('id', delActual.id);

            PageReference pRef = refresh.RefreshData();
            
            system.assertEquals(System.currentPageReference().getParameters().get('id'),delActual.id );

            Test.stopTest();
            delete oIntConsole;
        }
    }

    //Test method for callout to Google Analytics
    static testMethod void googleAnalyticsTest() {
        User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
        System.runAs(runAsUser) {

            //Querying the Integration console for Username and pswd of webtrends
            ACED_Integration_Console__c oIntConsole = new ACED_Integration_Console__c(Dimensions__c = 'ga:sessionCount,ga:userType', Metrics__c = 'ga:newUsers,ga:users,ga:sessions', End_Point_Url_For_Token__c = 'https://www.googleapis.com/oauth2/v3/token', Aud__c = 'https://www.googleapis.com/oauth2/v3/token', Grant_Type__c = 'urn:ietf:params:oauth:grant-type:jwt-bearer', End_Point_For_Data__c = 'https://www.googleapis.com/analytics/v3/data/ga?ids=ga:', Signing_Algorithm__c = 'RSA-SHA256', Service_account_Email__c = '622476851163-p2luu2l8qn962cnp2ur268eniqu3jokt@developer.gserviceaccount.com', Header_for_JWT__c = '{"alg":"RS256","typ":"JWT"}', Scope__c = 'https://www.googleapis.com/auth/analytics.readonly');
            insert oIntConsole;

            //Inserting the notes for above intconsole for storing privatekey
            Note notes = new Note(title = 'Google Analytics Private Key', body = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAM5HGuvhQEYBCuvDoYxlkU6bIaBIokCTIpkpVo6JSQt8e8p8yjzdGqI51DxYdKIPuHxG/S8wAUdf7gOHNQR3w+BcSzpu9Jr6bzTQSn/XLVVi4oc7LwlGsL0J0yJT8by4labAmf+qPYESboTKzMhMENU4A5TbjLZOPZ0D4nu9cZu9AgMBAAECgYAUkNZISi7kS9pQ4zJKEx5HngPePR+gHItIheyRTXKw6HpXF9X593leTzGvyonmVnboPROlDr4x5YiPZX2Nsnsex4IawQC2VoCVNI+2sqlisfNQSOeXjlJABnuWJNCW1afX29NNrkZ2rTSzzvZlaryCf9sp+eT9aMNLruq6kYCmwQJBAOd10jkRHaEWKKeLMO5fzLRiAKn7IYfYvk+ZfC/mpTFNmjrLq/5Uh4lKiTqiYM6q6T8IWFvMimwl+PsScazmS2kCQQDkJcsijgaCNyEdWWRJaqtrvVLDW4l7imfbYut5HOSp48SaDjWFCcUgUfCbIMBOEmuvGgnCUXoYcjTpnAdkLyc1AkEA3j7zrHgSyypLvxSX10uFc27m1FCe0aH8mtH1vMjqtXyeKvaGH59qxRkcy4A/FDJn5G5O6VZtU4ril7IOFMbMgQJASMOdBApUHRfEIf4utBOnVJdvXAtHz/UWpqvn+hqy+1Q/kfrSKvowutwnZvKNItlRKumdDzK5RC64nYE8AkHfuQJBAMI8VjZteXDvHuNvn989kNeFmlGPwdogKgfNelRDslKCikdAARTTu76HtPyHWl5inDo54I+O+e8uOtg7zpmf76k=', parentID = oIntConsole.ID);
            insert notes;

            //Inserting an Asset record with Profile ID
            ACED_Asset__c ast = ACED_DataFactory.createAssets(1)[0];
            ast.Google_Analytics_View_Id__c = '12345678';
            Update Ast;

            //Inserting a delivery actual and associating corresponding delivery with above asset
            list < ACED_Delivery_Actuals__c > delAct = ACED_DataFactory.createDeliveryActuals(1);
            delact[0].month__c = 'March';
            update delact;
            ACED_Delivery_Actuals__c delActual = [SELECT id, Delivery__c from ACED_Delivery_Actuals__c Where id = : delAct[0].ID];
            ACED_Deliveries__c del = [SELECT id, StandAlone_Asset__c from ACED_Deliveries__c Where id = : delActual.Delivery__c];
            del.StandAlone_Asset__c = ast.id;
            Update del;

            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('ACED_GoogleAnalyticsResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock);

            ApexPages.StandardController sc = new ApexPages.StandardController(delActual);
            ACED_Refresh_eInteractions refresh = New ACED_Refresh_eInteractions(sc);

            Test.setCurrentPageReference(new PageReference('Page.ACED_Refresh_eInteractions'));

            System.currentPageReference().getParameters().put('id', delActual.id);            

            PageReference pRef = refresh.RefreshData();
            
            system.assertEquals(System.currentPageReference().getParameters().get('id'),delActual.id );

            Test.stopTest();

        }
    }
}