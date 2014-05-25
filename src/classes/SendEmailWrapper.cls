public class SendEmailWrapper {
    public SendEmailWrapper(FolderedEmail email, List<Meeting_Participant_MERC__c> participants, String fromAddress, boolean deDup, boolean disableIndividualTracking, String sendTime, Datetime futureSendTime) {
        this.Email = email;
        this.Participants = participants;
        this.FromAddress = fromAddress;
        this.DeDupSubscribers = deDup;
        this.DisableIndividualTracking = disableIndividualTracking;
        this.SendTime = sendTime;
        this.FutureSendTime = futureSendTime;
    }

    public FolderedEmail Email { get; set; }
    public List<Meeting_Participant_MERC__c> Participants { get; set; }
    public String FromAddress { get; set; }
    public boolean DeDupSubscribers { get; set; }
    public boolean DisableIndividualTracking { get; set; }
    public String SendTime { get; set; }
    public Datetime FutureSendTime { get; set; }
}