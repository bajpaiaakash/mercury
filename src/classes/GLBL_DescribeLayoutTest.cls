/**
 * @author Joseph Ferraro
 *
 * Mock/Unit Test to test the dynamic layout describe via sobjectPartnerSoapSforceCom
 */

@IsTest
private with sharing class GLBL_DescribeLayoutTest {
	private class WebServiceMockImpl implements WebServiceMock {
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) {
			
			if (request instanceof sobjectPartnerSoapSforceCom.describeLayout_element) {
				sobjectPartnerSoapSforceCom.describeLayoutResponse_element responseElement = new sobjectPartnerSoapSforceCom.describeLayoutResponse_element();
				
				// BUTTONS
				sobjectPartnerSoapSforceCom.DescribeLayoutButtonSection buttonLayoutSection = new sobjectPartnerSoapSforceCom.DescribeLayoutButtonSection();

				sobjectPartnerSoapSforceCom.DescribeLayoutButton saveButton = new sobjectPartnerSoapSforceCom.DescribeLayoutButton();
				saveButton.custom = false;
				saveButton.label = 'Save';
				saveButton.name = 'Save';

				sobjectPartnerSoapSforceCom.DescribeLayoutButton cancelButton = new sobjectPartnerSoapSforceCom.DescribeLayoutButton();
				cancelButton.custom = false;
				cancelButton.label = 'Cancel';
				cancelButton.name = 'Cancel';

				List<sobjectPartnerSoapSforceCom.DescribeLayoutButton> buttons = new List<sobjectPartnerSoapSforceCom.DescribeLayoutButton>();
				buttons.add(saveButton);
				buttons.add(cancelButton);

				buttonLayoutSection.detailButtons = buttons;
				// /BUTTONS

				//LAYOUT COMPONENTS
				sobjectPartnerSoapSforceCom.DescribeLayoutComponent layoutComponent = new sobjectPartnerSoapSforceCom.DescribeLayoutComponent();
				layoutComponent.displayLines = 1;
				layoutComponent.tabOrder = 1;
				layoutComponent.type_x = 'STRING';
				layoutComponent.value = 'Custom_Field__c';

				sobjectPartnerSoapSforceCom.DescribeLayoutComponent layoutComponent2 = new sobjectPartnerSoapSforceCom.DescribeLayoutComponent();
				layoutComponent.displayLines = 1;
				layoutComponent.tabOrder = 2;
				layoutComponent.type_x = 'STRING';
				layoutComponent.value = 'Different_Custom_Field__c';

				/* sobjectPartnerSoapSforceCom.DescribeLayoutComponent layoutComponent3 = new sobjectPartnerSoapSforceCom.DescribeLayoutComponent();
				layoutComponent3.displayLines = 1;
				layoutComponent3.tabOrder = 1;
				layoutComponent3.type_x = 'STRING';
				layoutComponent3.value = 'Custom_Field__c';

				sobjectPartnerSoapSforceCom.DescribeLayoutComponent layoutComponent4 = new sobjectPartnerSoapSforceCom.DescribeLayoutComponent();
				layoutComponent4.displayLines = 1;
				layoutComponent4.tabOrder = 2;
				layoutComponent4.type_x = 'STRING';
				layoutComponent4.value = 'Different_Custom_Field__c'; */

				sobjectPartnerSoapSforceCom.DescribeLayoutComponent layoutComponent3 = new sobjectPartnerSoapSforceCom.DescribeLayoutComponent();
				layoutComponent3.displayLines = 1;
				layoutComponent3.tabOrder = 3;
				layoutComponent3.type_x = 'STRING';
				layoutComponent3.value = 'OwnerId';

				sobjectPartnerSoapSforceCom.DescribeLayoutComponent layoutComponent4 = new sobjectPartnerSoapSforceCom.DescribeLayoutComponent();
				layoutComponent4.displayLines = 1;
				layoutComponent4.tabOrder = 2;
				layoutComponent4.type_x = 'EmptySpace';

				//LAYOUT ITEMS
				sobjectPartnerSoapSforceCom.DescribeLayoutItem layoutItem = new sobjectPartnerSoapSforceCom.DescribeLayoutItem();
				layoutItem.editable = true;
				layoutItem.label = 'A label';
				layoutItem.placeholder = false;
				layoutItem.required = true;
				layoutItem.layoutComponents = new List<sobjectPartnerSoapSforceCom.DescribeLayoutComponent>{layoutComponent, layoutComponent2};

				sobjectPartnerSoapSforceCom.DescribeLayoutItem layoutItem2 = new sobjectPartnerSoapSforceCom.DescribeLayoutItem();
				layoutItem.editable = false;
				layoutItem.label = 'A different label';
				layoutItem.placeholder = false;
				layoutItem.required = false;
				layoutItem.layoutComponents = new List<sobjectPartnerSoapSforceCom.DescribeLayoutComponent>{layoutComponent3, layoutComponent4};

				//SECTION ROWS
				sobjectPartnerSoapSforceCom.DescribeLayoutRow row = new sobjectPartnerSoapSforceCom.DescribeLayoutRow();
				row.numItems = 2;
				row.layoutItems = new List<sobjectPartnerSoapSforceCom.DescribeLayoutItem>{layoutItem,layoutItem2};

				//SECTIONS
				sobjectPartnerSoapSforceCom.DescribeLayoutSection layoutSection = new sobjectPartnerSoapSforceCom.DescribeLayoutSection();
				layoutSection.columns = 2;
				layoutSection.heading = 'foo';
				layoutSection.rows = 1;
				layoutSection.useCollapsibleSection = false;
				layoutSection.useHeading = true;
				layoutSection.layoutRows = new List<sobjectPartnerSoapSforceCom.DescribeLayoutRow>{row};

				//LAYOUT
				sobjectPartnerSoapSforceCom.DescribeLayout layout = new sobjectPartnerSoapSforceCom.DescribeLayout();
				layout.id = 'foo';
				layout.buttonLayoutSection = buttonLayoutSection;
				layout.editLayoutSections = new List<sobjectPartnerSoapSforceCom.DescribeLayoutSection>{layoutSection};

				//RESULT
				sobjectPartnerSoapSforceCom.DescribeLayoutResult layoutResult = new sobjectPartnerSoapSforceCom.DescribeLayoutResult();
				layoutResult.recordTypeSelectorRequired = true;
				layoutResult.layouts = new List<sobjectPartnerSoapSforceCom.DescribeLayout>{layout};

				responseElement.result = layoutResult;

				response.put('response_x', responseElement);				
			}			
			return;
		}
	}

	private static testmethod void testDescribeLayout() {
		Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
		Test.startTest();
		Account a = new Account();
		GLBL_BaseEditController controller = new GLBL_BaseEditController(new ApexPages.StandardController(a), Account.SobjectType);
		Set<String> fieldSet = new Set<String>();
		fieldSet.add('Different_Custom_Field__c');
		controller.dynamicFields = fieldSet;

		List<GLBL_BaseEditController.PageBlockSection> sections = controller.sections;
		GLBL_BaseEditController.PageBlockSection section = sections.get(0);
		GLBL_BaseEditController.Field firstField = section.fields.get(0);
		system.assertEquals(null, firstField.onBlur);
		system.assertEquals(null, firstField.onChange);
		system.assertEquals(null, firstField.dynamic);
		system.assertEquals(null, firstField.styleClass);
		system.assertEquals(null, firstField.isParentField);
		system.assertEquals(null, firstField.isChildField);
		system.assertEquals(null, firstField.target);
		system.assertEquals(1, sections.size());
		Test.stopTest(); 	
	}
}