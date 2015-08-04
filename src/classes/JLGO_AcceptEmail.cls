/* Created by Agrex Matsunaga
 * 2015/02/05 New
 */
global class JLGO_AcceptEmail implements Messaging.InboundEmailHandler {
    /*
     * Accept Email
     */
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        system.debug('Accept Email');
        try{
            InsertEmail(email);
        }catch(exception e){
            system.debug(e.getMessage());
            JLGO_AppUtil.InsertError(e,'JLGO_AcceptEmail');
        }
        return result;
    }
    /*
     * Insert for JLGO_GrantReques
     */
    private void InsertEmail(Messaging.InboundEmail email){
        List<JLGO_GrantRequest__c> lstGranRep = new List<JLGO_GrantRequest__c>();
        string objId = JLGO_AppUtil.GetBetweenStrings(system.label.JLGO_CutStringFrom,system.label.JLGO_CutStringTo,email.subject);
        if(!string.isBlank(objId)){
            //check a exists
            lstGranRep = [select id,ownerid from JLGO_GrantRequest__c where id = :objId];
        }
        if(lstGranRep.size()<=0){
            lstGranRep = [select id,ownerid from JLGO_GrantRequest__c where dummyflag__c = true order by LastModifiedDate desc limit 1];
        }
        if(lstGranRep.size()<=0){
            lstGranRep = new List<JLGO_GrantRequest__c>();
            lstGranRep.Add(new JLGO_GrantRequest__c(ownerid=UserInfo.getUserId(),dummyflag__c=true));
            insert lstGranRep;
        }
        Task ts = new Task(
        	 whatid = lstGranRep[0].id
            ,OwnerId = lstGranRep[0].OwnerId
            ,subject = 'メール: '+ email.subject
            ,ActivityDate = system.today()
            ,status = 'Completed'
            ,Priority = 'Normal'
            ,Description = string.isblank(email.plainTextBody) ? email.fromAddress  +'\n\r'+'\n\r'+ email.htmlBody : email.fromAddress  +'\n\r'+'\n\r'+ email.plainTextBody
            );
        system.debug('insert task');
        insert ts;
        InsertAttachment(email,ts); 
    }
    /*
     * Insert Attachment
     */
    private static void InsertAttachment(Messaging.InboundEmail email,Task ts){
        List<Attachment> atts = new List<Attachment>();
        //Binary file
        if (email.binaryAttachments != null){
            for (Messaging.InboundEmail.BinaryAttachment batt: email.binaryAttachments){
                Attachment att = new Attachment(
                	 name = batt.fileName
                    ,body = batt.body
                    ,parentId = ts.Id
                    ,OwnerId = ts.OwnerId
                );
                atts.add(att);
            }
        }
        //Text File
		if (email.textAttachments != null){
			for (Messaging.InboundEmail.textAttachment tr: email.textAttachments){
				Attachment att = new Attachment(
					 name = tr.fileName
					,body = blob.valueOf(tr.body)
					,parentId = ts.Id
                    ,OwnerId = ts.OwnerId
				);
				atts.add(att);
			}
		}
        if(atts.size()>0){
            system.debug('insert Attachment');
            insert atts;
        }
    }
}