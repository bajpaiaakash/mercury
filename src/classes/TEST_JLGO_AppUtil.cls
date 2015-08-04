/*
 * TEST_JLGO_AppUtil
 */
@isTest
private class TEST_JLGO_AppUtil {
	/*
     *  Test Main
     */
	static testMethod void Main() {
        //*****************************************************
		//1.Test of 'InsertError' Method
		//*****************************************************
		try{
			decimal err = decimal.valueof('abc');
		}catch(Exception e){
			JLGO_AppUtil.InsertError(e,'TEST_JLGO_AppUtil');
            List<GLBL_Error_Log__c> lstGel = [select id from GLBL_Error_Log__c];
            //cheack insert row 
            system.assert(!lstGel.isEmpty());
		}
        //*****************************************************
		//2.Test of 'GetBetweenStrings' Method
		//*****************************************************
		string target = 'abc';
        //2-1
        string rslt = JLGO_AppUtil.GetBetweenStrings(system.label.JLGO_CutStringFrom,system.label.JLGO_CutStringTo,system.label.JLGO_CutStringFrom+target+system.label.JLGO_CutStringTo);
        system.assertEquals(target,rslt);
        //2-2
        rslt = JLGO_AppUtil.GetBetweenStrings(system.label.JLGO_CutStringFrom,system.label.JLGO_CutStringTo,target);
        system.assertEquals(rslt,'');
        //2-3
        rslt = JLGO_AppUtil.GetBetweenStrings(system.label.JLGO_CutStringFrom,null,target);
        system.assertEquals(rslt,'');
	}
}