/**
 * Copyright (c), Andrew Fawcett,
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * This is a dummy test class to obtain 100% coverage for the generated WSDL2Apex code, it is not a funcitonal test class
 *   You should follow the usual practices to cover your other code, as shown in the MetadataCreateJobTest.cls
 **/ 
@isTest  
private class GLBL_MetadataServiceTest 
{    
    /**
     * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
     **/
	private class WebServiceMockImpl implements WebServiceMock 
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
		
	@IsTest
	private static void coverGeneratedCodeCRUDOperations()
	{	
    	// Null Web Service mock implementation
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        GLBL_MetadataService metaDataService = new GLBL_MetadataService();
        // Invoke operations         
        GLBL_MetadataService.MetadataPort metaDataPort = new GLBL_MetadataService.MetadataPort();
        metaDataPort.create(null);
        metaDataPort.deleteMetadata(null);
        metaDataPort.updateMetadata(null);		
	}
	
	@IsTest
    private static void coverGeneratedCodeFileBasedOperations()
    {    	
    	// Null Web Service mock implementation
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        GLBL_MetadataService metaDataService = new GLBL_MetadataService();
        // Invoke operations         
        GLBL_MetadataService.MetadataPort metaDataPort = new GLBL_MetadataService.MetadataPort();
        metaDataPort.retrieve(null);
        metaDataPort.checkDeployStatus(null);
        metaDataPort.updateMetadata(null);
        metaDataPort.listMetadata(null, null);
        metaDataPort.checkStatus(null);
        metaDataPort.describeMetadata(null);
        metaDataPort.checkRetrieveStatus(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null);
    }
        
	@IsTest
    private static void coverGeneratedCodeTypes()
    {    	       
        // Reference types
        new GLBL_MetadataService();
        new GLBL_MetadataService.listMetadataResponse_element();
        new GLBL_MetadataService.WorkflowRule();
        new GLBL_MetadataService.AccountOwnerSharingRule();
        new GLBL_MetadataService.RecordTypeTranslation();
        new GLBL_MetadataService.checkDeployStatus_element();
        new GLBL_MetadataService.CodeCoverageWarning();
        new GLBL_MetadataService.FlowApexPluginCall();
        new GLBL_MetadataService.FlowInputValidationRule();
        new GLBL_MetadataService.FlowFormula();
        new GLBL_MetadataService.CustomObjectCriteriaBasedSharingRule();
        new GLBL_MetadataService.PasswordPolicies();
        new GLBL_MetadataService.QueueSobject();
        new GLBL_MetadataService.CaseSharingRules();
        new GLBL_MetadataService.PicklistValueTranslation();
        new GLBL_MetadataService.OpportunityOwnerSharingRule();
        new GLBL_MetadataService.ContactOwnerSharingRule();
        new GLBL_MetadataService.CustomDataType();
        new GLBL_MetadataService.PrimaryTabComponents();
        new GLBL_MetadataService.WorkflowEmailRecipient();
        new GLBL_MetadataService.DescribeMetadataResult();
        new GLBL_MetadataService.RecordType();
        new GLBL_MetadataService.Scontrol();
        new GLBL_MetadataService.DashboardComponent();
        new GLBL_MetadataService.ContactCriteriaBasedSharingRule();
        new GLBL_MetadataService.FilterItem();
        new GLBL_MetadataService.Profile();
        new GLBL_MetadataService.ReportFilter();
        new GLBL_MetadataService.PermissionSetApexClassAccess();
        new GLBL_MetadataService.LogInfo();
        new GLBL_MetadataService.Layout();
        new GLBL_MetadataService.WebLink();
        new GLBL_MetadataService.WorkflowTaskTranslation();
        new GLBL_MetadataService.FlowElement();
        new GLBL_MetadataService.ObjectNameCaseValue();
        new GLBL_MetadataService.FlowInputFieldAssignment();
        new GLBL_MetadataService.CustomDataTypeTranslation();
        new GLBL_MetadataService.DashboardComponentSection();
        new GLBL_MetadataService.ReportTypeColumn();
        new GLBL_MetadataService.CallOptions_element();
        new GLBL_MetadataService.CustomObjectOwnerSharingRule();
        new GLBL_MetadataService.CustomFieldTranslation();
        new GLBL_MetadataService.AnalyticSnapshot();
        new GLBL_MetadataService.FlowRule();
        new GLBL_MetadataService.FlowRecordUpdate();
        new GLBL_MetadataService.CustomSite();
        new GLBL_MetadataService.ReportBlockInfo();
        new GLBL_MetadataService.describeMetadataResponse_element();
        new GLBL_MetadataService.CaseOwnerSharingRule();
        new GLBL_MetadataService.ScontrolTranslation();
        new GLBL_MetadataService.DeployMessage();
        new GLBL_MetadataService.FlowSubflowInputAssignment();
        new GLBL_MetadataService.Group_x();
        new GLBL_MetadataService.ReportColumn();
        new GLBL_MetadataService.ReportType();
        new GLBL_MetadataService.CustomPageWebLink();
        new GLBL_MetadataService.CodeCoverageResult();
        new GLBL_MetadataService.ApexComponent();
        new GLBL_MetadataService.BaseSharingRule();
        new GLBL_MetadataService.WorkflowKnowledgePublish();
        new GLBL_MetadataService.NetworkAccess();
        new GLBL_MetadataService.Workflow();
        new GLBL_MetadataService.RecordTypePicklistValue();
        new GLBL_MetadataService.describeMetadata_element();
        new GLBL_MetadataService.DashboardFilterColumn();
        new GLBL_MetadataService.FlowChoice();
        new GLBL_MetadataService.ReportParam();
        new GLBL_MetadataService.RoleOrTerritory();
        new GLBL_MetadataService.FlowStep();
        new GLBL_MetadataService.FlowApexPluginCallInputParameter();
        new GLBL_MetadataService.WorkflowActionReference();
        new GLBL_MetadataService.ProfileObjectPermissions();
        new GLBL_MetadataService.Role();
        new GLBL_MetadataService.RetrieveResult();
        new GLBL_MetadataService.delete_element();
        new GLBL_MetadataService.SecuritySettings();
        new GLBL_MetadataService.WorkflowTimeTrigger();
        new GLBL_MetadataService.CustomObjectSharingRules();
        new GLBL_MetadataService.updateResponse_element();
        new GLBL_MetadataService.retrieve_element();
        new GLBL_MetadataService.create_element();
        new GLBL_MetadataService.DescribeMetadataObject();
        new GLBL_MetadataService.createResponse_element();
        new GLBL_MetadataService.DashboardFilterOption();
        new GLBL_MetadataService.checkStatus_element();
        new GLBL_MetadataService.LayoutColumn();
        new GLBL_MetadataService.WorkflowOutboundMessage();
        new GLBL_MetadataService.RunTestSuccess();
        new GLBL_MetadataService.Queue();
        new GLBL_MetadataService.LeadSharingRules();
        new GLBL_MetadataService.NamedFilter();
        new GLBL_MetadataService.ListViewFilter();
        new GLBL_MetadataService.CampaignOwnerSharingRule();
        new GLBL_MetadataService.checkStatusResponse_element();
        new GLBL_MetadataService.CustomField();
        new GLBL_MetadataService.WorkflowTask();
        new GLBL_MetadataService.deployResponse_element();
        new GLBL_MetadataService.DataCategory();
        new GLBL_MetadataService.FlowOutputFieldAssignment();
        new GLBL_MetadataService.EmailTemplate();
        new GLBL_MetadataService.ReportAggregateReference();
        new GLBL_MetadataService.ObjectUsage();
        new GLBL_MetadataService.FileProperties();
        new GLBL_MetadataService.CustomTabTranslation();
        new GLBL_MetadataService.BusinessProcess();
        new GLBL_MetadataService.Flow();
        new GLBL_MetadataService.PermissionSet();
        new GLBL_MetadataService.PermissionSetObjectPermissions();
        new GLBL_MetadataService.ReportCrossFilter();
        new GLBL_MetadataService.Report();
        new GLBL_MetadataService.FlowSubflowOutputAssignment();
        new GLBL_MetadataService.ListView();
        new GLBL_MetadataService.FlowRecordCreate();
        new GLBL_MetadataService.DashboardTableColumn();
        new GLBL_MetadataService.ContactSharingRules();
        new GLBL_MetadataService.AccountTerritorySharingRules();
        new GLBL_MetadataService.AsyncResult();
        new GLBL_MetadataService.ArticleTypeChannelDisplay();
        new GLBL_MetadataService.checkRetrieveStatus_element();
        new GLBL_MetadataService.ProfileLayoutAssignment();
        new GLBL_MetadataService.ReportFolder();
        new GLBL_MetadataService.FlowTextTemplate();
        new GLBL_MetadataService.RelatedListItem();
        new GLBL_MetadataService.FlowNode();
        new GLBL_MetadataService.RetrieveRequest();
        new GLBL_MetadataService.ListMetadataQuery();
        new GLBL_MetadataService.FlowConnector();
        new GLBL_MetadataService.CustomApplicationComponent();
		new GLBL_MetadataService.FlowRecordLookup();
        new GLBL_MetadataService.FieldSet();
        new GLBL_MetadataService.ProfileApexClassAccess();
        new GLBL_MetadataService.AccountCriteriaBasedSharingRule();
        new GLBL_MetadataService.DebuggingHeader_element();
        new GLBL_MetadataService.CustomDataTypeComponentTranslation();
        new GLBL_MetadataService.FlowRecordDelete();
        new GLBL_MetadataService.FlowDecision();
        new GLBL_MetadataService.ReportTypeSectionTranslation();
        new GLBL_MetadataService.IpRange();
        new GLBL_MetadataService.FlowApexPluginCallOutputParameter();
        new GLBL_MetadataService.ReportBucketField();
        new GLBL_MetadataService.CaseCriteriaBasedSharingRule();
        new GLBL_MetadataService.CustomLabel();
        new GLBL_MetadataService.Attachment();
        new GLBL_MetadataService.SharingRules();
        new GLBL_MetadataService.CustomConsoleComponents();
        new GLBL_MetadataService.Portal();
        new GLBL_MetadataService.DomainWhitelist();
        new GLBL_MetadataService.ChartSummary();
        new GLBL_MetadataService.RunTestFailure();
        new GLBL_MetadataService.Territory();
        new GLBL_MetadataService.SharedTo();
        new GLBL_MetadataService.FlowRecordFilter();
        new GLBL_MetadataService.SubtabComponents();
        new GLBL_MetadataService.FlowScreen();
        new GLBL_MetadataService.WorkflowAlert();
        new GLBL_MetadataService.Picklist();
        new GLBL_MetadataService.ReportLayoutSection();
        new GLBL_MetadataService.SummaryLayoutItem();
        new GLBL_MetadataService.LayoutSection();
        new GLBL_MetadataService.ReportTimeFrameFilter();
        new GLBL_MetadataService.LayoutSectionTranslation();
        new GLBL_MetadataService.DataCategoryGroup();
        new GLBL_MetadataService.listMetadata_element();
        new GLBL_MetadataService.ValidationRule();
        new GLBL_MetadataService.NamedFilterTranslation();
        new GLBL_MetadataService.WorkspaceMapping();
        new GLBL_MetadataService.MetadataWithContent();
        new GLBL_MetadataService.ValidationRuleTranslation();
        new GLBL_MetadataService.AccountTerritorySharingRule();
        new GLBL_MetadataService.Metadata();
        new GLBL_MetadataService.ConsoleComponent();
        new GLBL_MetadataService.ReportBucketFieldValue();
        new GLBL_MetadataService.OpportunitySharingRules();
        new GLBL_MetadataService.HomePageLayout();
        new GLBL_MetadataService.FlowSubflow();
        new GLBL_MetadataService.FlowScreenField();
        new GLBL_MetadataService.SiteWebAddress();
        new GLBL_MetadataService.RetrieveMessage();
        new GLBL_MetadataService.Dashboard();
        new GLBL_MetadataService.EmailFolder();
        new GLBL_MetadataService.SessionHeader_element();
        new GLBL_MetadataService.SummaryLayout();
        new GLBL_MetadataService.FlowCondition();
        new GLBL_MetadataService.DeployOptions();
        new GLBL_MetadataService.FlowAssignment();
        new GLBL_MetadataService.ProfileApplicationVisibility();
        new GLBL_MetadataService.UpdateMetadata();
        new GLBL_MetadataService.CustomApplicationComponents();
        new GLBL_MetadataService.FlowElementReferenceOrValue();
        new GLBL_MetadataService.EntitlementTemplate();
        new GLBL_MetadataService.ProfileTabVisibility();
        new GLBL_MetadataService.ActionOverride();
        new GLBL_MetadataService.WorkspaceMappings();
        new GLBL_MetadataService.WorkflowAction();
        new GLBL_MetadataService.deleteResponse_element();
        new GLBL_MetadataService.update_element();
        new GLBL_MetadataService.DashboardFolder();
        new GLBL_MetadataService.PermissionSetApexPageAccess();
        new GLBL_MetadataService.LayoutTranslation();
        new GLBL_MetadataService.CustomObject();
        new GLBL_MetadataService.Translations();
        new GLBL_MetadataService.ApexTrigger();
        new GLBL_MetadataService.ReportTypeTranslation();
        new GLBL_MetadataService.FlowAssignmentItem();
        new GLBL_MetadataService.CustomApplicationTranslation();
        new GLBL_MetadataService.CustomLabels();
        new GLBL_MetadataService.PackageTypeMembers();
        new GLBL_MetadataService.PicklistValue();
        new GLBL_MetadataService.RemoteSiteSetting();
        new GLBL_MetadataService.deploy_element();
        new GLBL_MetadataService.retrieveResponse_element();
        new GLBL_MetadataService.ArticleTypeTemplate();
        new GLBL_MetadataService.ReportGrouping();
        new GLBL_MetadataService.PermissionSetFieldPermissions();
        new GLBL_MetadataService.AnalyticSnapshotMapping();
        new GLBL_MetadataService.LeadCriteriaBasedSharingRule();
        new GLBL_MetadataService.SharingRecalculation();
        new GLBL_MetadataService.ProfileLoginIpRange();
        new GLBL_MetadataService.WebLinkTranslation();
        new GLBL_MetadataService.ObjectRelationship();
        new GLBL_MetadataService.ListPlacement();
        new GLBL_MetadataService.SiteRedirectMapping();
        new GLBL_MetadataService.OwnerSharingRule();
        new GLBL_MetadataService.WorkflowFieldUpdate();
        new GLBL_MetadataService.LetterheadLine();
        new GLBL_MetadataService.OpportunityCriteriaBasedSharingRule();
        new GLBL_MetadataService.CustomTab();
        new GLBL_MetadataService.FlowChoiceUserInput();
        new GLBL_MetadataService.Letterhead();
        new GLBL_MetadataService.ReportTypeColumnTranslation();
        new GLBL_MetadataService.CustomPageWebLinkTranslation();
        new GLBL_MetadataService.DocumentFolder();
        new GLBL_MetadataService.FlowConstant();
        new GLBL_MetadataService.ProfileRecordTypeVisibility();
        new GLBL_MetadataService.PackageVersion();
        new GLBL_MetadataService.CustomLabelTranslation();
        new GLBL_MetadataService.ReportChart();
        new GLBL_MetadataService.checkRetrieveStatusResponse_element();
        new GLBL_MetadataService.LeadOwnerSharingRule();
        new GLBL_MetadataService.ProfileFieldLevelSecurity();
        new GLBL_MetadataService.SharingReason();
        new GLBL_MetadataService.RunTestsResult();
        new GLBL_MetadataService.PermissionSetUserPermission();
        new GLBL_MetadataService.MiniLayout();
        new GLBL_MetadataService.FlowVariable();
        new GLBL_MetadataService.ProfileLoginHours();
        new GLBL_MetadataService.DashboardFilter();
        new GLBL_MetadataService.CodeLocation();
        new GLBL_MetadataService.ReportBucketFieldSourceValue();
        new GLBL_MetadataService.FieldSetItem();
        new GLBL_MetadataService.ReportFilterItem();
        new GLBL_MetadataService.FlowDynamicChoiceSet();
        new GLBL_MetadataService.CustomDataTypeComponent();
        new GLBL_MetadataService.CustomObjectTranslation();
        new GLBL_MetadataService.CustomApplication();
        new GLBL_MetadataService.ReportAggregate();
        new GLBL_MetadataService.ApexClass();
        new GLBL_MetadataService.CampaignSharingRules();
        new GLBL_MetadataService.DebuggingInfo_element();
        new GLBL_MetadataService.Package_x();
        new GLBL_MetadataService.SessionSettings();
        new GLBL_MetadataService.Document();
        new GLBL_MetadataService.Folder();
        new GLBL_MetadataService.DeployResult();
        new GLBL_MetadataService.CampaignCriteriaBasedSharingRule();
        new GLBL_MetadataService.LayoutItem();
        new GLBL_MetadataService.ProfileApexPageAccess();
        new GLBL_MetadataService.SharingReasonTranslation();
        new GLBL_MetadataService.checkDeployStatusResponse_element();
        new GLBL_MetadataService.ReportColorRange();
        new GLBL_MetadataService.SearchLayouts();
        new GLBL_MetadataService.LetterheadHeaderFooter();
        new GLBL_MetadataService.HomePageComponent();
        new GLBL_MetadataService.AccountSharingRules();
        new GLBL_MetadataService.MobileSettings();
        new GLBL_MetadataService.EscalationRules();
        new GLBL_MetadataService.KnowledgeAnswerSettings();
        new GLBL_MetadataService.ExternalDataSource();
        new GLBL_MetadataService.EntitlementProcess();
        new GLBL_MetadataService.IdeasSettings();
        new GLBL_MetadataService.Country();
        new GLBL_MetadataService.ReputationLevels();
        new GLBL_MetadataService.KnowledgeSitesSettings();
        new GLBL_MetadataService.AddressSettings();
        new GLBL_MetadataService.ProfileExternalDataSourceAccess();
        new GLBL_MetadataService.CallCenterItem();
        new GLBL_MetadataService.CallCenter();
        new GLBL_MetadataService.PermissionSetExternalDataSourceAccess();
        new GLBL_MetadataService.PermissionSetTabSetting();
        new GLBL_MetadataService.AuthProvider();
        new GLBL_MetadataService.EmailToCaseSettings();
        new GLBL_MetadataService.EscalationAction();
        new GLBL_MetadataService.State();
        new GLBL_MetadataService.AssignmentRule();
        new GLBL_MetadataService.AutoResponseRule();
        new GLBL_MetadataService.CaseSettings();
        new GLBL_MetadataService.ChatterAnswersSettings();
        new GLBL_MetadataService.CountriesAndStates();
        new GLBL_MetadataService.SFDCMobileSettings();
        new GLBL_MetadataService.EntitlementProcessMilestoneItem();
        new GLBL_MetadataService.TouchMobileSettings();
        new GLBL_MetadataService.AssignmentRules();
        new GLBL_MetadataService.ContractSettings();
        new GLBL_MetadataService.KnowledgeCaseSettings();
        new GLBL_MetadataService.ChatterAnswersReputationLevel();
        new GLBL_MetadataService.KnowledgeSettings();
        new GLBL_MetadataService.Community();
        new GLBL_MetadataService.AutoResponseRules();
        new GLBL_MetadataService.EmailToCaseRoutingAddress();
        new GLBL_MetadataService.RuleEntry();
        new GLBL_MetadataService.EntitlementSettings();
        new GLBL_MetadataService.CriteriaBasedSharingRule();
        new GLBL_MetadataService.ApexPage();
        new GLBL_MetadataService.WorkflowSend();
        new GLBL_MetadataService.ChatterMobileSettings();
        new GLBL_MetadataService.CallCenterSection();
        new GLBL_MetadataService.EntitlementProcessMilestoneTimeTrigger();
        new GLBL_MetadataService.StaticResource();
        new GLBL_MetadataService.MilestoneType();
        new GLBL_MetadataService.FiscalYearSettings();
        new GLBL_MetadataService.CompanySettings();
        new GLBL_MetadataService.WebToCaseSettings();
        new GLBL_MetadataService.EscalationRule();
        new GLBL_MetadataService.DashboardMobileSettings();
        new GLBL_MetadataService.FieldOverride();
        new GLBL_MetadataService.QuotasSettings();
        new GLBL_MetadataService.Skill();
        new GLBL_MetadataService.AgentConfigProfileAssignments();
        new GLBL_MetadataService.LiveAgentSettings();
        new GLBL_MetadataService.SkillAssignments();
        new GLBL_MetadataService.ActivitiesSettings();
        new GLBL_MetadataService.LiveAgentConfig();
        new GLBL_MetadataService.ApprovalPageField();
        new GLBL_MetadataService.QuickActionList();
        new GLBL_MetadataService.LiveChatButtonDeployments();
        new GLBL_MetadataService.InstalledPackage();
        new GLBL_MetadataService.PushNotification();
        new GLBL_MetadataService.LiveChatAgentConfig();
		new GLBL_MetadataService.AdjustmentsSettings();                               
		new GLBL_MetadataService.ForecastingSettings();                                
		new GLBL_MetadataService.QuickActionListItem();           
		new GLBL_MetadataService.Branding();          
		new GLBL_MetadataService.QuickActionLayoutItem();                     
		new GLBL_MetadataService.OpportunityListFieldsSelectedSettings();        
		new GLBL_MetadataService.ApprovalStepRejectBehavior();
		new GLBL_MetadataService.FolderShare();   
		new GLBL_MetadataService.ApprovalEntryCriteria();                                
		new GLBL_MetadataService.ProductSettings();                                
		new GLBL_MetadataService.OpportunitySettings();              
		new GLBL_MetadataService.LiveChatDeployment();                                
		new GLBL_MetadataService.QuickActionLayoutColumn();           
		new GLBL_MetadataService.GlobalQuickActionTranslation();      
		new GLBL_MetadataService.ApprovalStepApprover();                                
		new GLBL_MetadataService.QuoteSettings();         
		new GLBL_MetadataService.LiveChatButton();                                
		new GLBL_MetadataService.Network();
		new GLBL_MetadataService.LiveChatDeploymentDomainWhitelist();
		new GLBL_MetadataService.KnowledgeLanguageSettings();
		new GLBL_MetadataService.Approver();
		new GLBL_MetadataService.SamlSsoConfig();
		new GLBL_MetadataService.ApprovalSubmitter();
		new GLBL_MetadataService.DataSourceSettings();
		new GLBL_MetadataService.KeyboardShortcuts();
		new GLBL_MetadataService.ApprovalStep();
		new GLBL_MetadataService.AgentConfigAssignments();
		new GLBL_MetadataService.QuickAction();
		new GLBL_MetadataService.DefaultShortcut();
		new GLBL_MetadataService.ApprovalAction();
		new GLBL_MetadataService.KnowledgeLanguage();
		new GLBL_MetadataService.LiveChatButtonSkills();
		new GLBL_MetadataService.SkillUserAssignments();
		new GLBL_MetadataService.NextAutomatedApprover();
		new GLBL_MetadataService.ApprovalProcess();
		new GLBL_MetadataService.QuickActionLayout();
		new GLBL_MetadataService.PushNotifications();
		new GLBL_MetadataService.ForecastRangeSettings();
		new GLBL_MetadataService.IdeaReputationLevel();
		new GLBL_MetadataService.NetworkTabSet();
		new GLBL_MetadataService.SkillProfileAssignments();
		new GLBL_MetadataService.CustomShortcut();
		new GLBL_MetadataService.PagesToOpen();
		new GLBL_MetadataService.AgentConfigUserAssignments();
		new GLBL_MetadataService.NetworkMemberGroup();
		new GLBL_MetadataService.FindSimilarOppFilter();
		new GLBL_MetadataService.QuickActionTranslation();				
    }
}