/**
 * @author Joseph Ferraro
 *
 * Controller for VF Page that enables users to modify Agenda via a unified UI
 */

public with sharing class MERC_AgendaBuilderController extends GLBL_GenericRelatedListController {
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
}