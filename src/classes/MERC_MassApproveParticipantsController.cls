/**
* @author Kyle Thornton
*
* Controller for the MERC_MassApproveParticipants page. There are two inner classes to help organize the structure
* of the page. First there is "SelectableParticipant" which simply wraps a particpant with a boolean. Next there is
* the "ParticipantGroup" class which contains a list of SelectableParticipant objects and methods to update the status
* of each participant contained in the list that has been selected.
*
* There are four groups 1. Pending Approval 2. Approved 3. Rejected and 4. Invited. each group is lazy loaded and can be forced into
* a refresh by calling refreshTables() which will null each object out and force them to reload.
*
* updateSingleParticipant() uses activeparticipantId and activeparticipantstatus values to update a single meeting
* participant status.
*
* Finally, there are two public variables with getters for use on the visualforce page: 1. meeting 2. statusoptions
*/
public with sharing class MERC_MassApproveParticipantsController {

    /*----- variables set by the updateSingleParticipant actionFunction on MERC_MassApproveParticipants.page -----*/
    public String activeParticipantId     { get; set; }
    public String activeParticipantStatus { get; set; }

    private final String theMeetingId;

    public MERC_MassApproveParticipantsController(ApexPages.StandardSetController stdSetController) {
        theMeetingId = ApexPages.currentPage().getParameters().get('id');
    }

    public Meeting_MERC__c meeting {
        get {
            if (meeting == null) {
                meeting = [Select Id, Name From Meeting_MERC__c Where Id = :theMeetingId];
            }
            return meeting;
        }
        private set;
    }

    public List<SelectOption> statusOptions
    {
        get
        {
            if (statusOptions == null)
            {
                statusOptions = new List<SelectOption>{
                    new SelectOption('Approved', 'Approved'),
                    new SelectOption('Rejected', 'Rejected')
                };
            }
            return statusOptions;
        }
        private set;
    }

    public void refreshTables()
    {
        participantsPendingApproval = null;
        participantsApproved        = null;
        participantsRejected        = null;
        participantsInvited         = null;
    }

    /*----- called from an action function, updates a single record -----*/
    public void updateSingleParticipant()
    {
        try
        {
            update new Meeting_Participant_MERC__c(id=activeParticipantId, Status_MERC__c=activeParticipantStatus);
        }
        catch (Exception ex)
        {
            System.debug('\n\n\nError is:\n' + ex + '\n\n\n');
            ApexPages.addMessages(ex);
        }
    }

    /*----- getters for the various ParticipantGroup records that represent each tab -----*/
    public ParticipantGroup participantsPendingApproval
    {
        get
        {
            if (participantsPendingApproval == null)
            {
                participantsPendingApproval = new ParticipantGroup('Pending Approval', theMeetingId);
            }
            return participantsPendingApproval;
        }
        set;
    }
    public ParticipantGroup participantsApproved
    {
        get
        {
            if (participantsApproved == null)
            {
                participantsApproved = new ParticipantGroup('Approved', theMeetingId);
            }
            return participantsApproved;
        }
        set;
    }
    public ParticipantGroup participantsRejected
    {
        get
        {
            if (participantsRejected == null)
            {
                participantsRejected = new ParticipantGroup('Rejected', theMeetingId);
            }
            return participantsRejected;
        }
        set;
    }
    public ParticipantGroup participantsInvited
    {
        get
        {
            if (participantsInvited == null)
            {
                participantsInvited = new ParticipantGroup('Invited', theMeetingId);
            }
            return participantsInvited;
        }
        set;
    }
    /*===== END GETTERS FOR PARTICIPANTGROUPS =====*/

    /*----- Helper method to build a query string from a fieldset, perform a query, wrap the
            results in a SelectableParticpant class, add to a list and return the list -----*/
    private static List<SelectableParticipant> participantsByStatus(String status, String meetingId)
    {
        List<SelectableParticipant> participants = new List<SelectableParticipant>();
        String soqlQuery = 'SELECT Id, Status_MERC__c';
        for (Schema.FieldSetMember fsm : Schema.SObjectType.Meeting_Participant_MERC__c.FieldSets.Mass_Approve_Meeting_Participants_MERC.getFields())
        {
            if (fsm.getFieldPath() != 'Id' && fsm.getFieldPath() != 'Status_MERC__c')
            {
                soqlQuery += ', ' + fsm.getFieldPath();
            }
        }
        soqlQuery += ' FROM Meeting_Participant_MERC__c WHERE Status_MERC__c=\''+status+'\' AND Meeting_MERC__c=\''+meetingId+'\'';
        for (Meeting_Participant_MERC__c mp : Database.query(soqlQuery))
        {
            participants.add( new SelectableParticipant(mp));
        }
        return participants;
    }

    /*----- A ParticipantGroup represents a tab on the MERC_MassApproveParticipants page.
            the approve/reject actions are isolated to each group of particpants and call to
            the update selected method to find all selected records, unwrap them, update their
            status appropriately and update the database. -----*/
    public class ParticipantGroup
    {
        public List<SelectableParticipant> participants { get; private set; }

        public ParticipantGroup (String status, String meetingId)
        {
            this.participants = MERC_MassApproveParticipantsController.participantsByStatus(status, meetingId);
        }

        public PageReference approveSelected()
        {
            return updateSelected('Approved');
        }

        public PageReference rejectSelected()
        {
            return updateSelected('Rejected');
        }

        public PageReference inviteSelected()
        {
            return updateSelected('Invited');
        }

        private PageReference updateSelected(String status)
        {
            List<Meeting_Participant_MERC__c> participantsToUpdate = new List<Meeting_Participant_MERC__c>();
            for (SelectableParticipant sp : participants)
            {
                if (sp.selected)
                {
                    sp.detail.Status_MERC__c = status;
                    participantsToUpdate.add(sp.detail);
                }
            }
            try
            {
                update participantsToUpdate;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, participantsToUpdate.size() + ' participants updated with status: ' + status +'.'));
            }
            catch (Exception ex)
            {
                System.debug('\n\n\nError is:\n' + ex + '\n\n\n');
                ApexPages.addMessages(ex);
            }
            return null;
        }
    }

    /*----- A SelectableParticipant is simple a Meeting Particpant wrapped with a select checkbox
            to allow for selecting of the record in the rendered table -----*/
    public class SelectableParticipant
    {
        public Meeting_Participant_MERC__c detail   { get; set; }
        public Boolean                     selected { get; set; }

        public SelectableParticipant(Meeting_Participant_MERC__c participant)
        {
            this.detail   = participant;
            this.selected = false;
        }
    }
}