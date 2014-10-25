/*
*  Classname : Iriss_UserSearchController
*   Created By: Deloitte USI    
*   Created Date: 25-Mar-2014
*   Description: This class is used in Iriss_UserSearchPage.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/

public with sharing class IRIS_UserSearchController{

    public List<UserWrapper> lstUserWrapp{set;get;}
    public transient String selectedUserIds{set;get;}
    public transient String selectedUserEmail{set;get;}
    public transient String selectedUserNames{set;get;}
    
    public IRIS_UserSearchController()
    {
        selectedUserIds = apexpages.currentpage().getparameters().get('userIds');
        populateUserWrapper();
    }
    
    /* 
     * Method name : populateUserWrapper
     * Description : This method is used to populate list of users from wrapper class.
     * Param - No parameter 
     * Returns :  null
    */
    
    private void populateUserWrapper(){
        List<User> lstUser = [Select Name, Email from User order by name limit :Limits.getLimitQueryRows()];
        if(lstUser != null && lstUser.size()>0){
            lstUserWrapp = new List<UserWrapper>();
                for(User Usr : lstUser){
                if(String.isNotBlank(selectedUserIds) && selectedUserIds.containsIgnoreCase(Usr.id)){
                    lstUserWrapp.add(new UserWrapper(Usr,true));
                }
                else{
                    lstUserWrapp.add(new UserWrapper(Usr,false));
                }
            }
        }
    }
    
    /* 
     * Method name : saveResponse
     * Description : This method is used to save the user details.
     * Param - No parameter 
     * Returns :  null
    */
    
    public void saveResponse(){
        selectedUserIds = '';
        selectedUserNames = '';
        selectedUserEmail = '';
        for(UserWrapper usrWrap : lstUserWrapp){
            if(usrWrap.isSelected == true){
                selectedUserIds += usrWrap.oUser.id + ';' ;
                selectedUserNames += usrWrap.oUser.Name+ ';' ;
                selectedUserEmail += usrWrap.oUser.Email + ';' ;
            }
        }
    }
    
    /*
    *  Classname : UserWrapper
    *  Description: This class is used to store the users which are selected. 
    */
    
    public class UserWrapper{
        public User oUser{set;get;}
        // name of the country with single quotes escaped
        public string UserName{set;get;}
        public string UserEmail{set;get;}
        public boolean isSelected{set;get;}
        
        UserWrapper(User usr , boolean bIsSelected){
            oUser = usr;
            UserEmail = String.escapeSingleQuotes(usr.Email);
            UserName = String.escapeSingleQuotes(usr.name);
            isSelected = bIsSelected;
        }
    }
}