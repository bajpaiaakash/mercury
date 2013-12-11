/**
 * @author Joseph Ferraro
 *
 * Controller for VF Page that enables users to modify Agenda via a unified UI
 */

public with sharing class MERC_AgendaBuilderController extends GLBL_GenericRelatedListController {
	MERC_TimeZoneCalculator tz = new MERC_TimeZoneCalculator('Agenda_Item_MERC__c');

	public MERC_AgendaBuilderController(ApexPages.StandardSetController controller) {
		super (
			controller, 
			'Meeting_MERC__c', 
			'Agenda_Item_MERC__c', 
			'Meeting_MERC__c',
			new List<String> { 
				'Id', 
				'Name'
			},
			MERC_Util.getFieldSetFieldList('Agenda_Item_MERC__c', 'Agenda_Builder_MERC'),
			'Start_Time_MERC__c'
		);
	}

	List<Sobject> getSobjects(List<GLBL_GenericRelatedListController.GenericSobjectWrapper> children) {
		List<Sobject> returnSobjects = new List<Sobject>();
		for (GLBL_GenericRelatedListController.GenericSobjectWrapper c : children) {
			returnSobjects.add(c.so);
		}
		return returnSobjects;
	}

	public PageReference setTimeZones() {
	    tz.execute(getSobjects(children), false); //sets date/times based on meeting time/zone, for UX purposes
	    if (MERC_Util.getUrlParam('notify') == '1') {
	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, MERC_Util.getUrlParam('msg')));
	    }
	    return null;
	}

	public override PageReference save() {
        tz.execute(getSobjects(children), true); //sets date/times based on UTC, stamps static text with "user-friendly" date/time values
		return super.save();
	}
}