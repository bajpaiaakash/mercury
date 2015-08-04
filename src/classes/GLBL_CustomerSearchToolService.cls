/**
 * @author Joseph Ferraro
 *
 * Service which submits query to Customer Search Tool running on Heroku
 *  -It relies on clientid/clientsecret distributed by the CST to retrieve a token
 *  -Because of Apex constraints re: DML/calling out, we retrieve a new access token each time the page is loaded
 * 	-we can refactor in the future to possibly implement a @future method which updates an expired access token on a 401 response
 */
public with sharing class GLBL_CustomerSearchToolService {

	public Boolean searching {
		get {
			if (searchStatus == null) {
				return false;
			}
			else if (searchStatus.toUpperCase() == 'SEARCHING' || searchStatus.toUpperCase() == 'QUEUED') {
				return true;
			}
			else {
				return false;
			}
		}
	}
	public String searchStatus;
	public String errorDescription;
	private String baseUrl;
	public String accessToken { get; private set; }
	public Mercury_Settings_MERC__c appSettings {
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

	//performs search against the CST
	public String doSearch(SearchRequest req) {
		String requestJson = JSON.serialize(req);
		system.debug('>>> '+requestJson);

		return processResponse(tryCallout(requestJson), requestJson);
	}


	/* retrieveResults
	 * Called to submit search and returns a search id,
	 * necessary for retrieving the results.
	 */ 
	private HttpResponse tryCallout(String requestJson) {
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
		return h.send(r);
	}

	/* processResponse
	 * Parses response and returns search id and/or errors.
	 */
	private String processResponse(HttpResponse response, String requestJson) {
		String result = '';
		System.debug('\n\n\nResponse body is: ' + response.getBody() + '\n\n\n');
		
		// 400 Bad Request: The request could not be understood by the server due to malformed syntax.
		if (response.getStatusCode() == 400) {
			error = (ErrorResult)JSON.deserialize(response.getBody(), ErrorResult.class);
		
		// 401 Unauthorized: The request requires user authentication.
		} else if (response.getStatusCode() == 401) {
			// If the user is unauthorized refresh the token and try again, only one more time
			if (String.isNotBlank(requestJson)) {
				refreshToken();
				HttpResponse retryResponse = tryCallout(requestJson);
				result = processResponse(retryResponse, ''); //pass empty string this time so we won't try again if we get another 401 response.
				return result;
			}
			error = (ErrorResult)JSON.deserialize(response.getBody(), ErrorResult.class);
		
		// 200 The request has succeeded.
		// Returning Search Id, if none retrieved, try one more time.
		} else if (response.getStatusCode() == 200) {
			String s = response.getBody();
			System.debug('\n\n\nresponse body  is: ' + s + '\n\n\n');
			SearchIdResult searchIdRes = (SearchIdResult)JSON.deserialize(s, SearchIdResult.class);
			if(String.isNotBlank(searchIdRes.search_id)) {
				refreshToken();
				//return result;
				return searchIdRes.search_id;
			} else if (String.isNotBlank(requestJson)) {
				HttpResponse retrieveSearch = tryCallout(requestJson);
				result = processResponse(retrieveSearch, ''); //pass empty string this time so we won't try again if we get another 401 response.
				return result;
			} else {
				error = new ErrorResult();
				error.Error = 'Search Id not found.';
				error.Message = response.getBody();
			}

		// Unknown response.
		} else {
			error = new ErrorResult();
			error.Error = 'UNEXPECTED';
			error.Message = response.getBody();
		}

		return result;
	}

	/* retrieveResults
	 * Called to retrieve results.
	 * Results are returned back through this method.
	 */ 
	public List<SearchResult> retrieveResults(String searchId) {
		system.debug('>>> '+searchId);
		return processResultResponse(tryCalloutRetrieve(searchId), searchId);
	}

	/* tryCallOutRetrieve
	 * Collects search results by passing a HttpRequest
	 * with the Search Id.
	 */
	public HttpResponse tryCallOutRetrieve(String searchId) {
		HttpRequest r = new HttpRequest();
		r.setHeader('Content-type', 'application/json');
		r.setHeader('Authorization', 'Bearer '+this.accessToken);
		r.setHeader('Accept', 'application/json');
		r.setEndpoint(this.baseUrl+'/search/'+searchId);
		System.debug(r.getEndpoint());
		r.setMethod('GET');
		r.setTimeout(30000); //match heroku timeout

		system.debug('>>>  '+r.getHeader('Authorization'));
		error = null;
		Http h = new Http();
		return h.send(r);
	}

	/* processResultResponse
	 * Used for processing the HttpResponse from an attempt to retrieve
	 * the results.
	 */
	private List<SearchResult> processResultResponse(HttpResponse response, String searchId) {
		List<SearchResult> results = new List<SearchResult>();
		
		// 400 Bad Request: The request could not be understood by the server due to malformed syntax.
		if (response.getStatusCode() == 400) {
			error = (ErrorResult)JSON.deserialize(response.getBody(), ErrorResult.class);
		
		// 401 Unauthorized: The request requires user authentication.
		} else if (response.getStatusCode() == 401) {
			// If the user is unauthorized refresh the token and try again, only one more time
			if (String.isNotBlank(searchId)) {
				refreshToken();
				HttpResponse retryResponse = tryCallOutRetrieve(searchId);
				results = processResultResponse(retryResponse, ''); //pass empty string this time so we won't try again if we get another 401 response.
			}
			error = (ErrorResult)JSON.deserialize(response.getBody(), ErrorResult.class);
		
		// 200 The request has succeeded.
		// Process response and return result.
		} else if (response.getStatusCode() == 200) {
			String s = response.getBody().replaceAll('__c"','"');
			system.debug('\n\n\nFull result is: ' + s + '\n\n\n');
			FullSearchResult fullResult = (FullSearchResult)JSON.deserialize(s, FullSearchResult.class);
			system.debug('\n\n\nFull result is: ' + fullResult + '\n\n\n');
			if(fullResult.status == null) {
				error = new ErrorResult();
				error.Error = 'NULL RESPONSE';
				error.Message = response.getBody();
			}
			if(fullResult.status.toUpperCase() == 'SEARCHING') {
				searchStatus = fullResult.status;
				errorDescription = fullResult.error;
			} else {
				results = fullResult.result;
				searchStatus = fullResult.status;
				errorDescription = fullResult.error;
				system.debug('>>> results from search tool: '+results);
			}
		
		// Any other type of response.
		} else {
			error = new ErrorResult();
			error.Error = 'UNEXPECTED';
			error.Message = response.getBody();
		}
		
		return results;
	}

	//retrieves a token if it expires
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
		} else if (tokenResponse.error != null) {
			System.debug('\n\n\n>>>> ERROR DURING TOKEN REFRESH ' + today+ ': '+ tokenResponse.error +' - '+tokenResponse.error_description);
		}
	}

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


	/* SearchRequest
	 * Inner request used to JSON.serialize 
	 * for the httpRequest.
	 */
	public class SearchRequest {
		public String fn { get; set; } //first name
		public String ls { get; set; } //last name
		public Boolean eonly { get; set; } //true: search employees only
		public String custId  { get; set; } //customer id
		// country should never ever be omitted from search request. Ever. So hard-coding here!!
		public String country { get{ if (String.isBlank(country)) {return '00';} else {return country;}} set; } //country of residence
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
	// ErrorResult
	public class ErrorResult {
		public String Error { get; set; }
		public String Message { get; set; }
	}

	/* SearchIdResult
	 * Used to deserialize the Json response.
	 * The Search Id will be then used to retrieve
	 * results in the next httpRequests.
	 */
	public class SearchIdResult {
		public String search_id {get; set;}
	}

	/* FullSearchResult
	 * Used for deserialization of the Json's search results.
	 * It includes a list of SearchResults.
	 */
	public class FullSearchResult {
		public String status { get; set; } //should be queued/searching/complete/error/expired
		public String error {get; set; }
		public List<SearchResult> result {get; set;}
	}

	/* SearchResult
	 * The deserialization class for the results. Used in list
	 * form inside FullSearchResult.
	 */
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