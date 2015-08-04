public with sharing class MERC_ApexProfiler {
	
	private Integer startAggQueries;
	private Integer startCallouts;
	private Integer startCPUTime;
	private Integer startDMLRows;
	private Integer startDMLStatements;
	private Integer startEmailInvocations;
	private Integer startFutureCalls;
	private Integer startHeapSize;
	private Integer startMobilePushApexCalls;
	private Integer startPicklistDescribes;
	private Integer startQueries;
	private Integer startQueryLocatorRows;
	private Integer startQueryRows;
	private Integer startQueueableJobs;
	private Integer startSOSLQueries;

	private Integer stopAggQueries;
	private Integer stopCallouts;
	private Integer stopCPUTime;
	private Integer stopDMLRows;
	private Integer stopDMLStatements;
	private Integer stopEmailInvocations;
	private Integer stopFutureCalls;
	private Integer stopHeapSize;
	private Integer stopMobilePushApexCalls;
	private Integer stopPicklistDescribes;
	private Integer stopQueries;
	private Integer stopQueryLocatorRows;
	private Integer stopQueryRows;
	private Integer stopQueueableJobs;
	private Integer stopSOSLQueries;

	public void startProfiling(){
		startAggQueries = Limits.getAggregateQueries();
		startCallouts = Limits.getCallouts();
		startCPUTime = Limits.getCpuTime();
		startDMLRows = Limits.getDMLRows();
		startDMLStatements = Limits.getDMLStatements();
		startEmailInvocations = Limits.getEmailInvocations();
		startFutureCalls = Limits.getFutureCalls();
		startHeapSize = Limits.getHeapSize();
		startMobilePushApexCalls = Limits.getMobilePushApexCalls();
		startQueries = Limits.getQueries();
		startQueryLocatorRows = Limits.getQueryLocatorRows();
		startQueryRows = Limits.getQueryRows();
		startQueueableJobs = Limits.getQueueableJobs();
		startSOSLQueries = Limits.getSoslQueries();
	}

	public void stopProfiling(){
		stopAggQueries = Limits.getAggregateQueries();
		stopCallouts = Limits.getCallouts();
		stopCPUTime = Limits.getCpuTime();
		stopDMLRows = Limits.getDMLRows();
		stopDMLStatements = Limits.getDMLStatements();
		stopEmailInvocations = Limits.getEmailInvocations();
		stopFutureCalls = Limits.getFutureCalls();
		stopHeapSize = Limits.getHeapSize();
		stopMobilePushApexCalls = Limits.getMobilePushApexCalls();
		stopQueries = Limits.getQueries();
		stopQueryLocatorRows = Limits.getQueryLocatorRows();
		stopQueryRows = Limits.getQueryRows();
		stopQueueableJobs = Limits.getQueueableJobs();
		stopSOSLQueries = Limits.getSoslQueries();
	}

	public void debugUsage(){
		String output = '\n\n----------------PROFILING INFO----------------\n';
		output += '\tAggregate Queries Used: ' + (stopAggQueries - startAggQueries) + '\n';
		output += '\tCallouts Used: ' + (stopCallouts - startCallouts) + '\n';
		output += '\tCPU Time Used: ' + (stopCPUTime - startCPUTime) + '\n';
		output += '\tDML Rows Used: ' + (stopDMLRows - startDMLRows) + '\n';
		output += '\tDML Statements Used: ' + (stopDMLStatements - startDMLStatements) + '\n';
		output += '\tEmail Invocations Used: ' + (stopEmailInvocations - startEmailInvocations) + '\n';
		output += '\tFuture Calls Used: ' + (stopFutureCalls - startFutureCalls) + '\n';
		output += '\tHeap Size Used: ' + (stopHeapSize - startHeapSize) + '\n';
		output += '\tMobile Push Apex Calls Used: ' + (stopMobilePushApexCalls - startMobilePushApexCalls) + '\n';
		output += '\tQueries Used: ' + (stopQueries - startQueries) + '\n';
		output += '\tQuery Locator Rows Used: ' + (stopQueryLocatorRows - startQueryLocatorRows) + '\n';
		output += '\tQuery Rows Used: ' + (stopQueryRows - startQueryRows) + '\n';
		output += '\tQueueable Jobs Used: ' + (stopQueueableJobs - startQueueableJobs) + '\n';
		output += '\tSOSL Queries Used: ' + (stopSOSLQueries - startSOSLQueries) + '\n';
		output += '----------------------------------------------\n\n';
		System.debug(output);
	}

}