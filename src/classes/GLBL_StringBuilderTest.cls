/**
 * @author Kyle Thornton
 *
 * Unit tests for the GLBL_StringBuilder class
 */
@isTest
private class GLBL_StringBuilderTest {

	@isTest static void test_can_add_to_string() {
		GLBL_StringBuilder sb = new GLBL_StringBuilder();
		sb.add('This');
		sb.add(new List<String>{' is',' a',' string','.'});
		System.assertEquals('This is a string.', sb.getStringValue());
	}

	@isTest static void test_can_initialize_with_list_of_strings() {
		GLBL_StringBuilder sb = new GLBL_StringBuilder(new List<String>{'This', ' is'});
		sb.add(new List<String>{' a',' string','.'});
		System.assertEquals('This is a string.', sb.getStringValue());
	}

	@isTest static void test_csv_builder() {
		GLBL_StringBuilder.CSVBuilder sbCsv = new GLBL_StringBuilder.CSVBuilder();
		sbCsv.add(' value');
		System.assertEquals('a value', sbCsv.getStringValue('a'));
		System.assertEquals(' value', sbCsv.getStringValue());
	}

	@isTest static void test_csv_builder_list_initialize() {
		GLBL_StringBuilder.CSVBuilder sbCsv = new GLBL_StringBuilder.CSVBuilder(new List<String>{' value'});
		System.assertEquals('a value', sbCsv.getStringValue('a'));
		System.assertEquals(' value', sbCsv.getStringValue());
	}

	@isTest static void test_field_list_builder() {
		List<Schema.SObjectField> values = new List<Schema.SObjectField>();
		Map<String, Schema.SObjectField> fields = Schema.describeSObjects(new List<String>{'Account'}).get(0).fields.getMap();
		values.add(fields.get('Name'));
		values.add(fields.get('Industry'));

		GLBL_StringBuilder.FieldListBuilder sbFlb = new GLBL_StringBuilder.FieldListBuilder(values);

		System.assert(sbFlb.getStringValue().contains('Name'));
		System.assert(sbFlb.getStringValue().contains('Industry'));
	}

	@isTest static void test_MultiCurrencyFieldListBuilder() {
		List<Schema.SObjectField> values = new List<Schema.SObjectField>();
		Map<String, Schema.SObjectField> fields = Schema.describeSObjects(new List<String>{'Account'}).get(0).fields.getMap();
		values.add(fields.get('Name'));
		values.add(fields.get('Industry'));

		GLBL_StringBuilder.MultiCurrencyFieldListBuilder sbMcFlb = new GLBL_StringBuilder.MultiCurrencyFieldListBuilder(values);

		System.assert(sbMcFlb.getStringValue().contains('Name'));
		System.assert(sbMcFlb.getStringValue().contains('Industry'));
		System.assert(sbMcFlb.getStringValue().contains('CurrencyIsoCode'));
	}

}