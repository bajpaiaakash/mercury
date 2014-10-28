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
 * Validation and other behaviour for the Lookup Rollup Summary custom object
 **/
public with sharing class GLBL_RollupSummaries extends GLBL_SObjectDomain
{
	/**
	 * Maps LookupRollupSummary_GLBL__c.AggregateOperation_GLBL__c picklist values to GLBL_LREngine.RollupOperation enum
	 **/
	public static Map<String, GLBL_LREngine.RollupOperation> OPERATION_PICKLIST_TO_ENUMS = new Map<String, GLBL_LREngine.RollupOperation> 
		{
			AggregateOperation.Sum.name() => GLBL_LREngine.RollupOperation.Sum,
        	AggregateOperation.Max.name() => GLBL_LREngine.RollupOperation.Max,
	        AggregateOperation.Min.name() => GLBL_LREngine.RollupOperation.Min,
	        AggregateOperation.Avg.name() => GLBL_LREngine.RollupOperation.Avg,
	        AggregateOperation.Count.name() => GLBL_LREngine.RollupOperation.Count			
		};
	
	/**
	 * Enum reflecting CalculationMode_GLBL__c field picklist values
	 **/
	public enum CalculationMode
	{
		Realtime, 
		Scheduled, 
		Developer
	}
	
	/**
	 * Enum reflecting AggregateOperation_GLBL__c field picklist values
	 **/
	public enum AggregateOperation 
	{
        Sum,
        Max, 
        Min,
        Avg,
        Count
    }
		
	public GLBL_RollupSummaries(List<LookupRollupSummary_GLBL__c> records)
	{
		super(records);
	}
	
	/**
	 * Validations for inserts and updates of records
	 **/ 
	public override void onValidate()
	{
		// Query for any related Apex triggers
		Set<String> rollupTriggerNames = new Set<String>();
		for(LookupRollupSummary_GLBL__c lookupRollupSummary : (List<LookupRollupSummary_GLBL__c>) Records)
			rollupTriggerNames.add(makeTriggerName(lookupRollupSummary));
		system.debug(' ----> rollupTriggerNames: '+rollupTriggerNames);
		Map<String, ApexTrigger> apexTriggers = new GLBL_ApexTriggersSelector().selectByName(rollupTriggerNames);
		system.debug(' ----> apexTriggers: '+apexTriggers);
		// Cache Apex Describes		
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Map<SObjectType, Map<String, Schema.SObjectField>> gdFields = new Map<SObjectType, Map<String, Schema.SObjectField>>(); 	
		for(LookupRollupSummary_GLBL__c lookupRollupSummary : (List<LookupRollupSummary_GLBL__c>) Records)
		{
			SObjectType parentObjectType = gd.get(lookupRollupSummary.ParentObject_GLBL__c);
			SObjectType childObjectType = gd.get(lookupRollupSummary.ChildObject_GLBL__c);
			if(parentObjectType!=null && !gdFields.containsKey(parentObjectType))
				gdFields.put(parentObjectType, parentObjectType.getDescribe().fields.getMap());
			if(childObjectType!=null && !gdFields.containsKey(childObjectType))
				gdFields.put(childObjectType, childObjectType.getDescribe().fields.getMap());
		}
		
		for(LookupRollupSummary_GLBL__c lookupRollupSummary : (List<LookupRollupSummary_GLBL__c>) Records)
		{
			// Parent Object valid?
			SObjectType parentObjectType = gd.get(lookupRollupSummary.ParentObject_GLBL__c);
			if(parentObjectType==null)
				lookupRollupSummary.ParentObject_GLBL__c.addError(error('Object does not exist.', lookupRollupSummary, LookupRollupSummary_GLBL__c.ParentObject_GLBL__c));				
			// Child Object valid?
			SObjectType childObjectType = gd.get(lookupRollupSummary.ChildObject_GLBL__c);
			if(childObjectType==null)
				lookupRollupSummary.ChildObject_GLBL__c.addError(error('Object does not exist.', lookupRollupSummary, LookupRollupSummary_GLBL__c.ChildObject_GLBL__c));
			// Child Object fields valid?
			SObjectField relationshipField = null;
			SObjectField fieldToAggregate = null;
			Map<String, Schema.SObjectField> childObjectFields = gdFields.get(childObjectType);
			if(childObjectFields!=null)
			{
				// Relationship field valid?
				relationshipField = childObjectFields.get(lookupRollupSummary.RelationshipField_GLBL__c);
				if(relationshipField==null)
					lookupRollupSummary.RelationshipField_GLBL__c.addError(error('Field does not exist.', lookupRollupSummary, LookupRollupSummary_GLBL__c.RelationshipField_GLBL__c));
				// Field to Aggregate valid?
				fieldToAggregate = childObjectFields.get(lookupRollupSummary.FieldToAggregate_GLBL__c);
				if(fieldToAggregate==null)
					lookupRollupSummary.FieldToAggregate_GLBL__c.addError(error('Field does not exist.', lookupRollupSummary, LookupRollupSummary_GLBL__c.FieldToAggregate_GLBL__c));
				// TODO: Validate relationship field is a lookup to the parent
				// ...
			}
			// Parent Object fields valid?
			SObjectField aggregateResultField = null;
			Map<String, Schema.SObjectField> parentObjectFields = gdFields.get(parentObjectType);
			if(parentObjectFields!=null)
			{
				// Aggregate Result field valid?
				aggregateResultField = parentObjectFields.get(lookupRollupSummary.AggregateResultField_GLBL__c);
				if(aggregateResultField==null)
					lookupRollupSummary.AggregateResultField_GLBL__c.addError(error('Field does not exist.', lookupRollupSummary, LookupRollupSummary_GLBL__c.AggregateResultField_GLBL__c));
			}						
			// Cannot activate Realtime or Scheduled rollup without the required trigger deployed
			String triggerName = makeTriggerName(lookupRollupSummary); 
			system.debug(' ----> TRIGGER NAME: '+triggerName);
			system.debug(' ----> APEX TRIGGERS: '+apexTriggers);
			if(lookupRollupSummary.Active_GLBL__c &&
				!lookupRollupSummary.OverrideTriggerValidation_GLBL__c &&
			   (lookupRollupSummary.CalculationMode_GLBL__c == CalculationMode.Realtime.name() ||
			    lookupRollupSummary.CalculationMode_GLBL__c == CalculationMode.Scheduled.name()) && 
			   !apexTriggers.containsKey(triggerName))
				lookupRollupSummary.Active_GLBL__c.addError(error('Apex Trigger ' + triggerName + ' has not been deployed. Click Manage Child Trigger and try again.', lookupRollupSummary, LookupRollupSummary_GLBL__c.Active_GLBL__c));
			// Check the list of fields expressed in the relationship critiera fields
			if(lookupRollupSummary.RelationshipCriteriaFields_GLBL__c!=null)
			{
				String[] fieldList = lookupRollupSummary.RelationshipCriteriaFields_GLBL__c.split('\r\n');
				String[] fieldsInError = new List<String>();
				for(String field : fieldList)
					if(childObjectFields.get(field)==null)
						fieldsInError.add(field);
				if(fieldsInError.size()==1)
					lookupRollupSummary.RelationshipCriteriaFields_GLBL__c.addError(error('Field ' + fieldsInError[0] + ' does not exist on the child object.', lookupRollupSummary, LookupRollupSummary_GLBL__c.RelationshipCriteriaFields_GLBL__c));
				else if(fieldsInError.size()>1)
					lookupRollupSummary.RelationshipCriteriaFields_GLBL__c.addError(error('Fields ' + String.join(fieldsInError, ',') + ' do not exist on the child object.', lookupRollupSummary, LookupRollupSummary_GLBL__c.RelationshipCriteriaFields_GLBL__c));
			} 	
			try
			{
				// If all objects and fields valid...
				if(parentObjectType!=null &&
				   childObjectType!=null &&
				   relationshipField!=null &&
				   aggregateResultField!=null &&
				   fieldToAggregate!=null)
				{
					// Validate via GLBL_LREngine context
					GLBL_LREngine.Context lreContext = new GLBL_LREngine.Context(
						parentObjectType, // parent object
		                childObjectType,  // child object
		                relationshipField.getDescribe(), // relationship field name
		                lookupRollupSummary.RelationShipCriteria_GLBL__c); 
					lreContext.add(
			            new GLBL_LREngine.RollupSummaryField(
							aggregateResultField.getDescribe(),
							fieldToAggregate.getDescribe(),
							OPERATION_PICKLIST_TO_ENUMS.get(lookupRollupSummary.AggregateOperation_GLBL__c)));
				}
			}
			catch (GLBL_LREngine.BadRollUpSummaryStateException e)
			{
				// Associate exception message with the lookup rollup summary error
				lookupRollupSummary.addError(error(e.getMessage(), lookupRollupSummary));	
			} 											
		}
	}
	
	public class Constructor implements GLBL_SObjectDomain.IConstructable
	{
		public GLBL_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new GLBL_RollupSummaries(sObjectList);
		}
	}	
	
	/**
	 * Trigger name for given lookup rollup summary
	 **/
	public static String makeTriggerName(LookupRollupSummary_GLBL__c lookupRollupSummary)
	{
		if(Test.isRunningTest() && lookupRollupSummary.ChildObject_GLBL__c == 'Opportunity')
			return 'GLBL_RollupServiceTestTrigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ChildObject_GLBL__c == 'LookupChild__c')
			return 'GLBL_RollupServiceTest2Trigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ChildObject_GLBL__c == 'Account')
			return 'GLBL_RollupServiceTest3Trigger';
		else		
			return 'GLBL_' + lookupRollupSummary.ChildObject_GLBL__c.replace('__c', '').replace('_GLBL', '').replace('__', '_') + 'Trigger';
	}
	
	/**
	 * Apex test name for given lookup rollup summary
	 **/
	public static String makeTriggerTestName(LookupRollupSummary_GLBL__c lookupRollupSummary)
	{
		if(Test.isRunningTest() && lookupRollupSummary.ChildObject_GLBL__c == 'Opportunity')
			return 'GLBL_RollupSummariesTest';
		else
			return 'GLBL_' + lookupRollupSummary.ChildObject_GLBL__c.replace('__c', '').replace('_GLBL', '').replace('__', '_') + 'Test';
	}
}