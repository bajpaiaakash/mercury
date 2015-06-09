/**
 * @author Joseph Ferraro
 *
 * Controller for vf page override of Meeting Participant New/Edit Pages
 */
public with sharing class MERC_MeetingParticipantNewEditController extends GLBL_BaseEditController {

	public Meeting_Participant_MERC__c meetingParticipant { get; set; }
	private ApexPages.StandardController controller;

	private String meetingParticipantSelectAllSoql {
		get {
			if (meetingParticipantSelectAllSoql == null) {
				meetingParticipantSelectAllSoql =
					new MERC_Util.SelectAll( Meeting_Participant_MERC__c.SobjectType, (ID)this.controller.getId() ).soql;
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

			// set new record type explicitly. The query immediately above has overridden the super class' set of RecordTypeId 
			if (ApexPages.currentPage().getParameters().containsKey('RecordType')) {
				this.meetingParticipant.RecordTypeId = MERC_Util.getUrlParam('RecordType');
			}

			//we can't run this code during a test because of quirkiness with setMock and test data creation -JFERRARO
			if (!Test.isRunningTest()) {
				for (GLBL_BaseEditController.PageBlockSection section : sections) {
					for (GLBL_BaseEditController.Field field : section.fields) {
						//adds javascript event handlers to dynamic input fields
						if (dynamicInputFieldNames.contains(field.value)) {
							field.onBlur = 'toggleLoading();'+submitFormViaAjaxJavaScriptMethod+'()';
							field.onChange = 'toggleLoading();'+submitFormViaAjaxJavaScriptMethod+'()';
						}
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
		'Confirm_Final_Fee_MERC__c',
		'Alliance_MERC__c'
	};

	//dynamic javascript function name so the vf page can submit form via ajax
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

	public override PageReference save() {
		try {
			if (ApexPages.currentPage().getParameters().containsKey('RecordType')) {
				this.meetingParticipant.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
			}

			if (this.meetingParticipant.Id == null) {
				insert this.meetingParticipant;					
			} else {
				if(Schema.sObjectType.Meeting_Participant_MERC__c.fields.RecordTypeId.isUpdateable()) {
					update this.meetingParticipant;					
				}
			}
		} catch(Exception e) {
			ApexPages.addMessages(e); //doesn't show ugly error text
			return null;
		}
		PageReference p = new PageReference('/'+this.meetingParticipant.Id);
		return p;
	}
}