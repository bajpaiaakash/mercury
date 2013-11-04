public with sharing class MERC_DailyAttendanceController {
	
	public String selectedMeetingDayId { get; set; }
	public Boolean refreshParticipants { get; set; }

	public MERC_DailyAttendanceController(ApexPages.StandardSetController c) {
		this.selectedMeetingDayId = meetingDays.get(0).Id;
		this.refreshParticipants = false;
	}

	public Meeting_MERC__c meeting {
		get {
			if (meeting == null) {
				meeting = [Select Id, Name From Meeting_MERC__c Where Id = :ApexPages.currentPage().getParameters().get('id')];
			}
			return meeting;
		}
		private set;
	}

	public List<Meeting_Day_MERC__c> meetingDays {
		get {
			if (meetingDays == null) {
				meetingDays = [Select Id, Date_MERC__c From Meeting_Day_MERC__c Where Meeting_MERC__c = :meeting.Id order by Date_MERC__c];
			}
			return meetingDays;
		}
		private set;
	}

	public PageReference changeDay() {
		this.refreshParticipants = true;
		return null;
	}

	public PageReference updateAttendanceForSelectedMeetingDay() {
		List<Daily_Attendance_TOV_MERC__c> existingTOVs = [Select ID, Meeting_Participant_MERC__r.Account_MERC__c From Daily_Attendance_TOV_MERC__c WHERE Meeting_Day_MERC__c = :selectedMeetingDayId];
		delete existingTOVs;

		List<Daily_Attendance_TOV_MERC__c> tovsToInsert = new List<Daily_Attendance_TOV_MERC__c>();
		for (ParticipantWrapper p : participants) {
			if (p.selected) {
				Daily_Attendance_TOV_MERC__c newTov = new Daily_Attendance_TOV_MERC__c();
				newTov.Meeting_Day_MERC__c = selectedMeetingDayId;
				newTov.Meeting_Participant_MERC__c = p.participant.Id;
				tovsToInsert.add(newTov);
			}
		}
		insert tovsToInsert;
		return null;
	}

	private Set<Id> accountIdsWithTOVForSelectedDay {
		get {
			accountIdsWithTOVForSelectedDay = new Set<Id>();
			for (Daily_Attendance_TOV_MERC__c tov : [Select ID, Meeting_Participant_MERC__r.Account_MERC__c From Daily_Attendance_TOV_MERC__c WHERE Meeting_Day_MERC__c = :selectedMeetingDayId]) {
				accountIdsWithTOVForSelectedDay.add(tov.Meeting_Participant_MERC__r.Account_MERC__c);
			}
			return accountIdsWithTOVForSelectedDay;
		}
		set;
	}

	public List<SelectOption> getMeetingDayOptions() {
		List<SelectOption> options = new List<SelectOption>();
		for (Meeting_Day_MERC__c m : meetingDays) {
			Datetime myDatetime = Datetime.newInstance(m.Date_MERC__c, Time.newInstance(12, 0, 0, 0));
			String sFormattedDate = myDatetime.format('MMMM d,  yyyy');
			options.add(new SelectOption((String)m.Id, sFormattedDate));
		}
		return options;
	} 

	public List<ParticipantWrapper> participants {
		get {
			if (participants == null || refreshParticipants) {
				participants = new List<ParticipantWrapper>();
				for (Meeting_Participant_MERC__c p : [Select Id, Account_MERC__c, Account_MERC__r.NAme From Meeting_Participant_MERC__c Where Meeting_MERC__c = :meeting.Id]) {
					Boolean isSelected = accountIdsWithTOVForSelectedDay.contains(p.Account_MERC__c);
					participants.add(new ParticipantWrapper(p, isSelected));
				}
			}
			if (this.refreshParticipants)
				this.refreshParticipants = false;

			return participants;
		}
		set;
	}

	public class ParticipantWrapper {
		public Boolean selected { get; set; }
		public Meeting_Participant_MERC__c participant { get; set; }
		public ParticipantWrapper(Meeting_Participant_MERC__c p, Boolean s) {
			this.participant = p;
			this.selected = s;
		}
	} 
}