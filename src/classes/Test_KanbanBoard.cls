public class Test_KanbanBoard{

public static testmethod void TestControlleroad(){
MICO_Sprint__c sp1 = new MICO_Sprint__c();
sp1.Name = 'Sprint 1A';
insert sp1;

MICO_User_Story__c Req = new MICO_User_Story__c();
Req.Proposed_Sprint__c = sp1.Id;
Req.Allocated_Sprint__c = sp1.Id;
Req.Development_Stage__c = 'BackLog';
Req.User__c = UserInfo.getUserId();
Req.Supporting_BA__c = UserInfo.getUserId();
Req.Release_Steps_Manual__c= 'N/A';
Req.Release_Steps_Automated__c = 'N/A';
Req.Version__c = 'N/A';
Req.Validation_steps__c = 'N/A';
Req.Release_Completeness__c = true;
insert Req;

PageReference pageRef = Page.DigitalKanban;
Test.setCurrentPage(pageRef);
ApexPages.currentPage().getParameters().put('id', sp1.Id);
ApexPages.StandardController cnt = new ApexPages.StandardController(Req);
KanbanBoardCntrl KBC = new KanbanBoardCntrl(cnt);
KBC.getsprintval();
KBC.getFuncval();
ApexPages.currentPage().getParameters().put('UpdateSwing', 'AwaitingDevUS');
ApexPages.currentPage().getParameters().put('UserStoryID', req.Id);

KBC.updateUserStoriesSprint();
ApexPages.currentPage().getParameters().put('UpdateSwing', 'InDevUS');
KBC.updateUserStoriesSprint();
ApexPages.currentPage().getParameters().put('UpdateSwing', 'BacklogUS');
KBC.updateUserStoriesSprint();
ApexPages.currentPage().getParameters().put('UpdateSwing', 'AwaitingSATUS');
KBC.updateUserStoriesSprint();
ApexPages.currentPage().getParameters().put('UpdateSwing', 'DoneUS');
KBC.updateUserStoriesSprint();
ApexPages.currentPage().getParameters().put('UpdateSwing', 'InSATUS');
KBC.updateUserStoriesSprint();
ApexPages.currentPage().getParameters().put('UpdateSwing', 'BPC');
KBC.updateUserStoriesSprint();
ApexPages.currentPage().getParameters().put('ChatterComment', 'DoneUS');
KBC.addChatterComment();
KBC.filteredVal();
KBC.selvalue  = sp1.Name;
KBC.filteredVal();
KBC.funcSelValue = 'Market Access';
KBC.DispUserStories(sp1.Name);
KBC.DispUserStories(null);

} 
}