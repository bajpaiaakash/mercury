public with sharing class SSSC_NewStoryOverride_Extension {
    
  private final ApexPages.StandardController storyController;
  public String keyObjectPrefix{get;set;}
  public SSSC_NewStoryOverride_Extension(ApexPages.StandardController storyController) {
     this.storyController = storyController;
     Schema.DescribeSObjectResult result = SSSC_SafeStart_Story__c.sObjectType.getDescribe();
     keyObjectPrefix = result.getKeyPrefix();
  }
  
  public integer getStoryRedirect(){
    if(string.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost'))
      || string.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin'))
      || ApexPages.currentPage().getParameters().get('isdtp') == 'p1'
      || (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone'))){
      return null;
    }
    else{
      return 0;
    }
   }
    
   public void getthrowError(){
     ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please use desktop version for creating new SafeStart Stories!');
     ApexPages.addMessage(errorMsg);
   }
    
}