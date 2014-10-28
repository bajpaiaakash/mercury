/**
 * @author Kyle Thornton
 *
 * mock response extracted from GLBL_RollupControllerTest. Unit tests show as uncovered lines of code
 * when inner classes exist.
 */
public with sharing class GLBL_RollupControllerWebServiceMockImpl implements WebServiceMock
{
	public void doInvoke(
		Object stub, Object request, Map<String, Object> response,
		String endpoint, String soapAction, String requestName,
		String responseNS, String responseName, String responseType)
	{
		if(request instanceof GLBL_MetadataService.deploy_element)
		{
			GLBL_MetadataService.deployResponse_element response_x = new GLBL_MetadataService.deployResponse_element();
			response_x.result = new GLBL_MetadataService.AsyncResult();
			response_x.result.id = 'someid';
			response_x.result.done = true;
			response_x.result.state = 'Complete';
			response.put('response_x', response_x);
		}
		else if(request instanceof GLBL_MetadataService.checkStatus_element)
		{
			System.assertEquals('someid', ((GLBL_MetadataService.checkStatus_element) request).asyncProcessId[0]);
			GLBL_MetadataService.checkStatusResponse_element response_x = new GLBL_MetadataService.checkStatusResponse_element();
			response_x.result = new List<GLBL_MetadataService.AsyncResult>();
			response_x.result.add(new GLBL_MetadataService.AsyncResult());
			response_x.result[0].done = true;
			response_x.result[0].state = 'Complete';
			response.put('response_x', response_x);
		}
		else if(request instanceof GLBL_MetadataService.checkDeployStatus_element)
		{
			System.assertEquals('someid', ((GLBL_MetadataService.checkDeployStatus_element) request).asyncProcessId);
			GLBL_MetadataService.checkDeployStatusResponse_element response_x = new GLBL_MetadataService.checkDeployStatusResponse_element();
			response_x.result = new GLBL_MetadataService.DeployResult();
			response_x.result.runTestResult = new GLBL_MetadataService.RunTestsResult();
			response_x.result.runTestResult.numFailures = 0;
			response_x.result.messages = new List<GLBL_MetadataService.DeployMessage>();
			response.put('response_x', response_x);
		}
		return;
	}
}