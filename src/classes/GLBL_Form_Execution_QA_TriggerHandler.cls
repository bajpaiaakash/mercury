/**
 * Scoring engine for the Form Builder
 */
public with sharing class GLBL_Form_Execution_QA_TriggerHandler {
	
	/**
	 * Score scorable each answer by looking at the answer option selected
	 */
	public static void scoreAnswers (List<GLBL_Form_Execution_Question_Answer__c> answers) {
		
		Set<Id> executionIds = new Set<Id>();
		Set<Id> questionIds = new Set<Id>();
		Map<Id, List<GLBL_Form_Template_Answer_Option__c>> questionToAnswerOptions = new Map<Id, List<GLBL_Form_Template_Answer_Option__c>>();
		
		// get a list of the scorable executions
		for (GLBL_Form_Execution_Question_Answer__c answer : answers) {
			executionIds.add(answer.Form_Execution__c);
			questionIds.add(answer.Source_Question__c);
		}
		
		Map<Id, GLBL_Form_Execution__c> scorableExecutions = new Map<Id, GLBL_Form_Execution__c>
																([
																SELECT Id, Enable_Scoring__c, Source_Form__c
																FROM GLBL_Form_Execution__c
																WHERE Id IN :executionIds
																AND Enable_Scoring__c = true
																]);
		System.debug('### found ' + scorableExecutions.size() + ' scorable executions for Ids:' + executionIds);
		// get a list of picklist questions
		Map<Id, GLBL_Form_Template_Question__c> picklistQuestions = new Map<Id, GLBL_Form_Template_Question__c>
																([
																SELECT Id
																FROM GLBL_Form_Template_Question__c
																WHERE Question_Type__c = :FORM_Constants.QUESTION_TYPE_PICKLIST
																]);
		
		// get a list of picklist answer options
		List<GLBL_Form_Template_Answer_Option__c> answerOptions = 
																[
																SELECT Id, Answer_option__c, Form_Template_Question__c, 
																	Score_A__c, Score_B__c, Score_C__c, Score_D__c, Score_E__c,  
																	Score_F__c, Score_G__c, Score_H__c, Score_I__c, Score_J__c 
																FROM GLBL_Form_Template_Answer_Option__c
																WHERE Form_Template_Question__c IN :picklistQuestions.keySet()
																];
		
		//create a map of questions to answer options
		for (GLBL_Form_Template_Answer_Option__c answerOption : answerOptions) {
			
			if (questionToAnswerOptions.get(answerOption.Form_Template_Question__c) == null) {
				questionToAnswerOptions.put(answerOption.Form_Template_Question__c, new List<GLBL_Form_Template_Answer_Option__c>());
			}
			
			questionToAnswerOptions.get(answerOption.Form_Template_Question__c).add(answerOption);		
		}
		
		// go through each answer option for this question, and stamp the scores for the respective answers if the question matches
		for (GLBL_Form_Execution_Question_Answer__c answer : answers) {
			
			List<GLBL_Form_Template_Answer_Option__c> questionAnswerOptions = questionToAnswerOptions.get(answer.Source_Question__c);
			if (questionAnswerOptions == null) {
				continue;
			}
			for (GLBL_Form_Template_Answer_Option__c answerOption : questionAnswerOptions) {
				if ( answer.Response_Text__c == answerOption.Answer_option__c) {
					answer.Total_Score_A__c = answerOption.Score_A__c;
					answer.Total_Score_B__c = answerOption.Score_B__c;
					answer.Total_Score_C__c = answerOption.Score_C__c;
					answer.Total_Score_D__c = answerOption.Score_D__c;
					answer.Total_Score_E__c = answerOption.Score_E__c;
					answer.Total_Score_F__c = answerOption.Score_F__c;
					answer.Total_Score_G__c = answerOption.Score_G__c;
					answer.Total_Score_H__c = answerOption.Score_H__c;
					answer.Total_Score_I__c = answerOption.Score_I__c;
					answer.Total_Score_J__c = answerOption.Score_J__c;
					break;
				}
			}
		}
	}
}