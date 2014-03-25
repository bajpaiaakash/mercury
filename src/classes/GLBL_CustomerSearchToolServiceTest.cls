/**
 * Unit tests for the GLBL_CustomerSearchToolService
 *
 * @author Sean Harrison
 **/
@isTest
private class GLBL_CustomerSearchToolServiceTest {
	
	static final Integer TEST_SET_SIZE = 200;

	static List<Account> accts;
	static GLBL_CustomerSearchToolServiceMock mockServices;

	static {
		accts = MERC_TestFactory.insertAccounts(TEST_SET_SIZE);
		mockServices = new GLBL_CustomerSearchToolServiceMock();
	}

	/**
	 * Exercise the token refresh, both it's error state and success
	 */
	@isTest 
	static void testRefreshToken() {
		Mercury_Settings_MERC__c settings = new Mercury_Settings_MERC__c();
		settings.CST_Client_Id_MERC__c = 'Guildenstern';
		settings.CST_Client_Secret_MERC__c = 'Rosencrantz';
		insert settings;

		GLBL_CustomerSearchToolService.AccessTokenResponse tokenRespObj = new GLBL_CustomerSearchToolService.AccessTokenResponse();
		tokenRespObj.error = 'To be;';
        String tokenResponse = JSON.serialize(tokenRespObj);
		Test.setMock(HttpCalloutMock.class, new GLBL_CustomerSearchToolServiceMock(400, 'BAD REQUEST', tokenResponse, new Map<String, String>{'Content-Type'=>'application/json'}));

		Test.startTest();
		GLBL_CustomerSearchToolService service = new GLBL_CustomerSearchToolService();
		service.refreshToken();
		System.assertEquals(null,service.accessToken,'Expected null value for access token but got '+service.accessToken);

		tokenRespObj.access_token = 'Or not to be.';
        tokenResponse = JSON.serialize(tokenRespObj);
		Test.setMock(HttpCalloutMock.class, new GLBL_CustomerSearchToolServiceMock(200, 'OK', tokenResponse, new Map<String, String>{'Content-Type'=>'application/json'}));

		service.refreshToken();
		System.assertEquals(tokenRespObj.access_token,service.accessToken,'Unexpected value for access token: '+service.accessToken);

		Test.stopTest();
	}

	/**
	 * Exercise a simple search.
	 * @see GLBL_CustomerSearchToolServiceMock
	 **/
 	@isTest
	static void testSearch() {
		Test.setMock(HttpCalloutMock.class, mockServices);
		mockServices.setBody(JSON.serialize(accts));

		GLBL_CustomerSearchToolService service;
		List<GLBL_CustomerSearchToolService.SearchResult> results;

		Test.startTest();
		service = new GLBL_CustomerSearchToolService();
		results = service.doSearch(new GLBL_CustomerSearchToolService.SearchRequest());
		Test.stopTest();

		System.assertEquals((TEST_SET_SIZE),results.size(),'Unexpected search result size.');
	}

	/**
	 * Cycle through various possible errors
	 **/
	@isTest
	static void testSearchExceptions() {
		Test.startTest();
		testSearchException(400,'BAD REQUEST');
		testSearchException(401,'NOT AUTHORIZED');
		testSearchException(999,'UNKNOWN');
		Test.stopTest();
	}

	/**
	 * Builds an ErrorResult based on the submitted info, initiates a search, then checks for the null result
	 *
	 * @errNum    Integer for HTTP error code
	 * @errStatus HTTP status string
	 */
	static void testSearchException(Integer errNum, String errStatus) {
		GLBL_CustomerSearchToolService.ErrorResult errOjb = new GLBL_CustomerSearchToolService.ErrorResult();
		errOjb.Error = 'Hamlet';
		errOjb.Message = 'Aye, there\'s the rub.';
        String errResponse = JSON.serialize(errOjb);
		Test.setMock(HttpCalloutMock.class, new GLBL_CustomerSearchToolServiceMock(errNum, errStatus, errResponse, new Map<String, String>{'Content-Type'=>'application/json'}));

		GLBL_CustomerSearchToolService service;
		List<GLBL_CustomerSearchToolService.SearchResult> results;

		service = new GLBL_CustomerSearchToolService();
		results = service.doSearch(new GLBL_CustomerSearchToolService.SearchRequest());

		System.assertEquals(null,results,'Unexpected search result List returned after '+errNum);
	}

	/**
	 * This method is just embarrassing. Apparently all the calls to JSON.deserialise are not 
	 * recognized by the test coverage engine even though it does use the SearchResult inner
	 * class. So, to get official coverage, call each property explicitly...
	 */
	@isTest
	static void testSearchResultClass() {

		GLBL_CustomerSearchToolService.SearchResult sr = new GLBL_CustomerSearchToolService.SearchResult();

		// ug. the JSON methods do not exercise getters/setters and Apex doesn't have reflection
		if (sr.selected == null) sr.selected = true;
		if (sr.selectable == null) sr.selectable = true;
		if (sr.prim_affil_pstl_cd_extnsn_glbl == null) sr.prim_affil_pstl_cd_extnsn_glbl = 'prim_affil_pstl_cd_extnsn_glbl';
	    if (sr.sfid == null) sr.sfid = 'sfid';
	    if (sr.prsnl_nbr_glbl == null) sr.prsnl_nbr_glbl = 'prsnl_nbr_glbl';
	    if (sr.country_code_merc == null) sr.country_code_merc = 'country_code_merc';
	    if (sr.primary_addr_line2_glbl == null) sr.primary_addr_line2_glbl = 'primary_addr_line2_glbl';
	    if (sr.lastname == null) sr.lastname = 'lastname';
	    if (sr.firstname == null) sr.firstname = 'firstname';
	    if (sr.cust_id_glbl == null) sr.cust_id_glbl = 'cust_id_glbl';
	    if (sr.primary_address_country_glbl == null) sr.primary_address_country_glbl = 'primary_address_country_glbl';
	    if (sr.spclty_desc_glbl == null) sr.spclty_desc_glbl = 'spclty_desc_glbl';
	    if (sr.clsfctn_cd_glbl == null) sr.clsfctn_cd_glbl = 'clsfctn_cd_glbl';
	    if (sr.scnd_nm_glbl == null) sr.scnd_nm_glbl = 'scnd_nm_glbl';
	    if (sr.primary_pstl_cd_extnsn_glbl == null) sr.primary_pstl_cd_extnsn_glbl = 'primary_pstl_cd_extnsn_glbl';
	    if (sr.systemmodstamp == null) sr.systemmodstamp = 'systemmodstamp';
	    if (sr.name == null) sr.name = 'name';
	    if (sr.mdl_nm_glbl == null) sr.mdl_nm_glbl = 'mdl_nm_glbl';
	    if (sr.prim_affil_hco_glbl == null) sr.prim_affil_hco_glbl = 'prim_affil_hco_glbl';
	    if (sr.hcp_profile_status_glbl == null) sr.hcp_profile_status_glbl = 'hcp_profile_status_glbl';
	    if (sr.lastmodifieddate == null) sr.lastmodifieddate = 'lastmodifieddate';
	    if (sr.prim_affil_addr_country_glbl == null) sr.prim_affil_addr_country_glbl = 'prim_affil_addr_country_glbl';
	    if (sr.id == null) sr.id = 'id';
	    if (sr.primary_hco_glbl == null) sr.primary_hco_glbl = 'primary_hco_glbl';
	    if (sr.bnft_dsgn_cd_glbl == null) sr.bnft_dsgn_cd_glbl = 'bnft_dsgn_cd_glbl';
	    if (sr.primary_addr_line1_glbl == null) sr.primary_addr_line1_glbl = 'primary_addr_line1_glbl';
	    if (sr.isdeleted == null) sr.isdeleted = 'isdeleted';
	    if (sr.spclty_cd_glbl == null) sr.spclty_cd_glbl = 'spclty_cd_glbl';
	    if (sr.createddate == null) sr.createddate = 'createddate';
	    if (sr.prim_affil_addr_line1_glbl == null) sr.prim_affil_addr_line1_glbl = 'prim_affil_addr_line1_glbl';
	    if (sr.primary_addr_city_glbl == null) sr.primary_addr_city_glbl = 'primary_addr_city_glbl';
	    if (sr.prim_affil_addr_city_glbl == null) sr.prim_affil_addr_city_glbl = 'prim_affil_addr_city_glbl';
	    if (sr.recordtypeid == null) sr.recordtypeid = 'recordtypeid';
	}	
}