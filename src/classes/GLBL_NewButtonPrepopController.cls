public with sharing class GLBL_NewButtonPrepopController {

	String cObjName {get; private set;}
	Map<String,String> submittedParams = new Map<String,String>();
	Map<String,String> newParams = new Map<String,String>();
	Boolean toRecordTypeSelect {get; set;}

	public static final String PREFIX = 'cf_';
	public static final String SUFFIX = '_lkid';

	public GLBL_NewButtonPrepopController() {

		// filter out noise
		for (String key : Apexpages.currentPage().getParameters().keySet()) {
			if (key.startsWithIgnoreCase(PREFIX)) submittedParams.put(key.removeStart(PREFIX).toLowerCase(), Apexpages.currentPage().getParameters().get(key));
		}

		cObjName = Apexpages.currentPage().getParameters().get('cObj');
		newParams.put('ent', getCustomObjectIdFromURL(Apexpages.currentPage().getParameters().get('cObjURL')));

		String saveNewURL;
		if (!Apexpages.currentPage().getParameters().get('cObjURL').contains('recordtypeselect')) {
			toRecordTypeSelect = false;
			List<Schema.DescribeSObjectResult> descResults = Schema.describeSObjects(new List<String>{cObjName});
			for (Schema.DescribeSObjectResult dsr : descResults) {
				saveNewURL = '/'+dsr.getKeyPrefix()+'/e';
			}
		} else {
			toRecordTypeSelect = true;
			saveNewURL = getSimpleSaveURLFromURL(Apexpages.currentPage().getParameters().get('cObjURL'));
		}

		String saveParamString = '?';
		Map<String,String> customFieldIdParams = new Map<String,String>();
		Map<String,String> nameToCFID = getCFIds(submittedParams, cObjName);
		for (String key : nameToCFID.keySet()) {
			saveParamString += nameToCFID.get(key) + '=' + submittedParams.get(key) + '&';
			if (submittedParams.containsKey(key+SUFFIX)) saveParamString += nameToCFID.get(key)+SUFFIX+ '=' +submittedParams.get(key+SUFFIX) + '&';

		}
		if (Apexpages.currentPage().getParameters().get('cObjParentId')!=null) {
			String parentId = Apexpages.currentPage().getParameters().get('cObjParentId');
			String parentName = Apexpages.currentPage().getParameters().get('cObjParent').toLowerCase();
			saveParamString += 'retURL=/'+parentId;
			newParams.put('retURL', '/'+parentId);
			newParams.put('saveURL','/'+parentId+'#'+parentId+'_'+nameToCFID.get(parentName).substringAfter('CF')+'_target');
		}
		newParams.put('save_new_url', saveNewURL+saveParamString);

		// ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.valueOf(newParams)));

	}

	public PageReference redirect() {
		PageReference pageRef;
		if (toRecordTypeSelect) {
			pageRef = new PageReference('/setup/ui/recordtypeselect.jsp');
			for (String key : newParams.keySet()) {
				pageRef.getParameters().put(key, newParams.get(key));
			}
		//	return pageRef;
		} else {
			pageRef = new PageReference(newParams.get('save_new_url'));
		}
//		 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.valueOf(newParams.get('save_new_url'))));
//		 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.valueOf(pageRef.getParameters())));
//		 return null;
		 return pageRef;
	}

	public static String getCustomObjectIdFromURL(String defaultObjectNewURL) {
		try {
			defaultObjectNewURL = EncodingUtil.urlDecode(defaultObjectNewURL,'UTF-8');
			String custObjId = defaultObjectNewURL.substringAfter('ent=');
			return custObjId.substring(0, 15);
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Unable to parse Custom Object Id from URL: '+defaultObjectNewURL);
			return null;
		}
	}

	public static String getSimpleSaveURLFromURL(String defaultObjectNewURL) {
		try {
			defaultObjectNewURL = EncodingUtil.urlDecode(defaultObjectNewURL,'UTF-8');
			String saveURL = defaultObjectNewURL.substringAfter('save_new_url=');
			return EncodingUtil.urlDecode(saveURL, 'UTF-8').substring(0, 6);
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Unable to parse Custom Object save URL from URL: '+defaultObjectNewURL);
			return null;
		}
	}

	public static Map<String,String> getCFIds(Map<String,String> namesToData, String cObjName) {	

		Map<String,String> namesToCFIDs = new Map<String,String>();
		try {
			String saveURL;

			Map<String,String> nameToLabel = new Map<String,String>();
			List<Schema.DescribeSObjectResult> descResults = Schema.describeSObjects(new List<String>{cObjName});
			for (Schema.DescribeSObjectResult dsr : descResults) {
				saveURL = '/'+dsr.getKeyPrefix()+'/e?nooverride=1';
				Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
				for (String fieldName : fieldMap.keySet()) {
					if (namesToData.containsKey(fieldName)) {
						nameToLabel.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
					}
				}
			}

//System.debug('nameToLabel:'+ nameToLabel);
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'nameToLabel:'+ nameToLabel));

			Map<String,String> htmlToCFIDs = new Map<String,String>();

			PageReference savePageRef = new PageReference(saveURL);
			String content = savePageRef.getContent().toString();
			Pattern labelId = Pattern.compile('<label for="([^"]+)">(.+?)</label>');
			Matcher m = labelId.matcher(content);
			while (m.find()) {
				String stripPrependingNoise = (m.group(2).contains('>')) ? m.group(2).substringAfterLast('>') : m.group(2);
				htmlToCFIDs.put(stripPrependingNoise, m.group(1));
			}

			for (String key : nameToLabel.keySet()) {
				if (htmlToCFIDs.containsKey(nameToLabel.get(key))) namesToCFIDs.put(key, htmlToCFIDs.get(nameToLabel.get(key)));
			}

			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'htmlToCFIDs: '+String.valueOf(htmlToCFIDs)));
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'namesToCFIDs: '+String.valueOf(namesToCFIDs)));
		} catch (Exception e) {
			System.debug('Error trying to get CFIDs: '+e.getMessage());
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Error trying to get CFIDs: '+e.getMessage()));
		}

		return namesToCFIDs;
	}
}