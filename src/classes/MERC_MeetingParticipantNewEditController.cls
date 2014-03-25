public with sharing class MERC_MeetingParticipantNewEditController extends GLBL_BaseEditController {
	
	public Meeting_Participant_MERC__c meetingParticipant { get; set; }
	private ApexPages.StandardController controller;

	private String meetingParticipantSelectAllSoql {
		get {
			if (meetingParticipantSelectAllSoql == null) {
				meetingParticipantSelectAllSoql = 
					new MERC_Util.SelectAll( Meeting_Participant_MERC__c.SobjectType, this.controller.getId() ).soql;
			} 
			return meetingParticipantSelectAllSoql;
		}
		set;
	}

    public MERC_MeetingParticipantNewEditController(ApexPages.StandardController c) {
		super(c, Meeting_Participant_MERC__c.SobjectType);
		this.controller = c;
		this.meetingParticipant = (Meeting_Participant_MERC__c)this.controller.getRecord();

		if (this.meetingParticipant.Id != null) {
			this.meetingParticipant = Database.query(meetingParticipantSelectAllSoql);
			for (GLBL_BaseEditController.PageBlockSection section : sections) {
				for (GLBL_BaseEditController.Field field : section.fields) {
					if (dynamicInputFieldNames.contains(field.value)) {
						field.onBlur = 'toggleLoading();'+submitFormViaAjaxJavaScriptMethod+'()';
						field.onChange = 'toggleLoading();'+submitFormViaAjaxJavaScriptMethod+'()';
					}
				}
			}
		}
	}

	//these fields, will fire the onblur javascript event to prompt the page to update the MP
	//and rerender from the server
	public Set<String> dynamicInputFieldNames = new Set<String> {
		'Preparation_Time_Hrs_MERC__c',
		'Event_Time_Hrs_MERC__c',
		'Travel_Time_Hrs_MERC__c',
		'Confirm_Final_Fee_MERC__c'
	};

	public String submitFormViaAjaxJavaScriptMethod {
		get {
			return 'submitFormViaAjax';
		}
	}

	public PageReference ajaxUpdate() {
		try {
			update this.meetingParticipant; 
			this.meetingParticipant = Database.query(meetingParticipantSelectAllSoql);
		} catch(Exception e) {
		    ApexPages.addMessages(e); //doesn't show ugly error text
		}
		return null;	
	}

	public PageReference save() {
		try {
		    if (this.meetingParticipant.Id == null) {
		        insert this.meetingParticipant;
		    } else {
		        update this.meetingParticipant; 
		    }
		} catch(Exception e) {
		    ApexPages.addMessages(e); //doesn't show ugly error text
		    return null;
		}
		PageReference p = new PageReference('/'+this.meetingParticipant.Id);
		return p;
	}
}