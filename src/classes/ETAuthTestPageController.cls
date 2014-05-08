public with sharing class ETAuthTestPageController {
    public ETAuthTestPageController() {
        authorizer = new ETAuthorizer();
        showSoapAuthString = false;
        showFuelAuthString = false;
        showDEResponse = false;
    }

    public ETAuthorizer authorizer { get; set; }

    public Boolean showSoapAuthString { get; set; }
    public PageReference toggleShowSoapAuthString() {
        showSoapAuthString = true;
        return null;
    }

    public Boolean showFuelAuthString { get; set; }
    public PageReference toggleShowFuelAuthString() {
        showFuelAuthString = true;
        return null;
    }

    public String deKey { get; set; }
    public Boolean showDEResponse { get; set; }
    public ETDataExtension.DataExtensionResponse deResponse { get; set; }
    public PageReference toggleShowDEResponse() {
        showDEResponse = true;
        deKey = Datetime.now().format('yyyyMMddHHmmssSSS');
        deResponse = authorizer.createDataExtensionWithKey(deKey);
        return null;
    }

    public String dataCreateResponseBody { get; set; }
    public Boolean showDataCreateResponseBody { get; set; }
    public PageReference toggleShowDataCreateResponseBody() {
        showDataCreateResponseBody = true;
        dataCreateResponseBody = authorizer.createDummyDataExtensionDataForKey(deKey);
        return null;
    }
}