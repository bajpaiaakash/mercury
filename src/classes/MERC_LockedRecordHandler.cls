/**
 * @author Joseph Ferraro
 *
 * Trigger handler that prevents Trigger actions on locked records
 *	Handles both parent/child scenarios
 */

public with sharing class MERC_LockedRecordHandler implements GLBL_TriggerHandler.HandlerInterface {
	
	public static Boolean overrideLockCheck = false;
    public Schema.DescribeFieldResult lockedField;
    public Set<String> exemptFields;
    Schema.SobjectType sObjectType;
    Schema.SobjectType parentSobjectType;
    Schema.DescribeFieldResult parentLookupField;
    Boolean sObjectIsChild;

    public MERC_LockedRecordHandler(Schema.SobjectType sObjectType) {
        this.sObjectType = sObjectType;
        this.lockedField = sObjectToLockedField.get(this.sObjectType);
        this.sObjectIsChild = false;
    }

    public MERC_LockedRecordHandler(Schema.SobjectType sObjectType, Set<String> exemptFields) {
        this.sObjectType = sObjectType;
        this.lockedField = sObjectToLockedField.get(this.sObjectType);
        this.exemptFields = exemptFields;
        this.sObjectIsChild = false;
    }

    public MERC_LockedRecordHandler(Schema.SobjectType sObjectType, Schema.SobjectType parentType, Schema.DescribeFieldResult parentLookupField) {
        this.sObjectType = sObjectType;
        this.parentSobjectType = parentType;
        this.lockedField = sObjectToLockedField.get(this.parentSobjectType);
        this.parentLookupField = parentLookupField;
        this.sObjectIsChild = true;
    }

    public MERC_LockedRecordHandler(Schema.SobjectType sObjectType, Schema.SobjectType parentType, Schema.DescribeFieldResult parentLookupField, Set<String> exemptFields) {
        this.sObjectType = sObjectType;
        this.parentSobjectType = parentType;
        this.lockedField = sObjectToLockedField.get(this.parentSobjectType);
        this.exemptFields = exemptFields;
        this.parentLookupField = parentLookupField;
        this.sObjectIsChild = true;
    }

    Map<Schema.SobjectType, Schema.DescribeFieldResult> sObjectToLockedField = new Map<Schema.SobjectType, Schema.DescribeFieldResult> {
    	Meeting_MERC__c.SobjectType => Schema.sObjectType.Meeting_MERC__c.fields.Lock_Meeting_MERC__c
    };

    Map<Schema.SobjectType, String> sObjectToErrorMessage = new Map<Schema.SobjectType, String> {
        Meeting_MERC__c.SobjectType => Label.Meeting_Locked_MERC,
        Meeting_Participant_MERC__c.SobjectType => Label.Meeting_Locked_MERC,
        Agenda_Item_MERC__c.SobjectType => Label.Meeting_Locked_MERC,
        Meeting_Products_MERC__c.SobjectType => Label.Meeting_Locked_MERC,
        Team_Member_MERC__c.SobjectType => Label.Meeting_Locked_MERC,
        Meeting_Vendor_MERC__c.SobjectType => Label.Meeting_Locked_MERC,
        Meeting_Day_MERC__c.SobjectType => Label.Meeting_Locked_MERC,
        ContentVersion.SobjectType => Label.Meeting_Locked_MERC
    };

    Map<String, Schema.SObjectField> fieldListMap {
    	get {
    		if (this.exemptFields != null) {
    		    Schema.DescribeSObjectResult objectDescribe = this.sObjectType.getDescribe();
    		    String objectNameString = objectDescribe.getName();

    		    Map<String, Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
    		    Schema.sObjectType sObjType = globalDescription.get(objectNameString); 
    		    Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
    		    fieldListMap = r1.fields.getMap();  
    		    return fieldListMap;
    		} else {
    			return null;
    		}	
    	}
    	set;
    }

    Map<Id, Sobject> parentMap {
    	get {
    		if (this.parentSobjectType != null) {
    			parentMap = new Map<Id, Sobject>();
    			List<Sobject> sobjects = (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) ? Trigger.new : Trigger.old;
    			Set<Id> parentObjectIds = new Set<Id>();
    			for (SObject s : sobjects)
    				parentObjectIds.add((Id)s.get(this.parentLookupField.getName()));
    			for (Sobject s : Database.query('SELECT Id, '+this.lockedField.getName()+' FROM '+this.parentSobjectType.getDescribe().getName()+' Where Id in :parentObjectIds'))
    				parentMap.put((Id)s.get('Id'), s);
    			return parentMap;
			} else {
				return null;
			}
    	}
    	set;
    }

    Boolean isSystemAdmin {
    	get {
    		//return [SELECT Profile.Name FROM User WHERE ID = :UserInfo.getUserId()].Profile.Name == 'System Administrator';
    		return false;
    	}
    }

    String errorMessage {
    	get {
    		try {
                if (this.parentSobjectType != null) {
                    return sObjectToErrorMessage.get(this.parentSobjectType);
                } else {
                    return sObjectToErrorMessage.get(this.sObjectType);
                }
            } catch(Exception e) {
                if (this.parentSobjectType != null) {
                    return 'Operation failed: Parent record is locked';
                } else {
                    return 'Operation failed: Record is locked';
                }
            }
    	}
    }

    public void handle() {
        if (!MERC_LockedRecordHandler.overrideLockCheck) {
            if (Trigger.isBefore) {
                if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
                    execute(Trigger.new);
                } else if (Trigger.isDelete) {
                    execute(Trigger.old);
                }
            }
        }
    }

    Boolean getIsLockedFromEditing(Sobject s) {
    	if (this.sObjectIsChild) {
    		Id parentId = (Id)s.get(this.parentLookupField.getName());
    		if (parentId == null) {
                return false;
            } else {
                Sobject parent = this.parentMap.get(parentId);
                return (Boolean)parent.get(this.lockedField.getName()) && !isSystemAdmin;
            }
    	} else {
    		return (Boolean)s.get(this.lockedField.getName()) && !isSystemAdmin;
    	}
    }

    public void execute(List<Sobject> sobjects) {
        
        for (SObject s : sobjects) {
            Id recordId = (Id)s.get('Id');
            Boolean isLocked = getIsLockedFromEditing(s);
            
            if (!this.sObjectIsChild) {
                if (Trigger.isUpdate) {
                    Boolean oldLockValue = (Boolean)Trigger.oldmap.get(recordId).get(this.lockedField.getName());
                    Boolean newLockValue = (Boolean)Trigger.newmap.get(recordId).get(this.lockedField.getName());
                    if (oldLockValue != newLockValue)
                        continue; //user is unlocking/locking the record
                }
            }


            if (Trigger.isUpdate && this.exemptFields != null) {
            	Boolean isUpdateOK = true; //this is set to false if user attempts to edit non-exempt field
            	String fieldName;
            	String fieldType;
            	Boolean isCalculated; //whether this is a formula field
            	
            	for (Schema.SObjectField field : fieldListMap.values()) {

            	    Schema.DescribeFieldResult fieldDescribe = field.getDescribe(); 
            	    fieldName = String.valueOf(fieldDescribe.getName());
            	    fieldType = String.valueOf(fieldDescribe.getSoaptype());
            	    isCalculated = Boolean.valueOf(fieldDescribe.isCalculated());

            	    if (isCalculated) continue; //we can't control this, so we let it go

            	    if (fieldName != this.lockedField.getName()){
            	        if (fieldType == 'DOUBLE') {
            	            Double oldFieldValue = (Double)Trigger.oldmap.get(recordId).get(fieldName);
            	            Double newFieldValue = (Double)Trigger.newmap.get(recordId).get(fieldName);
            	            if (oldFieldValue != newFieldValue && !exemptFields.contains(fieldName)) {
            	                isUpdateOK = false;
            	                break;
            	            }
            	        } else if (fieldType == 'STRING') {
            	            String oldFieldValue = (String)Trigger.oldmap.get(recordId).get(fieldName);
            	            String newFieldValue = (String)Trigger.newmap.get(recordId).get(fieldName);
            	            if (oldFieldValue != newFieldValue && !exemptFields.contains(fieldName)) {
            	                isUpdateOK = false;
            	                break;
            	            }
            	        } else if (fieldType == 'DATE') {
            	            Date oldFieldValue = (Date)Trigger.oldmap.get(recordId).get(fieldName);
            	            Date newFieldValue = (Date)Trigger.newmap.get(recordId).get(fieldName);
            	            if (oldFieldValue != newFieldValue && !exemptFields.contains(fieldName)) {
            	                isUpdateOK = false;
            	                break;
            	            }
            	        } else if (fieldType == 'BOOLEAN') {
            	            Boolean oldFieldValue = (Boolean)Trigger.oldmap.get(recordId).get(fieldName);
            	            Boolean newFieldValue = (Boolean)Trigger.newmap.get(recordId).get(fieldName);
            	            if (oldFieldValue != newFieldValue && !exemptFields.contains(fieldName)) {
            	                isUpdateOK = false;
            	                break;
            	            }
            	        } else if (fieldType == 'DATETIME') {
            	            DateTime oldFieldValue = (DateTime)Trigger.oldmap.get(recordId).get(fieldName);
            	            DateTime newFieldValue = (DateTime)Trigger.newmap.get(recordId).get(fieldName);
            	            if (oldFieldValue != newFieldValue && !exemptFields.contains(fieldName)) {
            	                isUpdateOK = false;
            	                break;
            	            }
            	        } else if (fieldType == 'ID') {
            	            Id oldFieldValue = (Id)Trigger.oldmap.get(recordId).get(fieldName);
            	            Id newFieldValue = (Id)Trigger.newmap.get(recordId).get(fieldName);
            	            if (oldFieldValue != newFieldValue && !exemptFields.contains(fieldName)) {
            	                isUpdateOK = false;
            	                break;
            	            }
            	        }
            	    }                           
            	}
            	
            	system.debug('isupdateOK --> '+isUpdateOK);
            	system.debug('isLocked --> '+isLocked);

            	if (isLocked && !isUpdateOK) { //if it's locked and the update is not ok (they are not editing exempt fields) throw an error
            	    system.debug('--> record/parent locked and exempt field is not being updated, so no update allowed');
            	    s.addError(errorMessage);
            	} else if (isUpdateOK) {
            	    system.debug('--> update is ok because only exempt fields are being updated');
            	    MERC_LockedRecordHandler.overrideLockCheck = true;
            	}	            	
            } else {
            	if (isLocked)
            		s.addError(errorMessage);
            }
        }
    }
}