public class ETObject
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
        public list<ETObject.EmailFolder> subfolders { get; set; }
        public list<folderedEmail> emails { get; set; }
    }

    public class CallEmailFolderResponse extends ETResponse
    {
        public list<EmailFolder> entry;
    }  
}