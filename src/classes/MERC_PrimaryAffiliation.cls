/**
 * @author Jyoti Gaur
 *
 * For populating affiliated HCO info onto corresponding HCP account
 */
 
public with sharing class MERC_PrimaryAffiliation implements GLBL_TriggerHandler.HandlerInterface {
    public boolean isActive() {
        return MERC_TriggerHandlerStateManager.isActive(MERC_PrimaryAffiliation.class);
    }
    public void handle() {
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            execute(Trigger.new);
        } /*else if (Trigger.isDelete) {
            execute(Trigger.old);
        }*/
    }
    public void execute(List<SObject> sobjects){
    List<Id> accids= new List<Id>();
    Map<id,id> map_of_affiliated_childs_cust_id = new Map<id,id>();
    Map<id,id> map_of_affiliated_parent_account_glbl_c = new Map<id,id>();
    Map<Id,Account> Map_of_Account = new Map<Id,Account>();
    Map<Id,Affiliation_GLBL__c> Map_of_Affiliation = new Map<Id,Affiliation_GLBL__c>();
    List<Account> acclist_parent=new List<Account>();
    List<Account> acclist_child =new List<Account>();
    List<Account> acclist =new List<Account>();
    List<Account> Account_update= new List<Account>();
    SET<Account> Accounts_for_update = new SET<Account>();
    System.debug('@@Size'+ sobjects.size());

    // Primary affiliation condition
    for(Affiliation_GLBL__c aff1:(List<Affiliation_GLBL__c>)sobjects){
    
      if(aff1.Efctv_End_Dt_GLBL__c != null && aff1.Priority_Rank_Nbr_GLBL__c== 1){
          Date sysdate = (Date)System.today();
          Date endDate = date.newinstance(aff1.Efctv_End_Dt_GLBL__c.year(), aff1.Efctv_End_Dt_GLBL__c.month(), aff1.Efctv_End_Dt_GLBL__c.day());
        if(aff1.Account_Cust_Id_GLBL__c != null && sysdate < endDate){
            map_of_affiliated_childs_cust_id.put(aff1.id,aff1.Account_Cust_Id_GLBL__c);
            map_of_affiliated_parent_account_glbl_c.put(aff1.id,aff1.Account_GLBL__c);  
            Map_of_Affiliation.put(aff1.id,aff1);     
        }
        }

    }
        
    //For storing all accounts associated to inserted/updated Affiliation
    try{
        acclist_parent = [select id,name,Primary_HCO_GLBL__c,Prim_Affil_Pstl_Cd_Extnsn_GLBL__c,Party_Rcrd_Typ_Cd_GLBL__c,Prim_Affil_HCO_GLBL__c,Prim_Affil_Addr_Country_GLBL__c,Prim_Affil_Addr_City_GLBL__c,Prim_Affil_Addr_Line1_GLBL__c,Prim_Affil_Addr_Line2_GLBL__c,Primary_Address_Country_GLBL__c,Primary_Addr_City_GLBL__c,Primary_Pstl_Cd_Extnsn_GLBL__c,Primary_Addr_Line1_GLBL__c,Primary_Addr_Line2_GLBL__c from account where id in:map_of_affiliated_parent_account_glbl_c.values()];
        acclist_child = [select id,Primary_HCO_GLBL__c,Prim_Affil_Pstl_Cd_Extnsn_GLBL__c,Party_Rcrd_Typ_Cd_GLBL__c,Prim_Affil_HCO_GLBL__c,Prim_Affil_Addr_Country_GLBL__c,Prim_Affil_Addr_City_GLBL__c,Prim_Affil_Addr_Line1_GLBL__c,Prim_Affil_Addr_Line2_GLBL__c,Primary_Address_Country_GLBL__c,Primary_Addr_City_GLBL__c,Primary_Pstl_Cd_Extnsn_GLBL__c,Primary_Addr_Line1_GLBL__c,Primary_Addr_Line2_GLBL__c from account where id in:map_of_affiliated_childs_cust_id.values()];
        acclist.addall(acclist_child);
        acclist.addall(acclist_parent);
   
    For(account acc:acclist){
            Map_of_Account.put(acc.id,acc);
        }
    // assigning parent affiliated account values to child affiliated account   
    for(Id affiliation_ID:map_of_affiliated_childs_cust_id.keyset()){
            Affiliation_GLBL__c aff_obj = Map_of_Affiliation.get(affiliation_ID);
            if((aff_obj.Rltnshp_Typ_Cd_GLBL__c =='PCAF'  && aff_obj.Afltn_Party_Rcrd_Typ_Cd_GLBL__c == 'HCP' && aff_obj.Party_Rcrd_Typ_Cd_GLBL__c == 'HCO' && aff_obj.Party_Cntry_Cd_GLBL__c != 'US') || (aff_obj.Party_Rcrd_Typ_Cd_GLBL__c == 'HCO' && aff_obj.Party_Cntry_Cd_GLBL__c == 'US' && aff_obj.Afltn_Party_Rcrd_Typ_Cd_GLBL__c == 'HCP')){
            Account Child_Account = Map_of_Account.get(map_of_affiliated_childs_cust_id.get(affiliation_ID));
            Account Parent_Account = Map_of_Account.get(map_of_affiliated_parent_account_glbl_c.get(affiliation_ID));
            Child_Account.Primary_HCO_GLBL__c=Parent_Account.id;
            Child_Account.Prim_Affil_HCO_GLBL__c=Parent_Account.Name;
            Child_Account.Prim_Affil_Addr_Country_GLBL__c=Parent_Account.Primary_Address_Country_GLBL__c;
            Child_Account.Prim_Affil_Addr_City_GLBL__c= Parent_Account.Primary_Addr_City_GLBL__c;
            Child_Account.Prim_Affil_Pstl_Cd_Extnsn_GLBL__c= Parent_Account.Primary_Pstl_Cd_Extnsn_GLBL__c;
            Child_Account.Prim_Affil_Addr_Line1_GLBL__c= Parent_Account.Primary_Addr_Line1_GLBL__c;
            Child_Account.Prim_Affil_Addr_Line2_GLBL__c= Parent_Account.Primary_Addr_Line2_GLBL__c;
            system.Debug( Child_Account);
            Accounts_for_update.add(Child_Account);
            }
        
    }
     system.debug('Accounts for update-----'+Accounts_for_update);
     
    Account_update.addAll(Accounts_for_update);
    }catch(exception e){
        if (Apexpages.currentPage() != null) {
        ApexPages.addMessages(e);
        }
    }
    // update child accounts
	if(Account_update != null && Account_update.size()>0){
    update Account_update; 
	}
    }
}