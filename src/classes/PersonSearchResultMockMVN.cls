/*
* PersonSearchControllerMVN
* Created By: Kai Amundsen
* Created Date: April 5, 2013
* Last Modified Date: April 5, 2013
* Description: Mock class used to store search results for person search.
*/

public without sharing class PersonSearchResultMockMVN {
	//Account Fields
	public String acctId {get; set;}
	public String lastName {get; set;}
	public String firstName {get; set;}
	public String middleName {get; set;}
	public String recordType {get; set;}

	//Address Fields
	public String addrId {get; set;}
	public String addressLine1 {get; set;}
	public String city {get; set;}
	public String state {get; set;}
	public String zipCode {get; set;}
	public String country {get; set;}

	private Account theAccount;
	private Address_GLBL__c theAddress;

	public PersonSearchResultMockMVN() {
		this(new Account(),new Address_GLBL__c());
	}

	public PersonSearchResultMockMVN(Account acct) {
		this(acct,new Address_GLBL__c());
	}

	public PersonSearchResultMockMVN(Address_GLBL__c addr) {
		this(new Account(),addr);
	}

	public PersonSearchResultMockMVN(Account acct, Address_GLBL__c addr) {
		theAccount = acct;
		theAddress = addr;

		acctId = acct.Id;
		lastName = acct.LastName;
		firstName = acct.FirstName;
		middleName = acct.Mdl_Nm_GLBL__c;
		recordType = acct.RecordTypeId;

		addrId = addr.Id;
		addressLine1 = addr.Line_1_Adrs_Txt_GLBL__c;
		city = addr.City_GLBL__c;
		state = addr.St_Cd_GLBL__c;
		zipCode = addr.Zip_Postal_Code_GLBL__c;
		country = addr.Adrs_Cntry_Cd_GLBL__c;
	}

	public Account getAccount() {
		theAccount.LastName = lastName;
		theAccount.FirstName = firstName;
		theAccount.Mdl_Nm_GLBL__c = middleName;
		return theAccount;
	}

	public Address_GLBL__c getAddress() {
		theAddress.Line_1_Adrs_Txt_GLBL__c = addressLine1;
		theAddress.City_GLBL__c = city;
		theAddress.St_Cd_GLBL__c = state;
		theAddress.Zip_Postal_Code_GLBL__c = zipCode;
		theAddress.Adrs_Cntry_Cd_GLBL__c = country;
		return theAddress;
	}

	public void setAccount(Account acct) {
		theAccount = acct;

		acctId = acct.Id;
		lastName = acct.LastName;
		firstName = acct.FirstName;
		middleName = acct.Mdl_Nm_GLBL__c;
	}

	public void setAddress(Address_GLBL__c addr) {
		theAddress = addr;

		addrId = addr.Id;
		addressLine1 = addr.Line_1_Adrs_Txt_GLBL__c;
		city = addr.City_GLBL__c;
		state = addr.St_Cd_GLBL__c;
		zipCode = addr.Zip_Postal_Code_GLBL__c;
		country = addr.Adrs_Cntry_Cd_GLBL__c;
	}
}