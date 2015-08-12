/**
 * @author Joseph Ferraro & Kyle Thornton
 *
 * Exercises the appropriate coverage for the GLBL_BaseEditController controller via the Account page
 * Note: this does not test the callouts, those are tested in GLBL_DescribeLayoutTest
 */

@isTest
private class GLBL_BaseEditControllerTest {

static User runningUser = MERC_TestFactory.getRunningUser();
static User testUser = MERC_TestFactory.getTestingUser();
static List<Account> accounts;

static {
    System.runAs(runningUser) {
        accounts = MERC_TestFactory.insertAccounts(1);
    }
}

    @isTest
    static void testAccountEditPage() {
        System.runAs(testUser) {
            PageReference ref = Page.Get_Started;
            ref.getParameters().put('saveURL','thisismysaveurl#anchor1');
            Test.setCurrentPage(ref);

            ApexPages.StandardController acctController = new ApexPages.StandardController(accounts.get(0));
            GLBL_BaseEditController controller = new GLBL_BaseEditController(acctController, Account.SobjectType);
            GLBL_BaseEditController.Field innerclass1= new GLBL_BaseEditController.Field();
            boolean b1=innerclass1.readOnly;
            string s1=innerclass1.id;
            boolean b2=innerclass1.blankSpace;
            boolean b3=innerclass1.required;
            boolean b4=innerclass1.dynamic;
            boolean b5=innerclass1.isParentField;
            boolean b6=innerclass1.isChildField;
            string s2=innerclass1.value;
            string s3=innerclass1.label;
            string s4=innerclass1.onBlur;
            string s5=innerclass1.onChange;
            string s6=innerclass1.styleClass;
            string s7=innerclass1.target;
            integer i1=innerclass1.tabOrder;
            
            GLBL_BaseEditController.PageBlockSection innerclass2= new GLBL_BaseEditController.PageBlockSection(1);
            List<GLBL_BaseEditController.Field> wrapfields1=innerclass2.fields;
            PageReference save_a = controller.save();
            string s8=innerclass2.title;
            integer i2= innerclass2.columns;
            integer i3= innerclass2.index;
            
            System.assertEquals('GLBL_BaseEditController', controller.getClassName());
            
            System.assert(controller.save().getUrl().contains('thisismysaveurl'), 'save URL missing saveURL parameter: '+controller.save().getUrl());
            System.assert(controller.save().getUrl().contains('anchor1'), 'save URL missing anchor1 tag: '+controller.save().getUrl());
        }
    }
    
    

    @isTest
    static void testDynamicFieldsConstructor() {
        System.runAs(testUser) {
            PageReference ref = Page.Get_Started;
            ref.getParameters().put('saveURL','thisismysaveurl#anchor1');
            Test.setCurrentPage(ref);

            ApexPages.StandardController acctController = new ApexPages.StandardController(accounts.get(0));
            GLBL_BaseEditController controller = new GLBL_BaseEditController(acctController, Account.SobjectType, new Set<String>{'value1', 'value2'});
            System.assertEquals('GLBL_BaseEditController', controller.getClassName());
            System.assert(controller.dynamicFields.contains('value1'));
            System.assert(controller.dynamicFields.contains('value2'));
        }
    }

    @isTest
    static void test_should_return_single_select_option_if_no_custom_seting() {
        System.runAs(testUser) {
            System.assertEquals(
                '<option value="">-- Select --</option>',
                GLBL_BaseEditController.getOptions('doesntMatter', 'badId', 'doesntMatter')
            );
        }
    }
    
 


    @isTest
    static void test_should_return_select_options_simple_config() {
        //Create data for the Meeting Product lookup. the simplest config
        Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
        Product_Group_GLBL__c product = new Product_Group_GLBL__c(
            Name='Test Product',
            Cntry_Cd_GLBL__c = 'GB',
            Crt_Dt_GLBL__c = Date.today(),
            Dialect_Nm_GLBL__c = 'TestId',
            Grp_Prps_Cd_GLBL__c = 'test',
            Lst_Pblsh_Dt_GLBL__c = Date.today(),
            Updt_Dt_GLBL__c = Date.today()
        );
        insert product;
        List<Indication_GLBL__c> indications = new List<Indication_GLBL__c> {
            createIndication( product.Id, 'Indication 1'),
            createIndication( product.Id, 'Indication 2')
        };
        insert indications;
        
        
        
        Lookup_Picklist_Settings_MERC__c meetingProductConfig = new Lookup_Picklist_Settings_MERC__c(
            Name                                 = 'Meeting Product Indications',
            Parent_Field_MERC__c                 = 'Product_MERC__c',
            Child_Field_MERC__c                  = 'Indication_MERC__c',
            Picklist_Object_Relationship_MERC__c = 'Indications__r',
            Controlling_Object_MERC__c           = 'Meeting_Products_MERC__c',
            Parent_Object_API_Name_MERC__c       = 'Product_Group_GLBL__c'
        );
        
        insert meetingProductConfig;
        
        System.runAs(testUser) {
            String response = GLBL_BaseEditController.getOptions('Meeting_Products_MERC__c', meetingProductConfig.Id, product.Id);
            System.assert(String.isNotBlank(response),'No select options returned');
            System.assert(response.startsWith('<option value="">-- Select --</option>'),'Unexpected response prefix: '+ response.escapeXml());
            System.assert(response.contains('">Indication 1</option>'));
            System.assert(response.contains('">Indication 2</option>'));
        }
    }

    // TODO - update this method to use test Users
    @isTest
    static void test_should_return_select_options_complex_config() {

//      System.runAs(runningUser) {
            //Create data for the Budget Line Item Vendors. the most complex config
            Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
            List<Meeting_Vendor_MERC__c> hotels = MERC_TestFactory.insertHotelsForMeeting(2, meeting.Id);
            Budget_MERC__c budget   = MERC_TestFactory.insertBudget(meeting.Id,true);
            // List<Budget_Line_Item_MERC__c> = MERC_TestFactory.insertBudgetLineItems(budget.Id, 2);

            Map<Id, Account> acctMap = new Map<Id, Account>([SELECT Id, Name FROM Account]);
            
            Lookup_Picklist_Settings_MERC__c budgetVendorConfig = new Lookup_Picklist_Settings_MERC__c(
                Name                                 = 'Budget Line Item Vendors',
                Parent_Field_MERC__c                 = 'Budget_MERC__c',
                Child_Field_MERC__c                  = 'Meeting_Vendor_MERC__c',
                Picklist_Object_Relationship_MERC__c = 'Meeting_Vendors__r',
                Controlling_Object_MERC__c           = 'Budget_Line_Item_MERC__c',
                Parent_Object_API_Name_MERC__c       = 'Meeting_MERC__c',
                Parent_Object_Id_Relationship_MERC__c= 'Meeting_MERC__c',
                Picklist_Label_Source_MERC__c        = 'Account_MERC__r'
            );
           
            insert budgetVendorConfig;
        
//      }

//      System.runAs(testUser) {
            String response = GLBL_BaseEditController.getOptions('Budget_Line_Item_MERC__c', budgetVendorConfig.Id, budget.Id);
            System.assert(String.isNotBlank(response),'No select options returned');
            System.assert(response.startsWith('<option value="">-- Select --</option>'),'Unexpected response prefix: '+response.escapeXml());
            System.assert(response.contains('">' + acctMap.get(hotels.get(0).Account_MERC__c).Name + '</option>'),'Options missing expected value: '+response.escapeXml());
//      }
    }


    private static Indication_GLBL__c createIndication(Id productId, String name) {
        Indication_GLBL__c indication = new Indication_GLBL__c(
            Prod_Grp_Prnt_Id_GLBL__c = productId,
            Name = name,
            Crt_Dt_GLBL__c = Date.today(),
            Dialect_Nm_GLBL__c ='123',
            Indctn_Desc_GLBL__c = 'desc',
            Indctn_Id_GLBL__c = 'indId',
            Indctn_Typ_GLBL__c = 'type',
            Lst_Pblsh_Dt_GLBL__c = Date.today(),
            Updt_Dt_GLBL__c = Date.today()
        );
        return indication;
    }
}