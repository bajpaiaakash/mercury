/**
 * @author Kyle Thornton
 *
 * Trigger handler to perform validation on Meeting Participant and ensure that ToV values are not changed if
 * tov is final. This was originally handled in a validation rule but the val rule would fire when the
 * lookup rollup summaries update the meeting participant when child records changed. Moving the logic to a
 * trigger allows us to set static booleans that we can use to ensure this doesn't fire when children records
 * are edited.
 *
 * Business Criteria: If the meeting has been reported as Participant_ToV_Final_MERC__c = 'Yes' and any field
 * in the Meeting Participant ToV_Validation_Fields field set is changed AND Confirm_ToV_Reporting_Change_MERC__c
 * is false then we need to prevent a database update.
 */
public with sharing class MERC_MeetingParticipantTovValidation implements GLBL_TriggerHandler.HandlerInterface
{

	public static Boolean tovValidationByPass = false;

	public Boolean isActive()
	{
		return MERC_TriggerHandlerStateManager.isActive(MERC_MeetingParticipantTovValidation.class);
	}

	public void handle()
	{
		System.debug('\n\n\ntovValidationByPass: ' + tovValidationByPass);
		if (!tovValidationByPass && Trigger.isBefore && Trigger.isUpdate)
			execute();
	}

	private void execute() {
		Schema.FieldSet validationFields = Schema.SObjectType.Meeting_Participant_MERC__c.fieldSets.ToV_Validation_Fields;

		for (Meeting_Participant_MERC__c mp : [SELECT Id, Meeting_MERC__r.Participant_ToV_Final_MERC__c
		                    	                 FROM Meeting_Participant_MERC__c
		                    	                WHERE Id IN :Trigger.new])
		{
			if (mp.Meeting_MERC__r.Participant_ToV_Final_MERC__c == 'Yes')
			{
				SObject newMp = Trigger.newMap.get(mp.Id);
				if (newMp.get('Confirm_ToV_Reporting_Change_MERC__c') == true)
				{
					continue; //this has been flagged as ok to update, move on to the next record.
				}
				SObject oldMp = Trigger.oldMap.get(mp.Id);

				//for each meeting participant under the meeting check if any of the fields from the fieldset have changed
				//and add an error to the record if it has.
				for (Schema.FieldSetMember fsm : validationFields.getFields())
				{
					if (oldMp.get(fsm.getFieldPath()) != newMp.get(fsm.getFieldPath()))
					{
						newMp.addError(Label.ToV_Already_Reported);
						break;
					}
				}
			}
		}

		//now that the validation has been done once turn it off for the remainder of this execution context.
		//the workflow will fire and uncheck Confirm_ToV_Reporting_Change_MERC__c and the lookup rollup summary
		//will try to update this record again and the valdation won't pass if we don't bypass it.
		tovValidationByPass = true;
	}
}