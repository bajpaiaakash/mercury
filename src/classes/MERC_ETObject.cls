public class MERC_ETObject
{
    public virtual class ETEntry
    {
        public string id { get; set; }
        public string name { get; set; }
        public string description;
    }

    public virtual class ETResponse
    {
        public integer startIndex;
        public integer itemsPerPage;
        public integer totalResults;
    }
    
    public class EmailFolder extends ETEntry
    {
        public string type;
        public string lastUpdated;
        public string createdBy;
        public string parentId;
        public string iconType;
        public List<MERC_ETObject.EmailFolder> subfolders { get; set; }
        public List<MERC_ETFolderedEmail> emails { get; set; }
    }

    public class CallEmailFolderResponse extends ETResponse
    {
        public List<EmailFolder> entry;
    } 

    public class EntryType extends ETEntry
    {

    }

    public class SendClassification extends ETEntry
    {
        public String key;
        public Boolean honorListLevelOptOut;
        public String senderProfileId;
        public String deliveryProfileId;
        public EntryType classificationType;
    }

    public class SendClassificationResponse extends ETResponse
    {
        public List<SendClassification> entry;
    }
    
    public class SenderProfile extends ETEntry
    {
        public String key;
        public String profileName;
        public String fromEmail;
        public String fromName;
    }

    public class SenderProfileResponse extends ETResponse
    {
        public List<SenderProfile> entry;
    }
}