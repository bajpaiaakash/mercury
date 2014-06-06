/**
* @author Joseph Ferraro
*
* Controller for unified interface to manage meeting days and hotels for a meeting
*/

global with sharing class MERC_MeetingDayManagerController extends GLBL_GenericRelatedListController {

	public Boolean hasError { get; private set; }
	public String pageMessage { get; private set; }
	String hotelVendorRecordTypeId = [SELECT ID FROM RecordType WHERE
																	SObjectType = 'Meeting_Vendor_MERC__c' AND
																	DeveloperName = 'Hotel_MERC'].ID;

	public MERC_MeetingDayManagerController(ApexPages.StandardSetController controller) {
		super (
			controller,
			'Meeting_MERC__c', //parentObjectAPIName
			'Meeting_Day_MERC__c', //childObjectAPIName
			'Meeting_MERC__c', //parentFieldAPIName
			new List<String> {  //parentFields
				'Id',
				'Name',
				'Start_Time_In_Meeting_Time_Zone__c',
				'End_Time_In_Meeting_Time_Zone_MERC__c',
				'Event_Country_MERC__c',
				'Date_of_Event_MERC__c'
			},
			MERC_Util.getFieldSetFieldList('Meeting_Day_MERC__c', new List<String>{'Meeting_Day_Manager_Columns_MERC'}),
			'Date_MERC__c' //orderChildrenBy
		);
	}

	public override PageReference add() {
		PageReference p = super.add();
		if (children.size() == 1) {
			Date startDateOfMeeting = (Date)parent.get('Date_of_Event_MERC__c');
			children.get(0).so.put('Date_MERC__c', startDateOfMeeting);
			children.get(0).so.put('CurrencyIsoCode', meetingCurrency);
		} else if (children.size() > 1) {
			Date prevDate = (Date)children.get(children.size()-2).so.get('Date_MERC__c');
			Date nextDate = prevDate.addDays(1);
			children.get(children.size()-1).so.put('Date_MERC__c', nextDate);
			children.get(children.size()-1).so.put('CurrencyIsoCode', meetingCurrency);
		}

		/*----- k. thornton: update to insert the new record immediately and set hotel allocations
		        otherwise the user could end up not setting up hotel blocks for meeting days -----*/
		children.get(children.size()-1).so.put('Meeting_MERC__c', parentId);
		try {
			insert children.get(children.size()-1).so;
		} catch(Exception e) {
			ApexPages.addMessages(e);
			return null;
		}
		//ensureHotelAllocationsForMeetingDays();

		return p;
	}

	public override PageReference remove() {
		Meeting_Day_MERC__c removedMeetingDay;
		List<GenericSobjectWrapper> childrenList = (recordTypeDeveloperNameParam != null) ? childrenMap.get(recordTypeDeveloperNameParam) : children;
		for (GenericSobjectWrapper sow : childrenList) {
			if (sow.hash == clientHash) {
				removedMeetingDay = (Meeting_Day_MERC__c)sow.so;
				break;
			}
		}
		PageReference p = super.remove();
		deleteReferencesToRemovedMeetingDay(removedMeetingDay);
		return p;
	}

	public override PageReference save() {
		PageReference p = super.save();
		ensureHotelAllocationsForMeetingDays();
		return p;
	}

	public List<FieldSetMember> getMeetingDayFields() {
		List<FieldSetMember> fields = new List<FieldSetMember>();
		DescribeSObjectResult meetingDayDescribe = Schema.SObjectType.Meeting_Day_MERC__c;
		for (FieldSetMember fsm : meetingDayDescribe.fieldSets.getMap().get('Meeting_Day_Manager_Columns_MERC').getFields()) {
			if (meetingDayDescribe.fields.getMap().get(fsm.getFieldPath()).getDescribe().isAccessible()) {
				fields.add(fsm);
			}
		}
		return fields;
	}

	void deleteReferencesToRemovedMeetingDay(Meeting_Day_MERC__c meetingDay) {
		for (HotelWrapper h : hotels) {
			List<AllocationWrapper> newAllocationList = new List<AllocationWrapper>();
			List<AllocationWrapper> existingHotelAllocations = h.hotelAllocations; //get current hotel allocations for each hotel
			for (AllocationWrapper aw : existingHotelAllocations) {
				if (aw.hotelAllocationSObject.Meeting_Day_MERC__c == meetingDay.Id)
					continue;
				newAllocationList.add(aw);
			}
			h.hotelAllocations = newAllocationList;
		}
	}

	public void ensureHotelAllocationsForMeetingDays() {
		List<Meeting_Day_MERC__c> meetingDays = [SELECT ID, Name FROM Meeting_Day_MERC__c WHERE Meeting_MERC__c = :parentId order by Date_MERC__c];
		for (HotelWrapper h : hotels) {
			Set<Id> meetingDayIds = new Set<Id>();
			List<AllocationWrapper> hotelAllocations = h.hotelAllocations; //get current hotel allocations for each hotel
			for (AllocationWrapper aw : hotelAllocations) {
				meetingDayIds.add(aw.hotelAllocationSObject.Meeting_Day_MERC__c); //create list of meeting day ids allocated for this hotel
			}
			for (Meeting_Day_MERC__c day : meetingDays) {
				if (!meetingDayIds.contains(day.Id)) { //if the hotel does not have an allocation for this meeting day create it
					Hotel_Allocation_MERC__c ha = new Hotel_Allocation_MERC__c();
					ha.Meeting_Day_MERC__c = day.Id;
					ha.Meeting_Vendor_MERC__c = (Id)h.so.get('Id');
					hotelAllocations.add(new AllocationWrapper(ha, day.Name));
				}
			}
		}
	}

	public String getHotelSOQLQuery(String fieldString, String fromObject, String whereClause, String orderBy) {
		String soql;
		soql = 'Select '+fieldString+',Account_MERC__r.Name,(SELECT ID, Meeting_Day_MERC__c, Meeting_Day_MERC__r.Name, Booked_Rooms__c, Meeting_Vendor_MERC__c, Remaining_Rooms_MERC__c, Room_Block_Release_Date_MERC__c, Total_Rooms_in_Block_MERC__c FROM Hotel_Allocations_MERC__r ORDER BY Meeting_Day_MERC__r.Date_MERC__c) From '+fromObject+' Where Meeting_MERC__c = \''+parentId+'\' AND RecordType.DeveloperName = \'Hotel_MERC\'';
		if (orderBy != null)
			soql = soql += ' order by '+orderBy;
		return soql;
	}

	public class HotelWrapper extends GenericSobjectWrapper {
		public String hotelName { get; set; }
		public List<AllocationWrapper> hotelAllocations { get; set; }
		public HotelWrapper(String meetingCurrency) {
			super('Meeting_Vendor_MERC__c');
			this.so.put('CurrencyIsoCode', meetingCurrency);
			this.hotelAllocations = new List<AllocationWrapper>();
		}
		public HotelWrapper(SObject so, String meetingCurrency) {
			super('Meeting_Vendor_MERC__c', so);
			Meeting_Vendor_MERC__c vendor = (Meeting_Vendor_MERC__c)so;
			this.so.put('CurrencyIsoCode', meetingCurrency);
			this.hotelName = vendor.Account_MERC__r.Name;
			this.hotelAllocations = new List<AllocationWrapper>();
			List<Hotel_Allocation_MERC__c> allocationSObjects = vendor.Hotel_Allocations_MERC__r;
			for (Hotel_Allocation_MERC__c a : allocationSObjects) {
				AllocationWrapper aw = new AllocationWrapper(a);
				aw.hotelAllocationSObject.put('CurrencyIsoCode', meetingCurrency);
				this.hotelAllocations.add(aw);
			}
		}
	}

	public class AllocationWrapper {
		public String meetingDayName { get; set; }
		public Hotel_Allocation_MERC__c hotelAllocationSObject { get; set; }
		public AllocationWrapper(Hotel_Allocation_MERC__c ha) {
			this.hotelAllocationSObject = ha;
			this.meetingDayName = ha.Meeting_Day_MERC__r.Name;
		}
		public AllocationWrapper(Hotel_Allocation_MERC__c ha, String dayName) {
			this.hotelAllocationSObject = ha;
			this.meetingDayName = dayName;
		}
	}

	public List<HotelWrapper> hotels {
		get {
			if (hotels == null) {
				hotels = new List<HotelWrapper>();
				List<String> fieldList = MERC_Util.getFieldSetFieldList('Meeting_Vendor_MERC__c', 'Meeting_Day_Manager_MERC');
				String fieldString = String.join(fieldList, ',');
				Integer i = 1;
				String query = getHotelSOQLQuery(fieldString, 'Meeting_Vendor_MERC__c', parentFieldAPIName+' = \''+parentId, 'Name');
				for (Sobject s : Database.query(query)) {
					HotelWrapper child = new HotelWrapper(s, meetingCurrency);
					child.index = i;
					hotels.add(new HotelWrapper(s, meetingCurrency));
					i++;
				}
			}
			return hotels;
		}
		set;
	}

	public PageReference addHotel() {
		Savepoint sp = Database.setSavepoint();
		HotelWrapper newItem;
		newItem = new HotelWrapper(meetingCurrency);
		newItem.index = hotels.size()+1;
		newItem.so.put('Meeting_MERC__c',parentId);
		newItem.so.put('RecordTypeId', hotelVendorRecordTypeId);
		/*----- k. thornton: we don't want to insert the hotel until there is an account selected -----*/
		//try {
		//	insert newItem.so;
		//} catch(Exception e) {
		//	Database.rollback(sp);
		//	ApexPages.addMessages(e);
		//	return null;
		//}
		hotels.add(newItem);
		//ensureHotelAllocationsForMeetingDays();
		return null;
	}

	public PageReference removeHotel() {
		Savepoint sp = Database.setSavepoint();
		List<HotelWrapper> newChildList = new List<HotelWrapper>();
		List<Sobject> childrenToDelete = new List<Sobject>();
		List<HotelWrapper> childrenList;
		childrenList = hotels;
		for (HotelWrapper sow : childrenList) {
			if (sow.hash != clientHash) {
				newChildList.add(sow);
			}
			if (sow.hash == clientHash && sow.so.ID != null) {
				childrenToDelete.add(sow.so);
			}
		}
		try {
			delete [SELECT ID FROM Hotel_Allocation_MERC__c WHERE Meeting_Vendor_MERC__c in :childrenToDelete];
			delete childrenToDelete;
			hotels = newChildList;
		} catch(Exception e) {
			Database.rollback(sp);
			ApexPages.addMessages(e);
		}
		return null;
	}

	public PageReference saveHotels() {
		for (HotelWrapper sow : hotels) {
			if (sow.so.get('Account_MERC__c') == null || sow.so.get('Account_MERC__c') == '') {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify an Account for each hotel.'));
				return null;
			}
		}

		Savepoint sp = Database.setSavepoint();
		List<Hotel_Allocation_MERC__c> hotelAllocationsToInsert = new List<Hotel_Allocation_MERC__c>();
		List<Hotel_Allocation_MERC__c> hotelAllocationsToUpdate = new List<Hotel_Allocation_MERC__c>();
		try {
			List<Meeting_Vendor_MERC__c> hotelsToUpdate = new List<Meeting_Vendor_MERC__c>();
			system.debug('>>> '+hotels);
			for (HotelWrapper sow : hotels) {
				system.debug('child so........ '+sow.so);
				hotelsToUpdate.add((Meeting_Vendor_MERC__c)sow.so);
				for (AllocationWrapper aw : sow.hotelAllocations) {
					if (aw.hotelAllocationSObject.Id == null) {
						hotelAllocationsToInsert.add(aw.hotelAllocationSObject);
					} else {
						hotelAllocationsToUpdate.add(aw.hotelAllocationSObject);
					}
				}
			}
			system.debug('>>> '+hotelsToUpdate);
			upsert hotelsToUpdate;

			system.debug('>>> '+hotelAllocationsToUpdate);
			insert hotelAllocationsToInsert;
			update hotelAllocationsToUpdate;
		} catch (Exception e) {
			Database.rollback(sp);
			ApexPages.addMessages(e);
		}
		ensureHotelAllocationsForMeetingDays();
		return null;
	}

	@RemoteAction
    global static List<Account> getVendors(String token, String country) {
        String soqlQuery = 'SELECT Id, Name, Primary_Addr_City_GLBL__c, Primary_Addr_Line1_GLBL__c, Primary_Addr_Line2_GLBL__c, Primary_Address_Country_GLBL__c, Primary_Pstl_Cd_Extnsn_GLBL__c FROM Account WHERE RecordType.DeveloperName in (\'Vendor_GLBL\',\'Venue_GLBL\') AND Name LIKE \''+token+'%\' AND Primary_Address_Country_GLBL__c = \''+country+'\' order by Name Limit 100';
        System.debug(soqlQuery);
        List<Account> vendors = Database.query(soqlQuery);
        return vendors;
    }

}