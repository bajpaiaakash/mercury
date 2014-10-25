/****************************************************************************************************************************************** 
* Class Name   : KanbanBoardCntrl
* Description  : This is a class that will show the correct records in the digital Kanban board + make updates    
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/

public class KanbanBoardCntrl {

    public MICO_Sprint__c spr {get; set;}
    public list <MICO_User_Story__c> Columns1List{get; set;}
    public list <MICO_User_Story__c> BacklogList{get; set;}
    public list <MICO_User_Story__c> AwaitingDev{get; set;}
    public list <MICO_User_Story__c> InDev{get; set;}
    public list <MICO_User_Story__c> AwaitingSAT{get; set;}
    public list <MICO_User_Story__c> InSAT{get; set;}
    public list <MICO_User_Story__c> Done{get; set;}
    public list <MICO_User_Story__c> BPC{get; set;}  
    
    Public List <MICO_User_Story__c> completeUSList;
    Map<String,List<MICO_User_Story__c>> AllocatedSprintUSList ;
    Public string selvalue {get;set;}
    Public string funcSelValue {get;set;}
    public string SprintName;
    public Set <String> sprintNames = new Set<String>();
    public Set <Id> sprintIds = new Set<Id>();
    public List<MICO_Sprint__c> sprintList = new List<MICO_Sprint__c>();
       
    public KanbanBoardCntrl(ApexPages.StandardController controller) {
        spr = new MICO_Sprint__c();
        spr = [select Name, id from MICO_Sprint__c where id =: apexpages.currentpage().getparameters().get('Id')];  
        sprintList = [select Name from MICO_Sprint__c where Status__c = 'In Progress'];    
        for (MICO_Sprint__c sprint : sprintList)
        {
            if (!sprintIds.contains(sprint.Id)){
                sprintNames.add(sprint.Name);
                sprintIds.add(sprint.Id);
            }
        }
        system.debug(sprintNames.size()); 
        SprintName = spr.Name;
        selvalue = SprintName;
        DispUserStories(null);
    }    
    
    public List<SelectOption> getsprintval(){
        List<SelectOption> tempSOPList = new List<SelectOption>();
        tempSOPList.add(new selectOption('All','All'));

        for(String str : sprintNames){
                tempSOPList.add(new SelectOption(str,str));
        }
        return tempSOPList;
    }
    
    // Compose Functional Areas Dropdown
    
    public List<SelectOption> getFuncval(){
        List<SelectOption> tempSOPList = new List<SelectOption>();
        tempSOPList.add(new selectOption('All','All'));
        tempSOPList.add(new selectOption('Customer Services','Customer Services'));        
        tempSOPList.add(new selectOption('Event / Medical','Event / Medical'));       
        tempSOPList.add(new selectOption('Market Access','Market Access'));        
        tempSOPList.add(new selectOption('Marketing / Multichannel','Marketing / Multichannel'));      
        tempSOPList.add(new selectOption('SFA','SFA'));     
        tempSOPList.add(new selectOption('Analytics / Insights','Analytics / Insights'));
        return tempSOPList;
    }
    
  // Display all user stories taking into account filters  
  Public void DispUserStories(string selvalx){
     if(selvalue ==null)
        selvalue ='All';
    if(funcSelValue ==null)
        funcSelValue ='All';
    
    // Find all requirements linked to the available sprint
    List<MICO_User_Story__c> AllocatedSprintUSList  = [Select id, Name, Allocated_Sprint__c , Development_Stage__c, Functional_Area__c, As_A__c, I_Want_To__c, So_that__c, Allocated_Sprint__r.Name from MICO_User_Story__c where Allocated_Sprint__c in: sprintids];
    List<MICO_User_Story__c> TempList = new List<MICO_User_Story__c>();
    List<MICO_User_Story__c> TempList2 = new List<MICO_User_Story__c>();
    
    // Create a subset of user stories based on filters
    if (selvalue == 'All'){
        TempList.addAll (AllocatedSprintUSList);
    }
    else{
        for (MICO_User_Story__c req : AllocatedSprintUSList){
            if (selvalue != null && selvalue != 'All'){
                if (req.Allocated_Sprint__r.Name == selvalue){
                    TempList.add(req);
                }
            }
        }
    }
    
    
    if (funcSelValue == 'All'){
        TempList2 = Templist;
    }
    else{
        for (MICO_User_Story__c req : TempList){
            if (funcSelValue != null && funcSelValue != 'All'){
                if (req.Functional_Area__c == funcSelValue){
                    TempList2.add(req);
                }
            }
        }
   }
    
    
    
    BacklogList = new list <MICO_User_Story__c>();
    AwaitingDev = new list <MICO_User_Story__c>();
    InDev = new list <MICO_User_Story__c>();
    AwaitingSAT = new list <MICO_User_Story__c>();
    InSAT = new list <MICO_User_Story__c>();
    Done = new list <MICO_User_Story__c>();
    BPC = new list <MICO_User_Story__c>();
    
    // Compose a list per status
    for(MICO_User_Story__c req : TempList2){
        if(req.Development_Stage__c.contains('Backlog'))
            BacklogList.add(req);
        else if(req.Development_Stage__c.contains('Awaiting Dev'))
            AwaitingDev.add(req);
        else if(req.Development_Stage__c.contains('In Dev'))
            Indev.add(req);
        else if(req.Development_Stage__c.contains('Review'))
            Indev.add(req);
        else if(req.Development_Stage__c.contains('Awaiting Release'))
            Indev.add(req);
        else if(req.Development_Stage__c.contains('Awaiting SAT'))
            AwaitingSAT.add(req);
        else if(req.Development_Stage__c.contains('In Test'))
            InSAT.add(req);
        else if(req.Development_Stage__c.contains('Done'))
            Done.add(req);
        else if(req.Development_Stage__c.contains('BPC'))
            BPC.add(req);
    }
  }
  
  // Method to change user story selection after changing dropdown values
  Public void filteredVal(){
    
    if(selvalue != null && selValue != 'All')
        DispUserStories(selvalue);
        
     else if(selvalue == null || selValue == 'All')
         DispUserStories(null);
    
    }  
 
 public void updateUserStoriesSprint(){
     String  UpdateSwing     = Apexpages.currentPage().getParameters().get('UpdateSwing');
     String  userStroyID     = Apexpages.currentPage().getParameters().get('UserStoryID');
     MICO_User_Story__c req = new MICO_User_Story__c(id=userStroyID);
     
     if(UpdateSwing == 'AwaitingDevUS')
         req.Development_Stage__c = '5.3 Sprint Team - Awaiting Development';
     else if(UpdateSwing == 'InDevUS')
         req.Development_Stage__c = '5.4 Sprint Team - In Development';
     else if(UpdateSwing == 'BacklogUS')
         req.Development_Stage__c = '5.1 Sprint Team - Sprint Backlog';
     else if(UpdateSwing == 'AwaitingSATUS')
         req.Development_Stage__c = '5.7. Sprint - Awaiting SAT';
     else if(UpdateSwing == 'InSATUS')
         req.Development_Stage__c = '5.8. Sprint - In Test';
     else if(UpdateSwing == 'DoneUS')
         req.Development_Stage__c = '5.9. Done';
          else if(UpdateSwing == 'BPC')
         req.Development_Stage__c = '5.2 Sprint Team - With BPC';
     update req;
     }
     public void addChatterComment(){
        String  chatterComment  = Apexpages.currentPage().getParameters().get('ChatterComment');
        String  userStroyID     = Apexpages.currentPage().getParameters().get('UserStoryID');
        
        if( chatterComment != '' &  userStroyID != ''){
            try{
                FeedItem post = new FeedItem();
                post.ParentId = userStroyID; //user stroy id.
                post.Body = chatterComment;  //chatter comment.
                insert post;
            }catch (System.Dmlexception e){
                System.debug(e);                
            }   
            
        }
        
    } 
}