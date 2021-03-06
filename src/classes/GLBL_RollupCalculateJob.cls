/**
 * Copyright (c) 2013, Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Job recaculates a given rollup for all master records
 **/
public with sharing class GLBL_RollupCalculateJob 
	implements Database.Batchable<sObject>
{
	private Id lookupId;
	
	public GLBL_RollupCalculateJob(String lookupId)
	{
		this.lookupId = lookupId;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) 
	{
		// Query all the parent records as per the lookup definition
		return GLBL_RollupService.masterRecordsAsQueryLocator(lookupId);
	}
	
	public void execute(Database.BatchableContext BC, List<sObject> masterRecords)
	{
		// Update the master records as per the lookup definition
		GLBL_RollupService.updateMasterRollups(new Set<Id> { lookupId }, new Map<Id, Sobject>(masterRecords).keySet());
	}
	
	public void finish(Database.BatchableContext BC) 
	{
		// Clear the Job Id which was preventing another calculate job running while this one was running
		GLBL_RollupService.clearCalculateJobId(new Set<Id> { lookupId }); 
	}
}