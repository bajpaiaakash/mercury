public class MERC_ETSendEmailWrapper {
    public MERC_ETSendEmailWrapper(MERC_ETFolderedEmail email, List<Meeting_Participant_MERC__c> participants, String fromAddress, boolean deDup, boolean disableIndividualTracking, String sendTime, Datetime futureSendTime) {
        this.Email = email;
        this.Participants = participants;
        this.FromAddress = fromAddress;
        this.DeDupSubscribers = deDup;
        this.DisableIndividualTracking = disableIndividualTracking;
        this.SendTime = sendTime;
        this.FutureSendTime = futureSendTime;
    }

    public MERC_ETFolderedEmail Email { get; set; }
    public List<Meeting_Participant_MERC__c> Participants { get; set; }
    public String FromAddress { get; set; }
    public boolean DeDupSubscribers { get; set; }
    public boolean DisableIndividualTracking { get; set; }
    public String SendTime { get; set; }
    public Datetime FutureSendTime { get; set; }
}