/**
 * @author Joseph Ferraro
 *
 * Base controller that builds an edit page layout dynamically via the Metadata API
 * We use this for Meeting and Travel Itinerary new/edit pages because it allows us to provide a better UX when dealing with Date/Times
 */

public virtual with sharing class GLBL_BaseEditController {

	public Sobject mySobject { get; set; }
	
	private String sObjectAPIName;
	private String sObjectRecordType;
	private Map<String, sObjectField> schemaFields;

	public String title { get; private set; }
	public String subtitle { get; private set; }

	public Set<String> dynamicFields;

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

		this.sObjectAPIName = sobjectDescribe.getName();

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

	public GLBL_BaseEditController(ApexPages.StandardController stdController, Schema.SobjectType sotype, Set<String> dfs) {
		this(stdController, sotype);
		this.dynamicFields = dfs;		
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

	public class Field {
		public Boolean readOnly { get; set; }
		public Boolean blankSpace { get; set; }
		public String id { get; set; }
		public String value { get; set; }
		public Integer tabOrder { get; set; }
		public Boolean required { get; set; }
		public String onBlur { get; set; }
		public String onChange { get; set; }
		public Boolean dynamic { get; set; }
	}

	//returns layouts for a given sobject type and record type (if applicable)
	public sobjectPartnerSoapSforceCom.DescribeLayoutResult layoutResult {
		get {
			if (layoutResult == null) {
				sobjectPartnerSoapSforceCom.Soap handler = HandlerMetadataInit();
				layoutResult = handler.describeLayout(this.sObjectAPIName, new list<String>{sObjectRecordType});
			}
			return layoutResult;
		}
		private set;
	}

	public Map<String,String> fieldNameToDetailSectionName {
		get {
			if (fieldNameToDetailSectionName == null) {
				fieldNameToDetailSectionName = new Map<String,String>();
				if (layoutResult != null) {
	            	//we take the first one because we queried only one recordtype.               
	                for (sobjectPartnerSoapSforceCom.DescribeLayoutSection LayoutSection : layoutResult.Layouts.get(0).detailLayoutSections) {
	                   	
						String layoutSectionHeading = LayoutSection.heading;

	                    for (sobjectPartnerSoapSforceCom.DescribeLayoutRow layoutRow:LayoutSection.layoutRows) {
	                        for (sobjectPartnerSoapSforceCom.DescribeLayoutItem layoutItem:layoutRow.layoutItems) {
	                           	if (layoutItem.layoutComponents != null) {
	                                //fields
	                                for (sobjectPartnerSoapSforceCom.DescribeLayoutComponent layoutComponent : layoutItem.layoutComponents) {
	                                	if (
	                                		layoutComponent.type_x != 'Separator' && 
	                                		layoutComponent.type_x != 'EmptySpace' &&
	                                		layoutComponent.value != null
	                                	) {
	                                		fieldNameToDetailSectionName.put(layoutComponent.value, layoutSectionHeading); 
	                                	}
	                                }
	                            }
	                        }
	                    }
	                }
	            }	
			}
			return fieldNameToDetailSectionName;
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
	                                  	
	                                  	if (dynamicFields != null) {
	                                  		if (this.dynamicFields.contains(layoutComponent.value)) {
	                                  			f = new Field();
	                                  			f.id = layoutComponent.value;
	                                  			f.readOnly = false;
	                                  			f.tabOrder = layoutComponent.tabOrder;
	                                  			f.value = layoutComponent.value;
	                                  			f.dynamic = true;
	                                  			pBs.fields.add(f);
	                                  			continue;	
	                                  		}
	                                  	}
	                                  	
	                                  	if (layoutComponent.value=='OwnerId' || layoutComponent.value=='RecordTypeId') {
	                                  		//The user shouldn't change the OwnerId/RecordType this way.
	                                  		f = new Field();
	                                  		f.id = layoutComponent.value;
	                                  		f.readOnly = true;
	                                  		f.tabOrder = layoutComponent.tabOrder;
	                                  		f.value = layoutComponent.value;
	                                  		pBs.fields.add(f);
	                                  	} else if (layoutitem.editable == false && layoutComponent.value != null) {
											f = new Field();
											f.id = layoutComponent.value;
											f.readOnly = true;
											f.tabOrder = layoutComponent.tabOrder;
											f.value = layoutComponent.value;
											pBs.fields.add(f);
										} else if (layoutComponent.type_x == 'EmptySpace') {
		                                  	f = new Field();
		                                  	f.blankSpace = true;
		                                  	f.id = layoutComponent.value;
		                                  	f.readOnly = layoutItem.editable;
		                                  	f.tabOrder = layoutComponent.tabOrder;
		                                  	pBs.fields.add(f);
							            } else if (layoutComponent.value != null) {
		                                  	f = new Field();
		                                  	f.id = layoutComponent.value;
		                                  	f.readOnly = false;
		                                  	f.value = layoutComponent.value;
		                                  	f.tabOrder = layoutComponent.tabOrder;
		                                  	f.required = layoutItem.required;
		                                  	pBs.fields.add(f);
							            } 
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