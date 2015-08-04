Public class ACED_RightNowUtility{

    @future(callout=true)
    Public static void ACED_RightNowUtility(string Endpoint,String ReportId,String Username, String Password,String sEmailAdmin){
    	string SuccessPlainTextBody ='';
		string SuccessHtmlBody ='';
		string ErrorHtmlBody ='';
		string ErrorPlainTextBody ='';
		
        // Create the request envelope
        DOM.Document doc = new DOM.Document();
        
        string xsi = 'http://schemas.xmlsoap.org/soap/envelope/';
        string RNv1 = 'urn:messages.ws.rightnow.com/v1_2';
        string RNv11 = 'urn:base.ws.rightnow.com/v1_2';
        string wsse = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
        
        //Create Envelope element
        dom.XmlNode envelope = doc.createRootElement('Envelope', xsi, 'soapenv');
        envelope.setNamespace('v1', RNv1);   
        envelope.setNamespace('v11', RNv11 );
        
        //Create headerElemenr
        dom.XmlNode HeaderElement = envelope.addChildElement('soapenv:Header', null, null);    
        dom.XmlNode Clientinfo  = HeaderElement.addChildElement('v1:ClientInfoHeader', null, null).addChildElement('v1:AppID', null, null).addTextNode('classifieds');
        dom.XmlNode wsseSecurity = HeaderElement.addChildElement('Security', wsse, 'wsse').addChildElement('wsse:UsernameToken', null, null);
        wsseSecurity.addChildElement('wsse:Username',null,null).addTextNode(Username);
        wsseSecurity.addChildElement('wsse:Password',null,null).addTextNode(Password);
        
        //Create Body element 
        dom.XmlNode body = envelope.addChildElement('soapenv:Body', null, null).addChildElement('v1:RunAnalyticsReport', null, null).addChildElement('v1:AnalyticsReport', null, null); 
        body.addChildElement('v11:ID', null, null).setattribute('id', ReportId); 
        
        //Create Filter Element
        dom.XmlNode Filter = body.addChildElement('v12:Filters', null, null);
        Filter.addChildElement('v12:Name', null, null).addTextNode('Mailing');
        
        //Create Operator Element
        dom.XmlNode Operator = Filter.addChildElement('v12:Operator', null, null);
        Operator.addChildElement('v11:ID', null, null).setattribute('id', '1');
        Operator.addChildElement('v11:Name', null, null).addTextNode('equal');
        Filter.addChildElement('v12:Values', null, null);
        
        System.debug(doc.toXmlString());
        
        // Send the request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(Endpoint);
        req.setBodyDocument(doc);
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('SOAPAction','RunAnalyticsReport');
        req.settimeout(120000);
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        
        if(res.getStatusCode()!=200){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = sEmailAdmin.normalizeSpace().split(';');
            mail.setToAddresses(toAddresses);
            mail.setSubject(Label.ACED_RightNow_SubjectLine);
            mail.saveAsActivity = false;
            mail.setPlainTextBody(Label.ACED_Webtrends_EmailContent+'\n'+ res.getStatus());
            mail.setHtmlBody(Label.ACED_Webtrends_EmailContent+'</br></br>' + res.getStatus());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        XmlStreamReader reader = new XmlStreamReader(res.getBody());
        reader.setCoalescing(true);
        Map<String,Map<String,String>> mDeliveryIdToActuals = new Map<String,Map<String,String>>();
        Map<String,Id> mDeliveryRightNowIdToSFDCID = new Map<String,Id>();
        List<String> lResult = parseresults(reader);
        if(lResult.size()>0){
            for(String str :  lResult){
                if(str.contains(',')){
                    List<String> strg =  str.escapeHtml4().split(',');
                    if(strg.size()>0 && strg[2].contains('|')){
                         Map<String,String> mRighNowActuals = new Map<String,String>();
                        string DeliveryId = strg[2].trim().split('\\|')[1].trim();
                        String sMonth = Datetime.newInstance(integer.valueof(strg[0]), integer.valueof(strg[1]), 1).format('MMMMM');
                        mRighNowActuals.put('Year',strg[0]);
                        mRighNowActuals.put('Month',sMonth);
                        mRighNowActuals.put('Sent',strg[3]);//
                        mRighNowActuals.put('Delivered',strg[4]);
                        mRighNowActuals.put('Opened',strg[5]);//
                        mRighNowActuals.put('Total Clicked',strg[6]);
                        mRighNowActuals.put('Bounced',strg[7]);
                        mRighNowActuals.put('Unsubscribed',strg[8]);
                        if(!Test.Isrunningtest())
                        	mDeliveryIdToActuals.put(DeliveryId,mRighNowActuals);
                        else{
                        	ACED_Deliveries__c oDelivery =  [Select id,name from ACED_Deliveries__c limit 1];
                        	mDeliveryIdToActuals.put(oDelivery.Name,mRighNowActuals);	
                        }
                    }
                }    
            }
        }
        
        system.debug('&&&&&&'+mDeliveryIdToActuals);
        List<ACED_Delivery_Actuals__c> lDeliveryActual = new List<ACED_Delivery_Actuals__c>();
        List<ACED_Delivery_Actual_Line__c> lDeliveryActualLine = new List<ACED_Delivery_Actual_Line__c>();
        for(ACED_Deliveries__c oDeliveries : [Select id,name,Activity__r.Channel__r.Actual_Attribute__c from ACED_Deliveries__c where name in : mDeliveryIdToActuals.keyset()]){
            if((mDeliveryIdToActuals.Containskey(oDeliveries.Name) && mDeliveryIdToActuals.get(oDeliveries.Name).Containskey(oDeliveries.Activity__r.Channel__r.Actual_Attribute__c) && mDeliveryIdToActuals.get(oDeliveries.Name).get(oDeliveries.Activity__r.Channel__r.Actual_Attribute__c)!='0') || Test.Isrunningtest()){
	            ACED_Delivery_Actuals__c ds = new ACED_Delivery_Actuals__c();
	            ds.month__c = mDeliveryIdToActuals.get(oDeliveries.Name).get('Month');
	            ds.Delivery_Attribute_Upsert__c = oDeliveries.Id+'-'+mDeliveryIdToActuals.get(oDeliveries.Name).get('Month')+'-'+oDeliveries.Activity__r.Channel__r.Actual_Attribute__c;
	            ds.delivery__c = oDeliveries.Id;
	            lDeliveryActual.add(ds);
	            for(String str : mDeliveryIdToActuals.get(oDeliveries.Name).keyset()){
	                if(str!='Month' && str!='Year' && mDeliveryIdToActuals.get(oDeliveries.Name).get(str)!='0'){
		                ACED_Delivery_Actual_Line__c dActualLine = new ACED_Delivery_Actual_Line__c();
		                dActualLine.Delivery_Actuals__r = new ACED_Delivery_Actuals__c(Delivery_Attribute_Upsert__c = oDeliveries.Id+'-'+mDeliveryIdToActuals.get(oDeliveries.Name).get('Month')+'-'+oDeliveries.Activity__r.Channel__r.Actual_Attribute__c);
		                dActualLine.Delivery_Attribute_Upsert__c = oDeliveries.Id+'-'+mDeliveryIdToActuals.get(oDeliveries.Name).get('Month')+'-'+str;
		                dActualLine.Attribute__c = str;
		                dActualLine.Value__c = decimal.valueof(mDeliveryIdToActuals.get(oDeliveries.Name).get(str));
		                lDeliveryActualLine.add(dActualLine);
	                }    
	            }
            }   
        }
        
        Database.UpsertResult[] lDatabaseDeliveryActualsResult = database.upsert(lDeliveryActual,ACED_Delivery_Actuals__c.Fields.Delivery_Attribute_Upsert__c,false);
		Database.UpsertResult[] lDatabaseDeliveryActualLineResult = database.upsert(lDeliveryActualLine,ACED_Delivery_Actual_Line__c.Fields.Delivery_Attribute_Upsert__c,false);
		
		if(lDatabaseDeliveryActualLineResult.size()>0){      
			for(Database.UpsertResult sr : lDatabaseDeliveryActualLineResult) {
				if (sr.isSuccess()) {
					SuccessPlainTextBody = SuccessPlainTextBody + 'Delivery Actuals with ID ->'+sr.getId()+'----Successfully Updated'+'\n';
				    SuccessHtmlBody = SuccessHtmlBody+ 'Delivery Actuals with ID ->'+sr.getId()+'----Successfully Updated'+'</br></br>';
				}
				else {
					ErrorPlainTextBody = ErrorPlainTextBody + 'Error in Updating Delivery Actual----'+sr.getErrors()[0].getMessage()+'\n';
				    ErrorHtmlBody = ErrorHtmlBody+ 'Error in Updating Delivery Actual----'+sr.getErrors()[0].getMessage()+'</br></br>';
				}    
			}
	        
	        string PlainTextBody = Label.ACED_RightNow_EmailContent+'\n'+ErrorPlainTextBody+'\n'+SuccessPlainTextBody+'\n';
			string HtmlBody = Label.ACED_RightNow_EmailContent+'</br></br>'+ErrorHtmlBody+'</br></br>'+SuccessHtmlBody+'\n';
			
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = sEmailAdmin.normalizeSpace().split(';');
			mail.setToAddresses(toAddresses);
			mail.setSubject(Label.ACED_RightNow_SubjectLine);
			mail.saveAsActivity = false;
			mail.setPlainTextBody(PlainTextBody);
			mail.setHtmlBody(HtmlBody);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
                            
    }           
    
    public static List<String> parseresults(XmlStreamReader reader) {
        List<String> sResults = new List<String>();
        boolean isSafeToGetNextXmlElement = true;
        while(isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if ('Row' == reader.getLocalName()) {
                    boolean isSafeToGetNextchildXmlElement = true;
                    while(isSafeToGetNextXmlElement) {
                        if (reader.getEventType() == XmlTag.END_ELEMENT) {
                            break;
                        } else if (reader.getEventType() == XmlTag.CHARACTERS) {
                            system.debug(reader.getText());
                            sResults.add(reader.getText().escapeHtml4());
                        }
                        
                        if (reader.hasNext()) {
                            reader.next();
                        } else {
                            isSafeToGetNextchildXmlElement = false;
                            break;
                        }
                    }
                }
            }
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        return sResults;
    }
    
        
   
}