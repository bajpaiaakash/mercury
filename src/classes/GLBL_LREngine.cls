/*
Copyright (c) tgerm.com
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/**
	LREngine("L"ookup "R"ollup Engine) : This class simplifies rolling up on the child records in lookup relationship.
*/
public class GLBL_LREngine {

	/*
		Tempalte tokens
			0 : Fields to project
			1 : Object to query
			2 : Optional WHERE clause filter to add
			3 : Group By field name
	*/
	static String SOQL_TEMPLATE = 'SELECT {0} FROM {1} WHERE {3} in :masterIds {2} GROUP BY {3}';
	static String NON_AGGREGATE_SOQL_TEMPLATE = 'SELECT {0} FROM {1} WHERE {3} in :masterIds {2}';

	/**
		Key driver method that rolls up lookup fields based on the context. This is specially useful in Trigger context.
		
		@param ctx Context the complete context required to rollup
		@param detailRecordsFromTrigger child/detail records which are modified/created/deleted during the Trigger 
		@returns Array of in memory master objects. These objects are not updated back to the database
				because we want client or calling code to have this freedom to do some post processing and update when required.
	*/
	public static Sobject[] rollUp(Context ctx, Sobject[] detailRecordsFromTrigger) {
		
		// API name of the lookup field on detail sobject
        String lookUpFieldName = ctx.lookupField.getName();
		        
        Set<Id> masterRecordIds = new Set<Id>(); 
        for (Sobject kid : detailRecordsFromTrigger) {
            masterRecordIds.add((Id)kid.get(lookUpFieldName));
        }
        return rollUp(ctx, masterRecordIds);
	}
	
	/**
		Key driver method that rolls up lookup fields based on the context. This is meant to be called from non trigger contexts like
		scheduled/batch apex, where we want to rollup on some master record ids.
		
		@param Context the complete context required to rollup
		@param masterIds Master record IDs whose child records should be rolled up. 
		@returns Array of in memory master objects. These objects are not updated back to the database
				because we want client or calling code to have this freedom to do some post processing and update when required.
	*/
	public static Sobject[] rollUp(Context ctx,  Set<Id> masterIds) {
		// Clone this since we are about to modify it later
		masterIds = masterIds.clone();
        // K: Id of master record
        // V: Empty sobject with ID field, this will be used for updating the masters
        Map<Id, Sobject> masterRecordsMap = new Map<Id, Sobject>(); 
        for (Id mId : masterIds) {
            masterRecordsMap.put(mId, ctx.master.newSobject(mId));
        }
		
        // #0 token : SOQL projection
        String soqlProjection = ctx.lookupField.getName();
 
        // #1 token for TEMPLATE
        String detailTblName = ctx.detail.getDescribe().getName();
        
        // #2 token Where clause
        String whereClause = '';
        if (ctx.detailWhereClause != null && ctx.detailWhereClause.trim().length() > 0) {
            whereClause = 'AND ' + ctx.detailWhereClause ;
        }

        // #3 token Lookup field
        String lookupFld = ctx.lookupField.getName();

        Boolean treatZerosAsNulls = ctx.treatZerosAsNulls;
    	
        if (ctx.useNonaggregatingRollup) {
            // #0 token continued...
            // k: detail field name, v: master field name
            Map<String, String> detail2MasterFldMap = new Map<String, String>();
            Map<String, RollupOperation> detail2Operation = new Map<String, RollupOperation>();
            Map<String, Boolean> master2IsNumber = new Map<String, Boolean>();
            for (RollupSummaryField rsf : ctx.fieldsToRoll) {
                soqlProjection += ', ' + rsf.detail.getName();
                detail2MasterFldMap.put(rsf.detail.getName(), rsf.master.getName());
                detail2Operation.put(rsf.detail.getName(),rsf.operation);
                master2IsNumber.put(rsf.master.getName(), rsf.isMasterTypeNumber);
            }

            String soql = String.format(NON_AGGREGATE_SOQL_TEMPLATE, new String[]{soqlProjection, detailTblName, whereClause, lookupFld});
            p('USING MANUAL CALCULATION: '+soql);
            List<Sobject> results = Database.query(soql);

            Map<Id,List<Sobject>> master2Operands = new Map<Id,List<Sobject>>();
            for (Sobject obj : results) {
                Id masterRecId = (Id) obj.get(lookupFld);
                Sobject masterObj = masterRecordsMap.get(masterRecId);                
                if (masterObj == null) {
                    System.debug(Logginglevel.WARN, 'No master record found for ID :' + masterRecId);
                    continue;
                }

                if (master2Operands.get(masterRecId)==null) master2Operands.put(masterRecId,new List<Sobject>());
                master2Operands.get(masterRecId).add(obj);
            }

            Map<Id, Map<String,Decimal>> master2ResultValues = new Map<Id, Map<String,Decimal>>();
            for (Id masterRecId : master2Operands.keySet()) {
                master2ResultValues.put(masterRecId, GLBL_LRAbacus.calculate(master2Operands.get(masterRecId), detail2Operation));
            }

            for (Id masterRecId : master2ResultValues.keySet()) {
                Sobject masterObj = masterRecordsMap.get(masterRecId);
                if (masterObj == null) {
                    System.debug(Logginglevel.WARN, 'No master record found for ID :' + masterRecId);
                    continue;
                }

                Map<String,Decimal> detail2ResultValue = master2ResultValues.get(masterRecId);
                for (String detailFld : detail2MasterFldMap.keySet()) {
                    Object detailVal = detail2ResultValue.get(detailFld);
                    System.debug(LoggingLevel.INFO, 'New calculated value ' + detailVal + ' for master ' + masterRecId);

                    String masterField = detail2MasterFldMap.get(detailFld);
                    if (master2IsNumber.get(masterField) && treatZerosAsNulls && Integer.valueOf(detailVal) == 0) {
                        masterObj.put(detail2MasterFldMap.get(detailFld), null);
                    } else {
                        masterObj.put(detail2MasterFldMap.get(detailFld), detailVal);
                    }
                }           
                // Remove master Id record as its been processed    
                masterIds.remove(masterRecId);  
            }
        } else {
            // #0 token continued...
            // k: detail field name, v: master field name
            Integer exprIdx = 0;
            Map<String, String> detail2MasterFldMap = new Map<String, String>();
            Map<String, String> detail2AliasMap = new Map<String, String>();
            Map<String, Boolean> master2IsNumber = new Map<String, Boolean>();
            for (RollupSummaryField rsf : ctx.fieldsToRoll) {
                // create aggreate projection with alias for easy fetching via AggregateResult class
                // i.e. SUM(Amount) Amount
                String alias = 'lre'+exprIdx++; // Calculate an alias, using field name blew the 25 character limit in some cases
                soqlProjection += ', ' + rsf.operation + '(' + rsf.detail.getName() + ') ' + alias;
                detail2MasterFldMap.put(rsf.detail.getName(), rsf.master.getName());
                detail2AliasMap.put(rsf.detail.getName(), alias);
                master2IsNumber.put(rsf.master.getName(), rsf.isMasterTypeNumber);
            }
                    
        	String soql = String.format(SOQL_TEMPLATE, new String[]{soqlProjection, detailTblName, whereClause, lookupFld});

        	// aggregated results 
        	List<AggregateResult> results = Database.query(soql);
        	
        	for (AggregateResult res : results){
    			Id masterRecId = (Id)res.get(lookupFld);
    			Sobject masterObj = masterRecordsMap.get(masterRecId);
    			if (masterObj == null) {
    				System.debug(Logginglevel.WARN, 'No master record found for ID :' + masterRecId);
    				continue;
    			}
    			
    			for (String detailFld : detail2MasterFldMap.keySet()) {
    				Object aggregatedDetailVal = res.get(detail2AliasMap.get(detailFld));
    				System.debug(LoggingLevel.INFO, 'New aggregate value ' + aggregatedDetailVal + ' for master ' + masterRecId);
    				//masterObj.put(detail2MasterFldMap.get(detailFld), aggregatedDetailVal);
                    String masterField = detail2MasterFldMap.get(detailFld);
                    if (master2IsNumber.get(masterField) && treatZerosAsNulls && Integer.valueOf(aggregatedDetailVal) == 0) {
                        masterObj.put(detail2MasterFldMap.get(detailFld), null);
                    } else {
                        masterObj.put(detail2MasterFldMap.get(detailFld), aggregatedDetailVal);
                    }
    			} 			
    			// Remove master Id record as its been processed   	
    			masterIds.remove(masterRecId);	
        	}
    	}

    	// Zero rollups for unprocessed master records (those with no longer any child relationships)
    	for(Id masterRecId : masterIds)
    		for (RollupSummaryField rsf : ctx.fieldsToRoll) {
				if (rsf.isMasterTypeNumber && treatZerosAsNulls) {
                    masterRecordsMap.get(masterRecId).put(rsf.master.getName(), null);
                } else {
                    masterRecordsMap.get(masterRecId).put(rsf.master.getName(), rsf.isMasterTypeNumber ? 0 : null);
                }
            }
    	
    	return masterRecordsMap.values();	
    }
	
	
	
	
    /**
        Exception throwed if Rollup Summary field is in bad state
    */
    public class BadRollUpSummaryStateException extends Exception {}
	
   /**
       Which rollup operation you want to perform 
    */ 
    public enum RollupOperation {
        Sum, Max, Min, Avg, Count
    }
    
    /**
    	Represents a "Single" roll up field, it contains
    	- Master field where the rolled up info will be saved
    	- Detail field that will be rolled up via any operation i.e. sum, avg etc 
    	- Operation to perform i.e. sum, avg, count etc
    		
    */
    public class RollupSummaryField {
        public Schema.Describefieldresult master;
        public Schema.Describefieldresult detail;
        public RollupOperation operation;
        
        // derived fields, kept like this to save script lines later, by saving the same
        // computations over and over again
        public boolean isMasterTypeNumber;
        public boolean isDetailTypeNumber;
        public boolean isMasterTypeDateOrTime;
        public boolean isDetailTypeDateOrTime; 
        
        public RollupSummaryField(Schema.Describefieldresult m, 
                                         Schema.Describefieldresult d, RollupOperation op) {
            this.master = m;
            this.detail = d;
            this.operation = op;
            // caching these derived attrbutes for once
            // as their is no view state involved here
            // and this caching will lead to saving in script lines later on
            this.isMasterTypeNumber = isNumber(master.getType());
            this.isDetailTypeNumber = isNumber(detail.getType());
            this.isMasterTypeDateOrTime = isDateOrTime(master.getType());
            this.isDetailTypeDateOrTime = isDateOrTime(detail.getType()); 
            // validate if field is good to work on later 
            validate();
        }   
        
        void validate() {
            if (master == null || detail == null || operation == null) 
                throw new BadRollUpSummaryStateException('All of Master/Detail Describefieldresult and RollupOperation info is mandantory');

            if ( (!isMasterTypeDateOrTime && !isMasterTypeNumber) 
                  || (!isDetailTypeDateOrTime && !isDetailTypeNumber)) {
                    throw new BadRollUpSummaryStateException('Only Date/DateTime/Time/Numeric fields are allowed');
            }
            
            if (isMasterTypeDateOrTime && (RollupOperation.Sum == operation || RollupOperation.Avg == operation)) {
                throw new BadRollUpSummaryStateException('Sum/Avg doesnt looks like valid for dates ! Still want, then implement the IRollerCoaster yourself and change this class as required.');
            }
        }
        
        boolean isNumber (Schema.Displaytype dt) {
            return dt == Schema.Displaytype.Currency 
                   || dt == Schema.Displaytype.Integer
                   || dt == Schema.Displaytype.Percent
                   || dt == Schema.Displaytype.Double;
        }
        
        boolean isDateOrTime(Schema.DisplayType dt) {
            return dt == Schema.Displaytype.Time 
                   || dt == Schema.Displaytype.Date
                   || dt == Schema.Displaytype.Datetime;
        }
    }
    
    /**
    	Context having all the information about the rollup to be done. 
    	Please note : This class encapsulates many rollup summary fields with different operations.
    */
	public class Context {
	    // Master Sobject Type
	    public Schema.Sobjecttype master;
	    // Child/Details Sobject Type
	    public Schema.Sobjecttype detail;
	    // Lookup field on Child/Detail Sobject
	    public Schema.Describefieldresult lookupField;
	    // various fields to rollup on
	    public List<RollupSummaryField> fieldsToRoll;
		
		// Where clause or filters to apply while aggregating detail records
		public String detailWhereClause;	

        public Boolean treatZerosAsNulls;

        public Boolean useNonaggregatingRollup;     
	    		
	    public Context(Schema.Sobjecttype m, Schema.Sobjecttype d, 
                           Schema.Describefieldresult lf) {
			this(m, d, lf, '');                           	
        }

        public Context(Schema.Sobjecttype m, Schema.Sobjecttype d, 
                           Schema.Describefieldresult lf, String detailWhereClause) {
            this(m, d, lf, detailWhereClause, false, false);
        }

        public Context(Schema.Sobjecttype m, Schema.Sobjecttype d, 
                           Schema.Describefieldresult lf, String detailWhereClause, 
                           Boolean treatZerosAsNulls) {
            this(m, d, lf, detailWhereClause, treatZerosAsNulls, false);
        }

	    public Context(Schema.Sobjecttype m, Schema.Sobjecttype d, 
                           Schema.Describefieldresult lf, String detailWhereClause, 
                           Boolean treatZerosAsNulls, Boolean useNonaggregatingRollup) {
	        this.master = m;
	        this.detail = d;
	        this.lookupField = lf;
	        this.detailWhereClause = detailWhereClause;
	        this.fieldsToRoll = new List<RollupSummaryField>();
            this.treatZerosAsNulls = treatZerosAsNulls;
            this.useNonaggregatingRollup = useNonaggregatingRollup;
	    }
	    
	    /**
	    	Adds new rollup summary fields to the context
	    */
	    public void add(RollupSummaryField fld) {
	        this.fieldsToRoll.add(fld);
	    }
	}    

    static void p(String m) {
        System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
    }
}