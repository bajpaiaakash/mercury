public with sharing class ACED_Channel_TriggerHandler {
    Public static void UpdateChannelActualNPotentialAttributes(List<ACED_Channel__c> lChannels){
        Map<Id,Map<String,String>> mChannelDetails = new Map<Id,Map<String,String>>();
        for(ACED_Channel_Attribute__c oChanneAttr : [Select Id,Attribute_Name__c,Channel__c,Actual__c,Potential__c from ACED_Channel_Attribute__c where Channel__c in : lChannels and (Actual__c = : true or Potential__c = : true)]){
            if(mChannelDetails.containskey(oChanneAttr.Channel__c) && mChannelDetails.get(oChanneAttr.Channel__c)!=null){
                if(oChanneAttr.Actual__c){
                    mChannelDetails.get(oChanneAttr.Channel__c).put('ACTUAL',oChanneAttr.Attribute_Name__c);
                }
                
                else if(oChanneAttr.Potential__c){
                    mChannelDetails.get(oChanneAttr.Channel__c).put('POTENTIAL',oChanneAttr.Attribute_Name__c);
                }   
            }
            else{
                if(oChanneAttr.Actual__c){
                    mChannelDetails.put(oChanneAttr.Channel__c,new Map<String,String>{'ACTUAL'=>oChanneAttr.Attribute_Name__c});
                }
                else if(oChanneAttr.Potential__c){
                    mChannelDetails.Put(oChanneAttr.Channel__c,new Map<String,String>{'POTENTIAL'=>oChanneAttr.Attribute_Name__c});
                }   
            }
        }
        
        for(ACED_Channel__c oChannel : lChannels){
            if(mChannelDetails.containskey(oChannel.Id) && mChannelDetails.get(oChannel.Id).containskey('ACTUAL'))
                oChannel.Actual_Attribute__c = mChannelDetails.get(oChannel.Id).get('ACTUAL');
            else
                oChannel.Actual_Attribute__c = null;    
            
            if(mChannelDetails.containskey(oChannel.Id) && mChannelDetails.get(oChannel.Id).containskey('POTENTIAL'))
                oChannel.Potential_Attribute__c = mChannelDetails.get(oChannel.Id).get('POTENTIAL');
            else
                oChannel.Potential_Attribute__c = null;             
        }
    }
}