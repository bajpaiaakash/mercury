public with sharing class MERC_MarketingCloudResponses {
	public class SuccessfulRestAuthorization {
        public Boolean shouldRespond(HttpRequest request) {
            return false;
        }

        public HttpResponse respond(){
            return null;
        }
    }
}