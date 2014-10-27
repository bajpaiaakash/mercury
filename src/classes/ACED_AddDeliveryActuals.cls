public with sharing class ACED_AddDeliveryActuals {

Public List<ACED_Delivery_Actuals__c> lDeliveryActuals{get;set;}
Public ACED_Deliveries__c oDelivery {get;set;}
Public List<String> sChannelAttributes {get;private set;}
Public List<wDeliveryActualLineItems > wDeliveryActuals{get;set;}
Public Map<String,String> mHelpText{get;private set;}
public Map<String, Boolean> mHelpTextBool {get; set;}
string sPrimaryChannel;

Public Map<String,Decimal> mValues{get;private set;}

Public ACED_AddDeliveryActuals(){
    try{
        mHelpText = new Map<String,String>();
        
        mHelpTextBool = new Map<String, Boolean>();
        lDeliveryActuals = new List<ACED_Delivery_Actuals__c>();
        wDeliveryActuals = new List<wDeliveryActualLineItems >();
        Map<String,Map<String,Decimal>> mDeliveryValues = new Map<String,Map<String,Decimal>>();
        wDeliveryActuals = new List<wDeliveryActualLineItems >();
    
        String oDeliveryId  = ApexPages.currentPage().getParameters().get('id');
        String sCurrentObjectType = ((Id)oDeliveryId).getSObjectType().getDescribe().getName();
        string query = 'Select ';
        for(Schema.FieldSetMember f :SObjectType.ACED_Deliveries__c.FieldSets.Delivery_Header.getFields()) {
            if(f.getFieldPath()!='Activity__r.Channel__c')
                query += f.getFieldPath() + ', ';
        }
        for(Schema.FieldSetMember f :SObjectType.ACED_Asset__c.FieldSets.ACED_Asset.getFields()) {
            if(f.getFieldPath()!='Channel__c')
                query += 'StandAlone_Asset__r.'+f.getFieldPath() + ', ';
        } 
        
        if(sCurrentObjectType == 'ACED_Deliveries__c'){
            Query = Query +'Id,StandAlone_Asset__c,Activity__r.Channel__c,StandAlone_Asset__r.Channel__c  from ACED_Deliveries__c WHERE Id = : oDeliveryId';
        }
        else if(sCurrentObjectType == 'ACED_Asset__c'){
            Query = Query +'Id,StandAlone_Asset__c,StandAlone_Asset__r.Channel__c from ACED_Deliveries__c WHERE StandAlone_Asset__c = : oDeliveryId';
        }   
        oDelivery = Database.query(query);
        String sChannelId;
        If(oDelivery.StandAlone_Asset__c!=null)
            sChannelId = oDelivery.StandAlone_Asset__r.Channel__c;
        else
            sChannelId = oDelivery.Activity__r.Channel__c;
        
        sChannelAttributes = new List<String>();
        
        for(ACED_Channel_Attribute__c  cattr : [select id,Attribute_Name__c,Description__c,Channel__c,Actual__c  from ACED_Channel_Attribute__c  where Channel__c = : sChannelId  and Potential__c =false order by Actual__c Desc ]){
            sChannelAttributes.add(cattr.Attribute_Name__c);
            if(cattr.Description__c!=null){
                mHelpText.put(cattr.Attribute_Name__c,cattr.Description__c);
                mHelpTextBool.put(cattr.Attribute_Name__c, true);
            } else{ 
                mHelpText.put(cattr.Attribute_Name__c,''); 
                mHelpTextBool.put(cattr.Attribute_Name__c, false);
            }
            if(cattr.Actual__c)
              sPrimaryChannel = cattr.Attribute_Name__c;
        }
        
        for(ACED_Delivery_Actual_Line__c dl  : [select id,Delivery_Actuals__r.month__c,Attribute__c,Value__c from ACED_Delivery_Actual_Line__c where Delivery_Actuals__r.delivery__c = :ApexPages.currentPage().getParameters().get('id') or Delivery_Actuals__r.delivery__r.StandAlone_Asset__c = :ApexPages.currentPage().getParameters().get('id')]){
        if(mDeliveryValues.containskey(dl.Delivery_Actuals__r.month__c)){
          mDeliveryValues.get(dl.Delivery_Actuals__r.month__c).put(dl.Attribute__c,dl.Value__c);
        }
        else{
          mDeliveryValues.put(dl.Delivery_Actuals__r.month__c,new map<String,Decimal>{dl.Attribute__c => dl.Value__c});
        }
        
        }
            
        for(integer j=0; j<oDelivery.start_date__c.monthsBetween(oDelivery.end_date__c)+1;j++){
            Map<String,Decimal> mValues = new Map<String,Decimal>();
            string sMonth = (datetime.newInstance(oDelivery.start_date__c.year(), oDelivery.start_date__c.month(),oDelivery.start_date__c.day()).addmonths(j)).format('MMMMM');
                for(string st : sChannelAttributes){
                  if(mDeliveryValues.containskey(sMonth) && mDeliveryValues.get(sMonth).containskey(st)){
                      mValues.put(st,mDeliveryValues.get(sMonth).get(st));
                  }
                  else
                    mValues.put(st,0);      
                }
            wDeliveryActualLineItems stest =  new wDeliveryActualLineItems((datetime.newInstance(oDelivery.start_date__c.year(), oDelivery.start_date__c.month(),oDelivery.start_date__c.day()).addmonths(j)).format('MMMMM'),mValues);
            wDeliveryActuals.add(stest);
        }
    }catch(Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ACED_DeliveryNotEligible));
    }          
}



Public Pagereference cancel(){
    Pagereference p;
    if(oDelivery.StandAlone_Asset__c!=null)
        p = new Pagereference('/'+oDelivery.StandAlone_Asset__c);
    else
        p = new Pagereference('/'+oDelivery.id);
    return p;
}

Public pagereference save(){
    List<ACED_Delivery_Actuals__c> lDeliveryActuals = new List<ACED_Delivery_Actuals__c>();
    List<ACED_Delivery_Actual_Line__c> lDeliveryActualslines = new List<ACED_Delivery_Actual_Line__c>();

    for(wDeliveryActualLineItems DAL : wDeliveryActuals){
      ACED_Delivery_Actuals__c sDeliveryActuals = new ACED_Delivery_Actuals__c();
      If(DAL.mValues.get(sPrimaryChannel)>0){
          sDeliveryActuals.Delivery__c = oDelivery.Id;
          sDeliveryActuals.Delivery_Attribute_Upsert__c = oDelivery.Id+'-'+DAL.sDeliveryMonth+'-'+sPrimaryChannel;
          sDeliveryActuals.Month__c = DAL.sDeliveryMonth;
          sDeliveryActuals.value__c = DAL.mValues.get(sPrimaryChannel);
          lDeliveryActuals.add(sDeliveryActuals);      
          
          for(string st : DAL.mValues.keyset()){
            if(DAL.mValues.get(st)>0){
              ACED_Delivery_Actual_Line__c oDeliveryActual = new ACED_Delivery_Actual_Line__c();
              oDeliveryActual.Attribute__c = st;
              oDeliveryActual.value__c = DAL.mValues.get(st);
              oDeliveryActual.Delivery_Attribute_Upsert__c = oDelivery.Id+'-'+DAL.sDeliveryMonth+'-'+st;
              ACED_Delivery_Actuals__c a = new ACED_Delivery_Actuals__c();
              a.Delivery_Attribute_Upsert__c = oDelivery.Id+'-'+DAL.sDeliveryMonth+'-'+sPrimaryChannel;
                oDeliveryActual.Delivery_Actuals__r = a;
                lDeliveryActualslines.add(oDeliveryActual);
            }
          }
      }
    }
     
    try{
        upsert lDeliveryActuals Delivery_Attribute_Upsert__c;
        upsert lDeliveryActualslines Delivery_Attribute_Upsert__c;
        
        Pagereference p;
        if(oDelivery.StandAlone_Asset__c!=null)
            p = new Pagereference('/'+oDelivery.StandAlone_Asset__c);
        else
            p = new Pagereference('/'+oDelivery.id);
        return p;
        
    } catch(System.Exception e) {
      ApexPages.addMessages(e);
      return null;
    }
}

Public class wDeliveryActualLineItems{
  Public string sDeliveryMonth {get;set;}
  Public Map<string,Decimal> mValues {get;set;}
  
  Public wDeliveryActualLineItems(string sDeliveryMonth, Map<string,Decimal> mValues){
    this.sDeliveryMonth = sDeliveryMonth;
    this.mValues = mValues;
  }
}

}