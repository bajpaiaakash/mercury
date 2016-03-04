/*
* MERC_EmailLocator
* Description : Handles finding emails
* Authors: David Helmer
*/
public with sharing class MERC_EmailLocator {
    public static MERC_MarketingCloudClient.FolderedEmail findEmailByPath(String folderPath, String emailName){
        String[] folderNames = folderPath.split('/');
        MERC_MarketingCloudClient.EmailFolder parentFolder = null;

        for(String folderName : folderNames){
            parentFolder = findEmailFolderInFolder(parentFolder, folderName);
        }

        return findEmailInFolder(parentFolder, emailName);
    }

    public static MERC_MarketingCloudClient.EmailFolder findEmailFolderInFolder(MERC_MarketingCloudClient.EmailFolder parentFolder, String folderName){
        MERC_MarketingCloudClient.EmailFolder foundFolder = null;
        List<MERC_MarketingCloudClient.EmailFolder> emailFolders = getEmailFolders(parentFolder);

        for(MERC_MarketingCloudClient.EmailFolder emailFolder : emailFolders){
            if(emailFolder.Name == folderName){
                foundFolder = emailFolder;
                break;
            }
        }

        if(foundFolder == null){
            throw new FolderNotFoundException('Could not find folder (' + folderName + ') in parentFolder (' + getParentFolderName(parentFolder) + ')');
        }
        return foundFolder;
    }

    private static List<MERC_MarketingCloudClient.EmailFolder> getEmailFolders(MERC_MarketingCloudClient.EmailFolder parentFolder){
        if(parentFolder != null){
            return MERC_MarketingCloudClient.getEmailFolders(parentFolder.Id);
        } else {
            return MERC_MarketingCloudClient.getEmailFolders();
        }
    }

    private static String getParentFolderName(MERC_MarketingCloudClient.EmailFolder parentFolder){
        String parentFolderName = 'null';
        if(parentFolder != null){
            parentFolderName = parentFolder.Id + ':' + parentFolder.Name;
        }
        return parentFolderName;
    }

    public static MERC_MarketingCloudClient.FolderedEmail findEmailInFolder(MERC_MarketingCloudClient.EmailFolder parentFolder, String emailName){
        MERC_MarketingCloudClient.FolderedEmail foundEmail = null;
        if(parentFolder == null){
            throw new FolderNotFoundException('Could not find email (' + emailName + ') because parentFolder is null');
        }
        List<MERC_MarketingCloudClient.FolderedEmail> emails = MERC_MarketingCloudClient.getEmails(parentFolder.Id);

        for(MERC_MarketingCloudClient.FolderedEmail email : emails){
            System.debug(email.Name + ' == ' + emailName);
            if(email.Name == emailName){
                foundEmail = email;
                break;
            }
        }

        if(foundEmail == null){
            throw new EmailNotFoundException('Could not find email (' + emailName + ') in parentFolder (' + getParentFolderName(parentFolder) + ')');
        }
        return foundEmail;
    }

    public class EmailNotFoundException extends Exception {}
    public class FolderNotFoundException extends Exception {}
}