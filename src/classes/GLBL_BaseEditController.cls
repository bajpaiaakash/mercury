/**
 * @author Joseph Ferraro & Kyle Thornton
 *
 * Base controller that builds an edit page layout dynamically via the Metadata API
 * We use this for Meeting and Travel Itinerary new/edit pages because it allows us to provide a better UX when dealing with Date/Times
 *
 * Also included is functionality that allows for lookups to be dependent on other lookups. The child lookup is rendered as a selectlist
 * limited to the records that match those configured. e.g. the indication options of a meeting product will be only those of the selected prodcut.
 */

global virtual with sharing class GLBL_BaseEditController {

	public Sobject mySobject { get; set; }

	private String sObjectAPIName;
	private String sObjectRecordType;
	private Map<String, sObjectField> schemaFields;

	public String title { get; private set; }
	public String subtitle { get; private set; }

	public Set<String> dynamicFields;

	private List<Lookup_Picklist_Settings_MERC__c> lps;

	public GLBL_BaseEditController getTheExtController() {
		return this;
	}

	public GLBL_BaseEditController(ApexPages.StandardController stdController, Schema.SobjectType sotype, Set<String> dfs) {
		this(stdController, sotype);
		this.dynamicFields = dfs;
	}

	public GLBL_BaseEditController(ApexPages.StandardController stdController, Schema.SobjectType sotype) {
		Schema.DescribeSObjectResult sobjectDescribe = sotype.getDescribe();
		this.schemaFields = sobjectDescribe.fields.getMap();
		if (!Test.isRunningTest()) {
		    stdController.addFields(new List<String>(
		    	this.schemaFields.keySet()
		    ));
		}

		finishInitialization(sobjectDescribe, stdController);
	}

	public GLBL_BaseEditController(ApexPages.StandardController stdController) {
		Schema.DescribeSObjectResult sobjectDescribe = stdController.getRecord().getSObjectType().getDescribe();
		this.schemaFields = sobjectDescribe.fields.getMap();

		finishInitialization(sobjectDescribe, stdController);
	}

	private void finishInitialization(Schema.DescribeSObjectResult sobjectDescribe, ApexPages.StandardController stdController) {
		Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=9'); //IE compatibility mode hack
		String myId = stdController.getId();
		this.sObjectAPIName = sobjectDescribe.getName();
		this.mySobject = (Sobject)stdController.getRecord();
		/* Check for any custom settings for this object to render lookups as picklists */
		lps = [SELECT Id
                    , Controlling_Object_MERC__c
                    , Parent_Field_MERC__c
                    , Child_Field_MERC__c
                    , Picklist_Object_Relationship_MERC__c
                    , Filter_Criteria_MERC__c
                    , Parent_Object_API_Name_MERC__c
                 FROM Lookup_Picklist_Settings_MERC__c
                WHERE Controlling_Object_MERC__c = :this.sObjectAPIName];

        Set<String> FieldssObject = new Set<String>(this.schemaFields.keySet());

		//set record type
		if (ApexPages.currentPage().getParameters().containsKey('RecordType')) {
	        this.mySobject.put('RecordTypeId', MERC_Util.getUrlParam('RecordType'));
	        this.sObjectRecordType = MERC_Util.getUrlParam('RecordType');
	    } else if(FieldssObject.contains('recordtypeid') && mySObject != null) {
			sObjectRecordType = (String)mySObject.get('recordtypeid');
		}

		this.title = sobjectDescribe.getLabel() + ' Edit';
		if (mySObject == null || mySObject.Id == null) {
			this.subtitle = 'New ' + sobjectDescribe.getLabel();
		} else {
			this.subtitle = (String)mySObject.get('name');
		}
	}

	private Map<String, Lookup_Picklist_Settings_MERC__c> lookupParentFields {
		get {
			if (lookupParentFields == null){
				lookupParentFields = new Map<String, Lookup_Picklist_Settings_MERC__c>();
				for (Lookup_Picklist_Settings_MERC__c lp : lps){
					lookupParentFields.put(lp.Parent_Field_MERC__c, lp);
				}
			}
			return lookupParentFields;
		}
		set;
	}

	private Map<String, Lookup_Picklist_Settings_MERC__c> lookupChildFields {
		get {
			if (lookupChildFields == null){
				lookupChildFields = new Map<String, Lookup_Picklist_Settings_MERC__c>();
				for (Lookup_Picklist_Settings_MERC__c lp : lps){
					lookupChildFields.put(lp.Child_Field_MERC__c, lp);
				}
			}
			return lookupChildFields;
		}
		set;
	}

	public class PageBlockSection {
		public List<Field> fields { get; set; }
		public String title { get; set; }
		public Integer columns { get; set; }
		public Integer index { get; set; }
		public PageBlockSection(Integer columns) {
			this.columns = columns;
			this.fields = new List<Field>();
		}
	}


	@RemoteAction global static String getOptions(String objectName, String customSettingId, String referenceId)
	{
		String options = '<option value="">-- Select --</option>';

		List<Lookup_Picklist_Settings_MERC__c> thisLps = [SELECT Id
											                   , Controlling_Object_MERC__c
											                   , Parent_Field_MERC__c
											                   , Child_Field_MERC__c
											                   , Picklist_Object_Relationship_MERC__c
											                   , Filter_Criteria_MERC__c
											                   , Parent_Object_API_Name_MERC__c
											                   , Parent_Object_Id_Relationship_MERC__c
											                   , Picklist_Label_Source_MERC__c
											                FROM Lookup_Picklist_Settings_MERC__c
											               WHERE Id =:customSettingId];

		if (!thisLps.isEmpty())
		{
			Map<String, Schema.SObjectField> theFields = Schema.describeSObjects(new String[]{objectName}).get(0).fields.getMap();

			//If the Parent_Object_Id_Relationship_MERC__c has been configured then referenceId does not refer to the controlling object
			//we need to get the id of the controlling object in this case
			if (String.isNotBlank(thisLps[0].Parent_Object_Id_Relationship_MERC__c))
			{
				//In order to query the controlling object we need to determine which object the parent field is pointing to
				//in order to get the related object name to build the query
				String relatedObject;
				if (theFields.containsKey(thisLps[0].Parent_Field_MERC__c)) {
					relatedObject = theFields.get(thisLps[0].Parent_Field_MERC__c).getDescribe().getReferenceTo().get(0).getDescribe().getName();
				} else {
					//we won't be able to build the query
					return options;
				}

				//The referenceId needs to be updated to get the ID at the Parent_Object_Id_Relationship_MERC__c path
				String newRefQuery = 'SELECT Id, '
                                   + thisLps[0].Parent_Object_Id_Relationship_MERC__c
                                   + ' FROM ' + relatedObject
                                   + ' WHERE Id =\'' + referenceId + '\'';

                System.debug(newRefQuery);
				List<SObject> refList = Database.query( newRefQuery );
				if (!refList.isEmpty()) {
					referenceId = (String)refList.get(0).get(thisLps[0].Parent_Object_Id_Relationship_MERC__c);
				} else {
					// no point in continuing on, we have nothing to find
					return options;
				}
			}

			String optionsSoql = 'SELECT Id, (SELECT Id, '
				                    + (String.isNotBlank(thisLps[0].Picklist_Label_Source_MERC__c) ? thisLps[0].Picklist_Label_Source_MERC__c + '.' : '')
				                    + 'Name FROM '
					                + thisLps[0].Picklist_Object_Relationship_MERC__c
					                + (String.isNotBlank(thisLps[0].Filter_Criteria_MERC__c) ? ' WHERE ' + thisLps[0].Filter_Criteria_MERC__c : '')
					                + ' ORDER BY Name) FROM '
	                                + thisLps[0].Parent_Object_API_Name_MERC__c
	                                + ' WHERE Id = \'' + referenceId + '\'';


			System.debug('###\n\n\nOptions SOQL: ' + optionsSoql );
			if (String.isNotBlank(referenceId)) {
				List<SObject> soList = Database.query(optionsSoql);
				if (!soList.isEmpty()) {
					for (SObject so : soList[0].getSObjects(thisLps[0].Picklist_Object_Relationship_MERC__c)) {
						options += '<option value="' + String.valueOf(so.get('Id')) + '">';
						if (String.isNotBlank(thisLps[0].Picklist_Label_Source_MERC__c)) {
							options += String.valueOf(so.getSObject(thisLps[0].Picklist_Label_Source_MERC__c).get('Name'));
						} else {
							options += String.valueOf(so.get('Name'));
						}
						options +=  +'</option>';
					}
				}
			}
		}

		return options;
	}

	public class Field {
		public Boolean readOnly { get; set; }
		public Boolean blankSpace { get; set; }
		public String id { get; set; }
		public String value { get; set; }
		public String label { get; set; }
		public Integer tabOrder { get; set; }
		public Boolean required { get; set; }
		public String onBlur { get; set; }
		public String onChange { get; set; }
		public Boolean dynamic { get; set; }
		public String styleClass { get; set; }

		/*----- Lookup picklist functionality : these values will be set if a lookup is part of a dependency where
		        values should be filtered and displayed as a picklist rather than a generic lookup.-----*/
		public Boolean isParentField { get; set; }
		public Boolean isChildField { get; set; }
		public String target { get; set; }
	}

	//returns layouts for a given sobject type and record type (if applicable)
	public sobjectPartnerSoapSforceCom.DescribeLayoutResult layoutResult {
		get {
			if (layoutResult == null) {
				system.debug('----> CALLLLLLLLLLOUTTTTTTTTTTTTTTT');
				sobjectPartnerSoapSforceCom.Soap handler = HandlerMetadataInit();
				layoutResult = handler.describeLayout(this.sObjectAPIName, new list<String>{sObjectRecordType});
			}
			return layoutResult;
		}
		private set;
	}

	//returns sections/fields for edit layout
	public List<PageBlockSection> sections {
		get {
			system.debug('getting sections!');
			if (sections == null) {
				sections = new List<PageBlockSection>();

				PageBlockSection pBs;
		        Field f;

	            if (layoutResult != null) {
	            	//we take the first one because we queried only one recordtype.
	                for (sobjectPartnerSoapSforceCom.DescribeLayoutSection LayoutSection : layoutResult.Layouts.get(0).editLayoutSections) {
	                   	//the different sections.
	                   	//System.debug('LAYOUT SECTION ---> '+LayoutSection);
	                   	//System.debug('LAYOUT SECTION HEADING ---> '+LayoutSection.heading);

						pBs = new PageBlockSection(LayoutSection.columns);

	                   	if (LayoutSection.useHeading==true) {
							pBS.title = LayoutSection.heading;
						}

	                    for (sobjectPartnerSoapSforceCom.DescribeLayoutRow layoutRow:LayoutSection.layoutRows) {
	                        for (sobjectPartnerSoapSforceCom.DescribeLayoutItem layoutItem:layoutRow.layoutItems) {
	                           	System.debug('LAYOUT ITEM ---> '+layoutItem);
	                           	if (layoutItem.layoutComponents != null) {
	                                //fields
	                                for (sobjectPartnerSoapSforceCom.DescribeLayoutComponent layoutComponent : layoutItem.layoutComponents) {
	                           			System.debug('LAYOUT COMPONENT ---> '+layoutComponent);

										f          = new Field();
										f.id       = layoutComponent.value;
										f.tabOrder = layoutComponent.tabOrder;
										f.value    = layoutComponent.value;
										f.required = layoutItem.required;
										f.label    = layoutItem.label;
	                                  	if (dynamicFields != null) {
	                                  		if (this.dynamicFields.contains(layoutComponent.value)) {
												f.readOnly = false;
												f.dynamic  = true;
	                                  			pBs.fields.add(f);
	                                  			continue;
	                                  		}
	                                  	}

	                                  	if (layoutComponent.value=='OwnerId' || layoutComponent.value=='RecordTypeId') {
	                                  		//The user shouldn't change the OwnerId/RecordType this way.
	                                  		f.readOnly = true;
	                                  	} else if (lookupParentFields.containsKey(layoutComponent.value) || lookupChildFields.containsKey(layoutComponent.value)) {
	                                  		f.readOnly = false;

	                                  		//set up the field correctly. if parent field we need to set up the onchange property to make a call to a javasript function
	                                  		//to trigger the call to the @RemoteAction get options
	                                  		if (lookupParentFields.containsKey(layoutComponent.value)) {
												f.isParentField = true;
												//assumed that there is a javascript function called updatePicklist that we need to pass the id of the custom setting
												//and the element triggering the onchange event.
												f.onChange   = 'updatePicklist(\'' + lookupParentFields.get(layoutComponent.value).Id + '\', this);';
												f.styleClass = lookupParentFields.get(layoutComponent.value).Parent_Field_MERC__c;
	                                  		}
	                                  		if (lookupChildFields.containsKey(layoutComponent.value)) {
												//target is the id of the custom setting that defines how this value is set. it will be set as a styleclass
												//on the page so that we an target it in javascript.
												f.isChildField = true;
												f.target       = lookupChildFields.get(layoutComponent.value).Id;

												//this javascript will be called when the page loads. it will trigger the change action on the selectlist forcing
												//the child select options to be udpated. We only want to call the onchange of inputs and spans. Salesforce will apply
												//the class name to an anchor tag assoiated with a lookup as well. The spans is rendered in place of an input when the
												//field is on the child side of a master-detail relationship in edit mode (and reparenting is not allowed)
												String clsName = lookupChildFields.get(layoutComponent.value).Parent_Field_MERC__c;
												f.onChange     = 'j$("input.' + clsName + ', span.' + clsName +'").change()';
	                                  		}
	                                  	} else if (layoutitem.editable == false && layoutComponent.value != null) {
											f.readOnly = true;
										} else if (layoutComponent.type_x == 'EmptySpace') {
		                                  	f.blankSpace = true;
		                                  	f.readOnly = layoutItem.editable;
							            } else if (layoutComponent.value != null) {
		                                  	f.readOnly = false;
							            }
							            pBs.fields.add(f);
	                                }
	                            }
	                            else {
	                            	f = new Field();
	                            	f.blankspace = true;
	                            	pBs.fields.add(f);
	                            }

	                        }
	                    }
	                    pBs.index = sections.size();
	                    sections.add(pBs);
	                }
	            }
			}
			return sections;
		}
		private set;
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