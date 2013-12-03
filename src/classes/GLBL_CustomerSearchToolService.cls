/**
 * @author Joseph Ferraro
 *
 * Service which submits query to Customer Search Tool running on Heroku
 */

public with sharing class GLBL_CustomerSearchToolService {
	
	static String baseUrl = 'http://afternoon-temple-9240.herokuapp.com'; //TODO: custom setting
	static String apiKey = '12345'; //TODO: custom setting

	public static List<SearchResult> doSearch(SearchRequest req) {
		HttpRequest r = new HttpRequest();
		r.setHeader('Content-type', 'application/json');
		r.setHeader('Accept', 'application/json');
		r.setEndpoint(GLBL_CustomerSearchToolService.baseUrl+'/search'); 
		r.setMethod('POST');
		r.setBody(JSON.serialize(req));

		Http h = new Http();
		HttpResponse response = h.send(r);
		String s = response.getBody();
		List<SearchResult> results = (List<SearchResult>)JSON.deserialize(s, List<SearchResult>.class);
		system.debug(results);
		return results;
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

	public class SearchResult {
		public Boolean selected { get; set; }
		public String id;
		public String sfdc_id;
		public String recordtype;
		public String firstname;
		public String mdl_nm_glbl;
		public String lastname;
		public String scnd_nm_glbl;
		public String cust_id_glbl;
		public String bnft_dsgn_cd_glbl;
		public String clsfctn_cd_glbl;
		public String hcp_profile_status_glbl;
		public String specialty_glbl;
		public String specialty_2_glbl;
		public String prsnl_nbr_glbl;
		public String country_merc;
		public String created_at;
		public String updated_at;
		public String primary_addr_line1_merc;
		public String primary_addr_line2_merc;
		public String primary_addr_city_merc;
		public String primary_addr_country_merc;
		public String primary_alignment_merc;
		public String primary_hco_merc;
	}
}