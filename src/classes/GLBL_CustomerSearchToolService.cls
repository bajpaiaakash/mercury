/**
 * @author Joseph Ferraro
 *
 * Service which submits query to Customer Search Tool running on Heroku
 */

public with sharing class GLBL_CustomerSearchToolService {
	
	static String baseUrl = 'https://afternoon-temple-9240.herokuapp.com'; //TODO: custom setting
	static String apiKey = '12345'; //TODO: custom setting

	public static List<SearchResult> doSearch(SearchRequest req) {
		String requestJson = JSON.serialize(req);
		system.debug('>>> '+requestJson);

		HttpRequest r = new HttpRequest();
		r.setHeader('Content-type', 'application/json');
		r.setHeader('Accept', 'application/json');
		r.setEndpoint(GLBL_CustomerSearchToolService.baseUrl+'/jsonsearch'); 
		r.setMethod('POST');
		r.setBody(requestJson);

		Http h = new Http();
		HttpResponse response = h.send(r);
		String s = response.getBody();
		system.debug('>>> response from search tool: '+s);
		if (response.getStatusCode() == 400) {
			ErrorResult res = (ErrorResult)JSON.deserialize(s, ErrorResult.class);
			return null;
		} else {
			List<SearchResult> results = (List<SearchResult>)JSON.deserialize(s, List<SearchResult>.class);
			system.debug(results);
			return results;
		}
	}

	public class SearchRequest {
		public String fn { get; set; } //first name
		public String ls { get; set; } //last name
		public String custId  { get; set; } //customer id
		public List<String> prod  { get; set; } //professional designation
		public String classification { get; set; }
		public List<String> status { get; set; }
		public List<String> specialty { get; set; }
		public String aIDType { get; set; }
		public String aId { get; set; }
		public String address { get; set; }
		public String state { get; set; }
		public String country { get; set; }
		public String pc { get; set; }
		public String affiliation { get; set; }
		public String priorityRank { get; set; }
		public String strict { get; set; } //"off" or "on"
	}

	public class ErrorResult {
		public String Error { get; set; }
		public String Message { get; set; }
	}

	public class SearchResult {
		public Boolean selected { get; set; }
		public String id { get; set; }
		public String sfdc_id { get; set; }
		public String recordtype { get; set; }
		public String firstname { get; set; }
		public String mdl_nm_glbl { get; set; }
		public String lastname { get; set; }
		public String scnd_nm_glbl { get; set; }
		public String cust_id_glbl { get; set; }
		public String bnft_dsgn_cd_glbl { get; set; }
		public String clsfctn_cd_glbl { get; set; }
		public String hcp_profile_status_glbl { get; set; }
		public String specialty_glbl { get; set; }
		public String specialty_2_glbl { get; set; }
		public String prsnl_nbr_glbl { get; set; }
		public String country_merc { get; set; }
		public String created_at { get; set; }
		public String updated_at { get; set; }
		public String primary_addr_line1_merc { get; set; }
		public String primary_addr_line2_merc { get; set; }
		public String primary_addr_city_merc { get; set; }
		public String primary_addr_country_merc { get; set; }
		public String primary_alignment_merc { get; set; }
		public String primary_hco_merc { get; set; }
	}
}