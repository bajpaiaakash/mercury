public virtual with sharing class GLBL_BaseEditController {

	private final Sobject mySobject;
	
	private String sObjectAPIName;
	private String sObjectRecordType;
	private Set<String> allFields;
	private transient Component.Apex.Form Form;
	private Map<String, sObjectField> schemaFields;

	private String title;
	private String subtitle;

	public GLBL_BaseEditController(ApexPages.StandardController stdController, Schema.SobjectType sotype) {
		Schema.DescribeSObjectResult sobjectDescribe = sotype.getDescribe();
		this.schemaFields = sobjectDescribe.fields.getMap();
		if (!Test.isRunningTest()) {
		    stdController.addFields(new List<String>(
		    	this.schemaFields.keySet()
		    ));
		}

		this.mySobject = (Sobject)stdController.getRecord();
		String myId = stdController.getId();

		//this.sobjectDescribe = this.mySobject.getSObjectType().getDescribe();
		this.sObjectAPIName = sobjectDescribe.getName();
		//we describe the object and put all fields in this variable.

		Set<String> FieldssObject = new Set<String>(this.schemaFields.keySet());
		
		//set record type
		if (ApexPages.currentPage().getParameters().containsKey('RecordType')) {
	        this.mySobject.put('RecordTypeId', MERC_Util.getUrlParam('RecordType'));
	        this.sObjectRecordType = MERC_Util.getUrlParam('RecordType');
	    } else if(FieldssObject.contains('recordtypeid') && mySObject != null) {
			//if this wasn't successful, maybe we can get the recordtypeid for an existing record.
			sObjectRecordType = (String)mySObject.get('recordtypeid');
		}

		allFields = new Set<String>(); //?
		
		//if (myId != null) {
		//	this.mySObject = database.query('select '+ String.join(new list<String>(FieldssObject), ',') +' from ' + this.sObjectAPIName + ' where Id=:myId');
		//}

		this.title = sobjectDescribe.getLabel() + ' edit';
		if (mySObject == null || mySObject.Id == null) {
			this.subtitle = 'New ' + sobjectDescribe.getLabel();
		} else {
			this.subtitle = (String)mySObject.get('name');
		}
		
		getForm();                  		
	}

	public Component.Apex.Form getForm() {

       	if (Form == null) {
			system.debug('...... generating form!!!!!!!!!!');
			Form = new Component.Apex.Form();
			Form.id = 'form';
			Set<String> rerenderFields = new Set<String>();
			Set<String> controllerFields = new Set<String>();
			Component.Apex.sectionHeader sectionHeader = new Component.Apex.sectionHeader();
			sectionHeader.subtitle = this.subtitle;
			sectionHeader.title = this.title;
			Form.childComponents.add(sectionHeader);

			Component.Apex.pageBlock pageBlock = new Component.Apex.pageBlock();
			pageBlock.id = 'pageBlock';
			pageBlock.mode = 'edit';
			pageBlock.title = this.title;
			
	        Component.Apex.pageBlockSection pBS;
	        Component.Apex.InputField inputField;
	        Component.Apex.OutputField outputField;
	        Component.Apex.InputText inputText;
	        Component.Apex.InputHidden inputHidden;
	        Component.Apex.Selectlist selectlist;
	        Component.Apex.SelectOptions selectOptions;

	        sobjectPartnerSoapSforceCom.Soap handler = HandlerMetadataInit();

	        if(!test.isRunningTest()) {
	        	//if running test, we can't make a callout, so this won't work.
	        	//sObjectRecordType is the recordtype of the sobject. If the sobject has no recordtype, then it's null and it's still fine.
	            sobjectPartnerSoapSforceCom.DescribeLayoutResult LayoutResult = handler.describeLayout(this.sObjectAPIName, new list<String>{sObjectRecordType});

	            if(LayoutResult != null) {
	            	//we take the first one because we queried only one recordtype.               
	                for(sobjectPartnerSoapSforceCom.DescribeLayoutSection LayoutSection:LayoutResult.Layouts.get(0).editLayoutSections) {
	                   	//the different sections.
	                   	pBS = new Component.Apex.pageBlockSection(
							columns = LayoutSection.columns
						);

	                   	if(LayoutSection.useHeading==true) {
							pBS.title = LayoutSection.heading;
						}

	                    for(sobjectPartnerSoapSforceCom.DescribeLayoutRow layoutRow:LayoutSection.layoutRows) {
	                        for(sobjectPartnerSoapSforceCom.DescribeLayoutItem layoutItem:layoutRow.layoutItems) {
	                           if(layoutItem.layoutComponents!=null){
	                                //here the fields.
	                                for(sobjectPartnerSoapSforceCom.DescribeLayoutComponent layoutComponent:layoutItem.layoutComponents){
	                                  	if(layoutComponent.value=='OwnerId' || layoutComponent.value=='RecordTypeId' ){
	                                  		//The user shouldn't change the OwnerId/RecordType this way.
	                                  	}
	                                  	else if (layoutitem.editable == false && layoutComponent.value != null) {
											outputField = new Component.Apex.outputField(
												id = layoutComponent.value
											);
											outputField.expressions.value = '{!'+this.sObjectAPIName+'.' + layoutComponent.value + '}';
											pBS.childComponents.add(outputField);
											allFields.add(layoutComponent.value);
										}
	                                  	else if (layoutComponent.value != null) {
		                                  	inputField = new Component.Apex.InputField(
		                                  		required = layoutItem.required,
		                                  		id = layoutComponent.value
		                                  	);
							                inputField.expressions.value = '{!'+this.sObjectAPIName+'.' + layoutComponent.value + '}';
							                //inputField.expressions.value = '{!mySobject.' + layoutComponent.value + '}';

							                pBS.childComponents.add(inputField);
							                allFields.add(layoutComponent.value);

							                //we store the controller fields, because we shouldn't rerender them - causing a bug...
							                //rerendering a controlled fields makes the value disappear
							                if(schemaFields.get(layoutComponent.value).getDescribe().isDependentPicklist()){
							                	controllerFields.add(schemaFields.get(layoutComponent.value).getDescribe().getController().getDescribe().getName() );
							                }
							            }
	                                }
	                            }
	                            else {
	                            	//small workaround for adding empty fields when the layout require it
	                            	//in order to reproduce to 100% the standard layout.
	                            	pBS.childComponents.add(new Component.Apex.OutputText());
	                            }
	                           
	                        }
	                    }
	                    pageBlock.childComponents.add(pBS);
	                }
	            }
	        }
	        Component.Apex.pageBlockButtons pageBlockButtons = new Component.Apex.pageBlockButtons();

			Component.Apex.commandButton commandButton = new Component.Apex.commandButton();
			commandButton.expressions.action = '{!save}';
			commandButton.id='saveBtn';
			commandButton.expressions.value = '{!$label.site.save}';
			//commandButton.onclick = 'fnSaveValuesAndCheck();';
			//commandButton.oncomplete = 'fnLoadInputValues();';
			//rerenderFields.add('pageMessage');

			//we remove the controller fields from the rerenderFields
			//rerenderFields.removeAll(controllerFields);

			//commandButton.rerender = rerenderFields;
			pageBlockButtons.childComponents.add(commandButton);

			commandButton = new Component.Apex.commandButton();
			commandButton.expressions.action = '{!cancel}';
			commandButton.id='cancelBtn';
			commandButton.expressions.value = '{!$label.site.cancel}';
			pageBlockButtons.childComponents.add(commandButton);

			pageBlock.childComponents.add(pageBlockButtons);

	        Form.childComponents.add(pageBlock);
	    }

        return Form;
    }

    public static sobjectPartnerSoapSforceCom.Soap handlerMetadataInit() {
        //here the authentication to the soap partner.
        //we build something quite dynamic which does not depend on any url (like cs17.salesforce.com)
        //therefore, should work for production like for sandbox, however the remote site settings
        //needs to be updated in Salesforce in Order to allow this outbound communication.

        sobjectPartnerSoapSforceCom.Soap handler = new sobjectPartnerSoapSforceCom.Soap();

        handler.endpoint_x = 'https://' + System.URL.getSalesforceBaseURL().getHost().split('\\.')[1]  + '-api.salesforce.com/services/Soap/u/27.0/' + UserInfo.getOrganizationId();
        
        sobjectPartnerSoapSforceCom.SessionHeader_element sessionHeader = new sobjectPartnerSoapSforceCom.SessionHeader_element();
        sessionHeader.sessionId = UserInfo.getSessionId();
        handler.SessionHeader = sessionHeader;
        return handler; 
    }

}