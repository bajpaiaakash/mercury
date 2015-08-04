/* Class Name  : ACED_WebTrendsScheduler
* Description  : Schedulable class which makes callout to Webtrends dialy and updated delivery actual lines
* Created By   : Deloitte Consulting
* Created Date : 
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID          Description 

* ---------------------------------------------------------------------------------------------------------------------------------------

*/
Public class ACED_WebTrendsScheduler implements Schedulable {

    @future(callout = true)
    Public static void InvokeWebTrends() {

        string SuccessPlainTextBody = '';
        string SuccessHtmlBody = '';
        string ErrorHtmlBody = '';
        string ErrorPlainTextBody = '';

        //Initialising the integartion console record
        ACED_Integration_Console__c oIntegration;

        //Initialising the statrt and end dates of the period for which the measures are fetched from webtrends
        string start_period = 'start_period=' + system.today().year() + 'm' + system.today().month() + 'd' + system.today().toStartOfMonth().day();
        string end_period = 'end_period=' + system.today().year() + 'm' + system.today().month() + 'd' + system.today().day();
        
        Integer thisMonth = system.today().month();


        //Declaring a map which holds the value of profile ID in JSON wrapper and its corresponding list of measures
        Map < String, List < ACED_WebtrendClass.Measures_Z >> mResponseMappingWithProfileId = new Map < String, List < ACED_WebtrendClass.Measures_Z >> ();

        //Declaring a list which holds list of delivery actuals to be upserted
        List < ACED_Delivery_Actuals__c > lDeliveryActuals = new List < ACED_Delivery_Actuals__c > ();

        //Declaring a list which holds list of delivery actual lines to be upserted
        List < ACED_Delivery_Actual_Line__c > lDeliveryActualLines = new List < ACED_Delivery_Actual_Line__c > ();

        try {
            //Querying the inegration console record for variables
            oIntegration = [Select id, Web_UserName__c, WebTrends_Admin_Email__c, Web_Password__c, WebTrends_Service_URL__c from ACED_Integration_Console__c limit 1];

            //Initialising the HTTP request
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000);
            req.setEndpoint(oIntegration.WebTrends_Service_URL__c + '?' + start_period + '&' + end_period);
            req.setMethod('GET');

            String username = oIntegration.Web_UserName__c;
            String password = oIntegration.Web_Password__c;
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            HTTPResponse res = http.send(req);

            //Adding the response body into string
            string s = res.getBody();
            System.Debug('@@@@@@@@@@@@'+s);

            //Declaring a map which holds the value of measure name and its corresponding value           
            Map < String, String > mMetricsContentHolder = new Map < String, String > ();

            //The final string after doing all the string operations below
            String Modified = '';
            
            If(s!=NULL){            
            //Removing leading [ as the response from webtrends is a list 
            s = s.removestart('[');

            //Removing trainling ] as the response from webtrends is a list 
            s = s.removeend(']');

            //Removing leading and trailing white spaces 
            s = s.trim();

            //Removing all white spaces from the response
            s = s.replaceAll('\\s+', '');

            //Removing all '"measures":{}' strings because if this string is present then the JSON wrapper will not be generic
            s = s.replaceAll('\"measures\":\\{\\},', '');

            //Removing all '"attributes":{}' strings because if this string is present then the JSON wrapper will not be generic
            s = s.replaceAll('\"attributes\":\\{\\},', '');

            //Removing all '"subrows":null' strings because if this string is present then the JSON wrapper will not be generic
            s = s.replaceAll(',\"SubRows\":null', '');

            //Splitting the string for each profileID
            for (string st: s.Split('\\{\"definition\":')) {

                if (st != NULL && st.trim() != '') {

                    String oneProfileResponse = '{\"definition\":' + st;

                    If(oneProfileResponse.contains('\"measures\":{')) {

                        //Taking the string which contains all the measure names and value
                        String MetricValues = '{' + oneProfileResponse.substringbetween('\"measures\":{', '}') + '}';

                        //Adding the measure name and values as string to a map       
                        for (string str: MetricValues.remove('{').remove('}').remove('\"').trim().Split(',')) {
                            string[] stg = str.split(':');
                            mMetricsContentHolder.put(stg[0].trim(), stg[1].trim());
                        }

                        string sUpdateMetricFormat = '';

                        for (string str: mMetricsContentHolder.keyset()) {
                            sUpdateMetricFormat += '{\"metricName\": \"' + str + '\",' + '\"value\":\"' + mMetricsContentHolder.get(str) + '\"},';
                        }

                        string sModifiedResponse;
                        //Replacing the original string with metric name and value string map
                        sModifiedResponse = oneProfileResponse.replace(MetricValues, '[' + sUpdateMetricFormat.removeend(',') + ']');

                        //Adding the modified profile response string to final string
                        If(sModifiedResponse != NULL) {
                            Modified += sModifiedResponse;
                        }
                    }
                }
            }
            }
            System.Debug('!!!!!!!!!!!!!!!'+Modified);
            String finalString;

            If(Modified != NULL) {

                finalString = '[' + Modified.removeend(',') + ']';
                System.Debug('**********'+finalString);

                List < String > ProfielIDs = New List < String > ();

                //Adding all profile IDs to a list obtained from JSON
                JSONParser parser = JSON.createParser(finalString);

                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                        (parser.getText() == 'profileID')) {
                        parser.nextToken();
                        ProfielIDs.add(parser.getText());
                    }
                }

                //Replacing all  profileID  wrapper class names  with 'Test'    
                for (string l: ProfielIDs) {
                    finalString = finalString.replaceAll('\"' + l + '\":', '\"Test\":');
                }
            }

            list < ACED_WebtrendClass > lresponse;
            if(finalString!=NULL){
             lresponse = ACED_WebtrendClass.parse(finalString);
             }
            
            If(lResponse.size()>0){
            //Mapping the profile ID of the response to its measures
            for (ACED_WebtrendClass resp: lResponse) {
                list < ACED_WebtrendClass.data > finaldata = resp.data;
                if (resp.Definition.profileID != null && finaldata[0].subrows.test.measures.size() > 0) {
                    mResponseMappingWithProfileId.put(resp.Definition.profileID, finaldata[0].SubRows.Test.measures);
                }
            }
            }
            Map < String, list < ACED_Deliveries__c > > mProgramAssetMappingWithItsDeliveries = new Map < String, list < ACED_Deliveries__c > > ();
            
            List<ACED_Deliveries__c> lDelivery = [SELECT ID,Start_Date__c,End_Date__c, Actual_Value__c,LASTMODIFIEDDATE,Activity__r.Program__r.Year__c, 
                                           StandAlone_Asset__c, StandAlone_Asset__r.ProfileId__c, StandAlone_Asset__r.channel__r.Actual_Attribute__c, Activity__r.Assets__r.ProfileId__c, Activity__r.Assets__r.channel__r.Actual_Attribute__c 
                                           FROM ACED_Deliveries__c 
                                           WHERE (Activity__r.Assets__r.ProfileId__c in : mResponseMappingWithProfileId.keyset() OR StandAlone_Asset__r.ProfileId__c in : mResponseMappingWithProfileId.keyset())
                                           AND(Activity__r.Program__r.Year__c = : String.ValueOf(System.Now().Year()))
                                           AND(CALENDAR_MONTH(Start_Date__c)<= :thisMonth) 
                                           AND(CALENDAR_MONTH(End_Date__c)>=:thisMonth) order by LastModifiedDate DESC];
            
            Set<Id> sDuplicateCheckDALAsset = new Set<Id>();
            Set<Id> sDelfinal = new Set<Id>();
            
            //Deliveries having delivery actuals
            List<ACED_Delivery_Actuals__c> lDelAct = [Select id,Asset_ID_TF__c,LastModifiedDate,Delivery__r.id from ACED_Delivery_Actuals__c where Delivery__r.id IN :lDelivery order by LastModifiedDate DESC];
            for(ACED_Delivery_Actuals__c oDAL:lDelAct){          
               if(!sDuplicateCheckDALAsset.contains(oDAL.Asset_ID_TF__c)){
                  sDuplicateCheckDALAsset.add(oDAL.Asset_ID_TF__c);  
                  sDelfinal.add(oDAL.Delivery__r.id);
                }
            }
            
            system.debug('##sDuplicateCheckDALAsset1'+sDuplicateCheckDALAsset);
            system.debug('##sDelfinal1'+sDelfinal);
            
            //Deliveries not having Delivery Actuals
            //adding all program deliveries
            for(ACED_Deliveries__c oDeli:lDelivery){
              if(oDeli.Actual_Value__c == 0 && !sDelfinal.contains(oDeli.id) && oDeli.StandAlone_Asset__c == NULL && !sDuplicateCheckDALAsset.contains(oDeli.Activity__r.Assets__r.id)){
                sDelfinal.add(oDeli.id);      
                sDuplicateCheckDALAsset.add(oDeli.Activity__r.Assets__r.id);          
              }
            }
            
            system.debug('##sDuplicateCheckDALAsset2'+sDuplicateCheckDALAsset);
            system.debug('##sDelfinal2'+sDelfinal);
            
            //adding all non program deliveries
            for(ACED_Deliveries__c oDeliv:lDelivery){
              if(oDeliv.Actual_Value__c == 0 && !sDelfinal.contains(oDeliv.id) && oDeliv.StandAlone_Asset__c != NULL && !sDuplicateCheckDALAsset.contains(oDeliv.Activity__r.Assets__r.id)){
                sDelfinal.add(oDeliv.id);      
                sDuplicateCheckDALAsset.add(oDeliv.Activity__r.Assets__r.id);          
              }
            }
            
            system.debug('##sDuplicateCheckDALAsset3'+sDuplicateCheckDALAsset);
            system.debug('##sDelfinal3'+sDelfinal);

            //Adding all deliveries which has Webtrends profile id on their corresponding asset to a map
            for (ACED_Deliveries__c oDel: lDelivery ) {
              if(sDelfinal.contains(oDel.id)){
                System.Debug('&&&&&&&&'+oDel.ID);

                If(oDel.StandAlone_Asset__c == NULL) {
                    If(mProgramAssetMappingWithItsDeliveries.containsKey(oDel.Activity__r.Assets__r.ProfileId__c)) {
                        mProgramAssetMappingWithItsDeliveries.get(oDel.Activity__r.Assets__r.ProfileId__c).add(oDel);
                    } else {
                        mProgramAssetMappingWithItsDeliveries.put(oDel.Activity__r.Assets__r.ProfileId__c, new list < ACED_Deliveries__c > {
                            oDel
                        });
                    }
                }
                Else {
                    If(mProgramAssetMappingWithItsDeliveries.containsKey(oDel.StandAlone_Asset__r.ProfileId__c)) {
                        mProgramAssetMappingWithItsDeliveries.get(oDel.StandAlone_Asset__r.ProfileId__c).add(oDel);
                    } else {
                        mProgramAssetMappingWithItsDeliveries.put(oDel.StandAlone_Asset__r.ProfileId__c, new list < ACED_Deliveries__c > {
                            oDel
                        });
                    }
                }
                
               }  
                
            }
            
            If(lResponse.size()>0){
            //Looping through measures of each profile ID and adding them as delivery actual lines
            for (ACED_WebtrendClass resp: lResponse) {
                list < ACED_WebtrendClass.data > ofinaldata = resp.data;
                if (resp.Definition.profileID != null && mProgramAssetMappingWithItsDeliveries.containskey(resp.Definition.profileID) && ofinaldata[0].SubRows.Test.measures.size() > 0) {

                    Map < String, String > mMetricsMap = new Map < String, String > ();
                    for (ACED_WebtrendClass.Measures_Z Metrics: ofinaldata[0].SubRows.Test.measures) {
                        mMetricsMap.put(Metrics.metricName, Metrics.Value);
                    }

                    list < ACED_Deliveries__c > lDeliveries = mProgramAssetMappingWithItsDeliveries.get(resp.Definition.profileID);

                    for (ACED_Deliveries__c oDel: lDeliveries) {
                        String sAttribute;
                        If(oDel.StandAlone_Asset__c != NULL) {
                            sAttribute = oDel.ID + '-' + System.now().format('MMMMM') + '-' + oDel.StandAlone_Asset__r.channel__r.Actual_Attribute__c;
                        } else {
                            sAttribute = oDel.ID + '-' + System.now().format('MMMMM') + '-' + oDel.Activity__r.Assets__r.channel__r.Actual_Attribute__c;
                        }
                        ACED_Delivery_Actuals__c oDeliveryActuals = new ACED_Delivery_Actuals__c();
                        oDeliveryActuals.Delivery__c = oDel.ID;
                        oDeliveryActuals.Delivery_Attribute_Upsert__c = sAttribute;
                        oDeliveryActuals.month__c = System.now().format('MMMMM');
                        lDeliveryActuals.add(oDeliveryActuals);

                        for (String valueKey: mMetricsMap.keySet()) {
                            ACED_Delivery_Actual_Line__c oDeliveryActual = new ACED_Delivery_Actual_Line__c();
                            oDeliveryActual.Attribute__c = valueKey;
                            If(mMetricsMap.get(valueKey)!=NULL&&mMetricsMap.get(valueKey)!='NULL'){
                            oDeliveryActual.value__c = Decimal.Valueof(mMetricsMap.get(valueKey));
                            }
                            oDeliveryActual.Delivery_Attribute_Upsert__c = oDel.ID + '-' + System.now().format('MMMMM') + '-' + valueKey;
                            ACED_Delivery_Actuals__c oAssetActuals = new ACED_Delivery_Actuals__c();
                            oAssetActuals.Delivery_Attribute_Upsert__c = sAttribute;
                            oDeliveryActual.Delivery_Actuals__r = oAssetActuals;
                            lDeliveryActualLines.add(oDeliveryActual);
                        }
                    }
                }
            }
            }
            System.Debug('((((((((((('+lDeliveryActualLines);
            System.Debug('&&&&&&&&'+lDeliveryActuals);
            System.Debug('&&&&&&&&'+lDeliveryActuals.size());
            System.Debug('((((((((((('+lDeliveryActualLines.size());


            //DML operation to capture partial failures 
            Database.UpsertResult[] lDatabaseDeliveryActualsResult = database.upsert(lDeliveryActuals, ACED_Delivery_Actuals__c.Fields.Delivery_Attribute_Upsert__c, false);
            //DML operation to capture partial failures
            Database.UpsertResult[] lDatabaseDeliveryActualLineResult = database.upsert(lDeliveryActualLines, ACED_Delivery_Actual_Line__c.Fields.Delivery_Attribute_Upsert__c, false);

            for (Database.UpsertResult sr: lDatabaseDeliveryActualLineResult) {
                if (sr.isSuccess()) {
                    SuccessPlainTextBody = SuccessPlainTextBody + 'Delivery Actuals with ID ->' + sr.getId() + '----Successfully Updated' + '\n';
                    SuccessHtmlBody = SuccessHtmlBody + 'Delivery Actuals with ID ->' + sr.getId() + '----Successfully Updated' + '</br></br>';
                } else {
                    ErrorPlainTextBody = ErrorPlainTextBody + 'Error in Updating Delivery Actual----' + sr.getErrors()[0].getMessage() + '\n';
                    ErrorHtmlBody = ErrorHtmlBody + 'Error in Updating Delivery Actual----' + sr.getErrors()[0].getMessage() + '</br></br>';
                }
            }

            //Email logic to mail webtrends admil all the succeses and failures
            string PlainTextBody = Label.ACED_Webtrends_EmailContent + '\n' + ErrorPlainTextBody + '\n' + SuccessPlainTextBody + '\n';
            string HtmlBody = Label.ACED_Webtrends_EmailContent + '</br></br>' + ErrorHtmlBody + '</br></br>' + SuccessHtmlBody + '\n';
            oIntegration.Web_Last_Run_Date__c = system.now();
            Update oIntegration;
            String[] toAddresses = oIntegration.WebTrends_Admin_Email__c.normalizeSpace().split(';');
            String Subject = Label.ACED_Webtrends_SubjectLine;

            //Sending email to Admin regarding success and failures of insertinf delivery actual lines
            emailAdmin(toAddresses, Subject, PlainTextBody, HtmlBody);

        } catch (exception e) {

            //Logic to mail admin incase above steps fail like expired/wrong password, wrong end point , wrong username etc etc on integration console
            string PlainTextBody = Label.ACED_Webtrends_intConsole_errors + '\n' + e.getmessage() + '\n';
            string HtmlBody = Label.ACED_Webtrends_intConsole_errors + '</br></br>' + e.getmessage() + '</br></br>';
            oIntegration.Web_Last_Run_Date__c = system.now();
            Update oIntegration;
            String[] toAddresses = oIntegration.WebTrends_Admin_Email__c.normalizeSpace().split(';');
            String Subject = Label.ACED_Webtrends_Batch_Job_Issues;

            //Sending email to Admin regarding batch Job failure
            emailAdmin(toAddresses, Subject, PlainTextBody, HtmlBody);
        }
    }

    Public void execute(SchedulableContext SC) {
        InvokeWebTrends();
    }

    //This method will mail the email Admin the issue with callout or success and failures of callout
    Public static void emailAdmin(string[] toAddresses, string Subject, string PlainTextBody, string HtmlBody) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(Subject);
        mail.saveAsActivity = false;
        mail.setPlainTextBody(PlainTextBody);
        mail.setHtmlBody(HtmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
    }

}