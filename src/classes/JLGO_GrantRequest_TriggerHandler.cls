public class JLGO_GrantRequest_TriggerHandler {

    private static final string oneQuarter   = '1Q';
    private static final string twoQuarter   = '2Q';
    private static final string threeQuarter = '3Q';
    private static final string fourQuarter  = '4Q';
	private static final string review  = 'レビュー中(Medical承認済)';
    private static final string com1Approve  = 'Comittee1承認';
    private static final string com1reject   = 'Comittee1却下';
    private static final string com2Approve  = 'Comittee2承認';
    private static final string com2reject   = 'Comittee2却下';
    //**************************************************************
    // Constractor
    //**************************************************************
    public JLGO_GrantRequest_TriggerHandler(){
    }
    //**************************************************************
    // Action
    //**************************************************************
    public void OnBeforeInsert(List<JLGO_GrantRequest__c> inNewList){
        updQuarter(inNewList);
    }
    public void OnBeforeUpdate(List<JLGO_GrantRequest__c> inNewList){
        updQuarter(inNewList);
        UpdateOwner(inNewList);
    }
    public void OnAfterUpdate(Map<id,JLGO_GrantRequest__c> inNewMap,Map<id,JLGO_GrantRequest__c> inOldMap){
        CustomValidationRules(inNewMap,inOldMap);
    }
    //**************************************************************
    // Method
    //**************************************************************
    private void UpdateOwner(List<JLGO_GrantRequest__c> inNewList){
        for(JLGO_GrantRequest__c r : inNewList){
            r.ownerId = string.isBlank(r.LGOAssistant__c) ? r.OwnerId : r.LGOAssistant__c; 
		}
    }
    //Custom Validation Rules
    private void CustomValidationRules(Map<id,JLGO_GrantRequest__c> inNewMap,Map<id,JLGO_GrantRequest__c> inOldMap){
		for (Id key : inNewMap.keySet()) {
           JLGO_GrantRequest__c newrec = inNewMap.get(key);
           JLGO_GrantRequest__c oldrec = inOldMap.get(key);
           //Cheack Commitee1
           if(newrec.Committee1Amount__c != oldrec.Committee1Amount__c){
                //check state 
                if(!newrec.ApplicationStatus__c.equals(review)
                   && !newrec.ApplicationStatus__c.equals(com1Approve)
                   && !newrec.ApplicationStatus__c.equals(com1reject)
                  ){
                   newrec.addError(system.label.JLGO_Com1EditStateError);
				}
            }
           //Cheack Commitee2
           if(newrec.Committee2Amount__c != oldrec.Committee2Amount__c){
                //check state 
                if(!newrec.ApplicationStatus__c.equals(com1Approve)
                  &&!newrec.ApplicationStatus__c.equals(com2Approve)
                  &&!newrec.ApplicationStatus__c.equals(com1reject)
                  &&!newrec.ApplicationStatus__c.equals(com2reject)){
                   newrec.addError(system.label.JLGO_Com2EditStateError);
				}
            }
        }
    }
    //Update Quarter
    private void updQuarter(List<JLGO_GrantRequest__c> targetist){
         List<JLGO_PeriodMaster__c> listPeriodMaster = [SELECT id,Name,X1QStart__c,X1QEnd__c,X2QStart__c,X2QEnd__c,X3QStart__c,X3QEnd__c,X4QStart__c,X4QEnd__c FROM JLGO_PeriodMaster__c order by name desc limit 10000 ];
        //listPeriodMaster.size() > 0
        if(!listPeriodMaster.isEmpty()){
            system.debug('before loop');
            for(JLGO_GrantRequest__c rec : targetist){

                //init
                rec.fiscalyear__c ='';
                rec.quarter__c ='';

                //not null
                if(rec.ApplicationDate__c!=null){

                    for(JLGO_PeriodMaster__c recMaster : listPeriodMaster){

                        date targetDate = rec.ApplicationDate__c;

                        date X1QStart = recMaster.X1QStart__c;
                        date X1QEnd = recMaster.X1QEnd__c;
                        date X2QStart = recMaster.X2QStart__c;
                        date X2QEnd = recMaster.X2QEnd__c;
                        date X3QStart = recMaster.X3QStart__c;
                        date X3QEnd = recMaster.X3QEnd__c;
                        date X4QStart = recMaster.X4QStart__c;
                        date X4QEnd = recMaster.X4QEnd__c;

                        if(X1QStart <= targetDate &&
                           X4QEnd >= targetDate
                        ){
                            rec.fiscalyear__c = recMaster.name;
                        }else{
                            continue;
                        }

                        //cheack Repetition
                        if(X1QEnd >= X2QStart ||
                           X2QEnd >= X3QStart ||
                           X3QEnd >= X4QStart
                        ){
                            rec.quarter__c = System.Label.JLGO_ErrorNoDuplicatedQuarter;
                            break;
                        }

                        integer cnt = 0;

                        //1Q
                        if(X1QStart <= targetDate && X1QEnd >= targetDate){
                            cnt++;
                            rec.quarter__c = oneQuarter;
                            break;
                        }
                        //2Q
                        if(X2QStart <= targetDate && X2QEnd >= targetDate){
                            cnt++;
                            rec.quarter__c = twoQuarter;
                            break;
                        }
                        //3Q
                        if(X3QStart <= targetDate && X3QEnd >= targetDate){
                            cnt++;
                            rec.quarter__c = threeQuarter;
                            break;
                        }
                        //4Q
                        if(X4QStart <= targetDate && X4QEnd >= targetDate){
                            cnt++;
                            rec.quarter__c = fourQuarter;
                            break;
                        }
                        //etc
                        if(cnt==0){
                            rec.quarter__c = system.label.JLGO_ErrorNoAdaptedQuarter;
                        }
                    }
                    //error
                    if(string.isBlank(rec.fiscalyear__c)){
                        rec.fiscalyear__c = system.label.JLGO_ErrorNoFiscalYear;
                    }
                }
            }
        }
    }
}