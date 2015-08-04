/****************************************************************************************************************************************** 
* Class Name   : PANG_HomePage
* Description  : Class for the HomePage on the UI
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
public with sharing class PANG_HomePage{ 

    Public Boolean IsInc {
        get;
        set;
    }
    Public String SetTitle {
        get;
        set;
    }
    public list<PermissionSetAssignment> perset;   
    Public Map<String,Integer> mCategoyCount {get;set;}
    public String ChatterGroupId {
        get{
            if(ChatterGroupId ==null){               
                String defaultChatterGroup = PANG_Settings__c.getAll().get('Default Chatter Group').Setting_Value__c;
                List<CollaborationGroup > groups = [select Id from CollaborationGroup where Name = :defaultChatterGroup limit 1];
                if(groups.size() > 0){
                    return groups[0].Id;  
                }
            }
            return ChatterGroupId;
        }
        
    }
    
    //Loading the Constructor
    public PANG_HomePage() {
        mCategoyCount = new Map<String,Integer>();
        
        for (AggregateResult ar : [SELECT count(Id) FROM PANG_Request__c]) {
            mCategoyCount.put('Request',(Integer)ar.get('expr0'));
        }
        
        for (AggregateResult ar : [SELECT count(Id) FROM PANG_Request__c where recordtype.developername='RWE_Partnership_Exploration']) {
            mCategoyCount.put('Partnerships',(Integer)ar.get('expr0'));
        }
                
        for (AggregateResult ar : [SELECT count(Id) FROM PANG_Data_Asset__c]) {
            mCategoyCount.put('DataAssets',(Integer)ar.get('expr0'));
        }
        
        
        for (AggregateResult ar : [SELECT count(Id) FROM PANG_Project__c]) {
            mCategoyCount.put('Study',(Integer)ar.get('expr0'));
        }
        
        perset=[SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =:UserInfo.getUserId() AND PermissionSet.Name = 'PANG_RWE_Member' limit 1];
        if (perset.size() >0)
        {
        IsInc = False;
        }
        else 
        {
        IsInc = True;
        SetTitle = 'Coming Soon!';
        }        
         
    }

}