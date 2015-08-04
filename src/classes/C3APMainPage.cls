/*
* @Name: C3APMainPage
* @Description: Developed for the C3 HomePage
* @date Latest:Sep 24, 2014
* @author Teena Susan Philip
*/



public with sharing class C3APMainPage{

    public list<selectoption> lstOptions = new list<selectoption>();
    public list<C3AP_Affiliate__c> lstAffiliateName = new list<C3AP_Affiliate__c>();
    public C3AP_Affiliate__c selectedaffiliate{get; set;} {selectedaffiliate = new C3AP_Affiliate__c();}
    public list<Attachment> lstAdditionalLinks{get; set;} {lstAdditionalLinks = new List <Attachment>();}
    public String listvalue {get;set;}
    public Boolean displayLocalText {get;set;}
    private  Id SYS_ADMIN_PROFILE_ID;
    //public map <id , string> Map1=new map<id , string>();
    
    public C3APMainPage(ApexPages.StandardController controller){
        listvalue=System.Label.C3AP_Select_Affiliate;
        lstAffiliateName = [SELECT id,Name,C3AP_Home_Page__c,C3AP_Local_Home_Page__c,Local_Language__c,Local_Language_ISO_Code__c
                            FROM C3AP_Affiliate__c];
        displayLocalText = false; 
    }
    
    
    /* 
     * Method name : getoptionlist
     * Description :  This method builds a list of Affiliates for the User to select from on the Homepage
     * Param :  None
     * Returns :  list<selectoption>
    */
    
    public list<selectoption> getoptionlist(){      
        lstOptions.add(new selectoption(System.Label.C3AP_Select_Affiliate, System.Label.C3AP_Select_Affiliate));
        for(C3AP_Affiliate__c ca :lstAffiliateName ){
            lstOptions.add(new selectoption(ca.id,ca.Name));
        }
        return lstOptions;
    }
    
    
    
    /* 
     * Method name : homepage
     * Description :  This method renders the right Homepage content when User changes Affiliates
     * Param :  None
     * Returns : None
    */
    public void homepage(){
        /* Modified By : Jayalakshmi Mohananpillai
         * Modified On : Sept 10, 2014
         * Description : Added Business logic for comparing the logged in user language with affliate local language 
         *               and based upon the result conditional rendering of the local home page text 
         */   
                        
        if(listvalue!=System.Label.C3AP_Select_Affiliate) {            
            for(C3AP_Affiliate__c ahp :lstAffiliateName) {
                if(ahp.id == listvalue) {
                    selectedaffiliate=ahp;
                    break; // break out of the loop once C3AP_Affiliate__c found
                }                              
            }

            lstAdditionalLinks = [Select Name, Body, Description from Attachment where Parentid=:selectedaffiliate.id];
            
            // To avoid null pointer exception checking for null values if null then always display English text on homepage of the selected affiliate
            if(selectedaffiliate != NULL && selectedaffiliate.Local_Language_ISO_Code__c != '') {
                if(UserInfo.getLanguage() == selectedaffiliate.Local_Language_ISO_Code__c && selectedaffiliate.Local_Language_ISO_Code__c != 'en_US')
                      displayLocalText = true;
                else
                      displayLocalText = false;       
            }        
        }
    }

    
    
    /* 
     * Method name : searchContract
     * Description :  This method navigates to the Search Historic Contracts Page
     * Param :  None
     * Returns : PageReference
    */
    
    public PageReference searchContract(){
        PageReference toSearchHistoric = null;
        
		Schema.DescribeSObjectResult describeResult = C3AP_Contract_Request_Summary__c.sObjectType.getDescribe();
		String keyPrefix = describeResult.getKeyPrefix();
		
        toSearchHistoric = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + keyPrefix);
        toSearchHistoric.setRedirect(true);
  
        return toSearchHistoric;
    }
    
    
    /* 
     * Method name : newContract
     * Description : This method navigates to the Introductory Questionnaire to create new Contract Requests
     * Param :  None
     * Returns : PageReference
    */
    public PageReference newContract(){
        PageReference toNewContractQuest = new PageReference(System.Label.C3AP_New_Contract_Request_URL + selectedaffiliate.id);
        toNewContractQuest.setRedirect(true);
        return toNewContractQuest ;
    }
}