/* Class Name  : Test_GLBL_ActionsOnSharingRecords 
* Description  : Test Class for GLBL_ActionsOnSharingRecords
* Created By   : Goutham
* Created Date : 12/11/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest  (SeeAllData = false)
public class Test_GLBL_ActionsOnSharingRecords{

    static testMethod void operationsOnSharingRecords() {
           
        Test.startTest();
            
            //Inserting a Form template Record
            List<GLBL_Form_Template__c> lTemplates = FORM_DataFactory.createTemplates(1);
            
            system.runas(new user(id=UserInfo.getUserId())){
	            // Create share records 
	            GLBL_Form_Template__Share frmTempShr  = new GLBL_Form_Template__Share();
	   
		        // Set the ID of record being shared.
		      	frmTempShr.ParentId = lTemplates[0].id;
		      	
		      	User frmCreator = FORM_DataFactory.createUser('FORM_Form_Creator');	        
		      	// Set the ID of user or group being granted access.
		      	frmTempShr.UserOrGroupId = frmCreator.id;
		        
		      	// Set the access level.
		      	frmTempShr.AccessLevel = 'Read';
		        
		      	// Set rowCause to 'manual' for manual sharing.
		      	// This line can be omitted as 'manual' is the default value for sharing objects.
		      	frmTempShr.RowCause = Schema.GLBL_Form_Template__Share.RowCause.Manual;
		        
			    // Insert the sharing record and capture the save result. 
			    // The false parameter allows for partial processing if multiple records passed 
			    // into the operation.
			    Database.SaveResult sr = Database.insert(frmTempShr,false);  
			    Map<Id,SObject> oldRecMap = New Map<Id,SObject>();
			    oldRecMap.put(lTemplates[0].id,lTemplates[0]);
		            
	            User frmUsrToShr = FORM_DataFactory.createUser('FORM_Form_Creator');
	            
	            //To check there were not any share records before change of owner happened 
	            List<GLBL_Form_Template__share> lformTempShare = [SELECT id,parentId,accesslevel,rowcause,UserOrGroupId 
	                                                       FROM GLBL_Form_Template__share
	                                                       WHERE parentId =: lTemplates[0].id AND UserOrGroupId =: frmUsrToShr.id
	                                                       AND rowcause='manual' ];
	            system.assertEquals(lformTempShare.size(),0);                                           
	                                                     
	            //Changing owner of template record
	            lTemplates[0].ownerId=frmUsrToShr.id;
	            update lTemplates;
	            
	            //To check there were not any share records before change of owner happened 
	            List<GLBL_Form_Template__share> lformTempShareAfterCall = [SELECT id,parentId,accesslevel,rowcause,UserOrGroupId 
	                                                       FROM GLBL_Form_Template__share
	                                                       WHERE parentId =: lTemplates[0].id AND UserOrGroupId =: frmUsrToShr.id];
	                                                       
	            system.assertEquals(lformTempShareAfterCall.size(),1);  
            }
        Test.stopTest();       
    }
}