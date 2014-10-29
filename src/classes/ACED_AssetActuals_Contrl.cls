Public class ACED_AssetActuals_Contrl{


Public pagereference ACED_AssetActuals_Contrl(){
    try{
        ACED_Deliveries__c oDelivery = [SELECT id FROM ACED_Deliveries__c WHERE Standalone_asset__c= :ApexPages.currentPage().getParameters().get('id') order by createddate desc limit 1];
        PageReference pDelivery = new PageReference('/apex/ACED_DeliveryActuals?id='+oDelivery.Id);
        pDelivery.setRedirect(true);
        return pDelivery;
    }catch(exception ex){
        ApexPages.addMessages(ex);
        return null;
    }

}


}