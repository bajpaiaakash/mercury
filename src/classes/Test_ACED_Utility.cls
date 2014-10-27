@isTest (SeeAllData=false)

public class Test_ACED_Utility {

    
    static testMethod void CallStaticStrings() {
    User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
	    System.runAs(runAsUser){
		    String Status1 = ACED_Utility.oAssetName;
		    system.assertequals(status1,ACED_Utility.oAssetName);
		    String RetiredStatus1 = ACED_Utility.RetiredStatus;
		    system.assertequals(RetiredStatus1,ACED_Utility.RetiredStatus);
		    String[] retiredStatuses1 = ACED_Utility.retiredStatuses;
		    system.assertequals(retiredStatuses1,ACED_Utility.retiredStatuses);
		    
		    ACED_Utility.mRecordType(Status1);
		    ACED_Utility.createErrorRecord(status1,status1,runasUser.Id);
	    }
    }
}