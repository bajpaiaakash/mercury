/**
 * @author Joseph Ferraro
 *
 * Generic controller for VF Pages that need to modify related lists via a unified UI
 */

global with sharing virtual class GLBL_GenericRelatedListController {

	public String clientHash { get; set; } //used to interact with dom elements
	public ApexPages.StandardSetController controller;
	String parentObjectAPIName;
	String childObjectAPIName;
	public String parentFieldAPIName;
	List<String> parentFields;
	List<String> childFields;
	List<String> recordTypeDeveloperNames;
	String orderChildrenBy;
	public Id parentId = ApexPages.currentPage().getParameters().get('id');

	public GLBL_GenericRelatedListController(
		ApexPages.StandardSetController controller,
		String parentObjectAPIName,
		String childObjectAPIName,
		String parentFieldAPIName,
		List<String> parentFields,
		List<String> childFields,
		List<String> recordTypeDeveloperNames) {
			this.controller 				= controller;
			this.parentObjectAPIName 		= parentObjectAPIName;
			this.parentFields 				= parentFields;
			this.childObjectAPIName 		= childObjectAPIName;
			this.childFields 				= childFields;
			this.parentFieldAPIName 		= parentFieldAPIName;
			this.orderChildrenBy 			= null;
			this.recordTypeDeveloperNames 	= recordTypeDeveloperNames;
	}

	public GLBL_GenericRelatedListController(
		ApexPages.StandardSetController controller,
		String parentObjectAPIName,
		String childObjectAPIName,
		String parentFieldAPIName,
		List<String> parentFields,
		List<String> childFields,
		String orderChildrenBy) {
			this.controller 			= controller;
			this.parentObjectAPIName 	= parentObjectAPIName;
			this.parentFields 			= parentFields;
			this.childObjectAPIName 	= childObjectAPIName;
			this.childFields 			= childFields;
			this.parentFieldAPIName 	= parentFieldAPIName;
			this.orderChildrenBy 		= orderChildrenBy;
	}

	protected String recordTypeDeveloperNameParam {
		get {
			return ApexPages.currentPage().getParameters().get('rtdn');
		}
	}

	public virtual PageReference add() {
		GenericSobjectWrapper newItem;
		if (recordTypeDeveloperNameParam != null) {
			String recordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = :recordTypeDeveloperNameParam].ID;
			newItem = new GenericSobjectWrapper(childObjectAPIName, recordTypeId);
			newItem.index = children.size()+1;
			List<GenericSobjectWrapper> addToList = childrenMap.get(recordTypeDeveloperNameParam);
			addToList.add(newItem);
			return null;
		} else {
			newItem = new GenericSobjectWrapper(childObjectAPIName);
			newItem.index = children.size()+1;
			children.add(newItem);
			return null;
		}
	}

	public virtual PageReference remove() {
		List<GenericSobjectWrapper> newChildList = new List<GenericSobjectWrapper>();
		List<Sobject> childrenToDelete = new List<Sobject>();
		List<GenericSobjectWrapper> childrenList;
		if (recordTypeDeveloperNameParam != null) {
			childrenList = childrenMap.get(recordTypeDeveloperNameParam);
		} else {
			childrenList = children;
		}
		for (GenericSobjectWrapper sow : childrenList) {
			if (sow.hash != clientHash) {
				newChildList.add(sow);
			}
			if (sow.hash == clientHash && sow.so.ID != null) {
				childrenToDelete.add(sow.so);
			}
		}
		delete childrenToDelete;
		if (recordTypeDeveloperNameParam != null) {
			childrenMap.put(recordTypeDeveloperNameParam, newChildList);
		} else {
			children = newChildList;
		}
		return null;
	}

	public virtual PageReference save() {
		try {
			//logic moved to doSave method so that controllers exetending this class can implement their
			//own try catch logic by overriding the save method.
			return doSave();
		} catch (Exception e) {
			ApexPages.addMessages(e);
			return null;
		}
	}

	public virtual PageReference doSave() {
		List<Sobject> childrenToInsert = new List<Sobject>();
		List<Sobject> childrenToUpdate = new List<Sobject>();
		List<GenericSobjectWrapper> childrenList;
		system.debug('>>> '+recordTypeDeveloperNameParam);
		if (recordTypeDeveloperNameParam != null) {
			childrenList = childrenMap.get(recordTypeDeveloperNameParam);
		} else {
			childrenList = children;
		}
		system.debug('>>> '+childrenList);
		for (GenericSobjectWrapper sow : childrenList) {
			system.debug('child so........ '+sow.so);
			if (sow.so.Id != null) {
				childrenToUpdate.add(sow.so);
			} else {
				sow.so.put(parentFieldAPIName, parentId);
				childrenToInsert.add(sow.so);
			}
		}
		system.debug('>>> '+childrenToInsert);
		system.debug('>>> '+childrenToUpdate);
		insert childrenToInsert;
		update childrenToUpdate;
		if (MERC_Util.getUrlParam('notify') == '1') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, MERC_Util.getUrlParam('msg')));
			return null;
		} else if (MERC_Util.getUrlParam('retNull') == '1') {
			return null;
		} else {
			return new PageReference('/'+parentId);
		}
	}


	//empty form method for ajax
	public PageReference goToServer() {
		return null;
	}

	public Sobject parent {
		get {
			if (parent == null) {
				String fieldString = String.join(parentFields, ',');
				parent = Database.query('Select '+fieldString+' From '+parentObjectAPIName+' Where Id = \''+ApexPages.currentPage().getParameters().get('id')+'\'');
			}
			return parent;
		}
		private set;
	}

	public Map<String, List<GenericSobjectWrapper>> childrenMap {
		get {
			if (childrenMap == null) {
				childrenMap = new Map<String, List<GenericSobjectWrapper>>();
				Set<String> childFieldSet = new Set<String>();
				childFieldSet.addAll(childFields);
				if (!childFieldSet.contains('RecordTypeId')) {
					childFields.add('RecordTypeId');
				}
				if (!childFieldSet.contains('RecordType.DeveloperName')) {
					childFields.add('RecordType.DeveloperName');
				}
				String fieldString = String.join(childFields, ',');
				Integer i = 1;
				String query = getSOQLQuery(fieldString, childObjectAPIName, parentFieldAPIName+' = \''+ApexPages.currentPage().getParameters().get('id'), orderChildrenBy);
				for (Sobject s : Database.query(query)) {
					if (childrenMap.containsKey((String)s.getSObject('RecordType').get('DeveloperName'))) {
						List<GenericSobjectWrapper> children = childrenMap.get((String)s.getSObject('RecordType').get('DeveloperName'));
						GenericSobjectWrapper child = new GenericSobjectWrapper(childObjectAPIName, s);
						children.add(child);
						child.index = i;
						childrenMap.put((String)s.getSObject('RecordType').get('DeveloperName'), children);
					} else {
						List<GenericSobjectWrapper> children = new List<GenericSobjectWrapper>();
						GenericSobjectWrapper child = new GenericSobjectWrapper(childObjectAPIName, s);
						children.add(child);
						child.index = i;
						childrenMap.put((String)s.getSObject('RecordType').get('DeveloperName'), children);
					}
					i++;
				}
			}
			return childrenMap;
		}
		set;
	}

	public List<GenericSobjectWrapper> children {
		get {
			if (children == null) {
				children = new List<GenericSobjectWrapper>();
				String fieldString = String.join(childFields, ',');
				Integer i = 1;
				String query = getSOQLQuery(fieldString, childObjectAPIName, parentFieldAPIName+' = \''+ApexPages.currentPage().getParameters().get('id'), orderChildrenBy);
				for (Sobject s : Database.query(query)) {
					GenericSobjectWrapper child = new GenericSobjectWrapper(childObjectAPIName, s);
					child.index = i;
					children.add(new GenericSobjectWrapper(childObjectAPIName, s));
					i++;
				}
			}
			return children;
		}
		set;
	}

	public String getSOQLQuery(String fieldString, String fromObject, String whereClause, String orderBy) {
		String soql;
		if (this.recordTypeDeveloperNames != null) {
			soql = 'Select '+fieldString+' From '+childObjectAPIName+' Where '+parentFieldAPIName+' = \''+ApexPages.currentPage().getParameters().get('id')+'\' AND RecordType.DeveloperName in :recordTypeDeveloperNames';
		} else {
			soql = 'Select '+fieldString+' From '+childObjectAPIName+' Where '+parentFieldAPIName+' = \''+ApexPages.currentPage().getParameters().get('id')+'\'';
		}
		if (orderBy != null) {
			soql = soql += ' order by '+orderBy;
		}
		return soql;
	}

	public virtual class GenericSobjectWrapper implements Comparable {
		public Sobject so { get; set; }
		public String hash { get; set; }
		public Integer index { get; set; }

		public GenericSobjectWrapper(String objectAPIName) {
			InitializeGenericSobjectWrapper(objectAPIName, null, null);
		}
		public GenericSobjectWrapper(String objectAPIName, ID recordTypeId) {
			InitializeGenericSobjectWrapper(objectAPIName, recordTypeId, null);
		}
		public GenericSobjectWrapper(String objectAPIName, Sobject so) {
			InitializeGenericSobjectWrapper(objectAPIName, null, so);
		}
		public GenericSobjectWrapper(Sobject genericObject) {
			this.so = genericObject;
			this.hash = MERC_Util.generateRandomString(10);
		}
		private void InitializeGenericSobjectWrapper(String objectAPIName, ID recordTypeId, Sobject so){
			Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectAPIName);
			if (so != null) {
				this.so = so;
			} else if (recordTypeId != null){
				this.so = objType.newSobject(recordTypeId, true);
			} else {
				this.so = objType.newSobject();
			}
			this.hash = MERC_Util.generateRandomString(10);
		}
		public Integer compareTo(Object compareTo) {
	        GenericSobjectWrapper item = (GenericSobjectWrapper) compareTo;
	        if (index == item.index) return 0;
	        if (index > item.index) return 1;
	        return -1;
	    }
	}
}