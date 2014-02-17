//Generated by wsdl2apex

public class sobjectPartnerSoapSforceCom {

    public class DescribeLayoutComponent {
        public Integer displayLines;
        public Integer tabOrder;
        public String type_x;
        public String value;
        private String[] displayLines_type_info = new String[]{'displayLines','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] tabOrder_type_info = new String[]{'tabOrder','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] type_x_type_info = new String[]{'type','urn:partner.soap.sforce.com','layoutComponentType','1','1','false'};
        private String[] value_type_info = new String[]{'value','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'displayLines','tabOrder','type_x','value'};
    }

    public class Soap {
        public String endpoint_x = 'https://login.salesforce.com/services/Soap/u/27.0';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;

        public sobjectPartnerSoapSforceCom.SessionHeader_element SessionHeader;

        private String StreamingEnabledHeader_hns = 'StreamingEnabledHeader=urn:partner.soap.sforce.com';
        private String MruHeader_hns = 'MruHeader=urn:partner.soap.sforce.com';
        private String CallOptions_hns = 'CallOptions=urn:partner.soap.sforce.com';
        private String PackageVersionHeader_hns = 'PackageVersionHeader=urn:partner.soap.sforce.com';
        private String EmailHeader_hns = 'EmailHeader=urn:partner.soap.sforce.com';
        private String LocaleOptions_hns = 'LocaleOptions=urn:partner.soap.sforce.com';
        private String DebuggingInfo_hns = 'DebuggingInfo=urn:partner.soap.sforce.com';
        private String SessionHeader_hns = 'SessionHeader=urn:partner.soap.sforce.com';
        private String DebuggingHeader_hns = 'DebuggingHeader=urn:partner.soap.sforce.com';
        private String LoginScopeHeader_hns = 'LoginScopeHeader=urn:partner.soap.sforce.com';
        private String DisableFeedTrackingHeader_hns = 'DisableFeedTrackingHeader=urn:partner.soap.sforce.com';
        private String UserTerritoryDeleteHeader_hns = 'UserTerritoryDeleteHeader=urn:partner.soap.sforce.com';
        private String AllowFieldTruncationHeader_hns = 'AllowFieldTruncationHeader=urn:partner.soap.sforce.com';
        private String QueryOptions_hns = 'QueryOptions=urn:partner.soap.sforce.com';
        private String AssignmentRuleHeader_hns = 'AssignmentRuleHeader=urn:partner.soap.sforce.com';
        private String AllOrNoneHeader_hns = 'AllOrNoneHeader=urn:partner.soap.sforce.com';
        private String[] ns_map_type_info = new String[]{'urn:sobject.partner.soap.sforce.com', 'sobjectPartnerSoapSforceCom', 'urn:fault.partner.soap.sforce.com', 'sobjectPartnerSoapSforceCom', 'urn:partner.soap.sforce.com', 'sobjectPartnerSoapSforceCom'};


        public sobjectPartnerSoapSforceCom.DescribeLayoutResult describeLayout(String sObjectType,String[] recordTypeIds) {
            sobjectPartnerSoapSforceCom.describeLayout_element request_x = new sobjectPartnerSoapSforceCom.describeLayout_element();
            sobjectPartnerSoapSforceCom.describeLayoutResponse_element response_x;
            request_x.sObjectType = sObjectType;
            request_x.recordTypeIds = recordTypeIds;
            Map<String, sobjectPartnerSoapSforceCom.describeLayoutResponse_element> response_map_x = new Map<String, sobjectPartnerSoapSforceCom.describeLayoutResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'urn:partner.soap.sforce.com',
              'describeLayout',
              'urn:partner.soap.sforce.com',
              'describeLayoutResponse',
              'sobjectPartnerSoapSforceCom.describeLayoutResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
    }
    public class SessionHeader_element {
        public String sessionId;
        private String[] sessionId_type_info = new String[]{'sessionId','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'sessionId'};
    }

    public class DescribeLayoutButton {
        public Boolean custom;
        public String label;
        public String name;
        private String[] custom_type_info = new String[]{'custom','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] label_type_info = new String[]{'label','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] name_type_info = new String[]{'name','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'custom','label','name'};
    }

    public class DescribeLayoutItem {
        public Boolean editable;
        public String label;
        public sobjectPartnerSoapSforceCom.DescribeLayoutComponent[] layoutComponents;
        public Boolean placeholder;
        public Boolean required;
        private String[] editable_type_info = new String[]{'editable','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] label_type_info = new String[]{'label','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] layoutComponents_type_info = new String[]{'layoutComponents','urn:partner.soap.sforce.com','DescribeLayoutComponent','0','-1','false'};
        private String[] placeholder_type_info = new String[]{'placeholder','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] required_type_info = new String[]{'required','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'editable','label','layoutComponents','placeholder','required'};
    }

    public class DescribeLayoutButtonSection {
        public sobjectPartnerSoapSforceCom.DescribeLayoutButton[] detailButtons;
        private String[] detailButtons_type_info = new String[]{'detailButtons','urn:partner.soap.sforce.com','DescribeLayoutButton','1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'detailButtons'};
    }

    public class describeLayoutResponse_element {
        public sobjectPartnerSoapSforceCom.DescribeLayoutResult result;
        private String[] result_type_info = new String[]{'result','urn:partner.soap.sforce.com','DescribeLayoutResult','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }

    public class DescribeLayoutResult {
        public sobjectPartnerSoapSforceCom.DescribeLayout[] layouts;
        public sobjectPartnerSoapSforceCom.RecordTypeMapping[] recordTypeMappings;
        public Boolean recordTypeSelectorRequired;
        private String[] layouts_type_info = new String[]{'layouts','urn:partner.soap.sforce.com','DescribeLayout','1','-1','false'};
        private String[] recordTypeMappings_type_info = new String[]{'recordTypeMappings','urn:partner.soap.sforce.com','RecordTypeMapping','0','-1','false'};
        private String[] recordTypeSelectorRequired_type_info = new String[]{'recordTypeSelectorRequired','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'layouts','recordTypeMappings','recordTypeSelectorRequired'};
    }
    public class RecordTypeMapping {
        public Boolean available;
        public Boolean defaultRecordTypeMapping;
        public String layoutId;
        public String name;
        public sobjectPartnerSoapSforceCom.PicklistForRecordType[] picklistsForRecordType;
        public String recordTypeId;
        private String[] available_type_info = new String[]{'available','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] defaultRecordTypeMapping_type_info = new String[]{'defaultRecordTypeMapping','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] layoutId_type_info = new String[]{'layoutId','urn:partner.soap.sforce.com','ID','1','1','false'};
        private String[] name_type_info = new String[]{'name','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] picklistsForRecordType_type_info = new String[]{'picklistsForRecordType','urn:partner.soap.sforce.com','PicklistForRecordType','0','-1','true'};
        private String[] recordTypeId_type_info = new String[]{'recordTypeId','urn:partner.soap.sforce.com','ID','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'available','defaultRecordTypeMapping','layoutId','name','picklistsForRecordType','recordTypeId'};
    }
    public class PicklistForRecordType {
        public String picklistName;
        public sobjectPartnerSoapSforceCom.PicklistEntry[] picklistValues;
        private String[] picklistName_type_info = new String[]{'picklistName','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] picklistValues_type_info = new String[]{'picklistValues','urn:partner.soap.sforce.com','PicklistEntry','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'picklistName','picklistValues'};
    }
    public class DescribeLayoutSection {
        public Integer columns;
        public String heading;
        public sobjectPartnerSoapSforceCom.DescribeLayoutRow[] layoutRows;
        public Integer rows;
        public Boolean useCollapsibleSection;
        public Boolean useHeading;
        private String[] columns_type_info = new String[]{'columns','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] heading_type_info = new String[]{'heading','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] layoutRows_type_info = new String[]{'layoutRows','urn:partner.soap.sforce.com','DescribeLayoutRow','1','-1','false'};
        private String[] rows_type_info = new String[]{'rows','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] useCollapsibleSection_type_info = new String[]{'useCollapsibleSection','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] useHeading_type_info = new String[]{'useHeading','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'columns','heading','layoutRows','rows','useCollapsibleSection','useHeading'};
    }
    public class PicklistEntry {
        public Boolean active;
        public Boolean defaultValue;
        public String label;
        public String validFor;
        public String value;
        private String[] active_type_info = new String[]{'active','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] defaultValue_type_info = new String[]{'defaultValue','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] label_type_info = new String[]{'label','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] validFor_type_info = new String[]{'validFor','http://www.w3.org/2001/XMLSchema','base64Binary','0','1','false'};
        private String[] value_type_info = new String[]{'value','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'active','defaultValue','label','validFor','value'};
    }
    public class describeLayout_element {
        public String sObjectType;
        public String[] recordTypeIds;
        private String[] sObjectType_type_info = new String[]{'sObjectType','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] recordTypeIds_type_info = new String[]{'recordTypeIds','urn:partner.soap.sforce.com','ID','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'sObjectType','recordTypeIds'};
    }
    public class DescribeLayout {
        public sobjectPartnerSoapSforceCom.DescribeLayoutButtonSection buttonLayoutSection;
        public sobjectPartnerSoapSforceCom.DescribeLayoutSection[] detailLayoutSections;
        public sobjectPartnerSoapSforceCom.DescribeLayoutSection[] editLayoutSections;
        public String id;
        public sobjectPartnerSoapSforceCom.RelatedList[] relatedLists;
        private String[] buttonLayoutSection_type_info = new String[]{'buttonLayoutSection','urn:partner.soap.sforce.com','DescribeLayoutButtonSection','0','1','false'};
        private String[] detailLayoutSections_type_info = new String[]{'detailLayoutSections','urn:partner.soap.sforce.com','DescribeLayoutSection','0','-1','false'};
        private String[] editLayoutSections_type_info = new String[]{'editLayoutSections','urn:partner.soap.sforce.com','DescribeLayoutSection','0','-1','false'};
        private String[] id_type_info = new String[]{'id','urn:partner.soap.sforce.com','ID','1','1','false'};
        private String[] relatedLists_type_info = new String[]{'relatedLists','urn:partner.soap.sforce.com','RelatedList','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'buttonLayoutSection','detailLayoutSections','editLayoutSections','id','relatedLists'};
    }
    public class RelatedList {
        public sobjectPartnerSoapSforceCom.RelatedListColumn[] columns;
        public Boolean custom;
        public String field;
        public String label;
        public Integer limitRows;
        public String name;
        public String sobject_x;
        public sobjectPartnerSoapSforceCom.RelatedListSort[] sort_x;
        private String[] columns_type_info = new String[]{'columns','urn:partner.soap.sforce.com','RelatedListColumn','1','-1','false'};
        private String[] custom_type_info = new String[]{'custom','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] field_type_info = new String[]{'field','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] label_type_info = new String[]{'label','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] limitRows_type_info = new String[]{'limitRows','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] name_type_info = new String[]{'name','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] sobject_x_type_info = new String[]{'sobject','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] sort_x_type_info = new String[]{'sort','urn:partner.soap.sforce.com','RelatedListSort','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'columns','custom','field','label','limitRows','name','sobject_x','sort_x'};
    }
    public class RelatedListSort {
        public Boolean ascending;
        public String column;
        private String[] ascending_type_info = new String[]{'ascending','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] column_type_info = new String[]{'column','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'ascending','column'};
    }

    public class RelatedListColumn {
        public String field;
        public String format;
        public String label;
        public String lookupId;
        public String name;
        private String[] field_type_info = new String[]{'field','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] format_type_info = new String[]{'format','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] label_type_info = new String[]{'label','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] lookupId_type_info = new String[]{'lookupId','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] name_type_info = new String[]{'name','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'field','format','label','lookupId','name'};
    }
    public class DescribeLayoutRow {
        public sobjectPartnerSoapSforceCom.DescribeLayoutItem[] layoutItems;
        public Integer numItems;
        private String[] layoutItems_type_info = new String[]{'layoutItems','urn:partner.soap.sforce.com','DescribeLayoutItem','1','-1','false'};
        private String[] numItems_type_info = new String[]{'numItems','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'layoutItems','numItems'};
    }

}