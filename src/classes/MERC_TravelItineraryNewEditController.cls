/**
 * @author Joseph Ferraro
 *
 * Controller to enable user to create/edit travel itineraries
 * we're overriding so we can control UX as it relates to Date/Times
 */

public with sharing class MERC_TravelItineraryNewEditController extends GLBL_BaseEditController {

	MERC_TimeZoneUtility tz = new MERC_TimeZoneUtility(Travel_Itinerary_MERC__c.sObjectType);
    String customObjectId;

    public Boolean provideSaveAndNew {get{return provideSaveAndNew!=null && provideSaveAndNew;} private set;}

	public MERC_TravelItineraryNewEditController(ApexPages.StandardController controller) {
		super(controller, Travel_Itinerary_MERC__c.SobjectType);

		// if the time zones have not been set yet, set according to user's locale
        String vfUrl = Apexpages.currentPage().getUrl().toLowerCase();
        if (vfUrl.contains('/apex/merc_travelitinerarynewedit')) {

            if (MERC_Util.getUrlParam('clone') == '1') {
                this.mySobject.put('Id', null);
            }

            if (this.mySobject.get('Meeting_Participant_MERC__c') != null && this.mySobject.get('Account_MERC__c') == null) {
                String meetingParticipantId = (String)this.mySobject.get('Meeting_Participant_MERC__c');
                this.mySobject.put('Account_MERC__c', [SELECT Account_MERC__c FROM Meeting_Participant_MERC__c WHERE ID = :meetingParticipantId].Account_MERC__c);
            }

            Schema.DescribeFieldResult meetingTimeZoneFieldDescribe = Meeting_MERC__c.Meeting_Time_Zone_MERC__c.getDescribe();
            String userTimeZoneDefault = MERC_Util.getTimeZonePicklistValueForCurrentUser(meetingTimeZoneFieldDescribe);
            if (this.mySobject.get('Segment_Begin_Timezone_MERC__c') == null)
                this.mySobject.put('Segment_Begin_Timezone_MERC__c', userTimeZoneDefault);
            if (this.mySobject.get('Segment_End_Timezone_MERC__c') == null)
                this.mySobject.put('Segment_End_Timezone_MERC__c', userTimeZoneDefault);
		}

        // need Custom Object ID to redirect user to Record Type selection screen
        provideSaveAndNew = Apexpages.currentPage().getParameters().keySet().contains('ent');
        customObjectId = Apexpages.currentPage().getParameters().get('ent');
	}

	public Map<String,String> fieldSetLabels {
    	get {
    		if (fieldSetLabels == null) {
    			fieldSetLabels = MERC_Util.getFieldSetLabels(
	    			Travel_Itinerary_MERC__c.SobjectType,
	    			new List<String> {
	    				'Date_Time_Information_Edit_MERC',
	    				'Date_Time_Information_View_MERC'
	    			}
	    		);
    		}
    		return fieldSetLabels;
    	}
    	private set;
    }

    public void setTimeZones() {
        tz.convertDateTimes(new List<Sobject>{this.mySobject}, false); //sets date/times based on meeting time/zone, for UX purposes
    }

    public override PageReference save() {
        return insertTheSObject(false);
    }

    public PageReference saveAndNew() {
        return insertTheSObject(true);
    }

    private PageReference insertTheSObject(Boolean saveAndNew) {
        try {
            tz.convertDateTimes(new List<Sobject>{this.mySobject}, true); //sets date/times based on UTC
            if (this.mySobject.Id == null) {
                insert this.mySobject;
            } else {
                update this.mySobject;
            }
        } catch(Exception e) {
            setTimeZones();
            ApexPages.addMessages(e); //TODO: doesn't show ugly error text
            return null;
        }
        PageReference p = (saveAndNew)
            ? buildSaveAndNewURL()
            : new PageReference('/'+this.mySobject.Id);
        return p;
    }

    /*
     * Creates a Save and New URL. The trick is returning the user to the Record Type selection screen
     * while retaining a Custom Object ID (that is not available to Apex!) and the previous Meeting
     * Participant and Account field values.
     */
    public PageReference buildSaveAndNewURL() {
        String recTypeSelectURL = '/setup/ui/recordtypeselect.jsp?ent='+customObjectId;
        String save_new_url = '/' + Schema.Sobjecttype.Travel_Itinerary_MERC__c.getKeyPrefix() + '/e?';
        Set<String> keys = new Set<String>{'ent','retURL'};
        for (String key : Apexpages.currentPage().getParameters().keySet()) {
            if (key.startsWith('CF') || keys.contains(key))
                save_new_url += key+'='+Apexpages.currentPage().getParameters().get(key)+'&';
        }

        save_new_url = '&save_new_url='+EncodingUtil.urlEncode(save_new_url.removeEnd('&'), 'UTF-8');
        PageReference pageRef = new PageReference(recTypeSelectURL+save_new_url);
        return pageRef;
    }
}