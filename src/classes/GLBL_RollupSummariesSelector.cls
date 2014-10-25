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

/**
 * Various queries for the Lookup Rollup Summary custom object
 **/
public with sharing class GLBL_RollupSummariesSelector extends GLBL_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			LookupRollupSummary_GLBL__c.Name,
			LookupRollupSummary_GLBL__c.Active_GLBL__c,
			LookupRollupSummary_GLBL__c.AggregateOperation_GLBL__c,
			LookupRollupSummary_GLBL__c.AggregateResultField_GLBL__c,
			LookupRollupSummary_GLBL__c.CalculationMode_GLBL__c,
			LookupRollupSummary_GLBL__c.ChildObject_GLBL__c,
			LookupRollupSummary_GLBL__c.FieldToAggregate_GLBL__c,
			LookupRollupSummary_GLBL__c.ParentObject_GLBL__c,
			LookupRollupSummary_GLBL__c.RelationshipCriteria_GLBL__c,
			LookupRollupSummary_GLBL__c.RelationshipCriteriaFields_GLBL__c,
			LookupRollupSummary_GLBL__c.RelationshipField_GLBL__c,
			LookupRollupSummary_GLBL__c.CalculateJobId_GLBL__c,
			LookupRollupSummary_GLBL__c.TreatZeroAsNull_GLBL__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return LookupRollupSummary_GLBL__c.sObjectType;
	}

	public List<LookupRollupSummary_GLBL__c> selectById(Set<ID> idSet)
	{
		return (List<LookupRollupSummary_GLBL__c>) selectSObjectsById(idSet);
	}
	/**
	 * Returns active lookup rollup summary definitions for thr given calculation mode and child object
	 **/
	public List<LookupRollupSummary_GLBL__c> selectActiveByChildObject(GLBL_RollupSummaries.CalculationMode calculationMode, Set<String> childObjectNames)
	{
		return selectActiveByChildObject(new List<GLBL_RollupSummaries.CalculationMode> { calculationMode }, childObjectNames);
	}

	/**
	 * Returns active lookup rollup summary definitions for thr given calculation modes and child object
	 **/
	public List<LookupRollupSummary_GLBL__c> selectActiveByChildObject(List<GLBL_RollupSummaries.CalculationMode> calculationModes, Set<String> childObjectNames)
	{
		assertIsAccessible();
		List<String> calculationModeNames = new List<String>();
		for(GLBL_RollupSummaries.CalculationMode calculationMode : calculationModes)
			calculationModeNames.add(calculationMode.name());

		return Database.query(String.format(
			'select {0} from {1} where CalculationMode_GLBL__c in :calculationModeNames and ChildObject_GLBL__c in :childObjectNames and Active_GLBL__c = true order by ParentObject_GLBL__c, RelationshipField_GLBL__c',
				new List<String>{getFieldListString(),
					getSObjectName(),
					getOrderBy()}));
	}
}