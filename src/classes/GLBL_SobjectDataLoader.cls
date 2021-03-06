/**
 * Copyright (c) 2012, Andrew Fawcett
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
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
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
 * Serializes and Deserializes SObject records and related child and referenced records using the Apex JSON support
 *
 *   See https://github.com/afawcett/apex-sobjectdataloader for known issues, restrictions and TODO's
 *
 **/
public with sharing class GLBL_SobjectDataLoader 
{
	/**
	 * Configuration uses a Fluent method design (http://en.wikipedia.org/wiki/Fluent_interface), 
	 **/
	public class SerializeConfig
	{
		protected Set<Schema.SObjectField> followRelationships;
		protected Set<Schema.SObjectField> followChildRelationships;
		protected Set<Schema.SObjectField> followMasterRelationships;
		protected Set<Schema.SObjectField> omitFields;
		
		public SerializeConfig()
		{	
			followRelationships = new Set<Schema.SObjectField>();
			followChildRelationships = new Set<Schema.SObjectField>();
			followMasterRelationships = new Set<Schema.SObjectField>();
			omitFields = new Set<Schema.SObjectField>(); 			
		}

		/**
		 * Provide a field that represents the lookup relationship the serializer should follow
		 **/
		public SerializeConfig follow(Schema.SObjectField relationshipField)
		{
			followRelationships.add(relationshipField);
			return this;
		}

		/**
		 * Provide a field that represents the lookup relationship the serializer should follow
		 **/
		public SerializeConfig followMaster(Schema.SObjectField relationshipField)
		{
			followMasterRelationships.add(relationshipField);
			return this;
		}
		
		/**
		 * Provide a field that represents a parent child relationship the serializer should follow
		 **/
		public SerializeConfig followChild(Schema.SObjectField relationshipField)
		{
			followChildRelationships.add(relationshipField);
			return this;
		}
		
		/**
		 * Provide a field that the serializer should omit from the serialized output
		 **/
		public SerializeConfig omit(Schema.SObjectField omitField)
		{
			omitFields.add(omitField);
			if(followRelationships.contains(omitField))
				followRelationships.remove(omitField);
			if(followChildRelationships.contains(omitField))
				followChildRelationships.remove(omitField);
			return this;
		}
		
		/** 
		 * Automatically configure (removes all previous configuration)
		 *  Skip known system lookup and child relationships but include the rest (direct children only) upto certain depth, 
		 *  Caller can always add or omit specific via follow or omit methods
		 **/
		public SerializeConfig auto(Schema.SObjectType sObjectType)
		{
			followRelationships = new Set<Schema.SObjectField>();
			followChildRelationships = new Set<Schema.SObjectField>();
			omitFields = new Set<Schema.SObjectField>();
			Set<Schema.SObjectType> searched = new Set<Schema.SObjectType>();
			searchRelationships(sObjectType, 0, 0, true, searched);	
			return this;	
		}

		public SerializeConfig init(Schema.SObjectType sObjectType, Integer lookupDepth, Integer childDepth, Boolean searchChildren)
		{
			if (lookupDepth==null) lookupDepth = 0;
			if (childDepth==null)  childDepth = 0;
			if (searchChildren==null) searchChildren = true;

			followRelationships = new Set<Schema.SObjectField>();
			followChildRelationships = new Set<Schema.SObjectField>();
			omitFields = new Set<Schema.SObjectField>();
			Set<Schema.SObjectType> searched = new Set<Schema.SObjectType>();
			searchRelationships(sObjectType, lookupDepth, childDepth, searchChildren, searched);	
			return this;	
		}
		public SerializeConfig init(Schema.SObjectType sObjectType, Integer lookupDepth, Integer childDepth)
		{
			return init(sObjectType, lookupDepth, childDepth, null);
		}
		public SerializeConfig init(Schema.SObjectType sObjectType, Integer lookupDepth)
		{
			return init(sObjectType, lookupDepth, null, null);
		}
		public SerializeConfig init(Schema.SObjectType sObjectType)
		{
			return auto(sObjectType);
		}
				
		/**
		 * Seek out recursively relationships
		 **/
		private void searchRelationships(Schema.SObjectType sObjectType, Integer lookupDepth, Integer childDepth, Boolean searchChildren, Set<Schema.SObjectType> searched)
		{		
			// Stop infinite recursion	
			if(searched.contains(sObjectType) || lookupDepth > 2 || childDepth > 3) // TODO: Make max depth configurable
				return;
			searched.add(sObjectType);
			Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
						
			// Following children? (only set for descendents of the top level object)
			if(searchChildren)
			{
				List<Schema.ChildRelationship> childRelationships = sObjectDescribe.getChildRelationships();
				for(Schema.ChildRelationship childRelationship : childRelationships)
				{
					// Determine which child relationships to automatically follow
					String childRelationshipName = childRelationship.getRelationshipName();
					if(childRelationshipName==null || 
					   childRelationshipWhitelist.contains(childRelationshipName)) // Skip relationships without names and those whitelisted
						continue;
					if(childRelationshipName.endsWith('Histories')) // Skip relationships ending in Histories (TODO: consider a RegEx approach?)
						continue;
					if(!childRelationship.isCascadeDelete()) // Skip relationships for none owned records (aka only follow master-detail relationships)
						continue;
					followChild(childRelationship.getField()).
						searchRelationships(childRelationship.getChildSObject(), lookupDepth, childDepth+1, true, searched);
				}
			}
							
			// Follow lookup relationships to long as they have not previously been added as child references and are not whitelisted
			Map<String, Schema.SObjectField> sObjectFields = sObjectDescribe.fields.getMap();
			for(Schema.SObjectField sObjectField : sObjectFields.values())
				if(sObjectField.getDescribe().getType() == Schema.DisplayType.Reference) 
					if(!followChildRelationships.contains(sObjectField) && !relationshipWhitelist.contains(sObjectField.getDescribe().getName()))
						follow(sObjectField).
							searchRelationships(sObjectField.getDescribe().getReferenceTo()[0], lookupDepth+1, childDepth, false, searched);
		}

		// Standard fields that are not included when using the auto config
		private Set<String> relationshipWhitelist = 
			new Set<String>
				{ 'OwnerId',
				  'CreatedById',
				  'LastModifiedById',
				  'RecordTypeId',
				  'PersonContactId'
				};
				
		// Standard child relationships that are not included when using the auto config
		private Set<String> childRelationshipWhitelist = 
			new Set<String> 
				{ 'Shares', 
				  'ProcessInstances', 
				  'ProcessSteps', 
				  'Tasks', 
				  'ActivityHistories', 
				  'Attachments', 
				  'FeedSubscriptionsForEntity', 
				  'Events', 
				  'Notes', 
				  'NotesAndAttachments', 
				  'OpenActivities', 
				  'Histories', 
				  'Feeds',
				  'PersonEmailStatuses',
				  'OpenActivities',
				  'PersonOpenActivities'};	
	}
	
	
	/**
	 * Serialize the given records using the default configuration (see SerializeConfig.auto)
	 **/
	public static String serialize(Set<Id> ids)
	{
		// Serialize based on no prior knowledge of the objects
		if(ids==null || ids.size()==0)
			throw new SerializerException('List of Ids cannot be null or empty.');
		return serialize(ids, new SerializeConfig().auto(new List<Id>(ids)[0].getSObjectType()));
	}
	
	/**
	 * Serialize the given records using the given configuration
	 **/
	public static String serialize(Set<Id> ids, SerializeConfig strategy)
	{			
		return serialize(ids, strategy, null, null);
	}
	public static String serialize(Set<Id> ids, SerializeConfig strategy, Integer lookupDepth)
	{
		return serialize(ids, strategy, lookupDepth, null);
	}
	public static String serialize(Set<Id> ids, SerializeConfig strategy, Integer lookupDepth, Integer childDepth)
	{			
		// Validate parameters
		if(ids==null || ids.size()==0)
			throw new SerializerException('List of Ids cannot be null or empty.');
		if(lookupDepth==null)
			lookupDepth = 0;
		if(childDepth==null)
			childDepth = 0;
			
		// Container to bundle record sets into    /// why not initialize these in the overridden method when a null is passed for recordsToBundle
		RecordsBundle recordsToBundle = new RecordsBundle();
		recordsToBundle.recordSetBundles = new List<RecordSetBundle>();		
		recordsToBundle.recordSetBundlesByType = new Map<String, RecordSetBundle>();
		
		// Begin recursive serialize from given records through to related records
		Schema.SObjectType sObjectType = new List<Id>(ids)[0].getSObjectType();
		serialize(ids, sObjectType, null, strategy, lookupDepth, childDepth, recordsToBundle);  // Mmmm... we seem to be setting the lookupDepth and childDepth here and within the SerializeConfig...
				
		// Serialise the records bundle container		
		return JSON.serialize(recordsToBundle);		 		
	}


// this serialize method is fundementally different from the two serialize methods above!! 
	private static void serialize(Set<ID> ids, Schema.SObjectType sObjectType, Schema.SObjectField queryByIdField, SerializeConfig config, Integer lookupDepth, Integer childDepth, RecordsBundle recordsToBundle)
	{		
		// Config?
		if(config==null)
			throw new SerializerException('Must pass a valid SerializeConfig instance.');
		// Stop infinite recursion
		if(lookupDepth > 3 || childDepth > 3) // TODO: Make max depth configurable
			return;  // return nothing?? why not return new SerializerException?
			
		// Describe object and determine fields to serialize
		Schema.DescribeSObjectResult sObjectDesc = sObjectType.getDescribe();
		Map<String, Schema.SObjectField> sObjectFields = sObjectDesc.fields.getMap();
		List<Schema.SObjectField> sObjectFieldsToSerialize = listFieldsToSerialize(sObjectFields, config);
		
		// Query records to serialize
		String fieldList = null;
		for(Schema.SObjectField sObjectField : sObjectFieldsToSerialize)
			fieldList = fieldList == null ? sObjectField.getDescribe().getName() : fieldList + ',' + sObjectField.getDescribe().getName();
		String query = String.format('select {0} from {1} where {2} in :ids order by {2}', 
			new List<String> { fieldList, sObjectDesc.getName(), queryByIdField == null ? 'id' : queryByIdField.getDescribe().getName(), 'Name' });
		Map<Id, SObject> recordsToSerializeById = new Map<Id, SObject>(Database.query(query));
		if(recordsToSerializeById.size()==0)
			return;

		// Any lookup relationships to folow?
		Set<Schema.SObjectField> sObjectFollowRelationships = config.followRelationships.clone();
		sObjectFollowRelationships.retainAll(sObjectFields.values());
		if(sObjectFollowRelationships.size()>0)
		{				
			// Build list of ID's for each related record
			Map<Schema.DescribeFieldResult, Set<Id>> relationshipsByField = new Map<Schema.DescribeFieldResult, Set<Id>>(); 
			for(Schema.SObjectField sObjectField : sObjectFollowRelationships)
				relationShipsByField.put(sObjectField.getDescribe(), new Set<Id>() );			
			for(SObject recordToSerialize : recordsToSerializeById.values())
			{
				for(Schema.DescribeFieldResult relationshipField : relationshipsByField.keySet())
				{
					Id relatedId = (Id) recordToSerialize.get(relationshipField.getSObjectField());
					if(relatedId!=null)
						relationshipsByField.get(relationshipField).add(relatedId);
				}
			}
			// Serialise related records
			for(Schema.DescribeFieldResult relationshipField : relationshipsByField.keySet())
			{
				Set<Id> relatedRecordIds = relationshipsByField.get(relationshipField);
				if(relatedRecordIds.size()>0)
					serialize(relatedRecordIds, relationshipField.getReferenceTo()[0], null, config, lookupDepth+1, childDepth, recordsToBundle);					
			}
		}
					
		// Add records to applicable record set bundle
		RecordSetBundle recordSetBundle = recordsToBundle.recordSetBundlesByType.get(sObjectDesc.getName());
		if(recordSetBundle!=null)
		{
			recordSetBundle.Records.addAll(recordsToSerializeById.values());
		}
		else if(recordSetBundle==null)
		{
			recordSetBundle = new RecordSetBundle();
			recordSetBundle.ObjectType = sObjectDesc.getName();
			recordSetBundle.Records = recordsToSerializeById.values();
			recordsToBundle.recordSetBundles.add(recordSetBundle);
			recordsToBundle.recordSetBundlesByType.put(recordSetBundle.ObjectType, recordSetBundle);
		}
				
		// Any child relationships to follow?
		List<Schema.ChildRelationship> childRelationships = sObjectDesc.getChildRelationships();
		for(Schema.ChildRelationship childRelationship : childRelationships)
		{ 
			// Is this a child relationship we have been asked to follow?
			Schema.SObjectType childSObjectType = childRelationship.getChildSObject();
			if(config.followChildRelationships.contains(childRelationship.getField()))
				serialize(recordsToSerializeById.keySet(), childSObjectType, childRelationship.getField(), config, lookupDepth, childDepth+1, recordsToBundle);
		}
	}

	/**
	 * Deserialize the given JSON record set bundle
	 **/
	public static Set<Id> deserialize(String recordsBundleAsJSON)
	{
		return deserialize(recordsBundleAsJSON, null);
	}
		
	/**
	 * Deserialize the given JSON record set bundle utilising the given callback
	 **/
	public static Set<Id> deserialize(String recordsBundleAsJSON, IDeserializeCallback callback)
	{
		// Desearialise the records bundle
		RecordsBundle recordsBundle = (RecordsBundle) 
			JSON.deserialize(recordsBundleAsJSON, GLBL_SobjectDataLoader.RecordsBundle.class);
		
		// Map to track original ID's against the new SObject record instances being inserted
		Map<Id, SObject> recordsByOriginalId = new Map<Id, SObject>();
		
		// Record set bundles are already ordered in dependency order due to serialisation approach
		Map<String, Schema.SObjectType> sObjectsByType = Schema.getGlobalDescribe();
		for(RecordSetBundle recordSetBundle : recordsBundle.recordSetBundles)
		{
			// Determine lookup / relationship fields to update prior to inserting these records
			Schema.SObjectType sObjectType = sObjectsByType.get(recordSetBundle.ObjectType);
			Map<String, Schema.SObjectField> sObjectFields = sObjectType.getDescribe().fields.getMap();
			List<Schema.SObjectField> relationshipsFields = new List<Schema.SObjectField>();
			for(Schema.SObjectField sObjectField : sObjectFields.values())
				if(sObjectField.getDescribe().getType() == Schema.DisplayType.Reference) 
					relationshipsFields.add(sObjectField);
									
			// Prepare records for insert
			List<SObject> recordsToInsert = new List<SObject>();
			List<UnresolvedReferences> unresolvedReferencesByRecord = new List<UnresolvedReferences>(); 
			for(SObject orignalRecord : recordSetBundle.Records)
			{
				// Clone the deserialised SObject to remove the original Id prior to inserting it
				SObject newRecord = orignalRecord.clone();
				recordsToInsert.add(newRecord);
				// Map the new cloned record to its old Id (once inserted this can be used to obtain the new id)
				recordsByOriginalId.put(orignalRecord.Id, newRecord);
				// Update foreign key references / lookups / master-detail relationships
				if(relationshipsFields.size()>0)
				{
					Set<Schema.SObjectField> unresolvedFieldReferences = new Set<Schema.SObjectField>(); 
					for(Schema.SObjectField sObjectField : relationshipsFields)
					{							
						// Obtained original related record Id and search map over new records by old Ids
						Id oldRelatedRecordId = (Id) orignalRecord.get(sObjectField);
						SObject newRelatedRecord = recordsByOriginalId.get(oldRelatedRecordId);
						if(newRelatedRecord!=null)
							newRecord.put(sObjectField, newRelatedRecord.Id);
						else
							unresolvedFieldReferences.add(sObjectField);
					}
					// Retain a list of records with unresolved references
					if(unresolvedFieldReferences.size()>0)
					{
						UnresolvedReferences unresolvedReferences = new UnresolvedReferences();
						unresolvedReferences.Record = newRecord;
						unresolvedReferences.References = unresolvedFieldReferences;
						unresolvedReferencesByRecord.add(unresolvedReferences);
					}	
				}
			}			
			
			// Let the caller attempt to resolve any references the above could not
			if(callback!=null && unresolvedReferencesByRecord.size()>0)
				callback.unresolvedReferences(sObjectType, unresolvedReferencesByRecord);
			
			if(callback!=null)
				callback.cloneMapHandler(recordsByOriginalId);

			// Insert cloned deserialised records
			recordSetBundle.Records = recordsToInsert;
			insert recordSetBundle.Records;
		}
		
		// Return Id list from the first bundle set
		return new Map<Id, SObject>(recordsBundle.recordSetBundles[0].Records).keySet();
	}
				
	private static List<Schema.SObjectField> listFieldsToSerialize(Map<String, Schema.SObjectField> sObjectFields, SerializeConfig config)
	{
		// Filter fields to serialise
		List<Schema.SObjectField> serializeFields = new List<Schema.SObjectField>(); 
		List<String> fieldNames = new List<String>(sObjectFields.keySet());
		fieldNames.sort();
		for(String fieldName : fieldNames)
		{
			// Skip fields indicated in config
			Schema.SObjectField sObjectField = sObjectFields.get(fieldName);
			if(config.omitFields!=null && config.omitFields.contains(sObjectField))
				continue;
			// Skip read only fields, such as auto numbers and formula fields
			Schema.DescribeFieldResult sObjectFieldDescribe = sObjectField.getDescribe();
			if(sObjectFieldDescribe.isAutoNumber() ||
			   sObjectFieldDescribe.isCalculated())
			   continue;	
			// Skip lookup fields not in either of the follow lists
			if(sObjectFieldDescribe.getType() == Schema.DisplayType.Reference)
				if(!(config.followRelationships.contains(sObjectField) ||
				     config.followChildRelationships.contains(sObjectField) ||
				     config.followMasterRelationships.contains(sObjectField)))
				   continue;
			// Serialize this field..						
			serializeFields.add(sObjectField);
		}			
		return serializeFields;	
	}
	
	/** 
	 * General exception class
	 **/
	public class SerializerException extends Exception
	{
		
	}
	
	/**
	 * Callback used during deserialization
	 **/
	public interface IDeserializeCallback
	{
		/**
		 * Used during deserialization to allow caller to attempt to resolve references not resolved but required to insert records
		 **/
		void unresolvedReferences(Schema.SObjectType sObjectType, List<UnresolvedReferences> unresolvedReferences);
		void cloneMapHAndler(Map<Id, SObject> cloneMap);
	}
	
	/**
	 * Used during deserialization to allow caller to attempt to resolve references not resolved but required to insert records
	 **/
	public class UnresolvedReferences
	{
		public SObject Record;
		public Set<Schema.SObjectField> References;
	}
	
	/**
	 * Internal Apex represnetation of the serialized output for all recordsets
	 **/
	private class RecordsBundle
	{
		// Order of bundle sets is important
		public List<RecordSetBundle> RecordSetBundles;			
		// Used by serialiser to group records by type during recursion
		public transient Map<String, RecordSetBundle> RecordSetBundlesByType;
	}
	
	/**
	 * Internal Apex represnetation of the serialized output for a given recordset
	 **/
	private class RecordSetBundle
	{
		// Groups records by type
		public String ObjectType;
		public List<SObject> Records;	
	}
}