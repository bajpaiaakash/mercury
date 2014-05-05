/**
 * @author Joseph Ferraro
 *
 * Service which submits query to Customer Search Tool running on Heroku
 * -It relies on clientid/clientsecret distributed by the CST to retrieve a token
 * -Because of Apex constraints re: DML/calling out, we retrieve a new access token each time the page is loaded
 * 		-we can refactor in the future to possibly implement a @future method which updates an expired access token on a 401 response
 */
public with sharing class GLBL_CustomerSearchToolService {
	
	private String baseUrl;
	public  String accessToken { get; private set; }
	public  Mercury_Settings_MERC__c appSettings {
		get {
			if (appSettings == null) {
				appSettings = Mercury_Settings_MERC__c.getOrgDefaults();
			}
			return appSettings;
		}
		private set;
	}
	public ErrorResult error {get; private set;}

	public GLBL_CustomerSearchToolService() {
		baseUrl = this.appSettings.CST_URL_GLBL__c;
	}

	public List<SearchResult> doSearch(SearchRequest req) {
		String requestJson = JSON.serialize(req);
		system.debug('>>> '+requestJson);

		HttpRequest r = new HttpRequest();
		r.setHeader('Content-type', 'application/json');
		r.setHeader('Authorization', 'Bearer '+this.accessToken);
		r.setHeader('Accept', 'application/json');
		r.setEndpoint(this.baseUrl+'/search'); 
		r.setMethod('POST');
		r.setBody(requestJson);
		r.setTimeout(30000); //match heroku timeout

		system.debug('>>>  '+r.getHeader('Authorization'));
		error = null;
		Http h = new Http();
		HttpResponse response = h.send(r);
		String s = response.getBody();
		system.debug('>>> response from search tool: '+s);
		if (response.getStatusCode() == 400) {
			error = (ErrorResult)JSON.deserialize(s, ErrorResult.class);
			return null;
		} else if (response.getStatusCode() == 401) {
			// TODO - instead of throwing an error we need to retry authorization (See class comments above)
			error = (ErrorResult)JSON.deserialize(s, ErrorResult.class);
			return null;
		} else if (response.getStatusCode() == 200) {
			s = s.replaceAll('__c"','"');
			List<SearchResult> results = (List<SearchResult>)JSON.deserialize(s, List<SearchResult>.class);
			system.debug('>>> results from search tool: '+results);
			return results;
		}
		error = new ErrorResult();
		error.Error = 'UNEXPECTED';
		error.Message = s;
		return null;
	}

	public void refreshToken() {
		HttpRequest r = new HttpRequest();
		r.setHeader('Content-type', 'application/x-www-form-urlencoded');
		r.setEndpoint(this.baseUrl+'/oauth/token'); 
		r.setBody('grant_type=client_credentials&client_id='+this.appSettings.CST_Client_Id_MERC__c+'&client_secret='+this.appSettings.CST_Client_Secret_MERC__c);
		r.setMethod('POST');

		Http h = new Http();
		HttpResponse response = h.send(r);
		String s = response.getBody();
		system.debug('>>> response from search tool: '+s);
		AccessTokenResponse tokenResponse = (AccessTokenResponse)JSON.deserialize(s, AccessTokenResponse.class);
		String today = DateTime.now().formatGmt('MMM d, hh:mm:ss z');
		if (tokenResponse.access_token != null) {
			this.accessToken = tokenResponse.access_token;
//			recordResult(today+': last response successful');
		} else if (tokenResponse.error != null) {
//			recordResult(today+': '+ tokenResponse.error +' - '+tokenResponse.error_description);
		}
	}

//	@future
//	private static void recordResult(String s) {
//		Mercury_Settings_MERC__c mercSettings = Mercury_Settings_MERC__c.getOrgDefaults();
//		mercSettings.CST_Client_Auth_Error_MERC__c = s.left(254);
// 		update mercSettings;
//	}

	public class AccessTokenResponse {
		public String token_type;
		public String access_token;
		public String expires_in;
		public String error_description;
		public String error;
	}

	//ERROR
	//{
	//  "error_description" : "Client authentication failed due to unknown client, no client authentication included, or unsupported authentication method.",
	//  "error" : "invalid_client"
	//}

	//SUCCESS
	//{
	//  "token_type" : "bearer",
	//  "access_token" : "7e008f3e324a631350183c95c8df51ad5b2e6fbecabfc8c653351c68df918005",
	//  "expires_in" : 7200
	//}

	public class SearchRequest {
		public String fn { get; set; } //first name
		public String ls { get; set; } //last name
		public Boolean eonly { get; set; } //true: search employees only
		public String custId  { get; set; } //customer id
		public String country { get; set; } //country of residence
		public List<String> prod  { get; set; } //professional designation
		public List<String> classifation { get; set; }
		public List<String> status { get; set; }
		public List<String> specialty { get; set; }
		public List<String> specialtyRank { get; set; }
		public List<String> aIDType { get; set; }
		public String aID { get; set; }
		public String address { get; set; }
		public String city { get; set; }
		public String state { get; set; }
		public List<String> acountry { get; set; }
		public String pc { get; set; }
		public List<String> role { get; set; }
		public String affil { get; set; }
		public String affilAddress { get; set; }
		public String affilCity { get; set; }
		public List<String> affilCountry { get; set; }
		public List<String> prAffil { get; set; } //priority rank
		public String prAddress { get; set; }
		public String sortField { get; set; }
		public String sortOrder { get; set; }
		public Boolean strict { get; set; } //"off" or "on"
	}

	public class ErrorResult {
		public String Error { get; set; }
		public String Message { get; set; }
	}

	public class SearchResult {
		public Boolean selected { get; set; }
		public Boolean selectable { get; set; }
		public String prim_affil_pstl_cd_extnsn_glbl { get; set; }
	    public String sfid { get; set; }
	    public String prsnl_nbr_glbl { get; set; }
	    public String country_code_merc { get; set; }
	    public String primary_addr_line2_glbl { get; set; }
	    public String lastname { get; set; }
	    public String firstname { get; set; }
	    public String cust_id_glbl { get; set; }
	    public String primary_address_country_glbl { get; set; }
	    public String spclty_desc_glbl { get; set; }
	    public String clsfctn_cd_glbl { get; set; }
	    public String scnd_nm_glbl { get; set; }
	    public String primary_pstl_cd_extnsn_glbl { get; set; }
	    public String systemmodstamp { get; set; }
	    public String name { get; set; }
	    public String mdl_nm_glbl { get; set; }
	    public String prim_affil_hco_glbl { get; set; }
	    public String hcp_profile_status_glbl { get; set; }
	    public String lastmodifieddate { get; set; }
	    public String prim_affil_addr_country_glbl { get; set; }
	    public String id { get; set; }
	    public String primary_hco_glbl { get; set; }
	    public String bnft_dsgn_cd_glbl { get; set; }
	    public String primary_addr_line1_glbl { get; set; }
	    public String isdeleted { get; set; }
	    public String spclty_cd_glbl { get; set; }
	    public String createddate { get; set; }
	    public String prim_affil_addr_line1_glbl { get; set; }
	    public String primary_addr_city_glbl { get; set; }
	    public String prim_affil_addr_city_glbl { get; set; }
	    public String recordtypeid { get; set; }
	}
}