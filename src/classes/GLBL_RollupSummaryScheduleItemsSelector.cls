/**
 * Copyright (c) 2013, Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public with sharing class GLBL_RollupSummaryScheduleItemsSelector extends GLBL_SObjectSelector 
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			LookupRollupSummaryScheduleItems_GLBL__c.Name,
			LookupRollupSummaryScheduleItems_GLBL__c.ParentId_GLBL__c,
			LookupRollupSummaryScheduleItems_GLBL__c.LookupRollupSummary_GLBL__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return LookupRollupSummaryScheduleItems_GLBL__c.sObjectType;
	}
	
	public override String getOrderBy()
	{
		return 'LookupRollupSummary_GLBL__r.ParentObject_GLBL__c';
	}
	
	public Database.Querylocator selectAllQueryLocator()
	{
		assertIsAccessible();
		return Database.getQueryLocator(String.format('SELECT {0} FROM {1} ORDER BY {2}',
			new List<String>{getFieldListString(),getSObjectName(),getOrderBy()}));
	}

	public List<LookupRollupSummaryScheduleItems_GLBL__c> selectById(Set<ID> idSet)
	{
		return (List<LookupRollupSummaryScheduleItems_GLBL__c>) selectSObjectsById(idSet);
	}
}