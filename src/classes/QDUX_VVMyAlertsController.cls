/**
 * Created by: Eric Montelibano (PwC)- 21/05/2015
 * Application: Quality in Design User Experience (QDUX)
 * 
 * Description: Controller class for the components for QDUX_VVMyAlerts
 * The controller will retrieve Task and alerts from applicable external systems like Veeva Vault Quality Docs and ETMF.
*/



public class QDUX_VVMyAlertsController {
    public QDUX_VVMyAlertsController(){ 
    }
    
    public String vaultHttps = 'https://';
    //other variables
    public boolean isException {get;set;}
    public String strVVId {get;set;}
    
    //Task List Wrapper from Vault to retrive current Task
    public List <VVMyTask> vvAlerts {get;set;}
    public class VVMyTask{
        public Integer workflow_id {get;set;}
        public String workflow_status {get;set;}
        public Integer task_id {get;set;}
        public String task_name {get;set;}
        public String task_status {get;set;}
        public String task_assignee_name {get;set;}
        public Integer task_assignee {get;set;}
        public date task_dueDate {get;set;}
        public string workflow_document_id {get;set;}
        public string docURL {get;set;}
        public string vName {get;set;}
    }
    
    //Method that will be called to retrieve alerts when an action is triggered from the VF Page
    //Methods will retrieve alerts form appropriate syste. To retrieve alerts from Vault, 2 HTTP call will need to happen.
	//1. Verify if the user has access to the Vault and retrieve the user's vault id
	//2. Send across Veeva Vault Id to the system to retrieve alerts.
    
	public void notificationAlert(){
        system.debug('START??? ');
        vvAlerts = new List <VVMyTask>();
        vvId(Label.QDUX_Quality_Docs_Label);
        if(strVVId != null){
            retriveAlerts(Label.QDUX_Quality_Docs_Label);
            retriveAlerts(Label.QDUX_ETMF_Label); 
        }
        system.debug('list size????? ' +vvAlerts.size());
        //return null;
    }
    
    //Retrieve Veeva Vault Alerts if the Vault Id is available. Sends a call to Vault and parse the JSON through QDUX_VeevaVaultTaskResponse
    public void retriveAlerts(String vaultName){
        QDUX_HTTPRestUtilsClass uc = new QDUX_HTTPRestUtilsClass();
        //vvAlerts = new List<VVMyTask>();
        String strQ = 'select workflow_id__v ,workflow_status__v, task_id__v, task_name__v, task_status__v, task_assignee_name__v, task_assignee__v, task_dueDate__v, workflow_document_id__v ';
        strQ += 'from workflows where task_assignee__v = \'' +strVVId +'\' and task_dueDate__v > \'2000-01-01\' ORDER BY task_dueDate__v ASC limit 5';
        system.debug('STRING Q???? ' +strQ); 
        try{
            String strQD;
            if(vaultName == Label.QDUX_Quality_Docs_Label){
                strQD = Label.QDUX_VaultQualityDocs_Prefix;   
            } else if (vaultName == Label.QDUX_ETMF_Label){
                strQD = Label.QDUX_VaultETMF_Prefix;
            }
            string endpoint = vaultHttps +strQD +label.QDUX_VV_BaseURL +label.QDUX_VV_Query_URL_Suffix;
            system.debug('?????' +endpoint);
            String urlprefix = vaultHttps +strQD +label.QDUX_VV_BaseURL + label.QDUX_VV_Doc_Link_URL;
            
            string strRep1 = uc.getJSON(endpoint +EncodingUtil.urlEncode(strQ , 'UTF-8')).replace('__v','');
            system.debug('WHAT IS MY REP1 ]]]]]]] ' +strRep1);
            QDUX_VeevaVaultTaskResponse tsk = (QDUX_VeevaVaultTaskResponse)system.JSON.deserialize(strRep1, QDUX_VeevaVaultTaskResponse.class);
            
            if(tsk.responseStatus == 'Success'){
                for(QDUX_VeevaVaultTaskResponse.data e : tsk.data){
                    system.debug('TASK STATUS =////// '+e.task_status);
                    if(e.task_status == 'Assigned'){
                        VVMyTask myT = new VVMyTask();
                        myT.workflow_id = e.workflow_id;
                        myT.workflow_status = e.workflow_status;
                        myT.task_id = e.task_id;
                        myT.task_name = e.task_name;
                        myT.task_status = e.task_status;
                        myT.task_assignee_name = e.task_assignee_name;
                        myT.task_assignee = e.task_assignee;
                        myT.task_dueDate = e.task_dueDate;
                        myT.workflow_document_id = e.workflow_document_id;
                        myT.docURL = urlprefix +e.workflow_document_id;
                        myT.vName = vaultName;
                        system.debug('task stats ???? '+myT.Task_Status);
                        vvAlerts.add(myT);
                        system.debug('what are my VVALERTS list '+vvAlerts);
                    } 
                }
            }
        }catch(System.CalloutException e){
            system.debug('my exception errror' +e);
            uc.createErrorMessage(e.getMessage(), e.getStackTraceString(), 'Error found at ' +vaultName);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, 'Error Message: '+e.getMessage() ));
            
        }
    }
    
    //Call to Vault to retrieve user vault id
    public String vvId(string vaultName){
        QDUX_HTTPRestUtilsClass uc = new QDUX_HTTPRestUtilsClass();
        try{
            String strQ ='SELECT id, user_name__v, salesforce_user_name__v FROM users where salesforce_user_name__v = \'' +UserInfo.getUserName() +'\'';
            string endpoint = vaultHttps +Label.QDUX_VaultQualityDocs_Prefix +label.QDUX_VV_BaseURL +label.QDUX_VV_Query_URL_Suffix;
            //response info
            string strRep1 = uc.getJSON(endpoint +EncodingUtil.urlEncode(strQ , 'UTF-8')).replace('__v','');
            QDUX_VeevaVaultTaskResponse usr = (QDUX_VeevaVaultTaskResponse)system.JSON.deserialize(strRep1, QDUX_VeevaVaultTaskResponse.class);
            if(usr.responseStatus == 'Success'){
                for(QDUX_VeevaVaultTaskResponse.data e : usr.data){
                    strVVId = string.valueof(e.id);
                    system.debug('strVVID ===='  +strVVId);
                }
            }
            return null;
        } catch(System.CalloutException e){
            system.debug('my exception errror' +e);
            uc.createErrorMessage(e.getMessage(), e.getStackTraceString(), Label.QDUX_Callout_Failed_Message);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, 'Error Message: '+e.getMessage() ));
            return null;
        }
    }
    
}