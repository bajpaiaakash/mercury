/*
	MERC_ParticipantListController
	Author : Kyle Thornton (Mavens Consulting)
	Date : March 2, 2016
	Description: This class is the controller for the MERC_ParticipantList component.
				 The component is used to display meeting participants based on a
				 MERC_ParticipantListDataObject that is passed into it which includes
				 a base where clause telling this controller how to filter the list
				 initially.

				 The component is configurable to allow for selection of records using
				 a wrapper class, clicking on a row to choose and individual row and
				 perform an action, or including various defined filters.
 */

public with sharing class MERC_ParticipantListController {

	public MERC_ParticipantListDataObject participantDataObject { get; set; }

	private final Integer DEFAULT_LIST_SIZE = 10;

	/*****
	   ATTRIBUTE VALUES
	   Everything in this section maps to an attribute for the component
	   Not all attributes are required and are defaulted if not provided
	 *****/

	// Should the presented participants be selectable?
	public Boolean selectable {
		get { return selectable == null ? false : selectable; }//default to false
		set;
	}

	// What javascript function should be called when a user clicks on a row in the table?
	public String rowFunctionToInvoke {
		//append a calling action to the method name. If 'callMe' is the value passed in then 'callMe();' will be rendered
		get { return String.isNotBlank(rowFunctionToInvoke) ? rowFunctionToInvoke + '();' : ''; }
		set;
	}

	// Can the user filter the list by Record Type?
	public Boolean recordTypeFilter {
		get { return recordTypeFilter == null ? false : recordTypeFilter; }//default to false
		set;
	}
	public String selectedRecordTypeId { get; set; }


	// Can the user search on account name and meeting participant name
	public Boolean searchable {
		get { return searchable == null ? false : searchable; }//default to false
		set;
	}
	public String searchTerm { get; set; }

	// set the fields which sould be displayed. Can either be a string of comma separated field names or a fieldset
	public String displayFields { get; set; }
	public String displayFieldSet { get; set; }

	// Can the user filter the list by Participant Account Record Type?
	public Boolean accountRecordTypeFilter {
		get { return accountRecordTypeFilter == null ? false : accountRecordTypeFilter; }//default to false
		set;
	}
	public String selectedAccountRecordTypeId { get; set; }

	// can the user filter the list by meeting participant status?
	public Boolean participantRegStatusFilter {
		get { return participantRegStatusFilter == null ? false : participantRegStatusFilter; }//default to false
		set;
	}
	public String selectedParticipantRegStatus { get; set; }

	/*****   END ATTRIBUTE VALUES  *****/

	// null, used to invoke rerender on component
	public void doNothing() {}

	// Return a list of participant record types
	public List<SelectOption> participantRecordTypes
	{
		get {
			List<SelectOption> participantRecordTypes = new List<SelectOption>();
			participantRecordTypes.add(new SelectOption('', 'All Record Types'));
			for (RecordType recordType : [SELECT Id, Name FROM RecordType WHERE SObjectType='Meeting_Participant_MERC__c']) {
				participantRecordTypes.add(new SelectOption(recordType.Id, recordType.Name));
			}
			return participantRecordTypes;
		}
	}

	// Return a list of participant record types
	public List<SelectOption> accountPersonRecordTypes
	{
		get {
			List<SelectOption> accountPersonRecordTypes = new List<SelectOption>();
			accountPersonRecordTypes.add(new SelectOption('', 'All Account Types'));

			for (RecordType recordType : [SELECT Id, Name
				                            FROM RecordType
				                           WHERE SObjectType='Account'
				                             AND isPersonType=true
				                             AND DeveloperName!='PersonAccount']) {
				accountPersonRecordTypes.add(new SelectOption(recordType.Id, recordType.Name));
			}
			return accountPersonRecordTypes;
		}
	}

	public List<SelectOption> participantRegStatusOptions {
		get {
			List<SelectOption> participantRegStatusOptions = new List<SelectOption>();
			participantRegStatusOptions.add(new SelectOption('', 'All Registration Statuses'));

			Schema.DescribeFieldResult dfr = Meeting_Participant_MERC__c.Status_MERC__c.getDescribe();

			for (Schema.PicklistEntry picklistEntry : dfr.getPicklistValues()) {
				participantRegStatusOptions.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getValue()));
			}

			return participantRegStatusOptions;
		}
	}

	public List<String> fieldsToDisplay {
		get {
			if (fieldsToDisplay != null) {
				return fieldsToDisplay;
			}
			fieldsToDisplay = new List<String>();
			// figure out whether to use fieldset or field list
			if (String.isNotBlank(displayFields) && String.isNotBlank(displayFieldSet)) {
				throw new MERC_Exception('Both \'fieldsList\' and \'fieldSet\' attributes cannot be defined');
			} else if (String.isBlank(displayFields) && String.isBlank(displayFieldSet)) {
				throw new MERC_Exception('One of \'fieldsList\' or \'fieldsSet\' attributes must be defined');
			} else if (String.isNotBlank(displayFields)) {
				// split the string up at each comma and add resulitng strings to the set
				fieldsToDisplay = displayFields.split(',');
			} else {
				// retrieve the field set and iterate over the fields, add them to the set
				for (Schema.FieldSetMember fsm : Schema.SObjectType.Meeting_Participant_MERC__c.fieldSets.getMap().get(displayFieldSet).getFields()) {
					fieldsToDisplay.add(fsm.getFieldPath());
				}
			}

			return fieldsToDisplay;
		}
		private set;
	}

	public void listFilterChanged() {
		// A filter changed so update the query string and requery
		participantDataObject.queryParticipants(getQueryString());
	}

	/***** BEGIN PAGINATION METHODS *****/
	//get page size from the participantDataObject and set it when chages are made
	public Integer pageSize {
		get {
			return participantDataObject.pageSize;
		}
		set {
			participantDataObject.pageSize = value;
		}
	}

	// page size select options should come from the data object
	public List<SelectOption> getPageSizeSelectOptions() {
		List<SelectOption> options =  new List<SelectOption>();
		for (Integer sizeOption : participantDataObject.pageSizeOptions) {
			String optionVal = String.valueOf(sizeOption);
			options.add(new SelectOption(optionVal, optionVal));
		}
		return options;
	}

	// navigate to first page of results
	public void first() {
		participantDataObject.setController.first();
	}

	// previous page of results exists?
	public Boolean getHasPrevious() {
		return participantDataObject.setController.getHasPrevious();
	}

	// navigate to previous page of results
	public void previous() {
		participantDataObject.setController.previous();
	}

	// next page of results exists?
	public Boolean getHasNext() {
		return participantDataObject.setController.gethasNext();
	}

	// navigate to the next page of results
	public void next() {
		participantDataObject.setController.next();
	}

	// navigate to the last page of results
	public void last() {
		participantDataObject.setController.last();
	}

	// return a string in the format 'Page x of y'
	public String getCurrentPage() {
		return 'Page ' + String.valueOf(participantDataObject.setController.getPageNumber())
		       + ' of ' + String.valueOf(getTotalPages());
	}

	// determine the total number of pages based on the result set size and current page size
	public Integer getTotalPages() {
		Decimal pageCount = Math.ceil(Decimal.valueOf(participantDataObject.setController.getResultSize()) / Decimal.valueOf(pageSize));
		return Integer.valueOf(pageCount);
	}
	/****** END PAGINATION METHODS ******/

	// get the list of participants and wrap them in case they are selectable
	public List<MERC_ParticipantListDataObject.SelectableParticipant> getParticipants() {
		//if the participantQueryString is empty, initialize it before getting records
		if (String.isBlank(participantDataObject.participantQueryString)) {
			participantDataObject.queryParticipants(getQueryString());
		}
		return participantDataObject.getRecords();
	}

	// build query string based on fieldsToDisplay, where clause and filters
	// and return it to the caller
	private String getQueryString() {
		String query = 'SELECT ';
		for (String fieldName : fieldsToDisplay) {
			query += fieldName + ', ';
		}

		// include isPersonAccount so exception isn't thrown when page block table renders
		query += 'Id, Account_MERC__r.isPersonAccount FROM Meeting_Participant_MERC__c WHERE ('
		      + participantDataObject.baseWhereClause.trim() + ')';

		// filter by record type if set
		if (recordTypeFilter && String.isNotBlank(selectedRecordTypeId)) {
			query += ' AND RecordTypeId=\'' + selectedRecordTypeId + '\'';
		}

		if (accountRecordTypeFilter && String.isNotBlank(selectedAccountRecordTypeId)) {
			query += ' AND Account_MERC__r.RecordTypeId=\'' + selectedAccountRecordTypeId + '\'';
		}

		if (participantRegStatusFilter && String.isNotBlank(selectedParticipantRegStatus)) {
			query += ' AND Registration_Status__c=\'' + selectedParticipantRegStatus + '\'';
		}

		// if a search term has been added include it. This performs a wild card search against name and account. Users
		// can add a wildcard to the middle of the search term using "*". e.g. av*Consult will match Mavens Consulting
		if (searchable && String.isNotBlank(searchTerm)) {
			String modifiedSearchTerm = searchTerm.replaceAll('\\*', '%');
			modifiedSearchTerm = String.escapeSingleQuotes(modifiedSearchTerm);

			query += ' AND (Account_MERC__r.Name LIKE \'%' + modifiedSearchTerm + '%\' OR Name LIKE \'%' + modifiedSearchTerm + '%\')';
		}

		return query;
	}
}