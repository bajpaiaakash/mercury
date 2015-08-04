@isTest
private class Test_JLGO_GrantRequest_TriggerHandler {
	private static JLGO_PeriodMaster__c PM = new JLGO_PeriodMaster__c();

    static testMethod void myUnitTest() {
        //Create MasterData
    	insPeriodMaster();
		List<JLGO_GrantRequest__c> lstGrant = new List<JLGO_GrantRequest__c>();
		//Test Start ----->>
		Test.startTest();
		
        //*****************************************************
        //1:BeforeInsert&Update Trigger Test
        //*****************************************************
        //1Q
		lstGrant.Add(new JLGO_GrantRequest__c(
			ApplicationDate__c = date.newInstance(2013, 12, 5)
            ,AcceptNo__c = '1Q'
		));
		//2Q
		lstGrant.Add(new JLGO_GrantRequest__c(
			ApplicationDate__c = date.newInstance(2014, 3, 5)
            ,AcceptNo__c = '2Q'
		));
		//3Q
		lstGrant.Add(new JLGO_GrantRequest__c(
			ApplicationDate__c = date.newInstance(2014, 7, 5)
            ,AcceptNo__c = '3Q'
		));
		//4Q
		lstGrant.Add(new JLGO_GrantRequest__c(
			ApplicationDate__c = date.newInstance(2014, 10, 12)
            ,AcceptNo__c = '4Q'
		));
        //Out of Fiscal year
		lstGrant.Add(new JLGO_GrantRequest__c(
			ApplicationDate__c = date.newInstance(2014, 12, 12)
            ,AcceptNo__c = 'Fiscal'
		));
		//Out of Period
		lstGrant.Add(new JLGO_GrantRequest__c(
			ApplicationDate__c = date.newInstance(2014, 8, 31)
            ,AcceptNo__c = 'Period'
		));
        insert lstGrant;
        for(JLGO_GrantRequest__c r : [select id,AcceptNo__c,quarter__c,fiscalyear__c from JLGO_GrantRequest__c]){
            //1Q
            if(r.AcceptNo__c.equals('1Q')){
                system.assertEquals(r.Quarter__c,'1Q');
                system.assertEquals(r.fiscalyear__c,PM.Name);
            }
            //2Q
            if(r.AcceptNo__c.equals('2Q')){
                system.assertEquals(r.Quarter__c,'2Q');
                system.assertEquals(r.fiscalyear__c,PM.Name);
            }
            //3Q
            if(r.AcceptNo__c.equals('3Q')){
                system.assertEquals(r.Quarter__c,'3Q');
                system.assertEquals(r.fiscalyear__c,PM.Name);
            }
            //4Q
            if(r.AcceptNo__c.equals('4Q')){
                system.assertEquals(r.Quarter__c,'4Q');
                system.assertEquals(r.fiscalyear__c,PM.Name);
            }
            //Fiscal
            if(r.AcceptNo__c.equals('Fiscal')){
                system.assertEquals(r.Quarter__c,null);
                system.assertEquals(r.fiscalyear__c,system.label.JLGO_ErrorNoFiscalYear);
            }
            //Period
            if(r.AcceptNo__c.equals('Period')){
                system.assertEquals(r.Quarter__c,system.label.JLGO_ErrorNoAdaptedQuarter);
                system.assertEquals(r.fiscalyear__c,PM.Name);
            }
        }
        //*****************************************************
        //2:When Master Error
        //*****************************************************
        lstGrant = new List<JLGO_GrantRequest__c>();
        PM.X1QEnd__c = date.newInstance(2014, 3, 13);
        update PM;
        //1Q
		lstGrant.Add(new JLGO_GrantRequest__c(
			ApplicationDate__c = date.newInstance(2013, 12, 5)
            ,AcceptNo__c = '1Q-2'
            ,HopeAmount__c=10000
		));
        insert lstGrant;
        for(JLGO_GrantRequest__c r : [select id,AcceptNo__c,quarter__c,fiscalyear__c from JLGO_GrantRequest__c where AcceptNo__c = '1Q-2']){
            system.assertEquals(r.Quarter__c,System.Label.JLGO_ErrorNoDuplicatedQuarter);
        }
        //*****************************************************
        //3:After Update Trigger Test
        //*****************************************************
		//Committee1Amount Error check
		lstGrant[0].Committee1Amount__c = 1000;
        try{
        	update lstGrant;
        }catch(Exception e){
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0));
        }
		//Committee2Amount Error check
		lstGrant[0].Committee1Amount__c = null;
        lstGrant[0].Committee2Amount__c = 1000;
        try{
        	update lstGrant;
        }catch(Exception e){
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0));
        }
		//Test End ----->>
		Test.stopTest();
    }
    //Create  JLGO_PeriodMaster
	public static void insPeriodMaster(){
		PM = new JLGO_PeriodMaster__c(
		Name = '2014'
		,X1QStart__c = date.newInstance(2013, 12, 1)
		,X1QEnd__c = date.newInstance(2014, 2, 28)
		,X2QStart__c = date.newInstance(2014, 3, 1)
		,X2QEnd__c = date.newInstance(2014, 5, 31)
		,X3QStart__c = date.newInstance(2014, 6, 1)
		,X3QEnd__c = date.newInstance(2014, 8, 30)
		,X4QStart__c = date.newInstance(2014, 9, 1)
		,X4QEnd__c = date.newInstance(2014, 11, 01)
		);
		insert PM;
	}

}