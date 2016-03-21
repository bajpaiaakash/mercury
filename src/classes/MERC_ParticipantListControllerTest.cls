@isTest
private class MERC_ParticipantListControllerTest
{
	static User lillyUser;
	static MERC_ParticipantListController controller;
	static List<Account> accounts;
	static Meeting_MERC__c meeting;
	static List<Meeting_Participant_MERC__c> particpants;
	static List<MERC_ParticipantListDataObject.SelectableParticipant> selectableParticipants;
	static {
		lillyUser = MERC_TestFactory.getRunningUser();
	}

	/************** INITIALIZATION OF FILTERS *******************/
	@isTest
	static void itShouldTurnAllFiltersOffByDefault()
	{
		System.runAs(lillyUser) {
			Test.startTest();
			givenAnInstantiatedParticipantListController();
			Test.stopTest();
			thenFiltersShouldBeDisabled();
		}
	}

	@isTest
	static void itShouldAllowFiltersToBeEnabledAndOtherAttributesToBeSet() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			whenAllFiltersSetToTrue();
			whenValuesSetForFilterSelections();
			whenADataObjectIsProvided();
			whenRowFuctionToInvokeIsSet();
			whenDisplayFieldSetIsSet();
			Test.stopTest();
			thenFiltersShouldBeEnabled();
			thenFilterSelectionValuesShouldBeSet();
			thenNonFilterAttributesShouldBeReturned();
		}
	}

	@isTest
	static void itShouldDoNothingWhenAskedTo() {
		//simply exercise the doNothing method.
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			thenItCanDoNothing();
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldReturnTheProperPicklistOptionsForVariousFilters() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			thenItShouldReturnAListOfParticipantRecordTypes();
			thenItShouldReturnAListOfAccountRecordTypes();
			thenItShouldReturnAListOfParticipantStatuses();
			thenItShouldReturnAListOfParticipantRegStatuses();
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldReturnAListOfStringsWhenDisplayFieldSetIsSet() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			whendisplayFieldSetIsSet();
			thengetFieldSetFieldsReturnsAListOfStringsUsingDisplayFieldset();
			Test.stopTest();

		}
	}

	@isTest
	static void itShouldCacheListOfFields() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			whenDisplayFieldSetIsSet();
			thengetFieldSetFieldsReturnsAListOfStringsUsingDisplayFieldset();
			//call method again to invoke getter once more. Should be same values
			//but execute the if fieldsToDisplay != null
			thengetFieldSetFieldsReturnsAListOfStringsUsingDisplayFieldset();
			Test.stopTest();

		}
	}

	@isTest
	static void itShouldTriggerAnUpdateToQueryStringWhenListFilterChanges() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			//turn everything on
			whenAllFiltersSetToTrue();
			whenValuesSetForFilterSelections();
			whenADataObjectIsProvided();
			whenRowFuctionToInvokeIsSet();
			whenDisplayFieldSetIsSet();
			Test.startTest();
			whenListFilterChangedIsCalled();
			Test.stopTest();
			thenTheDataObjectQueryShouldBeUpdated();

		}
	}

	/************* TABLE SORTING *******************/

	@isTest
	static void itShouldGetAndSetTheSortField() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			whendisplayFieldSetIsSet();
			Test.stopTest();
			thenSortFieldDoesNotReturnNull();
		}
	}

	@isTest
	static void itShouldSetandGetSortField() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			whenSortFieldIsSetTo('sort field');
			Test.stopTest();
			thenSortFieldReturns('sort field');
		}
	}

	@isTest
	static void itShouldReturnProperDefaultSortDirection() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			thenSortDirectionReturns('ASC');
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldSetAndGetSortDirection() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			whenSortDirectionIsSetTo('sort direction');
			Test.stopTest();
			thenSortDirectionReturns('sort direction');
		}
	}

	@isTest
	static void itShouldReturnTheOppositeSortDirectionFromASC() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			whenSortDirectionIsSetTo('ASC');
			Test.stopTest();
			thenGetOppositeSortDirectionReturns('DESC');
		}
	}

	@isTest
	static void itShouldReturnTheOppositeSortDirectionFromDESC() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			whenSortDirectionIsSetTo('DESC');
			Test.stopTest();
			thenGetOppositeSortDirectionReturns('ASC');
		}
	}

	/******************* NAVIGATION ********************/
	@isTest
	static void itShouldReturnTheCorrectRecords() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			whenParticipantsExist();
			whenDisplayFieldSetIsSet();
			Test.startTest();
			whenGetParticipantsIsCalled();
			Test.stopTest();
			thenTheProperNumberOfParticipantsAreReturned(10);
		}
	}

	@isTest
	static void itShouldAllowPageSizeToBeSet() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			whenParticipantsExist();
			whenDisplayFieldSetIsSet();
			Test.startTest();
			whenPageSizeIsSetTo(5);
			whenGetParticipantsIsCalled();
			Test.stopTest();
			thenTheProperNumberOfParticipantsAreReturned(5);
		}
	}

	@isTest
	static void itShouldReturnAListOfPageSizeOptions() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			thenGetPageSizeSelectOptionsShouldReturnCorrectOptions();
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldIndicateTheCorrectNumberOfTotalPages() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			whenParticipantsExist();
			whenDisplayFieldSetIsSet();
			whenGetParticipantsIsCalled();
			Test.startTest();
			thenGetTotalPageShouldReturn(3);
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldIndicateWhatPageOfHowManyTheUserIsOn() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			whenParticipantsExist();
			whenDisplayFieldSetIsSet();
			whenGetParticipantsIsCalled();
			Test.startTest();
			thenGetCurrentPageShouldReturn('Page 1 of 3');
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldIndicateWhenThereAreMoreRecords() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			whenParticipantsExist();
			whenDisplayFieldSetIsSet();
			whenGetParticipantsIsCalled();
			Test.startTest();
			thenGetHasNextShouldBe(true);
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldNavigateToNextPageOfRecords() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			whenParticipantsExist();
			whenDisplayFieldSetIsSet();
			whenGetParticipantsIsCalled();
			Test.startTest();
			whenNextIsCalled();
			Test.stopTest();
			thenGetCurrentPageShouldReturn('Page 2 of 3');
		}
	}

	@isTest
	static void itShouldNavigateToLastPageOfRecords() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			whenParticipantsExist();
			whenDisplayFieldSetIsSet();
			whenGetParticipantsIsCalled();
			Test.startTest();
			whenLastIsCalled();
			Test.stopTest();
			thenGetCurrentPageShouldReturn('Page 3 of 3');
			thenGetHasNextShouldBe(false);
		}
	}

	@isTest
	static void itShouldNavigateIndicateWhenThereArePriorPages() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			whenParticipantsExist();
			whenDisplayFieldSetIsSet();
			whenGetParticipantsIsCalled();
			whenNextIsCalled();
			Test.startTest();
			thenGetHasPreviousShouldBe(true);
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldNavigateToThePriorPage() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			whenParticipantsExist();
			whenDisplayFieldSetIsSet();
			whenGetParticipantsIsCalled();
			whenNextIsCalled();
			Test.startTest();
			whenPreviousIsCalled();
			Test.stopTest();
			thenGetCurrentPageShouldReturn('Page 1 of 3');
		}
	}

	@isTest
	static void itShouldNavigateToTheFirstPage() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			whenParticipantsExist();
			whenDisplayFieldSetIsSet();
			whenGetParticipantsIsCalled();
			whenLastIsCalled();
			Test.startTest();
			whenFirstIsCalled();
			Test.stopTest();
			thenGetCurrentPageShouldReturn('Page 1 of 3');
		}
	}

	@isTest
	static void itShouldSetTheDefaultRecordType() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			whenDefaultRecordTypeIsSetTo('MERC_Delegate');
			thenSelectedRecordTypeIdIsTheIdFor('MERC_Delegate');
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldSetTheDefaultAccountRecordType() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			whenDefaultAccountRecordTypeIsSetTo('HCP_GLBL');
			thenSelectedAccountRecordTypeIdIsTheIdFor('HCP_GLBL');
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldSetTheDefaultStatus() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			whenDefaultStatusIsSetTo('Invited');
			thenSelectedParticipantStatusIs('Invited');
			Test.stopTest();
		}
	}

	@isTest
	static void itShouldSetTheDefaultRegStatus() {
		System.runAs(lillyUser) {
			givenAnInstantiatedParticipantListController();
			Test.startTest();
			whenDefaultRegStatusIsSetTo('Invited');
			thenSelectedParticipantRegStatusIs('Invited');
			Test.stopTest();
		}
	}

	/**************************************/
	/*********** HELPER METHODS ***********/

	private static void givenAnInstantiatedParticipantListController() {
		controller = new MERC_ParticipantListController();
		controller.participantDataObject = new MERC_ParticipantListDataObject('Meeting_MERC__c != null', 10,null);
	}

	/****************** SET UP METHODS ****************/
	private static void whenAllFiltersSetToTrue() {
		controller.selectable = true;
		controller.recordTypeFilter = true;
		controller.searchable = true;
		controller.accountRecordTypeFilter = true;
		controller.participantStatusFilter = true;
		controller.participantRegStatusFilter = true;
	}

	private static void whenValuesSetForFilterSelections() {
		//set the values for the filter selections to strings. using variable name as value for no particular reason
		controller.selectedRecordTypeId = 'selectedRecordTypeId';
		controller.searchTerm = 'searchTerm';
		controller.selectedAccountRecordTypeId = 'selectedAccountRecordTypeId';
		controller.selectedParticipantStatus = 'selectedParticipantStatus';
		controller.selectedParticipantRegStatus = 'selectedParticipantRegStatus';
	}

	private static void whenADataObjectIsProvided() {
		// the most basic instantiation we can make of this object
		controller.participantDataObject = new MERC_ParticipantListDataObject('',10,null);
	}

	private static void whenRowFuctionToInvokeIsSet() {
		controller.rowFunctionToInvoke = 'rowFunctionToInvoke';
	}

	private static void whenDisplayFieldSetIsSet() {
		controller.displayFieldSet = 'Meeting_Group_Result_Fields_MERC';
	}

	private static void whenListFilterChangedIsCalled() {
		controller.listFilterChanged();
	}

	private static void whenSortFieldIsSetTo(String value) {
		controller.sortField = value;
	}

	private static void whenSortDirectionIsSetTo(String value) {
		controller.sortDirection = value;
	}

	private static void whenParticipantsExist() {
		accounts = MERC_TestFactory.insertAccounts(21); //create 21 so there are the pages when page size is 10
		meeting = MERC_TestFactory.insertMeetings(1)[0];
		particpants = MERC_TestFactory.insertParticipants(meeting.id, accounts);
	}

	private static void whenGetParticipantsIsCalled() {
		selectableParticipants = controller.getParticipants();
	}

	private static void whenPageSizeIsSetTo(Integer pageSize) {
		controller.pageSize = pageSize;
	}

	private static void whenNextIsCalled() {
		controller.next();
	}

	private static void whenLastIsCalled() {
		controller.last();
	}

	private static void whenPreviousIsCalled() {
		controller.previous();
	}

	private static void whenFirstIsCalled() {
		controller.first();
	}

	private static void whenDefaultRecordTypeIsSetTo(String developerName) {
		controller.defaultRecordType = developerName;
	}

	private static void whenDefaultAccountRecordTypeIsSetTo(String developerName) {
		controller.defaultAccountRecordType = developerName;
	}

	private static void whenDefaultStatusIsSetTo(String status) {
		controller.defaultStatus = status;
	}

	private static void whenDefaultRegStatusIsSetTo(String status) {
		controller.defaultRegStatus = status;
	}
	/******************* ASSERTION METHODS ************************/
	private static void thenFiltersShouldBeDisabled() {
		System.assertEquals(false, controller.selectable);
		System.assertEquals(false, controller.recordTypeFilter);
		System.assertEquals(false, controller.searchable);
		System.assertEquals(false, controller.accountRecordTypeFilter);
		System.assertEquals(false, controller.participantStatusFilter);
		System.assertEquals(false, controller.participantRegStatusFilter);
		System.assertEquals('', controller.rowFunctionToInvoke);
	}

	private static void thenFiltersShouldBeEnabled() {
		System.assertEquals(true, controller.selectable);
		System.assertEquals(true, controller.recordTypeFilter);
		System.assertEquals(true, controller.searchable);
		System.assertEquals(true, controller.accountRecordTypeFilter);
		System.assertEquals(true, controller.participantStatusFilter);
		System.assertEquals(true, controller.participantRegStatusFilter);
	}

	private static void thenFilterSelectionValuesShouldBeSet() {
		System.assertEquals('selectedRecordTypeId', controller.selectedRecordTypeId);
		System.assertEquals('searchTerm', controller.searchTerm);
		System.assertEquals('selectedAccountRecordTypeId', controller.selectedAccountRecordTypeId);
		System.assertEquals('selectedParticipantStatus', controller.selectedParticipantStatus);
		System.assertEquals('selectedParticipantRegStatus', controller.selectedParticipantRegStatus);
	}

	private static void thenNonFilterAttributesShouldBeReturned() {
		System.assertNotEquals(null, controller.participantDataObject);
		// the return value here should be a function call string. It should have parens and semi-colon on it.
		System.assertEquals('rowFunctionToInvoke();', controller.rowFunctionToInvoke);
		System.assertEquals('Meeting_Group_Result_Fields_MERC', controller.displayFieldSet);
	}

	private static void thenItCanDoNothing() {
		//exercise doNothing
		controller.doNothing();
	}

	private static void thenItShouldReturnAListOfParticipantRecordTypes() {
		//default value is inserted as first option. There should be ore than 1 option
		System.assert(controller.participantRecordTypes.size() > 1);
	}

	private static void thenItShouldReturnAListOfAccountRecordTypes() {
		//default value is inserted as first option. There should be ore than 1 option
		System.assert(controller.accountPersonRecordTypes.size() > 1);
	}

	private static void thenItShouldReturnAListOfParticipantStatuses() {
		//default value is inserted as first option. There should be ore than 1 option
		System.assert(controller.participantStatusOptions.size() > 1);
	}

	private static void thenItShouldReturnAListOfParticipantRegStatuses() {
		//default value is inserted as first option. There should be ore than 1 option
		System.assert(controller.participantRegStatusOptions.size() > 1);
	}

	private static void thengetFieldSetFieldsReturnsAListOfStringsUsingDisplayFieldset() {
		List<Schema.FieldSetMember> fields = controller.getFieldSetFields();
		System.assert(fields.size() > 0);
	}

	private static void thenTheDataObjectQueryShouldBeUpdated() {
		System.assert(controller.participantDataObject.participantQueryString.contains('Id, Account_MERC__r.isPersonAccount FROM Meeting_Participant_MERC__c WHERE'));
		System.assert(controller.participantDataObject.participantQueryString.contains('AND RecordTypeId='));
		System.assert(controller.participantDataObject.participantQueryString.contains('AND Account_MERC__r.RecordTypeId='));
		System.assert(controller.participantDataObject.participantQueryString.contains('AND Registration_Status_MERC__c='));
		System.assert(controller.participantDataObject.participantQueryString.contains('AND (Account_MERC__r.Name LIKE'));
	}

	private static void thenSortFieldDoesNotReturnNull() {
		System.assertNotEquals(null, controller.sortField);
	}

	private static void thenSortFieldReturns(String value) {
		System.assertEquals(value, controller.sortField);
	}

	private static void thenSortDirectionReturns(String value) {
		System.assertEquals(value, controller.sortDirection);
	}

	private static void thenGetOppositeSortDirectionReturns(String value) {
		System.assertEquals(value, controller.getOppositeSortDirection());
	}

	private static void thenTheProperNumberOfParticipantsAreReturned(Integer numberParticipants) {
		System.assertEquals(numberParticipants, selectableParticipants.size());
	}

	private static void thenGetTotalPageShouldReturn(Integer totalPages) {
		System.assertEquals(totalPages, controller.getTotalPages());
	}

	private static void thenGetCurrentPageShouldReturn(String currentPageString) {
		System.assertEquals(currentPageString, controller.getCurrentPage());
	}

	private static void thenGetHasNextShouldBe(Boolean hasNext) {
		System.assertEquals(hasNext, controller.getHasNext());
	}

	private static void thenGetHasPreviousShouldBe(Boolean hasNext) {
		System.assertEquals(hasNext, controller.getHasPrevious());
	}

	private static void thenGetPageSizeSelectOptionsShouldReturnCorrectOptions() {
		System.assertEquals('10', controller.getPageSizeSelectOptions()[0].getLabel());
	}

	private static void thenSelectedRecordTypeIdIsTheIdFor(String developerName) {
		RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Meeting_Participant_MERC__c' AND DeveloperName=:developerName limit 1];
		System.assertEquals(controller.selectedRecordTypeId, rt.Id);
	}

	private static void thenSelectedAccountRecordTypeIdIsTheIdFor(String developerName) {
		RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName=:developerName limit 1];
		System.assertEquals(controller.selectedAccountRecordTypeId, rt.Id);
	}

	private static void thenSelectedParticipantStatusIs(String status) {
		System.assertEquals(status, controller.selectedParticipantStatus);
	}

	private static void thenSelectedParticipantRegStatusIs(String status) {
		System.assertEquals(status, controller.selectedParticipantRegStatus);
	}
}