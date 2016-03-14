/*
	MERC_DrawLoopRegistrationQuestions
	Author : Kyle Thornton (Mavens Consulting)
	Date : March 11, 2016
	Description: This class implements an undocumented interface from drawloop. Most of the code
	             was copied from an example provided by drawloop and adapted for this class.
 */
global with sharing class MERC_DrawLoopRegistrationQuestions implements Loop.IApexDataSource {
	public Set<string> getGlobalDescribe() {
        return new Set<String>{
            'Registration_Question_MERC__c', 'Answer_MERC__c'
        };
    }

    public List<Loop.ExternalData.DataObject> describeObjects(List<string> objNames) {
    	List<Loop.ExternalData.DataObject> output = new List<Loop.ExternalData.DataObject>();
        for (string objName : objNames) {
            List<Loop.ExternalData.FieldInfo> outputFields = new List<Loop.ExternalData.FieldInfo>();

            Map<String, Schema.SObjectField> fields;
            if(objName == 'Registration_Question_MERC__c') {
            	fields = Schema.sObjectType.Registration_Question_MERC__c.fields.getMap();
            } else if (objName == 'Answer_MERC__c') {
            	fields = Schema.sObjectType.Answer_MERC__c.fields.getMap();
            }

            for (string key : fields.keySet()) {
                Schema.DescribeFieldResult info = fields.get(key).getDescribe();
                Loop.ExternalData.FieldInfo outputInfo = new Loop.ExternalData.FieldInfo(info.getName(), info.getType());
                outputInfo.referenceTo = info.getReferenceTo().size() > 0 ? string.valueOf(info.getReferenceTo()[0]) : null;
                outputInfo.scale = info.getScale();
                outputInfo.label = info.getLabel();
                outputFields.add(outputInfo);
            }

            if(objName == 'Registration_Question_MERC__c') {
            	outputFields.add(new Loop.ExternalData.FieldInfo('QuestionGroupName', Schema.DisplayType.STRING));
            } else if (objName == 'Answer_MERC__c') {
            	Loop.ExternalData.FieldInfo outputInfo = new Loop.ExternalData.FieldInfo('QuestionGroup', Schema.DisplayType.REFERENCE);
                outputInfo.referenceTo = 'Registration_Question_MERC__c';
                outputFields.add(outputInfo);
            }

       		output.add(new Loop.ExternalData.DataObject(objName, outputFields));
        }
        return output;
    }

    public Set<string> getChildRelationships(string objectName) {
        Set<string> childObjectNames = new Set<string>();
        if (objectName == 'Registration_Question_MERC__c') {
        	childObjectNames.add('Answer_MERC__c');
        }
        return childObjectNames;
    }

    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
    	Loop.ExternalData.QueryResultSet results = new Loop.ExternalData.QueryResultSet();

    	Loop.ExternalData.QueryResult regQuestions = new Loop.ExternalData.QueryResult('Registration_Question_MERC__c', new List<String>());
    	Loop.ExternalData.QueryResult answerResults = new Loop.ExternalData.QueryResult('Answer_MERC__c', new List<String>());

    	if (requestInfo.RecordId.getSObjectType() == Schema.Meeting_Participant_MERC__c.sObjectType) {
	        // Get the requested participant and associated group
	        Meeting_Participant_MERC__c participant = [SELECT Id,
	                                                          Meeting_MERC__c,
	                                                          Meeting_Group_MERC__c,
	                                                          RecordType.Name,
	                                                          Participant_Typ_MERC__c
	                                                     FROM Meeting_Participant_MERC__c
	                                                    WHERE Id = :requestInfo.RecordId
	                                                    LIMIT 1];

	        // figure out the type of user this is
	        String questionType;
	        if (participant.RecordType.Name == 'Delegate') {
	        	if (participant.Participant_Typ_MERC__c == 'HCP') {
	        		questionType = 'Delegate_HCP_MERC__c';
	        	} else if (participant.Participant_Typ_MERC__c == 'Employee') {
	        		questionType = 'Delegate_Employee_MERC__c';
	        	} else {
	        		questionType = 'Delegate_Non_HCP_MERC__c';
	        	}
	        } else if (participant.RecordType.Name == 'Consulting') {
	        	questionType = 'Consulting_MERC__c';
	        } else if (participant.RecordType.Name == 'Service Provider') {
	        	questionType = 'Service_Provider_MERC__c';
	        } else {
	        	questionType = 'Individual_Sponsorship_MERC__c';
	        }

	        Set<Id> regQuestionIds = new Set<Id>();

	        //query for the reg question Ids and add them to the regQuestionIds set
	        String query = 'SELECT Id FROM Registration_Question_MERC__c ';
	    	query += 'WHERE Meeting_MERC__c = \'' + participant.Meeting_MERC__c + '\'';
	    	query += 'AND ' + questionType + '=true';
	        Map<Id, Registration_Question_MERC__c> questionMap = new Map<Id, Registration_Question_MERC__c>(
	        	(List<Registration_Question_MERC__c>)Database.query(query)
	        );

	        regQuestionIds.addAll(questionMap.keySet());

	        // figure out the ids of questions for the group the participant belongs to.
	        if (String.isNotBlank(participant.Meeting_Group_MERC__c)) {
		        for (Meeting_Group_MERC__c mgroup : [SELECT Id,
		       	                                   	        (SELECT Id,
		       	                                  	                Registration_Question_MERC__c
		       	                                  	           FROM Group_Questions__r)
		       	                                       FROM Meeting_Group_MERC__c
		       	                                	  WHERE Id = :participant.Meeting_Group_MERC__c]) {
		        	for (Meeting_Group_Question_MERC__c groupQuestion : mgroup.Group_Questions__r) {
		        		regQuestionIds.add(groupQuestion.Registration_Question_MERC__c);
		        	}
		        }
		    }

	       	//build the full query for the registation questions
	       	Set<String> regQuestionFieldsSet = Schema.sObjectType.Registration_Question_MERC__c.fields.getMap().keySet();
	        List<String> regQuestionFields = new List<String>(regQuestionFieldsSet);

	        String fullQuestionQuery = 'SELECT ' + String.join(regQuestionFields,',');
	       	fullQuestionQuery += ' FROM Registration_Question_MERC__c WHERE Id IN :regQuestionIds';

	       	Map<Id, Registration_Question_MERC__c> participantRegQuestionMap =
	       		new Map<Id, Registration_Question_MERC__c>((List<Registration_Question_MERC__c>) Database.query(fullQuestionQuery));

	       	//we now have a map of ids to associated reg questions. need to sort them. first find any which don't
	       	//already have a sort order and set it 1000 to force them last.
	       	Map<Decimal, List<Id>> orderToIdMap = new Map<Decimal, List<Id>>();
	       	for (Id questionId : participantRegQuestionMap.keySet()) {
	       		Registration_Question_MERC__c question = participantRegQuestionMap.get(questionId);
	       		if (question.Order_Number_MERC__c == null) {
	       			question.Order_Number_MERC__c = 1000.0;
	       		}

	       		if (orderToIdMap.containsKey(question.Order_Number_MERC__c)) {
	       			orderToIdMap.get(question.Order_Number_MERC__c).add(question.Id);
	       		} else {
	       			orderToIdMap.put(question.Order_Number_MERC__c, new List<Id>{question.Id});
	       		}
	       	}

	       	//let's get the sort orders actually sorted
	       	List<Decimal> sortOrders = new List<Decimal>();
	       	sortOrders.addAll(orderToIdMap.keySet());
	       	sortOrders.sort();

	       	// now we have to sort orders sorted, need to get the associated reg questions into the list
	        List<Registration_Question_MERC__c> participantQuestions = new List<Registration_Question_MERC__c>();
	        for (Decimal sortOrder : sortOrders) {
	        	for (Id questionId : orderToIdMap.get(sortOrder)) {
	        		participantQuestions.add(participantRegQuestionMap.get(questionId));
	        	}
	        }

	        //get the answers for each question
	        Set<String> answerFieldsSet = Schema.sObjectType.Answer_MERC__c.fields.getMap().keySet();
	        List<String> answerFields = new List<String>(answerFieldsSet);

	        String qWithAsQuery = 'SELECT Id, (SELECT ' + String.join(answerFields, ',');
	        qWithAsQuery += ' FROM Answers__r ORDER BY Order_Number_MERC__c)';
	        qWithAsQuery += ' FROM Registration_Question_MERC__c WHERE Id IN :participantQuestions';
	        Map<Id, Registration_Question_MERC__c> questionsWithAnswers = new Map<Id, Registration_Question_MERC__c>(
	        	(List<Registration_Question_MERC__c>) Database.query(qWithAsQuery)
	        );

	        //now we have a sorted reg question list. Let's add that to the LOOP objects
	       	List<String> regOutputFields = new List<String>{'QuestionGroupName'};
	       	regOutputFields.addAll(regQuestionFields);
	       	List<String> ansOutputFields = new List<String>{'QuestionGroup'};
	        ansOutputFields.addAll(answerFields);

	        regQuestions = new Loop.ExternalData.QueryResult('Registration_Question_MERC__c', regOutputFields);
	        answerResults = new Loop.ExternalData.QueryResult('Answer_MERC__c', ansOutputFields);

	        for (Registration_Question_MERC__c question : participantQuestions) {
	        	List<String> questionFieldValues = new List<String>{question.id};
	        	for (String field : regQuestionFields) {
	        		// get the value of each field in the regQuestionFields, convert to string and add to list.
	        		questionFieldValues.add(String.valueOf(question.get(field)));
	        	}
	        	regQuestions.rows.add(questionFieldValues);

	        	for (Answer_MERC__c answer : questionsWithAnswers.get(question.id).Answers__r) {
		        	List<String> answerFieldValues = new List<String>{question.id};
		        	for (String field : answerFields) {
		        		System.debug('### answer Field is:' + field);
		        		if (field == 'Registration_Question_MERC__c') {
		        			System.debug(String.valueOf(answer.get(field)));
		        		}
		        		// get the value of each field in the regQuestionFields, convert to string and add to list.
		        		answerFieldValues.add(String.valueOf(answer.get(field)));
		        	}

		        	answerResults.rows.add(answerFieldValues);
		        }
	        }
	    }

	    for (string objectName : requestInfo.GetObjectNames()) {
            if (objectName == 'Registration_Question_MERC__c') {
                results.add(regQuestions);
            }
            else if (objectName == 'Answer_MERC__c') {
                results.add(answerResults);
            }
        }

        return results;
    }
}