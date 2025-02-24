public with sharing class WarehouseCalloutService{
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    public static void runWarehouseEquipmentSync(){

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);  
        List<Product2> wareHouseEquipment = new List<Product2>();    

        if (response.getStatusCode() == 200){
            List<Object> jsonResponse = (List<Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('L14-response',response.getBody());            
            for (Object eq : jsonResponse){
                Map<String,Object> mapJson = (Map<String,Object>)eq;
                Product2 currEquipment = new Product2();

                currEquipment.Replacement_Part__c = (Boolean) mapJson.get('replacement');
                currEquipment.Name = (String) mapJson.get('name');
                currEquipment.Maintenance_Cycle__c = (Integer) mapJson.get('maintenanceperiod');
                currEquipment.Lifespan_Months__c = (Integer) mapJson.get('lifespan');
                currEquipment.Cost__c = (Decimal) mapJson.get('lifespan');
                currEquipment.Warehouse_SKU__c = (String) mapJson.get('sku');
                currEquipment.Current_Inventory__c = (Double) mapJson.get('quantity');
                
                wareHouseEquipment.add(currEquipment);
            }            

            if(wareHouseEquipment.size() > 0){
                upsert wareHouseEquipment;
                System.debug('Success', wareHouseEquipment);
            }            
        }
    }
}