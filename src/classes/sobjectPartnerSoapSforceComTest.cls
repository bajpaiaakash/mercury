/**
 * @author Joseph Ferraro
 *
 * Intended to get the requisite coverage on the SOAP Partner connection
 * We'll test actual functionality in TODO_CLASS
 */

@IsTest
private with sharing class sobjectPartnerSoapSforceComTest {
    
    private static testMethod void coverTypes() {
        new sobjectPartnerSoapSforceCom.DescribeLayoutComponent();
        new sobjectPartnerSoapSforceCom.SessionHeader_element();
        new sobjectPartnerSoapSforceCom.DescribeLayoutButton();
        new sobjectPartnerSoapSforceCom.DescribeLayoutItem();
        new sobjectPartnerSoapSforceCom.DescribeLayoutButtonSection();
        new sobjectPartnerSoapSforceCom.describeLayoutResponse_element();
        new sobjectPartnerSoapSforceCom.DescribeLayoutResult();
        new sobjectPartnerSoapSforceCom.RecordTypeMapping();
        new sobjectPartnerSoapSforceCom.PicklistForRecordType();
        new sobjectPartnerSoapSforceCom.DescribeLayoutSection();
        new sobjectPartnerSoapSforceCom.PicklistEntry();
        new sobjectPartnerSoapSforceCom.describeLayout_element();
        new sobjectPartnerSoapSforceCom.DescribeLayout();
        new sobjectPartnerSoapSforceCom.RelatedList();
        new sobjectPartnerSoapSforceCom.RelatedListSort();
        new sobjectPartnerSoapSforceCom.RelatedListColumn();
        new sobjectPartnerSoapSforceCom.DescribeLayoutRow();
    }

    private class WebServiceMockImpl implements WebServiceMock {
		public void doInvoke(
		    Object stub, Object request, Map<String, Object> response,
		    String endpoint, String soapAction, String requestName,
		    String responseNS, String responseName, String responseType) {
            if(request instanceof sobjectPartnerSoapSforceCom.describeLayout_element) {
                sobjectPartnerSoapSforceCom.describeLayoutResponse_element el = new sobjectPartnerSoapSforceCom.describeLayoutResponse_element();
                el.result = new sobjectPartnerSoapSforceCom.DescribeLayoutResult();
		        response.put('response_x', el);
            }
		    return;
		}
	}

	private static testMethod void coverMethods() {
		Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        new sobjectPartnerSoapSforceCom.Soap().describeLayout(null, null);
	}
}