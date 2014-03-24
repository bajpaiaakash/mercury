global with sharing class MERC_MeetingDayManagerController extends GLBL_GenericRelatedListController {

	public Boolean hasError { get; private set; }
	public String pageMessage { get; private set; }
	public Boolean refreshHotels { get; private set; }

	public MERC_MeetingDayManagerController(ApexPages.StandardSetController controller) {
		super (
			controller, 
			'Meeting_MERC__c', //parentObjectAPIName
			'Meeting_Day_MERC__c', //childObjectAPIName 
			'Meeting_MERC__c', //parentFieldAPIName
			new List<String> {  //parentFields
				'Id', 
				'Name'
			},
			MERC_Util.getFieldSetFieldList('Meeting_Day_MERC__c', new List<String>{'Meeting_Day_Manager_Columns_MERC'}),
			'Date_MERC__c' //orderChildrenBy
		);
		this.refreshHotels = false;
	}

	public override PageReference add() {
		PageReference p = super.add();
		ensureHotelAllocationsForMeetingDays();
		return p;
	}

	public override PageReference remove() {
		PageReference p = super.remove();
		return p;
	}

	public void ensureHotelAllocationsForMeetingDays() {
		List<Meeting_Day_MERC__c> meetingDays = [SELECT ID FROM Meeting_Day_MERC__c WHERE Meeting_MERC__c = :MERC_Util.getUrlParam('id')];
		List<Hotel_Allocation_MERC__c> allocationsToInsert = new List<Hotel_Allocation_MERC__c>();
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
					allocationsToInsert.add(ha);
				}
			}
		}
		if (allocationsToInsert.size() > 0) {
			insert allocationsToInsert;
			this.refreshHotels = true;
			ensureHotelAllocationsForMeetingDays();
		}
	}

	public String getHotelSOQLQuery(String fieldString, String fromObject, String whereClause, String orderBy) {
		String soql;
		soql = 'Select '+fieldString+',Account_MERC__r.Name,(SELECT ID, Meeting_Day_MERC__c, Meeting_Day_MERC__r.Name, Booked_Rooms__c, Meeting_Vendor_MERC__c, Remaining_Rooms_MERC__c, Room_Block_Release_Date_MERC__c, Total_Rooms_in_Block_MERC__c FROM Hotel_Allocations_MERC__r ORDER BY Meeting_Day_MERC__r.Date_MERC__c) From '+fromObject+' Where Meeting_MERC__c = \''+ApexPages.currentPage().getParameters().get('id')+'\' AND RecordType.DeveloperName = \'Hotel_MERC\'';
		if (orderBy != null)
			soql = soql += ' order by '+orderBy;
		return soql;
	}

	public class HotelWrapper extends GenericSobjectWrapper {
		public List<AllocationWrapper> hotelAllocations { get; set; }
		public HotelWrapper() {
			super('Meeting_Vendor_MERC__c');
			this.hotelAllocations = new List<AllocationWrapper>();
		}
		public HotelWrapper(SObject so) {
			super('Meeting_Vendor_MERC__c', so);
			Meeting_Vendor_MERC__c vendor = (Meeting_Vendor_MERC__c)so;
			this.hotelAllocations = new List<AllocationWrapper>();
			List<Hotel_Allocation_MERC__c> allocationSObjects = vendor.Hotel_Allocations_MERC__r;
			for (Hotel_Allocation_MERC__c a : allocationSObjects) {
				this.hotelAllocations.add(new AllocationWrapper(a));
			}
		}
	}

	public class AllocationWrapper {
		public Hotel_Allocation_MERC__c hotelAllocationSObject { get; set; }
		public AllocationWrapper(Hotel_Allocation_MERC__c ha) {
			this.hotelAllocationSObject = ha;
		}
	}

	public List<HotelWrapper> hotels {
		get {
			if (hotels == null || this.refreshHotels) {
				hotels = new List<HotelWrapper>();
				List<String> fieldList = MERC_Util.getFieldSetFieldList('Meeting_Vendor_MERC__c', 'Meeting_Day_Manager_MERC');
				String fieldString = String.join(fieldList, ',');
				Integer i = 1;
				String query = getHotelSOQLQuery(fieldString, 'Meeting_Vendor_MERC__c', parentFieldAPIName+' = \''+ApexPages.currentPage().getParameters().get('id'), 'Name');
				for (Sobject s : Database.query(query)) {	
					HotelWrapper child = new HotelWrapper(s);
					child.index = i;
					hotels.add(new HotelWrapper(s));
					i++;
				}
				this.refreshHotels = false;
			}
			return hotels;
		}
		set;
	}

	public PageReference addHotel() {
		HotelWrapper newItem;
		String recordTypeId = [SELECT ID 
									FROM RecordType 
										WHERE 
											SObjectType = 'Meeting_Vendor_MERC__c' AND 
											DeveloperName = 'Hotel_MERC'].ID;
		newItem = new HotelWrapper();
		newItem.index = hotels.size()+1;
		newItem.so.put('Meeting_MERC__c',parentId);
		newItem.so.put('RecordTypeId', recordTypeId);
		insert newItem.so;
		hotels.add(newItem);
		//ensureHotelAllocationsForMeetingDays();
		return null;
	}

	public PageReference removeHotel() {
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
		delete [SELECT ID FROM Hotel_Allocation_MERC__c WHERE Meeting_Vendor_MERC__c in :childrenToDelete];
		delete childrenToDelete;
		hotels = newChildList;
		return null;
	}

	public PageReference saveHotels() {
		List<Hotel_Allocation_MERC__c> hotelAllocationsToUpdate = new List<Hotel_Allocation_MERC__c>();
		try {
			List<Sobject> hotelsToUpdate = new List<Sobject>();
			system.debug('>>> '+hotels);
			for (HotelWrapper sow : hotels) {
				system.debug('child so........ '+sow.so);
				hotelsToUpdate.add(sow.so);	
				for (AllocationWrapper aw : sow.hotelAllocations) {
					hotelAllocationsToUpdate.add(aw.hotelAllocationSObject);
				}
			}
			system.debug('>>> '+hotelsToUpdate);
			system.debug('>>> '+hotelAllocationsToUpdate);
			update hotelsToUpdate;
			update hotelAllocationsToUpdate;
			//this.refreshHotels = true;
		} catch (Exception e) {
			ApexPages.addMessages(e);
		}
		return null;
	}

	@RemoteAction
    global static List<Account> getVendors(String token) {
        List<Account> vendors = Database.query('SELECT Id, Name FROM Account WHERE RecordType.DeveloperName in (\'Vendor_GLBL\',\'Venue_GLBL\') AND Name LIKE \'%'+token+'%\'');
        return vendors;
    }

}