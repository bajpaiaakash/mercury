/****************************************************************************************************************************************** 
* Class Name   : CommitInboundEmailHandler
* Description  : This is a class that will handle the emails send out from Jenkins whenever someone commits a change to the repository    
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/

global class CommitInboundEmailHandler implements Messaging.Inboundemailhandler { 
    // Seperator Strings
    String seperatorString;
    String seperatorCommits;
    
    // Custom Settings Map
    Map<String,JenkinsCommitDetails__c> jenkinsDetails;
    
    // List containing the SCM Records
    public list<MICO_SCM_Commit__c> listSCMRecord = new list<MICO_SCM_Commit__c>();
    
    /*
    * Constructor name: handleInboundEmail
    * @description Constructor: Constructor for class handling inbound emails from Jenkins
    * @param email: Inbound Email comming from Jenkins
    * @param envg: Inbound Envelope from Email
    */
    global Messaging.Inboundemailresult handleInboundEmail(Messaging.inboundEmail email, Messaging.Inboundenvelope env) {
        // Fill the map for the custom settings & fill the seperator signs
        jenkinsDetails = JenkinsCommitDetails__c.getAll();
        System.Debug('Jenkins Details:' + jenkinsDetails);
        seperatorString             = jenkinsDetails.get('SeperatorString').FieldName__c;
        seperatorCommits            = jenkinsDetails.get('SeperatorCommits').FieldName__c;
        
        // Create an inbound email object
        Messaging.Inboundemailresult result = new Messaging.Inboundemailresult();
        
        // Create empty string which will hold body message
        String myPlainText = '';
        
        // Get body text from email
        myPlainText = email.plainTextBody;
        
        // Seperate the different commit messages
        List<String> differentCommitsList = splitDifferentCommits(myPlainText);
        
        // Itterate over the different commits and create for each commit a SCM Rec
        
        for(String commitString: differentCommitsList) {
            if(commitString== '') {
                // Do nothing
            }
            else {
                // Create list of body message from commit
                List<String> bodyList = splitEmailBody(commitString);
                
                // Parse body message
                if(parseMessage(bodyList)) {
                    result.success = true;
                }
                else {
                    result.success = false;
                    result.Message='Oops, Jenkins message is not readable';
                }
            }
        }
        
        try {       
            insert listSCMRecord;
        }
        catch (DMLException e) {
            System.Debug('Caught Error whilst insert SCM Record: ' + e);
            sendErrorMail(e, myPlainText);
        }

        return result;
    }
    
    /*
    * Method name: splitDifferentCommits
    * @description Method: Split the body from the Email according to the different commits
    * @param body: The string holding plain text from Jenkins email
    * @return List<String>: The list holding the different commits
    */
    private List<String> splitDifferentCommits(String body) {
        if(body == null) {
            return null;
        }
        
        List<String> commitsList = body.split(seperatorCommits);
        return commitsList;
    }
    
    /*
    * Method name: splitEmailBody
    * @description Method: Split the different commit details into a string list for later mapping
    * @param body: The string holding the details from one commit
    * @return List<String>: The list holding the commit details from one commit
    */
    private List<String> splitEmailBody(String body) {
        if(body == NULL)
            return null;

        List<String> parts = body.split(seperatorString);
        return parts;
    }
    
    /*
    * Method name: parseMessage
    * @description Method: Parse the commit details, add them to the SCM Record and add that Record to a Global Record list so that only one insert must happen
    * @param body: The list of strings holding the details from one commit
    * @return boolean: Return true is parsing worked, false is there was an error
    */
    private boolean parseMessage(List<String> body) {
        if(body == null)
        {
            return false;
        }
        
        try {
            
            MICO_SCM_Commit__c scmRec = new MICO_SCM_Commit__c();
            
//            Map<String,JenkinsCommitDetails__c> jenkinsDetails = JenkinsCommitDetails__c.getAll();
            
            for(String s: body) {
                List <String> temp = s.split(':',2);
                String tmpName = temp[0];
                String tmpContent = temp[1];
                scmRec.put(jenkinsDetails.get(tmpName).FieldName__c,tmpContent);
            }
            
            // Retrieve the US/Def rec of the Body
            String temp = scmRec.Body__c;
            
            if(temp.startsWithIgnoreCase('US')) {
                String tmp = '';
                system.debug('Pattern '+jenkinsDetails.get('USRef'));
                Pattern p = Pattern.compile(jenkinsDetails.get('USRef').FieldName__c);
                Matcher pm = p.matcher(temp);
                
                if(pm.find()) {
                    tmp = pm.group(0);
                }
                else {
                    System.Debug('No match found');
                }
                
                temp = temp.remove(tmp);
                scmRec.Related_To__c = tmp;
                
                // Remove the first - after the Reference to have cleaned up text field
                if(temp.contains('-')) {
                    temp = temp.subStringAfter('-');
                }
                scmRec.Body__c = temp;
            }
            else if (temp.startsWithIgnoreCase('DEF')) {
                String tmp = '';
                
                Pattern p = Pattern.compile(jenkinsDetails.get('DefRef').FieldName__c);
                Matcher pm = p.matcher(temp);
                
                if(pm.find()) {
                    tmp = pm.group(0);
                }
                else {
                    System.Debug('No match found');
                }
                
                temp = temp.remove(tmp);
                scmRec.Related_To__c = tmp;
                
                // Remove the first - after the Reference to have cleaned up text field
                if(temp.contains('-')) {
                    temp = temp.subStringAfter('-');
                }
                scmRec.Body__c = temp;
            }
            
            temp = scmRec.Author__c;
            
            if(temp.startsWithIgnoreCase('eu\\')) {
                temp = temp.removeStartIgnoreCase('eu\\');
                scmRec.Author__c = temp;
            }
            
            // Add to list
            listSCMRecord.add(scmRec);
            return true;
        }
        catch (Exception e)
        {   
            return false;
        }
    }
    
    /*
    * Method name: sendErrorMail
    * @description Method: Send Error mail to release manager responsible for Jenkins
    * @param body: String holding the message belonging to this error
    * @param e: The error message
    */
    public void sendErrorMail(DMLException e, String body) {
    	
    	// only try to send emails where it is enabled in the org.
    	try {
	        // Make sure we wont exceed our daily email limits
	        Messaging.reserveSingleEmailCapacity(1);
	        
	        // Create Email Object
	        Messaging.Singleemailmessage errorMail = new Messaging.Singleemailmessage();
	        
	        // Mail address
	        String[] toAddresses = new String[] {'rwijnen2@its.jnj.com'};
	        
	        // Assign mail address to To
	        errorMail.setToAddresses(toAddresses);
	        
	        // Set display name
	        errorMail.setSenderDisplayName('Tracker Jenkins Inbound Generator');
	        
	        errorMail.setSubject('Tracker error: Jenkins Inbound Email handler');
	        errorMail.setBccSender(false);
	        errorMail.setUseSignature(false);
	        
	        // Specify the content
	        errorMail.setPlainTextBody('Error log: ' + e + '/n Send Message: ' + body);
	        
	        // Send
	        Messaging.sendEmail(new Messaging.Singleemailmessage[] {errorMail});
    	}
    	catch (Exception ex) {
    		System.debug('Unable to send error mail!: ' + ex);
    	}

    }
}