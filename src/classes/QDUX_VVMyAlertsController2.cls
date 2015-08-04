public class QDUX_VVMyAlertsController2 {
     
    public String vaultHttps = 'https://';
    //public string urlprefix {get;set;}
    
    //other variables
    public boolean isException {get;set;}
    public String strVVId {get;set;}
    
    //Task List Wrapper from Vault to retrive current Task
    public List <VVMyTask> vvAlerts;
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
    
    //Retrieve Notification alert from Vault
    public list <VVMyTask> getMyNotificationAlert(){  
        vvAlerts = new List<VVMyTask>();
        vvId(Label.QDUX_Quality_Docs_Label);
        system.debug('VVID ====== ' +strVVId);
        if(strVVId != null){
            retreiveAlerts();
            //retreiveAlerts(Label.QDUX_ETMF_Label); 
        }
        system.debug('give me my alert list ??' +vvAlerts);
        //vvAlerts.sort().;
        return vvAlerts;
        
    }
    
    public void retreiveAlerts(){
        QDUX_HTTPRestUtilsClass uc = new QDUX_HTTPRestUtilsClass();
        //vvAlerts = new List<VVMyTask>();
        String strQ = 'select workflow_id__v ,workflow_status__v, task_id__v, task_name__v, task_status__v, task_assignee_name__v, task_assignee__v, task_dueDate__v, workflow_document_id__v ';
        strQ += 'from workflows where task_assignee__v = \'' +strVVId +'\' and task_dueDate__v > \'2000-01-01\' ORDER BY task_dueDate__v ASC limit 5';
        system.debug('STRING Q???? ' +strQ);
        try{
            String strQD;
            /*
            if(vaultName == Label.QDUX_Quality_Docs_Label){
                strQD = Label.QDUX_VaultQualityDocs_Prefix;   
            } else if (vaultName == Label.QDUX_ETMF_Label){
                strQD = Label.QDUX_VaultETMF_Prefix;
            }*/
            string endpointQD = vaultHttps +Label.QDUX_VaultQualityDocs_Prefix +label.QDUX_VV_BaseURL +label.QDUX_VV_Query_URL_Suffix;
            string endpointETMF = vaultHttps +Label.QDUX_VaultETMF_Prefix +label.QDUX_VV_BaseURL +label.QDUX_VV_Query_URL_Suffix;
            
            // String urlprefix = vaultHttps +Label.QDUX_VaultETMF_Prefix +label.QDUX_VV_BaseURL + label.QDUX_VV_Doc_Link_URL;
            
            string strQDresp = uc.getJSON(endpointQD +EncodingUtil.urlEncode(strQ , 'UTF-8')).replace('__v','');
            string strETMFresp = uc.getJSON(endpointETMF +EncodingUtil.urlEncode(strQ , 'UTF-8')).replace('__v','');
            
            //system.debug('WHAT IS MY REP1 ]]]]]]] ' +strRep1);
            QDUX_VeevaVaultTaskResponse tskQD = (QDUX_VeevaVaultTaskResponse)system.JSON.deserialize(strQDresp, QDUX_VeevaVaultTaskResponse.class);
            QDUX_VeevaVaultTaskResponse tskETMF = (QDUX_VeevaVaultTaskResponse)system.JSON.deserialize(strETMFresp, QDUX_VeevaVaultTaskResponse.class);
            
            if(tskQD.responseStatus == 'Success'){
                for(QDUX_VeevaVaultTaskResponse.data e : tskQD.data){
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
                        myT.docURL = vaultHttps +Label.QDUX_VaultQualityDocs_Prefix +label.QDUX_VV_BaseURL + label.QDUX_VV_Doc_Link_URL +e.workflow_document_id;
                        myT.vName = Label.QDUX_Quality_Docs_Label;
                        system.debug('task stats ???? '+myT.Task_Status);
                        vvAlerts.add(myT);
                        system.debug('what are my VVALERTS list '+vvAlerts);
                    } 
                }
            }
            
            if(tskETMF.responseStatus == 'Success'){
                for(QDUX_VeevaVaultTaskResponse.data e : tskETMF.data){
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
                        myT.docURL = vaultHttps +Label.QDUX_VaultETMF_Prefix +label.QDUX_VV_BaseURL + label.QDUX_VV_Doc_Link_URL +e.workflow_document_id;
                        myT.vName = Label.QDUX_ETMF_Label;
                        system.debug('task stats ???? '+myT.Task_Status);
                        vvAlerts.add(myT);
                        system.debug('what are my VVALERTS list '+vvAlerts);
                    } 
                }
            }
            
            //system.debug('what are my list size ' +vvAlerts.size());
        }catch(System.CalloutException e){
            system.debug('my exception errror' +e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, ''+e));
        }
    }
    
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, ''+e));
            return null;
        }
    }
    
}