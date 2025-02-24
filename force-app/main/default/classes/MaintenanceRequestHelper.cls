public with sharing class MaintenanceRequestHelper {
    public static void updateworkOrders(List<Case> updateWorkOrders, Map<Id,Case> nonupdateCase) {
        Set<Id> validcaseIds = new Set<Id>();  
        For (Case case : updateWorkOrders){
            if (nonupdateCase.get(case.Id).Status != 'Closed' && case.Status == 'Closed'){
                if (case.Type == 'Repair' || case.Type == 'Routine Maintenance'){
                    validcaseIds.add(c.Id);                   
               }
            }
        }  

        if (!validcaseIds.isEmpty()){
            List<Case> newlistCases = new List<Case>();
            Map<Id,Case> closedCasesMap = new Map<Id,Case>([
				SELECT Id, 
					   Vehicle__c, 
                       Equipment__c, 
                       Equipment__r.Maintenance_Cycle__c,
		    		   (SELECT Id,Equipment__c,Quantity__c FROM Equipment_Maintenance_Items__r) 
            	FROM Case 
				WHERE Id IN :validcaseIds
            ]);

            Map<Id,Decimal> caseMaintenance = new Map<ID,Decimal>();

            AggregateResult[] results = [
                SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)cycle
                FROM Equipment_Maintenance_Item__c 
                WHERE Maintenance_Request__c IN :ValidcaseIds 
                GROUP BY Maintenance_Request__c
			];
        
        for (AggregateResult aggResult : results){ 
            caseMaintenance.put((Id) aggResult.get('Maintenance_Request__c'), (Decimal) aggResult.get('cycle'));
        }            
            for(Case closedCase : closedCasesMap.values()){
                Case newCase = new Case (
                    ParentId = closedCase.Id,
                    Status = 'New',
                    Subject = 'Routine Maintenance',
                    Type = 'Routine Maintenance',
                    Vehicle__c = closedCase.Vehicle__c,
                    Equipment__c =closedCase.Equipment__c,
                    Origin = 'Web',
                    Date_Reported__c = Date.Today()
                    
                );                
                If (caseMaintenance.containskey(closedCase.Id)){
                    newCase.Date_Due__c = Date.today().addDays((Integer) caseMaintenance.get(closedCase.Id));
                }                
                newlistCases.add(newCase);
            }            
           insert newlistCases;   
          
           List<Equipment_Maintenance_Item__c> clonedEMIs = new List<Equipment_Maintenance_Item__c>();
           for (Case newCase : newlistCases){
                for (Equipment_Maintenance_Item__c emi : closedCasesMap.get(newCase.ParentId).Equipment_Maintenance_Items__r){
                    Equipment_Maintenance_Item__c emiClone = emi.clone();
                    emiClone.Maintenance_Request__c = newCase.Id;
                    clonedEMIs.add(emiClone);                    
                }
            }
            insert clonedEMIs;
        }
    }
}