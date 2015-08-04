/**
 * Handles emails from Bitbucket each time a push is made to the repository
 */
global class MICO_BitbucketEmailHookManager implements Messaging.InboundEmailHandler {
	
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		
		// get the email
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		System.debug('Inbound email message:\n' + email.plainTextBody);
		
		// create the commit records
		List<MICO_SCM_Commit__c> commits = createCommits(email.plainTextBody);
		
		// create the story and defect link records
		createCommitDefectLinks(commits);
		createCommitStoryLinks(commits);
		
		return result;
	}
	
	
	/**
	 * Parse email body and create an SCM Commit record for each Git commit
	 */
	private List<MICO_SCM_Commit__c> createCommits(String commitText) {
		
		List<MICO_SCM_Commit__c> commits = new List<MICO_SCM_Commit__c>();
		
		MICO_StringUtilsLineReader lineReader = new MICO_StringUtilsLineReader(commitText);
		//List<String> newLines = new List<String>();
		
		MICO_SCM_Commit__c commitRecord;
		
		// bool to track if we are in the middle of parsing the summary.
		// we need this in case there are line breaks in the commit message
		Boolean isParsingCommitMessage = false;
		
		// parse each line
		while (lineReader.hasNext()) {
			
		    String line = lineReader.next();
		    System.debug('Parsing line:' + line);
		    
		    if (line.startsWith('https://bitbucket.org')) {
		    	isParsingCommitMessage = false;
		    	commitRecord = new MICO_SCM_Commit__c();
		    	commitRecord.Link__c = line;
		    }
		    else if (line.startsWith('Changeset:')) {
		    	isParsingCommitMessage = false;
		    	commitRecord.Revision__c = line.substring('Changeset:'.length(), line.length());
		    }
		    else if (line.startsWith('Summary:')) {
		    	isParsingCommitMessage = true;
		    	commitRecord.Body__c = line.substring('Summary:'.length(), line.length());
		    	commitRecord.Related_To__c = null;
		    }
		    else if (line.startsWith('User:')) {
		    	isParsingCommitMessage = false;
		    	commitRecord.Author__c = line.substring('User:'.length(), line.length());
		    }
		    else if (line.startsWith('Affected #:')) {
		    	isParsingCommitMessage = false;
		    	commits.add(commitRecord);
		    }
		    else {
		    	if (isParsingCommitMessage) {
		    		commitRecord.Body__c = commitRecord.Body__c + '\n' + line;
		    	}
		    }
		}
		
		insert commits;
		return commits;	
	}
	
	
	/**
	 * Parse the commit messages and create defect links if needed
	 */
	private List<MICO_SCM_Commit_Bug_Link__c> createCommitDefectLinks(List<MICO_SCM_Commit__c> commits) {
		
		List<MICO_SCM_Commit_Bug_Link__c> commitLinks = new List<MICO_SCM_Commit_Bug_Link__c>();
		List<String> defectNames = new List<String>();
		Map<String, MICO_Bug__c> defects = new Map<String, MICO_Bug__c>();
		
		// set up the pattern to look for
		MICO_SCM_Commit_Settings__c defaultSetting = ([SELECT Name, Defect_Pattern__c, User_Story_Pattern__c FROM MICO_SCM_Commit_Settings__c LIMIT 1])[0];
		Pattern p = Pattern.compile(defaultSetting.Defect_Pattern__c);
		
		//1st pass - get a list of all defect names so we can fetch them
		for (MICO_SCM_Commit__c commitRecord : commits) {
			Matcher matcher = p.matcher(commitRecord.Body__c);
			
			// if the pattern is found, add the defect name to the list of defects
			while (matcher.find()) {
				defectNames.add(matcher.group(0));
	        }
		}
		
		//now fetch all those defects and put them in a map by defect name
		for (MICO_Bug__c defect : [SELECT Id, Name FROM MICO_Bug__c WHERE Name IN :defectNames]) {
			defects.put(defect.Name, defect);
		}
		
		//2nd pass - create the link records for the found defects
		for (MICO_SCM_Commit__c commitRecord : commits) {
			Matcher matcher = p.matcher(commitRecord.Body__c);
			
			while (matcher.find()) {
				MICO_Bug__c defect = defects.get(matcher.group(0));
				if (defect != null) {
					MICO_SCM_Commit_Bug_Link__c linkRecord = new MICO_SCM_Commit_Bug_Link__c();
					linkRecord.SCM_Commit__c = commitRecord.Id;
					linkRecord.Defect__c = defect.Id;
					commitLinks.add(linkRecord);
				}
	        }
		}
		
		insert commitLinks;
		return commitLinks;
	}
	
	
	/**
	 * Parse the commit messages and create story links if needed
	 */
	private List<MICO_SCM_Commit_Requirement_Link__c> createCommitStoryLinks(List<MICO_SCM_Commit__c> commits) {
		
		List<MICO_SCM_Commit_Requirement_Link__c> commitLinks = new List<MICO_SCM_Commit_Requirement_Link__c>();
		List<String> storyNames = new List<String>();
		Map<String, MICO_User_Story__c> stories = new Map<String, MICO_User_Story__c>();
		
		// set up the pattern to look for
		MICO_SCM_Commit_Settings__c defaultSetting = ([SELECT Name, Defect_Pattern__c, User_Story_Pattern__c FROM MICO_SCM_Commit_Settings__c LIMIT 1])[0];
		Pattern p = Pattern.compile(defaultSetting.User_Story_Pattern__c);
		
		//1st pass - get a list of all defect names so we can fetch them
		for (MICO_SCM_Commit__c commitRecord : commits) {
			Matcher matcher = p.matcher(commitRecord.Body__c);
			
			// if the pattern is found, add the defect name to the list of defects
			while (matcher.find()) {
				storyNames.add(matcher.group(0));
	        }
		}
		
		//now fetch all those defects and put them in a map by defect name
		for (MICO_User_Story__c story : [SELECT Id, Name FROM MICO_User_Story__c WHERE Name IN :storyNames]) {
			stories.put(story.Name, story);
		}
		
		//2nd pass - create the link records for the found stories
		for (MICO_SCM_Commit__c commitRecord : commits) {
			Matcher matcher = p.matcher(commitRecord.Body__c);
			
			while (matcher.find()) {
				MICO_User_Story__c story = stories.get(matcher.group(0));
				if (story != null) {
					MICO_SCM_Commit_Requirement_Link__c linkRecord = new MICO_SCM_Commit_Requirement_Link__c();
					linkRecord.SCM_Commit__c = commitRecord.Id;
					linkRecord.Requirement__c = story.Id;
					commitLinks.add(linkRecord);
				}
	        }
		}
		
		insert commitLinks;
		return commitLinks;
	}
}