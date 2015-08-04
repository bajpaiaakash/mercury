/**
 * @author Joseph Ferraro
 *
 * Controller for VF Page that enables users to build/modify Agenda via a unified UI
 * See GLBL_GenericRelatedListController for detailed documentation
 */

public with sharing class MERC_AgendaBuilderController extends GLBL_GenericRelatedListController {

	public Boolean hasError { get; private set; }
	public String pageMessage { get; private set; }

	public Boolean hasUnconfirmedFinalAgenda {get; set; }
	public Boolean confirmAgendaChange { get; set; }
	public Boolean finalUpdatable {get; set; }

	public Boolean hasUnconfirmedWebService {get; set; }
	public Boolean confirmAgendaChange2 { get; set; }
	public Boolean webUpdatable { get; set; }

	MERC_TimeZoneUtility tz = new MERC_TimeZoneUtility(Agenda_Item_MERC__c.sObjectType);

	public MERC_AgendaBuilderController(ApexPages.StandardSetController controller) {
		super (
			controller,
			'Meeting_MERC__c', //parentObjectAPIName
			'Agenda_Item_MERC__c', //childObjectAPIName
			'Meeting_MERC__c', //parentFieldAPIName
			new List<String> {  //parentFields
				'Id',
				'Name',
				'Meeting_Time_Zone_MERC__c',
				'Start_Time_of_Meeting_MERC__c'
			},
			MERC_Util.getFieldSetFieldList('Agenda_Item_MERC__c', new List<String>{
				'Agenda_Builder_MERC',
				'Agenda_Item_Date_Time_View_MERC',
				'Agenda_Builder_Non_UI_Fields_MERC'
			}), //childFields
			'Start_Time_MERC__c' //orderChildrenBy
		);
		this.hasError = false;
		this.confirmAgendaChange = false;
		this.confirmAgendaChange2 = false;

		finalUpdatable = Schema.sObjectType.Agenda_Item_MERC__c.fields.Cnfrm_Chg_Fnl_Agnd_MERC__c.isUpdateable();
		webUpdatable =  Schema.sObjectType.Agenda_Item_MERC__c.fields.Confirm_Web_Service_Change_MERC__c.isUpdateable();
	}

	public override PageReference add() {
		PageReference p = super.add();
		if (children.size() == 1) {
			DateTime startTimeOfMeeting = (DateTime)parent.get('Start_Time_of_Meeting_MERC__c');
			children.get(0).so.put('Start_Time_MERC__c', startTimeOfMeeting);
			children.get(0).so.put('End_Time_MERC__c', startTimeOfMeeting.addHours(1));
		} else if (children.size() > 1) {
			DateTime prevTime = (DateTime)children.get(children.size()-2).so.get('Start_Time_MERC__c');
			DateTime nextTime = prevTime.addHours(1);
			children.get(children.size()-1).so.put('Start_Time_MERC__c', nextTime);
			children.get(children.size()-1).so.put('End_Time_MERC__c', nextTime.addHours(1));
		}
		return p;
	}

	List<Sobject> getSobjects(List<GLBL_GenericRelatedListController.GenericSobjectWrapper> children) {
		List<Sobject> returnSobjects = new List<Sobject>();
		for (GLBL_GenericRelatedListController.GenericSobjectWrapper c : children) {
			returnSobjects.add(c.so);
		}
		return returnSobjects;
	}

	public Meeting_MERC__c meeting {
	    get {
	        return [SELECT ID, Name, Meeting_Time_Zone_MERC__c, Agenda_Status_MERC__c, Expose_on_Portal_MERC__c FROM Meeting_MERC__c WHERE ID = :MERC_Util.getUrlParam('id')];
	    }
	}

	public PageReference setTimeZones() {
	    if (children.size() > 0)
	    	tz.convertDateTimes(getSobjects(children), false, meeting.Meeting_Time_Zone_MERC__c); //sets date/times based on meeting time/zone, for UX purposes
	    if (MERC_Util.getUrlParam('notify') == '1') {
	    	if (hasError) {
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MERC_Util.getUrlParam('msg')));
    		} else {
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, MERC_Util.getUrlParam('msg')));
    		}
	    }
	    return null;
	}

	public override PageReference save() {
		hasUnconfirmedFinalAgenda = (meeting.Agenda_Status_MERC__c == 'Final' && !this.confirmAgendaChange);
		hasUnconfirmedWebService = (meeting.Expose_on_Portal_MERC__c && !this.confirmAgendaChange2);
        if (hasUnconfirmedFinalAgenda || hasUnconfirmedWebService) {
        	tz.convertDateTimes(getSobjects(children), true, meeting.Meeting_Time_Zone_MERC__c); //sets date/times based on UTC, stamps static text with "user-friendly" date/time values
			this.hasError = true;

			String message = '';
			if (finalUpdatable && webUpdatable) {
				message = 'This meeting has been ';
				if (hasUnconfirmedFinalAgenda) message += 'confirmed as final ';
				if (hasUnconfirmedFinalAgenda && hasUnconfirmedWebService) message += 'and ';
				if (hasUnconfirmedWebService) message += 'activated on the Web Service';
			} else {
				message = 'This meeting has been Activated on the Web Service and the Agenda is viewable.'+
				' Please speak to a member of the Customer Meeting Services team to request a change.';
			}
			this.pageMessage = message;
			return null;
        }
        this.confirmAgendaChange = false;
        this.confirmAgendaChange2 = false;
        tz.convertDateTimes(getSobjects(children), true, meeting.Meeting_Time_Zone_MERC__c); //sets date/times based on UTC, stamps static text with "user-friendly" date/time values
		//return super.save();
		try {
			List<Sobject> childrenToInsert = new List<Sobject>();
			List<Sobject> childrenToUpdate = new List<Sobject>();
			List<GenericSobjectWrapper> childrenList;
			if (recordTypeDeveloperNameParam != null) {
				childrenList = childrenMap.get(recordTypeDeveloperNameParam);
			} else {
				childrenList = children;
			}
			for (GenericSobjectWrapper sow : childrenList) {
				if (sow.so.Id != null) {
					sow.so.put('Cnfrm_Chg_Fnl_Agnd_MERC__c', true);
					childrenToUpdate.add(sow.so);
				} else {
					sow.so.put('Cnfrm_Chg_Fnl_Agnd_MERC__c', true);
					sow.so.put(parentFieldAPIName, parentId);
					childrenToInsert.add(sow.so);
				}
			}
			insert childrenToInsert;
			update childrenToUpdate;
			this.hasError = false;
			this.pageMessage = 'Meeting Agenda updated successfully!';
			if (MERC_Util.getUrlParam('notify') == '1') {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, MERC_Util.getUrlParam('msg')));
				return null;
			} else if (MERC_Util.getUrlParam('retNull') == '1') {
				return null;
			} else {
				return new PageReference('/'+parentId);
			}
		} catch (Exception e) {
			setTimeZones();
			this.hasError = true;
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			ApexPages.addMessages(e); //doesn't show ugly error text
			return null;
		}
	}
}