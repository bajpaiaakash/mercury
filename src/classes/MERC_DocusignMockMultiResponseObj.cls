/*
 * @author Kyle Thornton
 * A response object able to respond to the chain of callouts within the controller
 * this is just a mock response and not meant to be used outside of a test class.
 * Extracted from MERC_RequestHCPSignatureControllerTest as it was causing the entire
 * test class to show up as uncovered lines of code.
*/
public with sharing class MERC_DocusignMockMultiResponseObj {
	 // properties from MERC_DocusignService.EnvelopeResponse
    public String envelopeId;
    public String status;
    public String statusDateTime;
    public String uri;
    public String errorCode;
    public String message;

    // properties from MERC_DocusignService.TagAndSendResponse
    public String url;
}