/**
 * @author Kyle Thornton
 * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
 * extracted from GLBL_MetadataServiceTest as salesforce was reporting lines of code in the test
 * class as not covered when this class was an inner class
 **/
public class GLBL_MetadataWebServiceMockImpl implements WebServiceMock
{
	public void doInvoke(
		Object stub, Object request, Map<String, Object> response,
		String endpoint, String soapAction, String requestName,
		String responseNS, String responseName, String responseType)
	{
		if(request instanceof GLBL_MetadataService.retrieve_element)
			response.put('response_x', new GLBL_MetadataService.retrieveResponse_element());
		else if(request instanceof GLBL_MetadataService.checkDeployStatus_element)
			response.put('response_x', new GLBL_MetadataService.checkDeployStatusResponse_element());
		else if(request instanceof GLBL_MetadataService.update_element)
			response.put('response_x', new GLBL_MetadataService.updateResponse_element());
		else if(request instanceof GLBL_MetadataService.listMetadata_element)
			response.put('response_x', new GLBL_MetadataService.listMetadataResponse_element());
		else if(request instanceof GLBL_MetadataService.checkStatus_element)
			response.put('response_x', new GLBL_MetadataService.checkStatusResponse_element());
		else if(request instanceof GLBL_MetadataService.create_element)
			response.put('response_x', new GLBL_MetadataService.createResponse_element());
		else if(request instanceof GLBL_MetadataService.checkRetrieveStatus_element)
			response.put('response_x', new GLBL_MetadataService.checkRetrieveStatusResponse_element());
		else if(request instanceof GLBL_MetadataService.delete_element)
			response.put('response_x', new GLBL_MetadataService.deleteResponse_element());
		else if(request instanceof GLBL_MetadataService.describeMetadata_element)
			response.put('response_x', new GLBL_MetadataService.describeMetadataResponse_element());
		else if(request instanceof GLBL_MetadataService.deploy_element)
			response.put('response_x', new GLBL_MetadataService.deployResponse_element());
		return;
	}
}