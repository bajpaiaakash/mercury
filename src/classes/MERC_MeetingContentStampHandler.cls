/**
 * @author Kyle Thornton
 *
 * Trigger handler to stamp up to three products on content version in the Product_1_Merc__c, Product_2_Merc__c, Product_3_Merc__c fields
 * when content is associated to a meeting. The products are chosen randomly from the products related list on the meeting but the
 * business assumption is that there are never more than three products.
 */

public with sharing class MERC_MeetingContentStampHandler implements GLBL_TriggerHandler.HandlerInterface
{
	public Boolean isActive()
	{
		return true;
	}
	
	public void handle()
	{
		Id contentTypeId = [Select Id From RecordType WHERE DeveloperName = 'Meeting_MERC' AND SobjectType = 'ContentVersion' LIMIT 1].Id;

		Set<Id> mtgIds = new Set<Id>();
		for (ContentVersion cv : (List<ContentVersion>)Trigger.new)
		{
			if (cv.RecordTypeId == contentTypeId && cv.Meeting_MERC__c != null)
			{
				mtgIds.add(cv.Meeting_MERC__c);
			}
		}

		Map<Id, Meeting_MERC__c> mtgs = new Map<Id, Meeting_MERC__c>([SELECT Id
			                                                               , (SELECT Id, Product_MERC__c FROM Meeting_Products__r)
			                                                            FROM Meeting_MERC__c
			                                                            WHERE ID IN :mtgIds]);
		for (ContentVersion cv : (List<ContentVersion>)Trigger.new)
		{
			if (cv.RecordTypeId == contentTypeId && cv.Meeting_MERC__c != null)
			{
				if (mtgs.containsKey(cv.Meeting_MERC__c))
				{
					Meeting_MERC__c mtg = mtgs.get(cv.Meeting_MERC__c);
					if (mtg.Meeting_Products__r.size() >= 1)
						cv.Product_1_MERC__c = mtg.Meeting_Products__r.get(0).Product_MERC__c;
					if (mtg.Meeting_Products__r.size() >= 2)
						cv.Product_2_MERC__c = mtg.Meeting_Products__r.get(1).Product_MERC__c;
					if (mtg.Meeting_Products__r.size() >= 3)
						cv.Product_3_MERC__c = mtg.Meeting_Products__r.get(2).Product_MERC__c;
				}
			}
		}
	}

}