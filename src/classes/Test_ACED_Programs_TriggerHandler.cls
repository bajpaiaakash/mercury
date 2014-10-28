/* Class Name  : Test_ACED_Programs_TriggerHandler
* Description  : Test Class for ACED_Programs_TriggerHandler
* Created By   : Goutham
* Created Date : 9/25/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/
@isTest(SeeAllData=false)

public class Test_ACED_Programs_TriggerHandler{

    
    static testMethod void createNewProgramIndication() {
	    User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');   
	    List<ACED_Programs__c> lProgram = new List<ACED_Programs__c>();        
		    System.runAs(runAsUser) {
			    Test.startTest();
			    list<ACED_Program_Indication__c> lProgInd = ACED_DataFactory.createProgramIndication(100);
			    system.assertequals(200, lProgInd.size());
			    Test.stopTest();
		    }
	    }
    }