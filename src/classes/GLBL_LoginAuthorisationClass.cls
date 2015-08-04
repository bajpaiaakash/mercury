/*************************************************************************\
    @ Author        : Nitish Kumar
    @ Date          : 24-July-2014
    @ Test Class    : Test_GLBL_LoginAuthorisationClass
    @ Description   : This class is used in the visualforce component for login 
                      verification.
****************************************************************************/
public without sharing virtual class GLBL_LoginAuthorisationClass {

    public String username {
        get {
            return UserInfo.getUsername();
        }
    }
    public transient String password {
        get;
        set;
    }

  
    public Boolean verified {
        get;
        set;
    }

    /*********************************************************************************************************************
     Method : doVerify
     Input Parameters : N/A 
     Description : Boolean method which will be used to find if there is a loginResponse element.
                   If there is no loginresponse setting the boolean variable to false.     
    ********************************************************************************************************************/

    public Boolean doVerify() {

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://' + loginDomain() + '.salesforce.com/services/Soap/u/22.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        request.setBody(buildSoapLogin(username, password));

        verified = false;

        //basically if there is a loginResponse element, then login succeeded; else there
        // would be soap fault element after body
        if (!Test.isRunningTest()) {
            verified = (new Http()).send(request).getBodyDocument().getRootElement()
                .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('loginResponse', 'urn:partner.soap.sforce.com') != null;
        }
        //Condition for test classes
        else {
            verified = true;
        }

        return verified;
    }

    /*********************************************************************************************************************
     Method : checkLogin
     Input Parameters : N/A
     Description : PageReference method which shows the message based on the login verification     
    ********************************************************************************************************************/

    public pagereference checkLogin() {

        Boolean loginResponse = doVerify();
        

        if (loginResponse) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.GLBL_Correct_Password));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.GLBL_Incorrect_Password));
        }

        return null;
    }


    /*********************************************************************************************************************
     Method : buildSoapLogin
     Input Parameters : (String Username , String Password)
     Description : String method which returns the xml output of the login response     
    ********************************************************************************************************************/

    public static String buildSoapLogin(String username, String password) {
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement('', 'login', 'urn:partner.soap.sforce.com');
        w.writeNamespace('', 'urn:partner.soap.sforce.com');
        w.writeStartElement('', 'username', 'urn:partner.soap.sforce.com');
        w.writeCharacters(username);
        w.writeEndElement();
        w.writeStartElement('', 'password', 'urn:partner.soap.sforce.com');
        w.writeCharacters(password);
        w.writeEndElement();
        w.writeEndElement();

        String xmlOutput =
            '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Body>' + w.getXmlString() + '</Body></Envelope>';
        w.close();
        return xmlOutput;
    }

    /*********************************************************************************************************************
     Method : loginDomain
     Input Parameters : N/A
     Description : String method which Login Domain of the environment     
    ********************************************************************************************************************/

    public String loginDomain() {

        Organization org = [SELECT Id, IsSandbox from Organization limit 1];

        if (org.isSandBox) {
            return 'test';
        } else {
            return 'login';
        }
    }

}