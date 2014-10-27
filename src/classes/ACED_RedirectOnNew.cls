Public with sharing class ACED_RedirectOnNew{
    ApexPages.StandardController sController; 
    public ACED_RedirectOnNew(ApexPages.StandardController controller) {
		sController = controller;  
    }
    
    public PageReference Redirect() {
        	schema.sobjecttype oDynamicObjectype = ((sobject)sController.getRecord()).getsObjectType();
            PageReference pRedirectObjectPageReference = new PageReference('/' + oDynamicObjectype.getDescribe().getKeyPrefix()+ '/e');
            Map<String, String> mPageParameters = pRedirectObjectPageReference.getParameters();
            mPageParameters.putAll(ACED_Redirect_Utility.createDefaultValues(pRedirectObjectPageReference,oDynamicObjectype));
            mPageParameters.put('nooverride', '1');
            mPageParameters.putall(ApexPages.currentPage().getParameters());
            if(mPageParameters.containskey('save_new'))
            	mPageParameters.remove('save_new');
            return pRedirectObjectPageReference;
    }



}