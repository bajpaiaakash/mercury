Public class ACED_WebTrendsScheduler implements Schedulable{
 
    @future(callout=true)
	Public static void InvokeWebTrends(){ 
        
		string SuccessPlainTextBody ='';
	    string SuccessHtmlBody ='';
		string ErrorHtmlBody ='';
		string ErrorPlainTextBody ='';
        
    	ACED_Integration_Console__c oIntegration = [Select id,Web_UserName__c,WebTrends_Admin_Email__c,Web_Password__c,WebTrends_Service_URL__c from ACED_Integration_Console__c limit 1]; 
    
	     string start_period = 'start_period='+system.today().year()+'m'+system.today().month()+'d'+system.today().toStartOfMonth().day();       
	     string end_period = 'end_period='+system.today().year()+'m'+system.today().month()+'d'+system.today().day();        
	     
	     HttpRequest req = new HttpRequest();
	     req.setTimeout(120000);
	     req.setEndpoint(oIntegration.WebTrends_Service_URL__c+'?'+start_period+'&'+end_period);
	     req.setMethod('GET');
	 
	     String username = oIntegration.Web_UserName__c;
	     String password = oIntegration.Web_Password__c;
	     Blob headerValue = Blob.valueOf(username + ':' + password);
	     String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
	     req.setHeader('Authorization', authorizationHeader);
	  
	     Http http = new Http();
	     HTTPResponse res = http.send(req);
	     System.debug(res.getBody());
	     List<ACED_WebtrendClass> lResponse = ACED_WebtrendClass.parse(res.getBody());
	     
	     Map<String,List<ACED_WebtrendClass.Measures>> mResponseMappingWithProfileId = new Map<String,List<ACED_WebtrendClass.Measures>>();
	     Map<String,ACED_Deliveries__c> mAssetMappingWithProfileId = new Map<String,ACED_Deliveries__c>();
	     
	     for(ACED_WebtrendClass resp : lResponse){
	        if(resp.Definition.profileID!=null){
	           mResponseMappingWithProfileId.put(resp.Definition.profileID,resp.Definition.Measures);
	        }   
	     }
	     
	     for(ACED_Deliveries__c  oDeliveries : [Select id,StandAlone_Asset__r.ProfileId__c,StandAlone_Asset__r.channel__r.Actual_Attribute__c from ACED_Deliveries__c where StandAlone_Asset__r.ProfileId__c in : mResponseMappingWithProfileId.keyset() ]){
	        mAssetMappingWithProfileId.put(oDeliveries.StandAlone_Asset__r.ProfileId__c,oDeliveries);
	     }
	     List<ACED_Delivery_Actuals__c> lDeliveryActuals = new List<ACED_Delivery_Actuals__c>();  
	     List<ACED_Delivery_Actual_Line__c> lDeliveryActualLines = new List<ACED_Delivery_Actual_Line__c>();   
	     for(ACED_WebtrendClass resp : lResponse){
	        if(resp.Definition.profileID!=null && mAssetMappingWithProfileId.containskey(resp.Definition.profileID)){
	            ACED_Delivery_Actuals__c  oDeliveryActuals = new ACED_Delivery_Actuals__c();
	            oDeliveryActuals.Delivery__c = mAssetMappingWithProfileId.get(resp.Definition.profileID).ID;
	            oDeliveryActuals.Delivery_Attribute_Upsert__c = mAssetMappingWithProfileId.get(resp.Definition.profileID).ID+'-'+System.now().format('MMMMM')+'-'+mAssetMappingWithProfileId.get(resp.Definition.profileID).StandAlone_Asset__r.channel__r.Actual_Attribute__c;
	            oDeliveryActuals.month__c = System.now().format('MMMMM');
	            lDeliveryActuals.add(oDeliveryActuals);
	            
	            for(ACED_WebtrendClass.Measures rt : resp.Definition.Measures){
	                ACED_Delivery_Actual_Line__c oDeliveryActual = new ACED_Delivery_Actual_Line__c();
	                oDeliveryActual.Attribute__c = rt.name;
	                oDeliveryActual.value__c = rt.columnID;
	                oDeliveryActual.Delivery_Attribute_Upsert__c = mAssetMappingWithProfileId.get(resp.Definition.profileID).ID+'-'+System.now().format('MMMMM')+'-'+rt.name;
	                ACED_Delivery_Actuals__c oAssetActuals = new ACED_Delivery_Actuals__c();
	                oAssetActuals.Delivery_Attribute_Upsert__c = mAssetMappingWithProfileId.get(resp.Definition.profileID).ID+'-'+System.now().format('MMMMM')+'-'+mAssetMappingWithProfileId.get(resp.Definition.profileID).StandAlone_Asset__r.channel__r.Actual_Attribute__c;
	                oDeliveryActual.Delivery_Actuals__r = oAssetActuals;
	                lDeliveryActualLines.add(oDeliveryActual);
	            }
	        }   
	     }
     
		Database.UpsertResult[] lDatabaseDeliveryActualsResult = database.upsert(lDeliveryActuals,ACED_Delivery_Actuals__c.Fields.Delivery_Attribute_Upsert__c,false);
		Database.UpsertResult[] lDatabaseDeliveryActualLineResult = database.upsert(lDeliveryActualLines,ACED_Delivery_Actual_Line__c.Fields.Delivery_Attribute_Upsert__c,false);
		      
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
        
        string PlainTextBody = Label.ACED_Webtrends_EmailContent+'\n'+ErrorPlainTextBody+'\n'+SuccessPlainTextBody+'\n';
		string HtmlBody = Label.ACED_Webtrends_EmailContent+'</br></br>'+ErrorHtmlBody+'</br></br>'+SuccessHtmlBody+'\n';
		oIntegration.Web_Last_Run_Date__c = system.now();
	    Update oIntegration;
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = oIntegration.WebTrends_Admin_Email__c.normalizeSpace().split(';');
		mail.setToAddresses(toAddresses);
		mail.setSubject(Label.ACED_Webtrends_SubjectLine);
		mail.saveAsActivity = false;
		mail.setPlainTextBody(PlainTextBody);
		mail.setHtmlBody(HtmlBody);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
	   
}
 
Public void execute(SchedulableContext SC) {
    InvokeWebTrends();
}

}