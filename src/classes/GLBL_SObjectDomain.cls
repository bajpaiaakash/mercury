/**
 * Copyright (c), Andrew Fawcett,
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
 * Base class aiding in the implemetnation of a Domain Model around SObject collections
 * 
 * Domain (software engineering). “a set of common requirements, terminology, and functionality 
 * for any software program constructed to solve a problem in that field”,
 * http://en.wikipedia.org/wiki/Domain_(software_engineering)
 *
 * Domain Model, “An object model of the domain that incorporates both behavior and data.”, 
 * “At its worst business logic can be very complex. Rules and logic describe many different "
 * "cases and slants of behavior, and it's this complexity that objects were designed to work with...” 
 * Martin Fowler, EAA Patterns
 * http://martinfowler.com/eaaCatalog/domainModel.html
 *
 **/
public virtual with sharing class GLBL_SObjectDomain
{
	public List<SObject> Records { get; private set;}
	
	public Schema.DescribeSObjectResult SObjectDescribe {get; private set;}
			
	public static ErrorFactory Errors  {get; private set;}
	
	public static TestFactory Test  {get; private set;}
	
	static
	{
		Errors = new ErrorFactory();
		
		Test = new TestFactory();
	}
	
	public GLBL_SObjectDomain(List<SObject> sObjectList)
	{
		Records = sObjectList;
		
		SObjectDescribe = Records.getSObjectType().getDescribe();
	}
	
	/**
	 * Override this to apply defaults to the records, this is called by the handleBeforeInsert method
	 **/
	public virtual void onApplyDefaults() { }
	
	/**
	 * Override this to apply general validation to be performed during insert or update, called by the handleAfterInsert and handleAfterUpdate methods
	 **/
	public virtual void onValidate() {	}
	
	/**
	 * Override this to apply validation to be performed during insert, called by the handleAfterUpdate method
	 **/
	public virtual void onValidate(Map<Id,SObject> existingRecords)	{ }

	/**
	 * Override this to perform processing during the before insert phase, this is called by the handleBeforeInsert method
	 **/
    public virtual void onBeforeInsert() { }
    
	/**
	 * Override this to perform processing during the before update phase, this is called by the handleBeforeUpdate method
	 **/
    public virtual void onBeforeUpdate(Map<Id,SObject> existingRecords) { }
    
	/**
	 * Override this to perform processing during the before delete phase, this is called by the handleBeforeDelete method
	 **/
    public virtual void onBeforeDelete() { }
    
	/**
	 * Override this to perform processing during the after insert phase, this is called by the handleAfterInsert method
	 **/
    public virtual void onAfterInsert() { }
    
	/**
	 * Override this to perform processing during the after update phase, this is called by the handleAfterUpdate method
	 **/    
    public virtual void onAfterUpdate(Map<Id,SObject> existingRecords) { }
    
	/**
	 * Override this to perform processing during the after delete phase, this is called by the handleAfterDelete method
	 **/    
    public virtual void onAfterDelete() { }	
	
	/**
	 * Base handler for the Apex Trigger event Before Insert, calls the onApplyDefaults method, followed by onBeforeInsert
	 **/
    public virtual void handleBeforeInsert() 
    { 
    	onApplyDefaults(); 
    	onBeforeInsert();
    }
    
    /**
     * Base handler for the Apex Trigger event Before Update, calls the onBeforeUpdate method
     **/
    public void handleBeforeUpdate(Map<Id,SObject> existingRecords) 
    {
    	onBeforeUpdate(existingRecords);
    }
    
    /**
     * Base handler for the Apex Trigger event Before Delete, calls the onBeforeDelete method
     **/
    public void handleBeforeDelete() 
    {
    	onBeforeDelete();
    }
    
    /**
     * Base handler for the Apex Trigger event After Insert, checks object security and calls the onValidate and onAfterInsert methods
     *
     * @throws DomainException if the current user context is not able to create records
     **/
    public void handleAfterInsert()
    {
    	if(!SObjectDescribe.isCreateable())
    	   throw new DomainException('Permission to create an ' + SObjectDescribe.getName() + ' denied.');
    	   
    	onValidate();
    	onAfterInsert(); 
    }
    
    /**
     * Base handler for the Apex Trigger event After Update, checks object security and calls the onValidate, onValidate(Map<Id,SObject>) and onAfterUpdate methods
     *
     * @throws DomainException if the current user context is not able to update records
     **/
    public void handleAfterUpdate(Map<Id,SObject> existingRecords) 
    {
    	if(!SObjectDescribe.isUpdateable())
    	   throw new DomainException('Permission to udpate an ' + SObjectDescribe.getName() + ' denied.');
    	   
    	onValidate();
    	onValidate(existingRecords);
    	onAfterUpdate(existingRecords); 
    }
    
    /**
     * Base handler for the Apex Trigger event After Delete, checks object security and calls the onAfterDelete method
     *
     * @throws DomainException if the current user context is not able to delete records
     **/
    public void handleAfterDelete() 
    {
    	if(!SObjectDescribe.isDeletable())
    	   throw new DomainException('Permission to delete an ' + SObjectDescribe.getName() + ' denied.');
    	   
    	onAfterDelete();
    }	
	
	public interface IConstructable
	{
		GLBL_SObjectDomain construct(List<SObject> sObjectList);
	}
	
	/**
	 * Method constructs the given Domain class with the current Trigger context 
	 * before calling the applicable override methods such as beforeInsert, beforeUpdate etc.
	 **/
	public static void triggerHandler(Type domainClass)
	{
		// Construct the domain class constructor class
		String domainClassName = domainClass.getName();
		Type constructableClass = domainClassName.endsWith('Constructor') ? Type.forName(domainClassName) : Type.forName(domainClassName+'.Constructor');
		IConstructable constructor = (IConstructable) constructableClass.newInstance();
		
		// Process the trigger context
		if(System.Test.isRunningTest() & Test.Database.hasRecords())
		{
			// If in test context and records in the mock database delegate initially to the mock database trigger handler
			Test.Database.testTriggerHandler(constructor);
		}
		else
		{
			// Process the runtime Apex Trigger context 
			triggerHandler(constructor, 
				Trigger.isBefore, 
				Trigger.isAfter, 
				Trigger.isInsert, 
				Trigger.isUpdate, 
				Trigger.isDelete, 
				Trigger.new, 
				Trigger.oldMap);
		}
	}
	
	/**
	 * Calls the applicable override methods such as beforeInsert, beforeUpdate etc. based on a Trigger context
	 **/
	private static void triggerHandler(IConstructable domainConstructor, Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete, List<SObject> newRecords, Map<Id, SObject> oldRecordsMap)
	{	
		if(isBefore)
	    {
	        if(isInsert) domainConstructor.construct(newRecords).handleBeforeInsert();
	        else if(isUpdate) domainConstructor.construct(newRecords).handleBeforeUpdate(oldRecordsMap);
	        else if(isDelete) domainConstructor.construct(oldRecordsMap.values()).handleBeforeDelete();
	    }
	    else
	    {
	        if(isInsert) domainConstructor.construct(newRecords).handleAfterInsert();
	        else if(isUpdate) domainConstructor.construct(newRecords).handleAfterUpdate(oldRecordsMap);
	        else if(isDelete) domainConstructor.construct(oldRecordsMap.values()).handleAfterDelete();
	    }				
	}
	
	public class DomainException extends Exception
	{
	}

	public String error(String message, SObject record)
	{
		return Errors.error(this, message, record);	
	}
	
	public String error(String message, SObject record, SObjectField field)
	{
		return Errors.error(this, message, record, field);	
	}
	
	public class ErrorFactory
	{
		private List<Error> errorList = new List<Error>(); 
		
		private ErrorFactory()
		{
			
		}
		
		public String error(String message, SObject record)
		{
			return error(null, message, record);	
		}

		private String error(GLBL_SObjectDomain domain, String message, SObject record)
		{
			ObjectError objectError = new ObjectError();
			objectError.domain = domain;
			objectError.message = message;
			objectError.record = record;
			errorList.add(objectError);
			return message;	
		}
		
		public String error(String message, SObject record, SObjectField field)
		{
			return error(null, message, record, field);	
		}

		private String error(GLBL_SObjectDomain domain, String message, SObject record, SObjectField field)
		{
			FieldError fieldError = new FieldError();
			fieldError.domain = domain;
			fieldError.message = message;
			fieldError.record = record;
			fieldError.field = field;
			errorList.add(fieldError);
			return message;	
		}	
			
		public List<Error> getAll()
		{ 
			return errorList.clone();
		}
		
		public void clearAll()
		{
			errorList.clear();
		}					
	}
	
	public class FieldError extends ObjectError
	{
		public SObjectField field;
		
		private FieldError()
		{		
			
		}
	}
	
	public virtual class ObjectError extends Error
	{
		public SObject record;
		
		private ObjectError()
		{
		
		}
	}
	
	public abstract class Error
	{
		public String message;
		public GLBL_SObjectDomain domain;
	}
	
	public class TestFactory
	{
		public MockDatabase Database = new MockDatabase();
		 
		private TestFactory()
		{		
			
		}
	}
	
	public class MockDatabase
	{
		private Boolean isInsert = false;
		private Boolean isUpdate = false;
		private Boolean isDelete = false;
		private List<SObject> records = new List<SObject>();
		private Map<Id, SObject> oldRecords = new Map<Id, SObject>();
		
		private MockDatabase()
		{
			
		}
			
		private void testTriggerHandler(IConstructable domainConstructor)
		{
			// Mock Before
			triggerHandler(domainConstructor, true, false, isInsert, isUpdate, isDelete, records, oldRecords);
			
			// Mock After
			triggerHandler(domainConstructor, false, true, isInsert, isUpdate, isDelete, records, oldRecords);
		}
		
		public void onInsert(List<SObject> records)
		{
			this.isInsert = true;
			this.isUpdate = false;
			this.isDelete = false;
			this.records = records;
		}
		
		public void onUpdate(List<SObject> records, Map<Id, SObject> oldRecords)
		{
			this.isInsert = false;
			this.isUpdate = true;
			this.isDelete = false;
			this.records = records;
			this.oldRecords = oldRecords;
		}
		
		public void onDelete(Map<Id, SObject> records)
		{
			this.isInsert = false;
			this.isUpdate = false;
			this.isDelete = true;
			this.oldRecords = records;
		}
		
		public Boolean hasRecords()
		{
			return records!=null && records.size()>0 || oldRecords!=null && oldRecords.size()>0;
		}
	}
}