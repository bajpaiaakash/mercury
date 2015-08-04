/* Class Name  : ACED_Deliveries_TriggerHandler
* Description  : Trigger Handler Class to insert delivery indications, upsert delivery indication actuals and to calculate planned eInteractions upon creation and updating of Delivery record
* Created By   : Goutham
* Created Date : 9/04/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        	Description 
* Venugopal             12/16/2014              DEF-001242          	Modified to handle the bulk record creation of Delivery Indication Actuals starting line 53: method 'upsertDeliveryIndicationActuals'

* ---------------------------------------------------------------------------------------------------------------------------------------

*/

Public class ACED_Deliveries_TriggerHandler{
    
    
    Public static Void InsertDeliveryIndications(List<ACED_Deliveries__c> lDelivery){
        Map<Id,List<ACED_Program_Indication__c>> mProgramIndications = new Map<Id,List<ACED_Program_Indication__c>>();
        List<ACED_Delivery_Indication__c> lDeliveryIndications = new List<ACED_Delivery_Indication__c>();
        for(ACED_Deliveries__c oDelivery : lDelivery){
            if(oDelivery.ProgramID_TF__c!=null)
                mProgramIndications.put(oDelivery.ProgramID_TF__c,null);
        }
        
        for(ACED_Program_Indication__c oProgram : [Select Id,effort__c,Indication__c,Program__c from ACED_Program_Indication__c  where program__c in : mProgramIndications.keyset() and Program__r.Standalone_Asset_program_TF__c != true]){
            if(mProgramIndications.containskey(oProgram.Program__c) && mProgramIndications.get(oProgram.Program__c)!=null){
                List<ACED_Program_Indication__c> lProgramIndications = mProgramIndications.get(oProgram.Program__c);
                lProgramIndications.add(oProgram);
                mProgramIndications.put(oProgram.Program__c,lProgramIndications );
            }
            else{
                mProgramIndications.put(oProgram.Program__c,new List<ACED_Program_Indication__c>{oProgram});
            }
            
        }
        
        for(ACED_Deliveries__c oDelivery : lDelivery){
            if(mProgramIndications.containskey(oDelivery.ProgramID_TF__c) && mProgramIndications.get(oDelivery.ProgramID_TF__c)!=null){
                for(ACED_Program_Indication__c oProgram : mProgramIndications.get(oDelivery.ProgramID_TF__c)){
                    ACED_Delivery_Indication__c oDeliveryIndication = new  ACED_Delivery_Indication__c ();
                    oDeliveryIndication.Brand_Indication__c = oProgram.Indication__c;
                    oDeliveryIndication.Delivery__c = oDelivery.Id;
                    oDeliveryIndication.effort__c = oProgram.effort__c;
                    lDeliveryIndications.add(oDeliveryIndication);
                }
            }         
            
        }
        
        Insert lDeliveryIndications;
    }
    
       Public static void UpsertDeliveryIndicationActuals(List<ACED_Deliveries__c> lDeliveries){
        List<ACED_Delivery_Indication_Actuals__c> lDeliveryIndicationActuals = new List<ACED_Delivery_Indication_Actuals__c>();
        List<ACED_Delivery_Indication__c> lDeliveryIndications = [Select id,Effort__c,Delivery__r.Effort_TF__c,Delivery__c from ACED_Delivery_Indication__c where Delivery__c in : lDeliveries];
        // map to store Delivery Indicataions per each Delivery
        Map<Id, List<ACED_Delivery_Indication__c>> mapDelIndicationsPerDelivery = new Map<Id, List<ACED_Delivery_Indication__c>>();
        // map to store Delivery Actuals for each Delivery
        Map<Id, List<ACED_Delivery_Actuals__c>> mapDelActualsperDelivery = new Map<Id, List<ACED_Delivery_Actuals__c>>();
        
        for(ACED_Delivery_Indication__c delviInd : lDeliveryIndications){
            if(mapDelIndicationsPerDelivery.get(delviInd.Delivery__c) == null)
            {
                List<ACED_Delivery_Indication__c> ldelInd = new List<ACED_Delivery_Indication__c>();
                ldelInd.add(delviInd);
                mapDelIndicationsPerDelivery.put(delviInd.Delivery__c,ldelInd);
            }
            else
            {
                List<ACED_Delivery_Indication__c> ldelInd = mapDelIndicationsPerDelivery.get(delviInd.Delivery__c);
                ldelInd.add(delviInd);
                mapDelIndicationsPerDelivery.put(delviInd.Delivery__c,ldelInd);
            }
        }
        
        List<ACED_Delivery_Actuals__c> lDelAct = [Select Id,Month__c,Value__c,Delivery__c from ACED_Delivery_Actuals__c where Delivery__c in : lDeliveries];
        
        for(ACED_Delivery_Actuals__c delviAct : lDelAct){
            if(mapDelActualsperDelivery.get(delviAct.Delivery__c) == null)
            {
                List<ACED_Delivery_Actuals__c> ldeliveryActual = new List<ACED_Delivery_Actuals__c>();
                ldeliveryActual.add(delviAct);
                mapDelActualsperDelivery.put(delviAct.Delivery__c,ldeliveryActual);
            }
            else
            {
                List<ACED_Delivery_Actuals__c> ldeliveryActual = mapDelActualsperDelivery.get(delviAct.Delivery__c);
                ldeliveryActual.add(delviAct);
                mapDelActualsperDelivery.put(delviAct.Delivery__c,ldeliveryActual);
            }
        }

        Set<string> sDeliveryIndicationActuals = new Set<string>();
        for(Id delId : mapDelActualsperDelivery.keySet()) {
            for(ACED_Delivery_Actuals__c oActuals : mapDelActualsperDelivery.get(delId)){

                List<ACED_Delivery_Indication__c> lDeliveryIndication = mapDelIndicationsPerDelivery.get(delId);
                for(ACED_Delivery_Indication__c oDeliveryIndications : lDeliveryIndication){
                    
                    ACED_Delivery_Indication_Actuals__c oDeliveryActualLines = new ACED_Delivery_Indication_Actuals__c();
                    oDeliveryActualLines.Month__c = oActuals.Month__c;
                    oDeliveryActualLines.Effort_Value__c = oActuals.Value__c * (oDeliveryIndications.Effort__c/100);
                    oDeliveryActualLines.Actual_Value__c = oActuals.Value__c * (oDeliveryIndications.Effort__c/oDeliveryIndications.Delivery__r.Effort_TF__c);
                    oDeliveryActualLines.Delivery_Indication__c = oDeliveryIndications.Id;
                    oDeliveryActualLines.Delivery_Attribute_Upsert__c = oDeliveryIndications.Id+'-'+oActuals.Month__c;
                    if(!sDeliveryIndicationActuals.contains(oDeliveryIndications.Id+'-'+oActuals.Month__c))
                        lDeliveryIndicationActuals.add(oDeliveryActualLines);
                    sDeliveryIndicationActuals.add(oDeliveryIndications.Id+'-'+oActuals.Month__c);
                }
            }
        }
               
        Upsert lDeliveryIndicationActuals Delivery_Attribute_Upsert__c;
        
        List<ACED_Delivery_Indication__c> lDeliveryIndicationsAggre = new List<ACED_Delivery_Indication__c>();
        for (AggregateResult ar : [SELECT Delivery_Indication__c, SUM(Effort_Value__c),SUM(Actual_Value__c) FROM ACED_Delivery_Indication_Actuals__c  where Id in :  lDeliveryIndicationActuals GROUP BY Delivery_Indication__c]) {
            lDeliveryIndicationsAggre.add(new ACED_Delivery_Indication__c(Id = (Id)ar.get('Delivery_Indication__c'), 
                                                                          Effort_eInteraction__c = (Decimal)ar.get('expr0'),
                                                                          Actual_eInteraction__c = (Decimal)ar.get('expr1')));
            
        }
        Update lDeliveryIndicationsAggre;
    }
    
        Public static void CalculatePlannedInteractions(List<ACED_Deliveries__c> lDeliveries){
            Map<Id,ACED_Activity__c> mActivities = new Map<Id,ACED_Activity__c>();
            Map<Id,ACED_Audience__c> mAudience = new Map<Id,ACED_Audience__c>();
            Set<String> sProgYears = new Set<String>();
            Set<String> sChannelIds = new Set<String>();
            List<ACED_Deliveries__c> lDeliveryActualsForUpdate = new List<ACED_Deliveries__c>();
            Map<String,Decimal> mProviderRates = new Map<String,Decimal>();
            for(ACED_Deliveries__c oDelivery : lDeliveries){
                if(oDelivery.StandAlone_Asset__c==null){
                    mActivities.put(oDelivery.Activity__c,null);
                    mAudience.put(oDelivery.Audience__c,null);
                }
            }
            
            if(mActivities.size()>0){
                for(ACED_Activity__c oActivity : [select id,Assets__r.Target_type__c,Program__r.Year__c,Channel__c,Rate_Planned_eInt_Q1__c,Rate_Planned_eInt_Q2__c,Rate_Planned_eInt_Q3__c,Rate_Planned_eInt_Q4__c from ACED_Activity__c where id in : mActivities.keyset()]){
                    mActivities.put(oActivity.Id,oActivity);
                    sProgYears.add(oActivity.Program__r.Year__c);
                    sChannelIds.add(oActivity.Channel__c);
                }
            }
            
            if(mAudience.size()>0){
                for(ACED_Audience__c oAudience : [Select id,Non_Segmented__c,Patient_Focus_Professional__c,Patient_Idealist__c,Scientific_Innovator__c,Traditionalist__c,All_Segments__c from ACED_Audience__c where id in : mAudience.keyset()]){
                    mAudience.put(oAudience.Id,oAudience);
                }
            }
            
            if(sChannelIds.size()>0){
                for(ACED_Channel_Provider_Success_Rate__c oChannelRates:[Select Id,Year__c,Channel_Provider__c,Success_Rate__c,Channel__c from ACED_Channel_Provider_Success_Rate__c where Channel__c in : sChannelIds and Year__c in : sProgYears]){
                    mProviderRates.put(oChannelRates.Channel_Provider__c+'-'+oChannelRates.Channel__c+'-'+oChannelRates.Year__c, (decimal)oChannelRates.Success_Rate__c);
                }
            }
            
            for(ACED_Deliveries__c oDelivery : lDeliveries){
                if(oDelivery.StandAlone_Asset__c==null){    
                    if(mActivities.containskey(oDelivery.Activity__c) && mActivities.get(oDelivery.Activity__c)!=null && mActivities.get(oDelivery.Activity__c).Assets__c!=null && mActivities.get(oDelivery.Activity__c).Assets__r.Target_type__c!=null){
                        oDelivery.asset_Type_TF__c = mActivities.get(oDelivery.Activity__c).Assets__r.Target_type__c;
                    }
                    
                    if(mProviderRates.containskey(oDelivery.Provider__c+'-'+mActivities.get(oDelivery.Activity__c).Channel__c+'-'+mActivities.get(oDelivery.Activity__c).Program__r.Year__c) && mProviderRates.get(oDelivery.Provider__c+'-'+mActivities.get(oDelivery.Activity__c).Channel__c+'-'+mActivities.get(oDelivery.Activity__c).Program__r.Year__c)!=null){
                        oDelivery.Channel_Provider_Rate_TF__c = mProviderRates.get(oDelivery.Provider__c+'-'+mActivities.get(oDelivery.Activity__c).Channel__c+'-'+mActivities.get(oDelivery.Activity__c).Program__r.Year__c);
                    }
                    else oDelivery.Channel_Provider_Rate_TF__c = 0;         
                    If( mAudience.containskey(oDelivery.Audience__c) && mAudience.get(oDelivery.Audience__c) !=null){
                        if(oDelivery.PIM_Segment__c == 'No segmented') oDelivery.No_of_Attendees_TF__c = mAudience.get(oDelivery.Audience__c).Non_Segmented__c;
                        else if (oDelivery.PIM_Segment__c == 'Patient Focus Professional') oDelivery.No_of_Attendees_TF__c = mAudience.get(oDelivery.Audience__c).Patient_Focus_Professional__c;
                        else if (oDelivery.PIM_Segment__c == 'Patient Idealist') oDelivery.No_of_Attendees_TF__c = mAudience.get(oDelivery.Audience__c).Patient_Idealist__c; 
                        else if (oDelivery.PIM_Segment__c == 'Scientific Innovator') oDelivery.No_of_Attendees_TF__c = mAudience.get(oDelivery.Audience__c).Scientific_Innovator__c;
                        else if (oDelivery.PIM_Segment__c == 'Traditionalist') oDelivery.No_of_Attendees_TF__c = mAudience.get(oDelivery.Audience__c).Traditionalist__c; 
                        else oDelivery.No_of_Attendees_TF__c = mAudience.get(oDelivery.Audience__c).All_Segments__c;
                    }
                    else oDelivery.No_of_Attendees_TF__c = 0;   
                    
                    oDelivery.Estimated_eInt__c = oDelivery.No_of_Attendees_TF__c * (oDelivery.Channel_Provider_Rate_TF__c/100);
                    if(mActivities.containskey(oDelivery.Activity__c) && mActivities.get(oDelivery.Activity__c)!=null && oDelivery.Estimated_eInt__c!=null)
                        oDelivery.Planned_eInt__c = oDelivery.Estimated_eInt__c * mActivities.get(oDelivery.Activity__c).Rate_Planned_eInt_Q1__c + oDelivery.Estimated_eInt__c * mActivities.get(oDelivery.Activity__c).Rate_Planned_eInt_Q2__c +oDelivery.Estimated_eInt__c * mActivities.get(oDelivery.Activity__c).Rate_Planned_eInt_Q3__c+oDelivery.Estimated_eInt__c * mActivities.get(oDelivery.Activity__c).Rate_Planned_eInt_Q4__c; 
                    else
                        oDelivery.Planned_eInt__c = 0;
                }    
            }
            
            
        }
        
    }