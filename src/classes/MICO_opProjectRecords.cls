/*************************************************************************\
    @ Author        : Deloitte Digital
    @ Date          : 1-Sep-2014
    @ Test Class    : 
    @ Description   : This class is used as a helper class for MICO_TriggerProjectRecords trigger.
****************************************************************************/

public class MICO_opProjectRecords{

   public static MICO_Project__share[] projectRecLst=new List<MICO_Project__share>();
   
       public  void setProjectRecords(MICO_Project__share[] micoQueriedRecs)
       {
                 for(Integer i=0;i<micoQueriedRecs.size();i++)
                 {
                     //putting the queried result into a List pRecrds of Type MICO_Project__share
                     
                     MICO_Project__share pRecrds = new MICO_Project__share(UserOrGroupId = micoQueriedRecs[i].UserOrGroupId, accesslevel=micoQueriedRecs[i].accesslevel, rowcause=micoQueriedRecs[i].rowcause,parentId=micoQueriedRecs[i].parentId);
                     projectRecLst.add(pRecrds);
                 }
       }
   
       public  void insertProjectRecords()
       {
         //Insert the records which we queried before Update.
         insert projectRecLst;
       
       }

}