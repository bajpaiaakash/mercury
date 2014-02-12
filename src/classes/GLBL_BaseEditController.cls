/**
 * @author Joseph Ferraro
 *
 * Base controller that builds an edit page layout via the Metadata API
 */

public virtual with sharing class GLBL_BaseEditController {

	public Sobject mySobject { get; set; }
	
	private String sObjectAPIName;
	private String sObjectRecordType;
	private transient Component.Apex.Form Form;
	private Map<String, sObjectField> schemaFields;

	public String title { get; private set; }
	public String subtitle { get; private set; }

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
		
		this.title = sobjectDescribe.getLabel() + ' edit';
		if (mySObject == null || mySObject.Id == null) {
			this.subtitle = 'New ' + sobjectDescribe.getLabel();
		} else {
			this.subtitle = (String)mySObject.get('name');
		}		
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
		public Boolean required { get; set; }
	}

	public List<PageBlockSection> sections { 
		get {
			system.debug('getting sections!');
			if (sections == null) {
				sections = new List<PageBlockSection>();
				
				PageBlockSection pBs;
		        Field f;

		        sobjectPartnerSoapSforceCom.Soap handler = HandlerMetadataInit();

	        	//sObjectRecordType is the recordtype of the sobject. If the sobject has no recordtype, then it's null and it's still fine.
	            sobjectPartnerSoapSforceCom.DescribeLayoutResult LayoutResult = handler.describeLayout(this.sObjectAPIName, new list<String>{sObjectRecordType});

	            if (LayoutResult != null) {
	            	//we take the first one because we queried only one recordtype.               
	                for (sobjectPartnerSoapSforceCom.DescribeLayoutSection LayoutSection : LayoutResult.Layouts.get(0).editLayoutSections) {
	                   	//the different sections.
	                   	//System.debug('LAYOUT SECTION ---> '+LayoutSection);
	                   	//System.debug('LAYOUT SECTION HEADING ---> '+LayoutSection.heading);

						pBs = new PageBlockSection(LayoutSection.columns);

	                   	if (LayoutSection.useHeading==true) {
							pBS.title = LayoutSection.heading;
						}

	                    for (sobjectPartnerSoapSforceCom.DescribeLayoutRow layoutRow:LayoutSection.layoutRows) {
	                        //System.debug('LAYOUT ROW ---> '+layoutRow);
	                        for (sobjectPartnerSoapSforceCom.DescribeLayoutItem layoutItem:layoutRow.layoutItems) {
	                           	//System.debug('LAYOUT ITEM ---> '+layoutItem);
	                           	if (layoutItem.layoutComponents != null) {
	                                //fields
	                                for (sobjectPartnerSoapSforceCom.DescribeLayoutComponent layoutComponent : layoutItem.layoutComponents) {
	                                  	if (layoutComponent.value=='OwnerId' || layoutComponent.value=='RecordTypeId') {
	                                  		//The user shouldn't change the OwnerId/RecordType this way.
	                                  	}
	                                  	else if (layoutitem.editable == false && layoutComponent.value != null) {
											f = new Field();
											f.id = layoutComponent.value;
											f.readOnly = true;
											f.value = layoutComponent.value;
											pBs.fields.add(f);
										}
	                                  	else if (layoutComponent.value != null) {
		                                  	f = new Field();
		                                  	f.id = layoutComponent.value;
		                                  	f.readOnly = false;
		                                  	f.value = layoutComponent.value;
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