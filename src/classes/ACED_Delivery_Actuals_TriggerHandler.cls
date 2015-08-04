public class ACED_Delivery_Actuals_TriggerHandler {

    public static void DelDeliveryActualLinesOnDelivery(List < ACED_Delivery_Actuals__c > lDeliveryActuals) {

        List < ACED_Delivery_Actual_Line__c > lDeliveryActialLinesToBeDeleted = new List < ACED_Delivery_Actual_Line__c > ();
        for (ACED_Delivery_Actual_Line__c oDeliveryActualLine: [SELECT ID, Delivery_Actuals__c
                FROM ACED_Delivery_Actual_Line__c
                WHERE Delivery_Actuals__c in : lDeliveryActuals]
            ) {
            lDeliveryActialLinesToBeDeleted.add(oDeliveryActualLine);
        }
        Database.DeleteResult[] lDeleteResults = Database.Delete(lDeliveryActialLinesToBeDeleted, false);
        for (Integer i = 0; i < lDeleteResults.size(); i++) {
            if (!lDeleteResults.get(i).isSuccess()) {
                // DML operation failed
                lDeliveryActialLinesToBeDeleted[i].adderror(label.ACED_ErrorMessage); //failed record from the list
            }
        }
        // delete lDeliveryActialLinesToBeDeleted;
    }

    public static void UpsertAggregatedAssetActuals(List < ACED_Delivery_Actuals__c > lDeliveryActuals) {

        //Declaring a list of asset actuals to be upserted
        List < ACED_Asset_Actual__c > lAssetActuals = new List < ACED_Asset_Actual__c > ();

        Set < ID > sAssetIDs = new set < ID > ();
        Set < Id > delActIds = new Set < Id > ();
        for (ACED_Delivery_Actuals__c delAct: lDeliveryActuals) {
            delActIds.add(delACt.Id);
        }
        List < ACED_Delivery_Actuals__c > delActualsQueried = [Select Delivery__r.Activity__r.Assets__c from ACED_Delivery_Actuals__c where Id IN: delActIds];
        //Adding all assetID corresponding to actuals being edited to a Set
        for (ACED_Delivery_Actuals__c oDelAct: delActualsQueried) {
            if (oDelAct.Delivery__r.Activity__r.Assets__c <> null) {
                sAssetIDs.add(id.valueof(oDelAct.Delivery__r.Activity__r.Assets__c));
            }
        }

        for (AggregateResult oDeliveryAggregates: [Select Sum(Value__c) MonthlySum, Month__c Month, Delivery__r.Activity__r.Assets__c AssetIds, Delivery__r.Activity__r.program__r.Year__c year
                FROM ACED_Delivery_Actuals__c
                WHERE Delivery__r.Activity__r.Assets__c in : sAssetIDs
                GROUP BY Delivery__r.Activity__r.program__r.Year__c, Delivery__r.Activity__r.Assets__c, Month__c]) {
            if (oDeliveryAggregates.get('AssetIds') != null) {
                System.debug('!!!!' + oDeliveryAggregates);
                ACED_Asset_Actual__c oAssetActuals = new ACED_Asset_Actual__c();
                oAssetActuals.Asset__c = (Id) oDeliveryAggregates.get('AssetIds');
                oAssetActuals.Asset_Attribute_Upsert__c = (String) oDeliveryAggregates.get('AssetIds') + '-' + (String) oDeliveryAggregates.get('year') + '-' + (String) oDeliveryAggregates.get('Month');
                oAssetActuals.Value__c = (Decimal) oDeliveryAggregates.get('MonthlySum');
                oAssetActuals.Year__c = (String) oDeliveryAggregates.get('year');
                oAssetActuals.Month__c = (String) oDeliveryAggregates.get('Month');
                lAssetActuals.add(oAssetActuals);
            }
        }
        System.Debug('@@@@@@@@@@' + lAssetActuals.size());


        if (!lAssetActuals.isempty()) {
            Schema.SObjectField fUpsertfield = ACED_Asset_Actual__c.Asset_Attribute_Upsert__c;
            Database.UpsertResult[] lUpsertResults = Database.upsert(lAssetActuals, fUpsertfield, false);
            for (Integer i = 0; i < lUpsertResults.size(); i++) {
                if (!lUpsertResults.get(i).isSuccess()) {
                    // DML operation failed
                    lAssetActuals.get(i).adderror(label.ACED_ErrorMessage); //failed record from the list
                }
            }
        }
    }

    public static void DeleteAssetActualsonAsset(List < ACED_Delivery_Actuals__c > lDeliveryActuals) {
        Set < string > sAssetActualMonths = new Set < string > ();
        Set < string > sAssetActualYear = new Set < string > ();
        Set < ID > sAssetIDs = new Set < ID > ();
        Set < Id > delActIds = new Set < Id > ();

        for (ACED_Delivery_Actuals__c delAct: lDeliveryActuals) {
            delActIds.add(delACt.Id);
        }

        Map < ID, ACED_Delivery_Actuals__c > mDelMap = new Map < ID, ACED_Delivery_Actuals__c > ([SELECT id, Delivery__r.Activity__r.Assets__c, Delivery__r.Activity__r.program__r.Year__c
            FROM ACED_Delivery_Actuals__c WHERE id in : delActIds]);


        //Adding all assetID corresponding to actuals being edited to a Set
        for (ACED_Delivery_Actuals__c oDelAct: lDeliveryActuals) {
            sAssetActualMonths.add(oDelAct.Month__c);
            sAssetActualYear.add(mDelMap.get(oDelAct.ID).Delivery__r.Activity__r.program__r.Year__c);
            if (mDelMap.get(oDelAct.ID).Delivery__r.Activity__r.Assets__c <> null) {
                sAssetIDs.add(id.valueof(mDelMap.get(oDelAct.ID).Delivery__r.Activity__r.Assets__c));
            }
        }

        Map < string, ACED_Asset_Actual__c > mAssetMap = new Map < string, ACED_Asset_Actual__c > ();
        for (ACED_Asset_Actual__c oAssetAct: [SELECT id, value__c, year__c, month__c, Asset__c from ACED_Asset_Actual__c where Asset__c in : sAssetIDs AND Month__c in : sAssetActualMonths AND Year__c in : sAssetActualYear]) {
            mAssetMap.put(oAssetAct.Asset__c + '-' + oAssetAct.Month__c + '-' + oAssetAct.Year__c, oAssetAct);
        }

        System.Debug('@@@@@@@@@@' + mAssetMap);

        for (ACED_Delivery_Actuals__c oDelAct: lDeliveryActuals) {
            System.Debug('@@@@@@@@@@' + mDelMap.get(oDelAct.ID).Delivery__r.Activity__r.Assets__c + '-' + oDelAct.Month__c + '-' + mDelMap.get(oDelAct.id).Delivery__r.Activity__r.program__r.Year__c);
            if (mAssetMap.containsKey(mDelMap.get(oDelAct.ID).Delivery__r.Activity__r.Assets__c + '-' + oDelAct.Month__c + '-' + mDelMap.get(oDelAct.id).Delivery__r.Activity__r.program__r.Year__c)) {
                ACED_Asset_Actual__c oAstAct = mAssetMap.get(mDelMap.get(oDelAct.ID).Delivery__r.Activity__r.Assets__c + '-' + oDelAct.Month__c + '-' + mDelMap.get(oDelAct.id).Delivery__r.Activity__r.program__r.Year__c);
                oAstAct.Value__c = oAstAct.Value__c - oDelAct.Value__c;
                System.Debug('@@@@@@@@@@' + mAssetMap.size());
                mAssetMap.put(mDelMap.get(oDelAct.ID).Delivery__r.Activity__r.Assets__c + '-' + oDelAct.Month__c + '-' + mDelMap.get(oDelAct.id).Delivery__r.Activity__r.program__r.Year__c, oAstAct);
            }
        }
        System.Debug('@@@@@@@@@@' + mAssetMap.size());

        System.Debug('@@@@@@@@@@' + mAssetMap.values());

        List < ACED_Asset_Actual__c > lAssetAct = mAssetMap.values();
        List < ACED_Asset_Actual__c > lAssetActToBeDeleted = new List < ACED_Asset_Actual__c > ();
        List < ACED_Asset_Actual__c > lAssetActToBeUpdated = new List < ACED_Asset_Actual__c > ();

        If(lAssetAct.size() > 0) {
            for (ACED_Asset_Actual__c oAstAct: lAssetAct) {
                If(oAstAct.Value__c == 0) {
                    lAssetActToBeDeleted.add(oAstAct);
                } else {
                    lAssetActToBeUpdated.add(oAstAct);
                }
            }
        }
        System.Debug('@@@@@@@@@@' + lAssetActToBeDeleted.size());
        System.Debug('!!!!!!!!!!' + lAssetActToBeUpdated.size());
        System.Debug('##########' + lAssetAct.size());

        If(lAssetActToBeDeleted.size() > 0) {
            delete lAssetActToBeDeleted;
        }
        If(lAssetActToBeUpdated.size() > 0) {
            update lAssetActToBeUpdated;
        }
    }
    public static void DeleteDeliveryIndicationActual(List < ACED_Delivery_Actuals__c > lDeliveryActuals) {
    
        Set < Id > delActIds = new Set < Id > ();
        Set < String > delMonVar = new Set <String> ();
        List <ACED_Delivery_Indication_Actuals__c> delIndActs = new List < ACED_Delivery_Indication_Actuals__c > ();
        system.debug('##lDeliveryActuals'+lDeliveryActuals);
        if (lDeliveryActuals.size() > 0) {
        for (ACED_Delivery_Actuals__c delAct: lDeliveryActuals) {
            delActIds.add(delAct.Delivery__c);
            delMonVar.add(delAct.Delivery__c+'-'+delAct.Month__c);
        }
        
        for (ACED_Delivery_Indication_Actuals__c delIndActuals:[Select id,Delivery_Indication__r.Delivery__c,Month__c from ACED_Delivery_Indication_Actuals__c 
        where Delivery_Indication__r.Delivery__c IN: delActIds]) {
            for(String delMonStr:delMonVar){
              if(delMonStr==(delIndActuals.Delivery_Indication__r.Delivery__c+'-'+delIndActuals.Month__c)){
              delIndActs.add(delIndActuals);
              }
            }
        }
        if(delIndActs!=null){
         delete delIndActs;
        }
       }     
    }
}