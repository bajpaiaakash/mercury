/***************************************************************************************
    Name    : ACED_Programs_TriggerHandler
    Desc    : Trigger to update Indication Details field  Program record upon adding Brand Indications
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
Goutham              25/09/2014          Created
---------------------------------------------------------------------------
History Log:

******************************************************************************************/

Public class ACED_Programs_TriggerHandler{
    public static final String commaSep = ',';
    
    //Method to update to update Indication Details field  Program record upon adding Brand Indications
    Public static void updateIndicationDetails(list<ACED_Programs__c> lPrograms) {
        //Set of selected Indication details       
        Map<ID,Set<String>> ProgInd = New Map<ID,Set<String>>();
        

        //Looping over all Programs being updated and adding those fields to set       
        for (ACED_Program_Indication__c pi : [SELECT ID, Indication__r.Business_Unit__c,Indication__r.Brand__c,Indication__r.Therapeutic_Area__c,Indication__r.Name, Program__c from ACED_Program_Indication__c where Program__c  in :lPrograms]){
        If(ProgInd.containsKey(pi.Program__c)){
            Set<String> sIndDetails = ProgInd.get(pi.Program__c);
            sIndDetails.add(pi.Indication__r.Business_Unit__c);
            sIndDetails.add(pi.Indication__r.Brand__c);
            sIndDetails.add(pi.Indication__r.Therapeutic_Area__c);
            sIndDetails.add(pi.Indication__r.Name);
            ProgInd.put(pi.Program__c,sIndDetails);
        }
        else{
        Set<String> sIndDetails = New Set<String>();
            sIndDetails.add(pi.Indication__r.Business_Unit__c);
            sIndDetails.add(pi.Indication__r.Brand__c);
            sIndDetails.add(pi.Indication__r.Therapeutic_Area__c);
            sIndDetails.add(pi.Indication__r.Name);
            ProgInd.put(pi.Program__c,sIndDetails);

        }
      } 
      for (ACED_Programs__c p :lPrograms){
          If(ProgInd.containsKey(p.ID)){
          String value = '';
          for (string s:ProgInd.get(p.ID)){
              value = value + s + commaSep;
          }
          if(value.endsWith(commaSep)){
              value = value.substring(0, value.length() - commaSep.length());
          }
          p.Indication_Details__c = value;   
          }
       
        }  

    }
}