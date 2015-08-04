/****************************************************************************************************************************************** 
* Class Name   : APOL_Test_FindFilterJSON 
* Description  : test Class for FindFilterJSON
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
@istest(SeeAllData=false)
public class APOL_Test_FindFilterJSON {
    
    /* 
    * @Method Name                    :  testFindfilters
    * @Description                    :  Testing of findfilters method , which will get all the values of the Find Filter
                                         using Describe calls , and create a JSON in the specified format.  
    * @Return Type                    :  void
    */       
    public static testmethod void testFindfilters() {
        
        User u = APOL_Test_Utility_Class.CreateApolAdmin(); // Creating a user for Apollo Admin
        System.RunAs(u) {
        test.starttest();
        Object jsonresp =  APOL_FindFilterJSON.FindFilters();
        system.assert(jsonresp!=null);
        String jsonrespasString = jsonresp+'';
        system.assert(jsonrespasString.contains(label.APOL_Business_Unit));
        test.stoptest();
        }
    }
  }