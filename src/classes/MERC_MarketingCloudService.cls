public with sharing class MERC_MarketingCloudService {
    public static final Integer MaxFolderDepth = 6;

    public static List<MERC_MarketingCloudClient.EmailFolder> getEmailFolders(){
        return MERC_MarketingCloudClient.getEmailFolders();
    }

    public static List<MERC_MarketingCloudClient.EmailFolder> updateForFolder(List<MERC_MarketingCloudClient.EmailFolder> emailFolders, String folderId){
        List<MERC_MarketingCloudClient.EmailFolder> foldersToCheck = emailFolders;
        Integer folderDepth = 0;
        Boolean folderFound = false;
        while(foldersToCheck.size() > 0 && folderDepth < MaxFolderDepth && !folderFound){
            folderDepth++;
            List<MERC_MarketingCloudClient.EmailFolder> nextFoldersToCheck = new List<MERC_MarketingCloudClient.EmailFolder>();
            for(MERC_MarketingCloudClient.EmailFolder emailFolder : foldersToCheck){
                if(emailFolder.Id == folderId){
                    folderFound = true;
                    emailFolder.subfolders = MERC_MarketingCloudClient.getEmailFolders(folderId);
                    emailFolder.emails = MERC_MarketingCloudClient.getEmails(folderId);
                    break;
                } else if(emailFolder.subfolders != null){
                    nextFoldersToCheck.addAll(emailFolder.subfolders);
                }
            }
            foldersToCheck = nextFoldersToCheck;
        }

        return emailFolders;
    }
}