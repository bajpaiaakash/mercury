Global class ACED_RightNowScheduler implements Schedulable{
     Global void execute(SchedulableContext sc) {     	
       InvokeRightNow();
     }
      
     Public static Void InvokeRightNow(){
     	
        Try{ 
			for(ACED_RightNow_Country__c oRightNow : [Select id,RightNow_Service_URL__c,Report_ID__c,Integration_Console__r.RightNow_Admin_Email__c,Integration_Console__r.RN_UserName__c,Integration_Console__r.RN_Password__c from ACED_RightNow_Country__c limit 8]){
			    ACED_RightNowUtility.ACED_RightNowUtility(oRightNow.RightNow_Service_URL__c,oRightNow.Report_ID__c,oRightNow.Integration_Console__r.RN_UserName__c,oRightNow.Integration_Console__r.RN_Password__c,oRightNow.Integration_Console__r.RightNow_Admin_Email__c);
			} 
            }catch(exception e){
            	ACED_Integration_Console__c oIntegration = [Select id,Web_UserName__c,RightNow_Admin_Email__c,WebTrends_Admin_Email__c,Web_Password__c,WebTrends_Service_URL__c from ACED_Integration_Console__c limit 1];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = oIntegration.RightNow_Admin_Email__c.normalizeSpace().split(';');
                mail.setToAddresses(toAddresses);
                mail.setSubject(Label.ACED_RightNow_SubjectLine);
                mail.saveAsActivity = false;
                mail.setPlainTextBody(Label.ACED_RightNow_EmailContent+'\n'+ e);
                mail.setHtmlBody(Label.ACED_Webtrends_EmailContent+'</br></br>' + e);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
     }
}