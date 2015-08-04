public class GLBL_FormTemplateActionsWithoutSharing {
	
	/**
	 * Makes Form team member unsubscribe/subscribe to the template record  
	 */
	public static Void FollowUnfollowTemplate(list<GLBL_Form_Team__c> lfollowingTeamMembers,list<GLBL_Form_Team__c> lDeletedTeamMembers,map<id,GLBL_Form_Team__c> mfollowingOldTeamMembers,boolean isInsert,boolean isUpdate,boolean isDelete) {
		
		list<id> lformTeamMembers = new list<id>();
		list<id> lformTeamTemplates = new list<id>();
		list<EntitySubscription> lentitySubscriptionsToBeInserted = new List<EntitySubscription>();	
		list<EntitySubscription> lentitySubscriptionsToBeDeleted = new list<EntitySubscription>();
			
		If(isInsert){
		
			for(GLBL_Form_Team__c member:lfollowingTeamMembers){
				lformTeamMembers.add(member.Form_Team_Member__c);
				lformTeamTemplates.add(member.Form_Template__c);
			}
		
			list<EntitySubscription> lentitySubscriptions = [SELECT id,parentID,SubscriberID FROM EntitySubscription WHERE parentID in :lformTeamTemplates AND SubscriberID in :lformTeamMembers LIMIT 1000];				
		
			for(GLBL_Form_Team__c member:lfollowingTeamMembers){
				if(member.Follow_Template__c){	
					Boolean alreadyExists = false;		
					for(EntitySubscription s:lentitySubscriptions){
						if((s.parentID==member.Form_Template__c)&&(s.subscriberID==member.Form_Team_Member__c)){
							alreadyExists = true;
							Break;
						}
					}
					if(!alreadyExists){
						String UserID = member.Form_Team_Member__c;
						String TemplateID = member.Form_Template__c;
						lentitySubscriptionsToBeInserted.add(new EntitySubscription(ParentId = TemplateID, SubscriberID = UserID));
					}
						
				}				
			}
		}					 
		
		if(isUpdate){
						
			for(GLBL_Form_Team__c member:lfollowingTeamMembers){
				lformTeamMembers.add(member.Form_Team_Member__c);
				lformTeamTemplates.add(member.Form_Template__c);
			}
			
			list<EntitySubscription> lentitySubscriptions = [SELECT id,parentID,SubscriberID FROM EntitySubscription WHERE parentID in :lformTeamTemplates AND SubscriberID in :lformTeamMembers LIMIT 1000];
									
			for(GLBL_Form_Team__c member:lfollowingTeamMembers){
				GLBL_Form_Team__c oldMember = mfollowingOldTeamMembers.get(member.id);
				If((member.Follow_Template__c==FALSE)&&(oldMember.Follow_Template__c==TRUE)){
					for(EntitySubscription s:lentitySubscriptions){
						if((s.parentID==member.Form_Template__c)&&(s.subscriberID==member.Form_Team_Member__c)){
							lentitySubscriptionsToBeDeleted.add(s);
						}				
					}
				}
				If((member.Follow_Template__c==TRUE)&&(oldMember.Follow_Template__c==FALSE)){
					String UserID = member.Form_Team_Member__c;
					String TemplateID = member.Form_Template__c;
					lentitySubscriptionsToBeInserted.add(new EntitySubscription(ParentId = TemplateID, SubscriberID = UserID));
				}
			}
			
			
		}
		
		if(isDelete){

			
			for(GLBL_Form_Team__c member:lDeletedTeamMembers){
				lformTeamMembers.add(member.Form_Team_Member__c);
				lformTeamTemplates.add(member.Form_Template__c);
			}
	
			List<EntitySubscription> lentitySubscriptions = [SELECT id,parentID,SubscriberID FROM EntitySubscription WHERE parentID in :lformTeamTemplates AND SubscriberID in :lformTeamMembers LIMIT 1000];
			
			for(GLBL_Form_Team__c deletedMember:lDeletedTeamMembers){
				If(deletedMember.Follow_Template__c){
					for(EntitySubscription s:lentitySubscriptions){
						if((s.parentID==deletedMember.Form_Template__c)&&(s.subscriberID==deletedMember.Form_Team_Member__c)){
							lentitySubscriptionsToBeDeleted.add(s);
						}				
					}
				}					
			}
		}
			
		If(lentitySubscriptionsToBeInserted.size()>0){
			system.debug('List of entitySubscriptions' + lentitySubscriptionsToBeInserted);
			Insert lentitySubscriptionsToBeInserted;
		}
		If(lentitySubscriptionsToBeDeleted.size()>0){
			Delete lentitySubscriptionsToBeDeleted;
		}
		
		}


}