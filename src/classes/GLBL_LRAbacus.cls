public with sharing class GLBL_LRAbacus {

	public static Map<String, Decimal> calculate(List<Sobject> operands, Map<String, GLBL_LREngine.RollupOperation> field2Operation) {
		p('sliding bits around...');

		Map<String, Decimal> result = new Map<String, Decimal>();
		Decimal value;
		List<String> keys = new List<String>(field2Operation.keySet());  // make the for loop faster
		for (Integer i=0,j=keys.size(); i<j; i++) {
			String fieldName = keys.get(i);
			GLBL_LREngine.RollupOperation rollOp = field2Operation.get(fieldName);
			if (rollOp == GLBL_LREngine.RollupOperation.Sum) {
			    value = sum(fieldName,operands);
			    p('SUM='+value);
			} else if (rollOp == GLBL_LREngine.RollupOperation.Max) {
			    p('Max');
			    value = max(fieldName,operands);
			} else if (rollOp == GLBL_LREngine.RollupOperation.Min) {
			    p('Min');
			    value = min(fieldName,operands);
			} else if (rollOp == GLBL_LREngine.RollupOperation.Avg) {
			    p('Avg');
			    value = avg(fieldName,operands);
			} else if (rollOp == GLBL_LREngine.RollupOperation.Count) {
			    p('Count');
			    value = sum(fieldName,operands);
			} else {
			    p('n/a');
			}
			result.put(fieldName,value);
		}
		return result;
	}

	private static Decimal sum(String fieldName, List<Sobject> records) {

		p('SUMMING '+fieldName);
		Decimal sum;
		try {
			sum = 0;
			for (Integer i=0,j=records.size(); i<j; i++) {
				Sobject obj = records.get(i);
				sum += (Decimal) obj.get(fieldName);
			}
		} catch (Exception e) {
			System.debug(e);
		}
		return sum;
	}

	private static Decimal avg(String fieldName, List<Sobject> records){
		Decimal total = 0;
		Integer numRecords = records.size();

		for(Integer i = 0, j = numRecords; i < j; i++){
			total += (Decimal)records[i].get(fieldName);
		}

		return total/numRecords;
	}

	private static Decimal max(String fieldName, List<Sobject> records){
		Integer numRecords = records.size();
		List<Decimal> values = new Decimal[numRecords];

		for(Integer i = 0, j = numRecords; i < j; i++){
			values[i] = (Decimal)records[i].get(fieldName);
		}

		values.sort();

		return values[numRecords-1];
	}

	private static Decimal min(String fieldName, List<Sobject> records){
		Integer numRecords = records.size();
		List<Decimal> values = new Decimal[numRecords];

		for(Integer i = 0, j = numRecords; i < j; i++){
			values[i] = (Decimal)records[i].get(fieldName);
		}

		values.sort();

		return values[0];
	}

	private static Decimal count(String fieldName, List<Sobject> records){
		return records.size();
	}

	public static Map<String, Datetime> datetimeMuncher(List<Sobject> operands, Map<String, GLBL_LREngine.RollupOperation> field2Operation) {
		p('But what minutes! Count them by sensation, and not by calendars, and each moment is a day.');

		Map<String, Datetime> result = new Map<String, Datetime>();
		Decimal value;
		List<String> keys = new List<String>(field2Operation.keySet());  // make the for loop faster
		for (Integer i=0,j=keys.size(); i<j; i++) {
			GLBL_LREngine.RollupOperation rollOp = field2Operation.get(keys.get(i));
			if (rollOp == GLBL_LREngine.RollupOperation.Max) {
			    p('Max');
			} else if (rollOp == GLBL_LREngine.RollupOperation.Min) {
			    p('Min');
			} else if (rollOp == GLBL_LREngine.RollupOperation.Count) {
			    p('Count');
			} else {
			    p('n/a');
			}
		}
		return null;
	}

	static void p(String m) {
		System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
	}

	//public static Map<String, Decimal> calculateSlowly(List<Sobject> operands, Map<String, GLBL_LREngine.RollupOperation> field2Operation) {
	//	p('sliding bits around...');

	//	Map<String, Decimal> result = new Map<String, Decimal>();
	//	Decimal value;
	//	for (String fieldName : field2Operation.keySet()) {
	//		GLBL_LREngine.RollupOperation rollOp = field2Operation.get(fieldName);
	//		if (rollOp == GLBL_LREngine.RollupOperation.Sum) {
	//		    value = sum(fieldName,operands);
	//		    p('SUM='+value);
	//		} else if (rollOp == GLBL_LREngine.RollupOperation.Max) {
	//		    value = sum(fieldName,operands);
	//		} else if (rollOp == GLBL_LREngine.RollupOperation.Min) {
	//		    p('Min');
	//		    value = sum(fieldName,operands);
	//		} else if (rollOp == GLBL_LREngine.RollupOperation.Avg) {
	//		    p('Avg');
	//		    value = sum(fieldName,operands);
	//		} else if (rollOp == GLBL_LREngine.RollupOperation.Count) {
	//		    p('Count');
	//		    value = sum(fieldName,operands);
	//		} else {
	//		    p('n/a');
	//		}
	//		result.put(fieldName,value);
	//	}
	//	return result;
	//}

	//private static Decimal sumSlowley(String fieldName, List<Sobject> records) {
	//	Decimal sum;
	//	try {
	//		sum = 0;
	//		for (Sobject obj : records) {
	//			sum += (Decimal) obj.get(fieldName);
	//		}
	//	} catch (Exception e) {
	//		System.debug(e);
	//	}
	//	return sum;
	//}

	//public static Map<String, Datetime> datetimeMuncherSlowly(List<Sobject> operands, Map<String, GLBL_LREngine.RollupOperation> field2Operation) {
	//	p('But what minutes! Count them by sensation, and not by calendars, and each moment is a day.');

	//	Map<String, Datetime> result = new Map<String, Datetime>();
	//	Decimal value;
	//	for (String fieldName : field2Operation.keySet()) {
	//		GLBL_LREngine.RollupOperation rollOp = field2Operation.get(fieldName);
	//		if (rollOp == GLBL_LREngine.RollupOperation.Max) {
	//		    p('Max');
	//		} else if (rollOp == GLBL_LREngine.RollupOperation.Min) {
	//		    p('Min');
	//		} else if (rollOp == GLBL_LREngine.RollupOperation.Count) {
	//		    p('Count');
	//		} else {
	//		    p('n/a');
	//		}
	//	}
	//	return null;
	//}

}