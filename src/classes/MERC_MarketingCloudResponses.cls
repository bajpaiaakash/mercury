public with sharing class MERC_MarketingCloudResponses {
	public class SuccessfulRestAuthorization implements MERC_MockResponseInterface {
        public Boolean shouldRespond(HttpRequest request) {
            return false;
        }

        public HttpResponse respond(){
            return null;
        }
    }
}