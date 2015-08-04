/****************************************************************************************************************************************** 
* Class Name   : PANG_CreateRequestController 
* Description  : Class for Creating Requests on UI
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
public with sharing class PANG_CreateRequestController {
    
    public PANG_Request__c oRequest {
        get;
        set;
    }
    public list < wDataAsset > lDisplayAssets {
        get;
        set;
    }
    Public Boolean isAcknowledge {
        get;
        set;
    }
    Public Boolean isAcknowledgeChecked {
        get;
        set;
    }
    
    //Individually declaring 3 attachments rather than list beacuse this will resolve the issue of upolading documents with name more than 80 characters    
    public Transient Blob attachmentBody1 {
        get;
        set;
    }
    public String attachmentName1 {
        get;
        set;
    }
    public Transient Blob attachmentBody2 {
        get;
        set;
    }
    public String attachmentName2 {
        get;
        set;
    }
    public Transient Blob attachmentBody3 {
        get;
        set;
    }
    public String attachmentName3 {
        get;
        set;
    }
    
    Public Map < string, id > mRecordTypes = new Map < string, id > ();
    
    //Constructor of the Page
    public PANG_CreateRequestController(ApexPages.StandardController stdController) {
        
        isAcknowledge = false;
        
        for (RecordType oRecType: [SELECT id, developername FROM RecordType WHERE SobjectType = 'PANG_Request__c']) {
            mRecordTypes.put(oRecType.developername, oRecType.id);
        }
        
        lDisplayAssets = new List < wDataAsset > ();
        list < pang_data_asset__C > lDataMartAssets = [SELECT id, name, Documentation_Link__c 
                                                       FROM PANG_Data_Asset__c 
                                                       WHERE Asset_Status__c = 'Licensed Corporately'
                                                       AND Asset_Sub_Status__c = 'multi-use data asset'];
        
        if (lDataMartAssets.size() > 0) {
            for (PANG_Data_Asset__c oDataAsset: lDataMartAssets) {
                lDisplayAssets.add(new wDataAsset(oDataAsset, false));
            }
        }       
        
        string recTypeDevName = ApexPages.currentPage().getParameters().get('recTypeName');
        
        If(stdController.getrecord().id != NULL) {} else {
            oRequest = new PANG_Request__c();
            
            oRequest.recordTypeid = mRecordTypes.get(recTypeDevName);
            oRequest.Requestor__c = userinfo.getuserid();
            
            IF(recTypeDevName == 'Data_Sourcing') {
                oRequest.Proposed_Due_Date__c = addBussinessDays(system.today(), 10);
            }
            IF(recTypeDevName == 'EXPERT_or_ACT_Consultation') {
                oRequest.Proposed_Due_Date__c = addBussinessDays(system.today(), 5);
            }
            IF(recTypeDevName == 'EXPERT_Review') {
                oRequest.Proposed_Due_Date__c = addBussinessDays(system.today(), 10);
            }
            IF(recTypeDevName == 'RWE_Strategic_Consultation') {
                oRequest.Proposed_Due_Date__c = addBussinessDays(system.today(), 5);
            }
        }
        
    }
    
    /* 
* @Method Name                    :  displayAcknowledge
* @Description                    :  Checks if the user has selected a Data Asset.
* @Return Type                    :  void
* @Parameters                     :  None
*/ 
    public void displayAcknowledge() {
        for (wDataAsset oDataAsset: lDisplayAssets) {
            if (oDataAsset.isSelected == True) {
                isAcknowledge = true;
                break;
            } else {
                isAcknowledge = false;
            }
        }
    }
    
    /* 
* @Method Name                    :  insertDataMartAssets
* @Description                    :  Method to insert related inhouse data assets on data mart project and data mart access forms
* @Return Type                    :  void
* @Parameters                     :  lwrappers,oReq
*/ 
    public void insertDataMartAssets(list < wDataAsset > lwrappers, PANG_Request__c oReq) {
        list < PANG_Request_Data_Asset__c > lDataMartsIns = new list < PANG_Request_Data_Asset__c > ();
        for (wDataAsset oAst: lwrappers) {
            if (oAst.isSelected == True) {
                lDataMartsIns.add(new PANG_Request_Data_Asset__c(Request__c = oReq.ID, Data_Asset__c = oAst.oDataAsset.ID));
            }
        }
        if (lDataMartsIns.size() > 0) {
            insert lDataMartsIns;
        }
    }
    /* 
* @Method Name                    :  save
* @Description                    :  Method to save the form
* @Return Type                    :  void
* @Parameters                     :  None
*/ 
    public void save() {
        try {
            If(oRequest.recordTypeID == mRecordTypes.get('Internal_Real_World_Data_Analysis')) {
                if (isAcknowledge == true) {
                    if (isAcknowledgeChecked == True) {
                        oRequest.Completed_Data_Asset_Contract_Review_s__c = 'Yes';
                        insert oRequest;
                        insertDataMartAssets(lDisplayAssets, oRequest);
                        insertAttachments();
                        insertAccessForm(oRequest);
                        updateRequest(oRequest);
                        successMessage(true);
                    } else {
                        successMessage(false);
                    }
                } else {
                    insert oRequest;
                    insertAttachments();
                    insertAccessForm(oRequest);
                    updateRequest(oRequest);
                    successMessage(true);
                }
            } else {
                insert oRequest;
                insertAttachments();
                updateRequest(oRequest);
                successMessage(true);
            }
        } catch (exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getmessage()));
        }
    }
    
    
    /* 
* @Method Name                    :  updateRequest
* @Description                    :  Method to update request upon sumission
* @Return Type                    :  void
* @Parameters                     :  oReq
*/ 
    public void updateRequest(PANG_Request__c oReq){
        oReq.Submitted__c = true;
        oReq.Send_Notification__c = true;
        Update oReq;
    }
    
    /* 
* @Method Name                    :  successMessage
* @Description                    :  Method to display page messages upon submitting request form 
* @Return Type                    :  void
* @Parameters                     :  b
*/ 
    public void successMessage(Boolean b) {
        if (b) {
            String err = ' click <a href="/apex/PANG_Homepage">here</a> to return to the Pangaea home page.';
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.CONFIRM, 'Your Request has been successfully submitted. Thank You. Please' + err);
            ApexPages.addmessage(msg);
        } else {
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, 'Please acknowledge access requirements');
            ApexPages.addmessage(msg);
        }
    }
    
    /* 
* @Method Name                    :  insertAccessForm
* @Description                    :  Method to insert access form
* @Return Type                    :  void
* @Parameters                     :  oRequest
*/ 
    public void insertAccessForm(PANG_Request__c oRequest) {
        
        User u = [SELECT name FROM User WHERE id = : oRequest.Requestor__c];
        
        PANG_Request__c oAccessReq = new PANG_Request__c();
        oAccessReq.Name = u.name;
        oAccessReq.Requestor__c = oRequest.Requestor__c;
        oAccessReq.Requestor_Functional_Area__c = oRequest.Requestor_Functional_Area__c;
        oAccessReq.Date_Submitted__c = system.today();
        oAccessReq.Proposed_Due_Date__c = addBussinessDays(system.today(), 5);        
        oAccessReq.Contract_Review_Completion_Date__c = system.today();
        oAccessReq.recordTypeID = mRecordTypes.get('Internal_Real_World_Data_Access');
        oAccessReq.Primary_Request__c = oRequest.id;
        if (isAcknowledgeChecked == True) {
            oAccessReq.Completed_Data_Asset_Contract_Review_s__c = 'Yes';
        }
        insert oAccessReq;
        insertDataMartAssets(lDisplayAssets, oAccessReq);
        updateRequest(oAccessReq);
    }
    
    /* 
* @Method Name                    :  insertAttachments
* @Description                    :  Method to insert attachments for various forms
* @Return Type                    :  void
* @Parameters                     :  None
*/ 
    public void insertAttachments() {
        list < Attachment > lAttachments = new list < Attachment > ();
        if (attachmentBody1 != null && attachmentName1 != NULL) {
            lAttachments.add(new attachment(name = attachmentName1, body = attachmentBody1, parentID = oRequest.id));
        }
        if (attachmentBody2 != null && attachmentName2 != NULL) {
            lAttachments.add(new attachment(name = attachmentName2, body = attachmentBody2, parentID = oRequest.id));
        }
        if (attachmentBody3 != null && attachmentName3 != NULL) {
            lAttachments.add(new attachment(name = attachmentName3, body = attachmentBody3, parentID = oRequest.id));
        }
        if (lAttachments.size() > 0) {
            database.insert(lAttachments, false);
        }
        
    }
    
    /* 
* @Method Name                    :  addBussinessDays
* @Description                    :  Method to populate proposed due date field on forms excluding weekends
* @Return Type                    :  Date
* @Parameters                     :  startDate,iDays
*/     
    public Date addBussinessDays(Date startDate, Integer iDays) {
        Date endDate = startDate.addDays(iDays);
        Datetime current = System.now();
        Time currTime = current.time();  
        Datetime slocal = datetime.newinstance(startDate,currTime);
        Datetime elocal = datetime.newinstance(endDate,currTime);
        Integer iOffDays = daysOff(slocal, elocal);
        DateTime EndDateChecker = elocal.addDays(iOffDays);
        
        if (EndDateChecker.format('E') == 'Sat') {
            EndDateChecker = elocal.addDays(iOffDays) + 2;
        } else if (EndDateChecker.format('E') == 'Sun' && ioffDays == 2) {
            EndDateChecker = elocal.addDays(iOffDays) + 2;
        } else if (EndDateChecker.format('E') == 'Tue' && ioffDays == 3) {
            EndDateChecker = elocal.addDays(iOffDays) + 1;
        } else if (EndDateChecker.format('E') == 'Sun') {
            EndDateChecker = elocal.addDays(iOffDays) + 1;
        }
        DateTime DT = EndDateChecker;
        Date myDate = date.newinstance(DT.year(), DT.month(), DT.day());
        return myDate;
    }
    
    /* 
* @Method Name                    :  daysOff
* @Description                    :  Takes the Start Date and Endate from addBusinessday and check if the dates have weekends.
* @Return Type                    :  Integer
* @Parameters                     :  sdate,edate
*/     
    
    public Integer daysOff(Datetime sdate, Datetime edate) {
        Integer iCount = 0;
        while (sdate <= edate) {
            if (sdate.format('E') == 'Sat' | sdate.format('E') == 'Sun') {
                iCount = iCount + 1;
            }
            sdate = sdate.addDays(1);
        }
        return iCount;
    }
    
    //Wrapper class to hols check box and Datamart Asset for Data Mart Form
    Public class wDataAsset {
        Public Boolean isSelected {
            get;
            set;
        }
        Public PANG_Data_Asset__c oDataAsset {
            get;
            set;
        }
        public wDataAsset(PANG_Data_Asset__c Ast, Boolean isC) {
            this.oDataAsset = Ast;
            this.isSelected = isC;
        }
    }
    
}