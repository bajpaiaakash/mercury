/**
 * Utility class to handle the fact that the request and summary "new" buttons both want to go to the same VF
 * page, but it can only have 1 controller.
 * Use this class to redirect to the home page from the request and summary list views.
 */
public with sharing class C3AP_HomePageRouter {
	
	/**
	 * Empty private constructor
	 */
	public C3AP_HomePageRouter(ApexPages.StandardController controller) {}
	
	public PageReference init() {
		return Page.C3AP_Home_Page;
	}
	
	

}