/*
* MERC_TravelProposalsController
* Description : Controller which provides functionality for MERC_TravelProposals.page.
*               Allows users to Create Travel Proposals and their underlying segments (both types are Travel Itinerary records)
*               Uses inner classes to model the TravelProposal and Segments.
*               Allows for addition of new proposals and new segments within those proposals.
* Author: Kyle Thornton (Mavens Consulting)
* Created Date: April 23, 2015
*
* Modified By:
* Modified Date:
* Modification Description:
*/
public with sharing class MERC_TravelProposalsController {

	public List<TravelProposal> proposals { get; set; }
	public Meeting_Participant_MERC__c participant { get; private set; }

	public static MERC_TimeZoneUtility tz = new MERC_TimeZoneUtility(Travel_Itinerary_MERC__c.sObjectType);

	public MERC_TravelProposalsController() {
		initialize();
	}
	public Boolean initializationError { get; private set; }
	private void initialize() {
		initializationError = true;
		proposals = new List<TravelProposal>();

		Id participantId = ApexPages.currentPage().getParameters().get('id');
		//must have a participant
		if (String.isBlank(participantId)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Travel_Proposals_No_Participant_Id));
			return;
		}

		//query for participant based on given Id
		try {
			participant = getParticipant(participantId);
		} catch (System.exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Travel_Proposals_Cannot_Find_Participant));
			return;
		}

		//Grab the data
		List<Travel_Itinerary_MERC__c> proposalsAndItineraries = getProposalsAndChildItineraries();

		//build the list of proposals and segements and add them to a list to do time zone conversion
		List<Travel_Itinerary_MERC__c> timeZoneConvertList = new List<Travel_Itinerary_MERC__c>();
		for (Travel_Itinerary_MERC__c proposal : proposalsAndItineraries) {
			timeZoneConvertList.add(proposal);
			timeZoneConvertList.addAll(proposal.Travel_Itineraries__r);
			proposals.add( new TravelProposal(proposal));
		}

		//convert date time fields for display
		tz.convertDateTimes(timeZoneConvertList, false);

		//made it to the end so no initialization error
		initializationError = false;
	}

	//helper method for VF page to post to
	public void doNothing() {}

	@TestVisible
	private Boolean saveProposals() {
		//build a list of itineraries
		List<Travel_Itinerary_MERC__c> itinerariesToUpsert = new List<Travel_Itinerary_MERC__c>();
		for (TravelProposal proposal : proposals) {
			itinerariesToUpsert.add(proposal.detail);
			itinerariesToUpsert.addAll(proposal.getTravelItineraries());
		}

		//convert date time fields to UTC
		tz.convertDateTimes(itinerariesToUpsert, true);

		try {
			upsert itinerariesToUpsert;
		} catch (System.Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Travel_Proposals_Error_updating_proposals_segments + ex.getMessage()));
			//convert date time fields back for display
			tz.convertDateTimes(itinerariesToUpsert, false);
			return false;
		}

		//save succeeded
		return true;
	}

	//VF page Save button
	public void save() {
		//wraps save proposals and returns void so vf page can call save
		if(saveProposals()) {
			//only reinitialize if save was successful
			initialize();
		}
	}

	//VF Page Save and exit button
	public PageReference saveProposalsAndReturn() {
		if (saveProposals()) {
			return exitPage();
		}

		return null;
	}

	//VF page Cancel button
	public pageReference exitPage() {
		return new PageReference('/' + participant.id);
	}

	//VF page New Proposal Button
	public void addProposal() {
		TravelProposal proposal = new TravelProposal(participant);
		insert proposal.detail;
		proposal.detail = queryForProposal(proposal.detail.id);
		proposals.add(proposal);
	}

	//generate page title and subtitle
	public String getPageSubTitle() {
		return Label.Travel_Proposals_Page_subtitle_prefix + participant.Name + ' (' + participant.Account_MERC__r.Name + ')';
	}
	public String getPageTitle() {
		return  Schema.SObjectType.Meeting_MERC__c.fields.Name.getLabel() + ': ' + participant.Meeting_MERC__r.Name;
	}

	//return list of segment options. These options have the record type Name as the label and developerName as the Value
	public List<SelectOption> segmentOptions {
		get {
			if (segmentOptions == null) {
				segmentOptions = new List<SelectOption>();
				segmentOptions.add( new SelectOption('', ''));
				List<String> recTypes = new List<String>();
				for (Travel_Proposal_Segment_Type_MERC__c type : Travel_Proposal_Segment_Type_MERC__c.getAll().values()) {
					recTypes.add(type.Record_Type_Name_MERC__c);
				}
				System.debug(recTypes);
				for (RecordType rt : [SELECT Name, DeveloperName
				                        FROM RecordType
									   WHERE SObjectType='Travel_Itinerary_MERC__c'
									     AND DeveloperName IN :recTypes
									ORDER BY Name]) {
					segmentOptions.add( new SelectOption(rt.DeveloperName, rt.Name));
				}
			}
			return segmentOptions;
		}
		private set;
	}

	//Return the record type id for the Travel Proposal Record Type
	public static Id proposalRecordTypeId {
		get {
			if (String.isBlank(proposalRecordTypeId)) {
				proposalRecordTypeId = [SELECT Id
				                          FROM RecordType
										 WHERE DeveloperName='MERC_Travel_Proposal'
										   AND SObjectType='Travel_Itinerary_MERC__c' limit 1].Id;
			}
			return proposalRecordTypeId;
		}
		private set;
	}

	//Return ALL Travel Itinerary Record Types mapped by ID
	public static Map<Id, RecordType> itineraryRecordTypesById {
		get {
			if (itineraryRecordTypesById == null) {
				itineraryRecordTypesById = new Map<Id, RecordType>(
												[SELECT Id, DeveloperName, Name
				                              	   FROM RecordType
											      WHERE SObjectType = 'Travel_Itinerary_MERC__c']);
			}
			return itineraryRecordTypesById;
		}
		private set;
	}

	//Return ALL Travel Itinerary Record Types mapped by DeveloperName
	public static Map<String, RecordType> itineraryRecordTypesByDeveloperName {
		get {
			if (itineraryRecordTypesByDeveloperName == null) {
				itineraryRecordTypesByDeveloperName = new Map<String, RecordType>();
				for (RecordType recordType : [SELECT Id, DeveloperName, Name FROM RecordType WHERE SObjectType = 'Travel_Itinerary_MERC__c']) {
					itineraryRecordTypesByDeveloperName.put(recordType.DeveloperName, recordType);
				}
			}
			return itineraryRecordTypesByDeveloperName;
		}
		private set;
	}

	//return all Travel Itinerary Field sets
	public static Map<String, Schema.FieldSet> itineraryFieldSets {
		get {
			if (itineraryFieldSets == null) {
				itineraryFieldSets = new Map<String, Schema.FieldSet>();

				Map<String, Schema.FieldSet> allItineraryFieldSets = Schema.SObjectType.Travel_Itinerary_MERC__c.fieldSets.getMap();

				//Iterate over the segmentTypeMap to get the name of the fieldsets from the custom settings
				for (Travel_Proposal_Segment_Type_MERC__c segmentType : segmentTypeMap.values()) {
					String fieldSetName = (String) segmentType.get('Field_Set_Name_MERC__c');
					if (allItineraryFieldSets.containsKey(fieldSetName)) {
						itineraryFieldSets.put(fieldSetName, allItineraryFieldSets.get(fieldSetName));
					}
				}
				if (itineraryFieldSets.isEmpty()) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Travel_Proposals_No_Field_Sets_Defined));
					throw new TravelProposalException();
				}
			}
			return itineraryFieldSets;
		}
		private set;
	}

	//return the participant matching the passed in Id
	private Meeting_Participant_MERC__c getParticipant(String participantId) {
		return [SELECT Id,
		               Name,
		               Meeting_MERC__c,
					   Meeting_MERC__r.Name,
					   Meeting_MERC__r.Meeting_Time_Zone_MERC__c,
					   Meeting_MERC__r.Start_Time_In_Meeting_Time_Zone__c,
					   Meeting_MERC__r.End_Time_In_Meeting_Time_Zone_MERC__c,
					   Account_MERC__c,
					   Account_MERC__r.Name
                  FROM Meeting_Participant_MERC__c
				 WHERE Id = :participantId];
	}

	//Return a list of travel itineraries of record type proposal with all related travel itinerary records (Segments)
	//we do NOT retrieve cancelled Itineraries. These records are effectively deleted (users won't have delete access however)
	private List<Travel_Itinerary_MERC__c> getProposalsAndChildItineraries() {

		//build subselect query
		String subQueryString = 'SELECT';
		for (String fieldName : segmentFields) {
			subQueryString += ' ' + fieldName + ',';
		}
		subQueryString = subQueryString.removeEnd(',') + ' FROM Travel_Itineraries__r ';
		subQueryString += 'WHERE Status_MERC__c != \'Cancelled\' ';
		subQueryString += 'ORDER BY Segment_Number__c';

		//build main query
		String queryString = 'SELECT';
		for(String field : proposalFields) {
			queryString += ' ' + field + ',';
		}
		queryString += ' (' + subQueryString + ') ';
		queryString += 'FROM Travel_Itinerary_MERC__c ';
		queryString += 'WHERE Meeting_Participant_MERC__c = \'' + participant.Id + '\' ';
		queryString += 'AND RecordTypeId = \'' + proposalRecordTypeId + '\' ';
		queryString += 'AND Status_MERC__c != \'Cancelled\' ';
		queryString += 'ORDER BY Name';

		System.debug('-----------> query String ' + queryString);
		return Database.query(queryString);
	}

	//return a specific proposal. Used to ensure that autopopulate fields (e.g. name) are available
	private Travel_Itinerary_MERC__c queryForProposal(Id proposalId) {
		String queryString = 'SELECT';
		for (String field : proposalFields) {
			queryString += ' ' + field + ',';
		}
		queryString = queryString.removeEnd(',');
		queryString += ' FROM Travel_Itinerary_MERC__c WHERE Id = \'' + proposalId + '\'';

		system.debug(queryString);
		return (Travel_Itinerary_MERC__c) (Database.query(queryString).get(0));
	}

	//Required fields for time zone conversion
	private List<String> timeZoneFields = new List<String>{'Segment_End_Timezone_MERC__c', 'Segment_Begin_Timezone_MERC__c'};

	//Fields needed for the proposal records
	private Set<String> proposalFields {
		get {
			if (proposalFields == null) {
				proposalFields = new Set<String>();
				proposalFields.addAll( new List<String>{'Name', 'Meeting_Participant_MERC__r.Meeting_MERC__r.CurrencyIsoCode',
				                                        'Account_MERC__c','Meeting_Time_Zone_MERC__c', 'Status_MERC__c'});
				proposalFields.addall(timeZoneFields);
			}
			return proposalFields;
		}
		private set;
	}

	//Fields needed for the segment records
	private Set<String> segmentFields  {
		get {
			if (segmentFields == null) {
				segmentFields = new Set<String>();
				segmentFields.addAll( new List<String>{'RecordTypeId','Travel_Proposal_MERC__c','Segment_Number__c','Status_MERC__c'});
				segmentFields.addall(timeZoneFields);
				for (Schema.FieldSet fieldSet : itineraryFieldSets.values()) {
					for (Schema.FieldSetMember field : fieldSet.getFields()) {
						segmentFields.add(field.getFieldPath());
					}
				}
			}
			return segmentFields;
		}
		private set;
	}

	//Map of record Type name to the segment type. Allows for access of field sets by record type developer name
	//static so it can be accessed from inner classes
	private static Map<String, Travel_Proposal_Segment_Type_MERC__c> segmentTypeMap {
		get {
			if (segmentTypeMap == null) {
				segmentTypeMap = new Map<String, Travel_Proposal_Segment_Type_MERC__c>();
				Map<String, Travel_Proposal_Segment_Type_MERC__c> tempSegmentTypeMap = Travel_Proposal_Segment_Type_MERC__c.getAll();
				if (tempSegmentTypeMap.size() == 0) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Travel_Proposals_Custom_Settings_not_defined));
					throw new TravelProposalException();
				}

				//remap with record type names as keys
				for (Travel_Proposal_Segment_Type_MERC__c segmentType : tempSegmentTypeMap.values()) {
					segmentTypeMap.put(segmentType.Record_Type_Name_MERC__c, segmentType);
				}
			}
			return segmentTypeMap;
		}
		private set;
	}

	//Gives ability to throw an exception that can be caught at top level
	public class TravelProposalException extends Exception {}


	/************************** INNER CLASSES ******************************/
	/* TravelProposal : Models the Proposal record type MERC_Proposal on the Travel Itinerary with its children.
	                    Provides methods to manipulate segments (create, edit etc.)*/
	public class TravelProposal {
		public Travel_Itinerary_MERC__c detail { get; set; } //the proposal itinerary
		public List<Segment> segments          { get; set; } //the segments making up this proposal

		//Given a participant, create a new travel itinerary linked to the proper records,
		//initialize segments, and add a new segment to the list
		public TravelProposal(Meeting_Participant_MERC__c participant) {
			this.detail = new Travel_Itinerary_MERC__c(
			                     RecordTypeId=MERC_TravelProposalsController.proposalRecordTypeId,
								 Meeting_Participant_MERC__c = participant.id,
								 Account_MERC__c = participant.Account_MERC__c);
			this.segments = new List<Segment>();
			addSegment();
		}

		//given an existing proposal, extract the segments and add them to the segments list
		public TravelProposal(Travel_Itinerary_MERC__c proposal) {
			this.detail = proposal;
			this.segments = new List<Segment>();
			for (Travel_Itinerary_MERC__c itinerary : proposal.Travel_Itineraries__r) {
				this.segments.add(new Segment(itinerary, false));
			}
			numberSegments();
		}

		//create a new segment and add it to the segments list then ensure the segments are numbered correctly
		public void addSegment() {
			Segment segment = new Segment(this.detail, true);
			segments.add(segment);
			numberSegments();
		}

		//display segments only when the Proposal has not been cancelled
		public Boolean getDisplaySegments() {
			return this.detail.Status_MERC__c != 'Cancelled';
		}

		//iterate over the segements and number them starting from 1
		private void numberSegments() {
			Integer counter = 1;
			for (Segment segment : segments) {
				segment.detail.Segment_Number__c = counter++;
			}
		}

		//Iterate over the segments and extract the travel itinerary sObjects and return them as a list
		public List<Travel_Itinerary_MERC__c> getTravelItineraries() {
			List<Travel_Itinerary_MERC__c> itineraries = new List<Travel_Itinerary_MERC__c>();
			for (Segment segment : this.segments) {
				Travel_Itinerary_MERC__c detail = segment.getSegmentDetail();
				if (detail != null) {
					itineraries.add(detail);
				}
			}
			return itineraries;
		}
	}

	/* Segment : Models the Travel Itineraries that link to a proposal
	             Provides functionality to create new segments and appropriately map segmentTypes to record Types.
				Also provides some VF page helper methods */
	public class Segment {
		public Travel_Itinerary_MERC__c detail { get; set; }
		public String segmentType              { get; set; }

		public Segment(Travel_Itinerary_MERC__c itinerary, Boolean newSegment) {
			if (newSegment) {
				//this is a new segment, must pre-populate some values
				this.detail = new Travel_Itinerary_MERC__c(Travel_Proposal_MERC__c = itinerary.Id,
				                                           Meeting_Participant_MERC__c = itinerary.Meeting_Participant_MERC__c,
														   Account_MERC__c = itinerary.Account_MERC__c,
														   CurrencyIsoCode= itinerary.CurrencyIsoCode,
														   Status_MERC__c = 'Confirmed',
														   Segment_Begin_Timezone_MERC__c=itinerary.Meeting_Time_Zone_MERC__c,
														   Segment_End_Timezone_MERC__c=itinerary.Meeting_Time_Zone_MERC__c);
				this.segmentType = '';
			} else {
				//this isn't a new segment so just wrap it and set the segment type
				this.detail = itinerary;
				this.segmentType = MERC_TravelProposalsController.itineraryRecordTypesById.get(itinerary.RecordTypeId).DeveloperName;
			}
		}

		//return the Travel Itinerary SObject after converting the segment type to a record type and assigning
		public Travel_Itinerary_MERC__c getSegmentDetail() {
		 	// if we can't convert the segment type then it hasn't been set so we should not return the object to be saved.
			if (String.isNotBlank(segmentType) && MERC_TravelProposalsController.itineraryRecordTypesByDeveloperName.containsKey(segmentType)) {
				this.detail.RecordTypeId = MERC_TravelProposalsController.itineraryRecordTypesByDeveloperName.get(segmentType).Id;
				return this.detail;
			}
			return null;
		}

		//only display segment info if the segment is not cancelled
		public Boolean getDisplay() {
			return this.detail.Status_MERC__c != 'Cancelled';
		}

		//return the fields to be displayed based on the segment type
		public List<Schema.FieldSetMember> getSegmentFields() {
			if (segmentTypeMap.containsKey(segmentType)) {
				return itineraryFieldSets.get(segmentTypeMap.get(segmentType).Field_Set_Name_MERC__c).getFields();
			}
			return new List<Schema.FieldSetMember>();
		}
	}
}