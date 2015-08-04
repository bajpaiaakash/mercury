/* Class Name  : ACED_Refresh_eInteractions
* Description  : Extension class on Refresh eInteraction button on delivery actuals page to manually make callout to webtrends or Google analytics and update delivery actual lines
* Created By   : Deloitte Consulting
* Created Date : 
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID          Description 

* ---------------------------------------------------------------------------------------------------------------------------------------

*/
Public with sharing class ACED_Refresh_eInteractions {

    //Initialising the constructor
    public ACED_Refresh_eInteractions(ApexPages.StandardController controller) {

    }

    //Initialising the variables
    ACED_Delivery_Actuals__c oCurrentActual;
    ACED_Integration_Console__c oIntegration;
    Note notes;
    String actualMonth;
    Integer actualYear;
    Integer numberDays;

    //Creating Map for Months and corresponding numbers
    Map < String, string > monthInteger = New Map < String, string > {
        'January' => '01', 'February' => '02', 'March' => '03', 'April' => '04', 'May' => '05', 'June' => '06', 'July' => '07', 'August' => '08', 'September' => '09', 'October' => '10', 'November' => '11', 'December' => '12'
    };

    //Declaring a list of delivery actual lines which are being upserted 
    List < ACED_Delivery_Actual_Line__c > lDeliveryActualLines = new List < ACED_Delivery_Actual_Line__c > ();

    //Method to refresh Delivery Actual lines from Google Analytics and Webtrends
    Public pagereference RefreshData() {

        //Calling parameters method for all queries from integration console and current actual records
        Parameters();

        //Error message if corresponding Program/Non-Program asset has no Google Analytics or webtrends profile ID
        If(oCurrentActual.Delivery__r.StandAlone_Asset__r.Google_Analytics_View_Id__c == NULL && oCurrentActual.Delivery__r.StandAlone_Asset__r.ProfileId__c == NULL && oCurrentActual.Delivery__r.Activity__r.Assets__r.ProfileId__c == NULL && oCurrentActual.Delivery__r.Activity__r.Assets__r.Google_Analytics_View_Id__c == NULL) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ACED_Refresh_eInt_Error_Message));
            Return NULL;
        }
        List < ACED_Delivery_Actual_Line__c > lDeliveryActualLines1 = getMetricsFromWebtrends();
        List < ACED_Delivery_Actual_Line__c > lDeliveryActualLines2 = getMetricsFromGoogleAnalytics();

        //Adding the metrics from Google analytics and webtrends to a list
        If(lDeliveryActualLines1 != NULL && lDeliveryActualLines1.size() > 0) {
            lDeliveryActualLines.addall(lDeliveryActualLines1);
        }
        If(lDeliveryActualLines2 != NULL && lDeliveryActualLines2.size() > 0) {
            lDeliveryActualLines.addall(lDeliveryActualLines2);
        }

        try {
            //Upserting the delivery actual lines 
            Upsert lDeliveryActualLines Delivery_Attribute_Upsert__c;
        } catch (exception e) {

            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected exception occured' + e.getMessage()));
            Return NULL;
        }

        //Returning to the same delivery actual page after refreshing        
        pagereference p = new pagereference('/' + ApexPages.currentPage().getParameters().get('Id'));
        Return p;

    }



    //Method to query all parameters from integration console and current actual record
    Public void Parameters() {
        try {

            //Selecting the Webtrends ProfileID,Google analytics ProfileID and Delivery of the current page Delivery actual 
            oCurrentActual = [SELECT Id, Delivery_Attribute_Upsert__c, Month__c, Delivery__r.Activity__r.Assets__r.ProfileId__c, Delivery__r.Activity__r.Assets__r.Google_Analytics_View_Id__c, Delivery__r.StandAlone_Asset__r.ProfileId__c, Delivery__r.StandAlone_Asset__r.Google_Analytics_View_Id__c, Delivery__r.Activity__r.Program__r.Year__c, Delivery__c, Delivery__r.StandAlone_Asset__r.channel__r.Actual_Attribute__c FROM ACED_Delivery_Actuals__c WHERE Id = : ApexPages.currentPage().getParameters().get('Id')];
system.debug('@@@@@'+oCurrentActual.id);
            //Selecting the Integration console record 
            oIntegration = [Select id, End_Point_For_Data__c, Metrics__c, Dimensions__c, Web_UserName__c, Header_for_JWT__c, Aud__c, Scope__c, Service_account_Email__c, End_Point_Url_For_Token__c, Signing_Algorithm__c, Grant_Type__c, WebTrends_Admin_Email__c, Web_Password__c, WebTrends_Service_URL__c, (SELECT Id, Body FROM Notes Limit 1) from ACED_Integration_Console__c limit 1];

            //Querying for Private Key
            notes = [Select Body from Note where ParentId = : oIntegration.ID AND title = : label.ACED_Private_Key_title Limit 1];

            //Getting the number value of actuals month being refreshed
            If(monthInteger.containsKey(oCurrentActual.Month__c)) {
                actualMonth = monthInteger.get(oCurrentActual.Month__c);
            }
            system.debug('@@@@@'+actualMonth );
                        system.debug('@@@@@'+oCurrentActual.Month__c);



            //Getting the year value of actuals being refreshed
            actualYear = Integer.valueOf(oCurrentActual.Delivery__r.Activity__r.Program__r.Year__c);
                        system.debug('@@@@@'+oCurrentActual.Delivery__r.Activity__r.Program__r.Year__c);

                        system.debug('@@@@@'+actualYear );

            //Getting the number of days in actuals month being refreshed
            numberDays = date.daysInMonth(actualYear, integer.ValueOf(actualMonth));

        } catch (exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected exception occured' + e.getMessage()));
        }
    }

    //Method to get Metrics from Webtrends
    Public list < ACED_Delivery_Actual_Line__c > getMetricsFromWebtrends() {
        try {
            String profileID;

            //Declaring a list of delivery actual lines       
            List < ACED_Delivery_Actual_Line__c > lWebDeliveryActualLines = new List < ACED_Delivery_Actual_Line__c > ();

            //Checking if the assets belongs to webtrends
            If(oCurrentActual.Delivery__r.StandAlone_Asset__r.ProfileId__c != NULL || oCurrentActual.Delivery__r.Activity__r.Assets__r.ProfileId__c != NULL) {

                //Adding Profile ID present in Stand Alone/Non Program Asset of the delivery
                If(oCurrentActual.Delivery__r.StandAlone_Asset__r.ProfileId__c != NULL) {
                    profileID = '/' + oCurrentActual.Delivery__r.StandAlone_Asset__r.ProfileId__c + '/KeyMetrics';
                }

                //Adding Profile ID present in Program Asset of the delivery
                If(oCurrentActual.Delivery__r.Activity__r.Assets__r.ProfileId__c != NULL) {
                    profileID = '/' + oCurrentActual.Delivery__r.Activity__r.Assets__r.ProfileId__c + '/KeyMetrics';
                }

                //Initialising the start date and end date as 1st and last days of actual month 
                string start_period = 'start_period=' + actualYear + 'm' + actualMonth + 'd1';
                string end_period = 'end_period=' + actualYear + 'm' + actualMonth + 'd' + numberDays;

                //Initialising HTTP request
                HttpRequest req = new HttpRequest();
                req.setTimeout(120000);
                req.setEndpoint(oIntegration.WebTrends_Service_URL__c.replace('/KeyMetrics', profileID) + '?' + start_period + '&' + end_period);
                req.setMethod('GET');

                String username = oIntegration.Web_UserName__c;
                String password = oIntegration.Web_Password__c;
                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                req.setHeader('Authorization', authorizationHeader);

                Http http = new Http();
                HTTPResponse res = http.send(req);

                //Declaring a map which holds the value of measure names and its corresponding  values
                Map < String, String > mMetricsContentHolder = new Map < String, String > ();

                string s = res.getBody();

                If(s != NULL) {
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

                    If(s.contains('\"measures\":{')) {

                        //Taking the string which contains all the measure names and value
                        String MetricValues = '{' + s.substringbetween('\"measures\":{', '}') + '}';

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
                        sModifiedResponse = s.replace(MetricValues, '[' + sUpdateMetricFormat.removeend(',') + ']');
                        //Getting the profile ID and storing it in a string
                        String WebprofileID = sModifiedResponse.substringbetween('\"profileID\":\"', '"');

                        sModifiedResponse = sModifiedResponse.replaceAll('\"' + WebprofileID+ '\":', '\"Test\":');
                        
                        list < ACED_WebtrendClass > lResponse = ACED_WebtrendClass.parse('['+sModifiedResponse+']');

                        list < ACED_WebtrendClass.data > finaldata = lResponse[0].data;
                        

                        //Logic to add Metrics as Delivery actual lines
                        Map < String, String > mMetricsMap = new Map < String, String > ();
                        If(finaldata[0].subrows.test.measures.size() > 0) {
                            for (ACED_WebtrendClass.Measures_Z Metrics: finaldata[0].subrows.test.measures) {
                                mMetricsMap.put(Metrics.metricName, Metrics.Value);
                            }
                        }
                        if (mMetricsMap.size() > 0) {
                            //Looping through each measure and adding them as delivery actual line for the current delivery actual
                            for (String valueKey: mMetricsMap.keySet()) {
                                ACED_Delivery_Actual_Line__c oDeliveryActualLine = new ACED_Delivery_Actual_Line__c();
                                oDeliveryActualLine.Attribute__c = valueKey;
                                oDeliveryActualLine.value__c = Decimal.Valueof(mMetricsMap.get(valueKey));
                                oDeliveryActualLine.Delivery_Attribute_Upsert__c = oCurrentActual.Delivery__c + '-' + oCurrentActual.Month__c + '-' + valueKey;
                                oDeliveryActualLine.Delivery_Actuals__c = oCurrentActual.id;
                                lWebDeliveryActualLines.add(oDeliveryActualLine);
                            }
                        }
                    }
                    }
                }

                If(lWebDeliveryActualLines.size() > 0) {
                    Return lWebDeliveryActualLines;
                } else {
                    Return NULL;
                }
            } catch (exception e) {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected exception occured' + e.getMessage()));
                Return NULL;
            }
        }


        //Method to get Access token from Google analytics
        Public string getGoogleAccessToken() {
            try {
                //Creating the header string and encoding it to Base64
                String Header = oIntegration.Header_for_JWT__c;
                String Header_Encode = EncodingUtil.base64Encode(blob.valueof(Header));

                //setting the assertion expiration time and Issuing time
                long currentTime = datetime.now().getTime() / 1000;
                long expiryTime = datetime.now().addHours(1).getTime() / 1000;

                //Creating the Claimset string and encoding it to Base64
                String claim_set = '{"iss":"' + oIntegration.Service_account_Email__c + '"';
                claim_set += ',"scope":"' + oIntegration.Scope__c + '"';
                claim_set += ',"aud":"' + oIntegration.Aud__c + '"';
                claim_set += ',"exp":' + expiryTime;
                claim_set += ',"iat":' + currentTime + '}';
                String claim_set_Encode = EncodingUtil.base64Encode(blob.valueof(claim_set));

                //Creating the input for Signing i.e HeaderEncode.CalimSetEncode
                String Singature_Encode = Header_Encode + '.' + claim_set_Encode;

                //Download JSON format Key from google service account and take the Private key 
                String PrefixRemovedKey = notes.body.remove(label.ACED_PrivateKey_Prefix);
                String SuffixRemovedKey = PrefixRemovedKey.remove(label.ACED_PrivateKey_Suffix);

                String Key = SuffixRemovedKey.unescapeUnicode();

                //Decoding the Private Key to bytes
                blob privateKey = EncodingUtil.base64Decode(key);

                //Replacing '=' Value with blank value
                Singature_Encode = Singature_Encode.replaceAll('=', '');

                //URL encoding the sign string before signing
                String Singature_Encode_Url = EncodingUtil.urlEncode(Singature_Encode, 'UTF-8');

                blob Signature_b = blob.valueof(Singature_Encode_Url);

                String Sinatute_blob = EncodingUtil.base64Encode(Crypto.sign(oIntegration.Signing_Algorithm__c, Signature_b, privateKey));
                Sinatute_blob = Sinatute_blob.replaceAll('\\+', '-');
                Sinatute_blob = Sinatute_blob.replaceAll('/', '_');
                Sinatute_blob = Sinatute_blob.replaceAll('=', '');

                //Creating the JWT by appending Signature encode and Signature      
                String JWT = Singature_Encode + '.' + Sinatute_blob;


                //Making the HTTP request         
                http h = new Http();
                Httprequest req = new HttpRequest();
                req.setEndpoint(oIntegration.End_Point_Url_For_Token__c);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                string bodyrequest = '';
                bodyrequest = 'grant_type=' + EncodingUtil.urlEncode(oIntegration.Grant_Type__c, 'UTF-8');
                bodyrequest += '&assertion=' + EncodingUtil.urlEncode(JWT, 'UTF-8');
                req.setBody(bodyrequest);
                HttpResponse res = h.send(req);

                //Getting token from is a JSON Response string
                ACED_GoogleAnalyticsWrapper.TokenClass token = (ACED_GoogleAnalyticsWrapper.TokenClass) JSON.deserialize(res.getBody(), ACED_GoogleAnalyticsWrapper.TokenClass.class);

                String accesstoken = token.access_token;
                Return accesstoken;

            } catch (exception e) {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected exception occured' + e.getMessage()));
                Return NULL;
            }
        }

        //Method to get Metrics from Google analytics
        Public list < ACED_Delivery_Actual_Line__c > getMetricsFromGoogleAnalytics() {
            try {

                //Initialising the start date and end date as 1st and last days of actual month 
                string startdate = 'start-date=' + actualYear + '-' + actualMonth + '-01';
                string enddate = 'end-date=' + actualYear + '-' + actualMonth + '-' + numberDays;

                //Declaring a list of delivery actual lines       
                List < ACED_Delivery_Actual_Line__c > lGoogleDeliveryActualLines = new List < ACED_Delivery_Actual_Line__c > ();

                //Logic for Callout to Google analytics 
                If(oCurrentActual.Delivery__r.StandAlone_Asset__r.Google_Analytics_View_Id__c != NULL || oCurrentActual.Delivery__r.Activity__r.Assets__r.Google_Analytics_View_Id__c != NULL) {

                    string GoogleID;
                    String url;

                    //Adding Google Profile ID if it is present in Stand Alone/Non Program Asset of the delivery
                    If(oCurrentActual.Delivery__r.StandAlone_Asset__r.Google_Analytics_View_Id__c != NULL) {
                        GoogleID = oCurrentActual.Delivery__r.StandAlone_Asset__r.Google_Analytics_View_Id__c;
                    }

                    //Adding Google Profile ID if it is present in Program Asset of the delivery
                    If(oCurrentActual.Delivery__r.Activity__r.Assets__r.Google_Analytics_View_Id__c != NULL) {
                        GoogleID = oCurrentActual.Delivery__r.Activity__r.Assets__r.Google_Analytics_View_Id__c;
                    }

                    //Adding Dimensions to end point URL based on their availability on Integration console record
                    If(oIntegration.Dimensions__c != NULL) {
                        url = oIntegration.End_Point_For_Data__c + GoogleID + '&' + startdate + '&' + enddate + '&metrics=' + oIntegration.Metrics__c + '&dimensions=' + oIntegration.Dimensions__c + '&access_token=' + getGoogleAccessToken();
                    } else {
                        url = oIntegration.End_Point_For_Data__c + GoogleID + '&' + startdate + '&' + enddate + '&metrics=' + oIntegration.Metrics__c + '&access_token=' + getGoogleAccessToken();
                    }

                    //callout to Google Analytics Api
                    Http callGoogle = new Http();
                    //String url = oIntegration.End_Point_For_Data__c + oCurrentActual.Delivery__r.StandAlone_Asset__r.Google_Analytics_View_Id__c + '&' + startdate + '&' + enddate + '&metrics=' + oIntegration.Metrics__c + '&dimensions=' + oIntegration.Dimensions__c + '&access_token=' + accesstoken;
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(url);
                    request.setMethod('GET');
                    HttpResponse resp = callGoogle.send(request);


                    //Logic to modify the response recieved to couple Metric name and its value because unlike Google Metric name and its value are present in different wrapper classes in the JSON recieved
                    string sTotalResponse = resp.getBody().replaceall('ga:', 'ga');

                    string sMetricContentInResponse = sTotalResponse.substringbetween('\"totalsForAllResults\":', '}') + '}';

                    Map < String, String > mMetricsContentHolder = new Map < String, String > ();

                    for (string st: sMetricContentInResponse.remove('{').remove('}').remove('\"').trim().Split(',')) {
                        string[] stg = st.split(':');
                        mMetricsContentHolder.put(stg[0].trim(), stg[1].trim());
                    }
                    string sUpdateMetricFormat = '';

                    for (string str: mMetricsContentHolder.keyset()) {
                        sUpdateMetricFormat += '{\"metricName\": \"' + str + '\",' + '\"value\":\"' + mMetricsContentHolder.get(str) + '\"},';
                    }
                    string sModifiedResponse = sTotalResponse.replace(sMetricContentInResponse, '[' + sUpdateMetricFormat.removeend(',') + ']');

                    //Logic to add Metrics as Delivery actual lines
                    ACED_GoogleAnalyticsWrapper lResponse = ACED_GoogleAnalyticsWrapper.parse(sModifiedResponse);
                    Map < String, String > mMetricsMap = new Map < String, String > ();
                    for (ACED_GoogleAnalyticsWrapper.TotalsForAllResults Metrics: lResponse.totalsForAllResults) {
                        mMetricsMap.put(Metrics.metricName, Metrics.Value);
                    }

                    if (lResponse.ProfileInfo.profileID != null) {
                        //Looping through each result in total results and adding them as delivery actual line for the current delivery actual
                        for (ACED_GoogleAnalyticsWrapper.ColumnHeaders ch: lResponse.columnHeaders) {
                            If(ch.columnType == 'METRIC') {
                                ACED_Delivery_Actual_Line__c oDeliveryActualLine = new ACED_Delivery_Actual_Line__c();
                                oDeliveryActualLine.Attribute__c = ch.name.replace('ga', 'GA-');
                                oDeliveryActualLine.value__c = Decimal.valueof(mMetricsMap.get(ch.name));
                                oDeliveryActualLine.Delivery_Attribute_Upsert__c = oCurrentActual.Delivery__c + '-' + oCurrentActual.Month__c + '-' + ch.name.replace('ga', 'GA-');
                                oDeliveryActualLine.Delivery_Actuals__c = oCurrentActual.id;
                                lGoogleDeliveryActualLines.add(oDeliveryActualLine);
                            }
                        }
                    }
                }
                If(lGoogleDeliveryActualLines.size() > 0) {
                    Return lGoogleDeliveryActualLines;
                } else {
                    Return NULL;
                }
            } catch (exception e) {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected exception occured' + e.getMessage()));
                Return NULL;
            }
        }



    }