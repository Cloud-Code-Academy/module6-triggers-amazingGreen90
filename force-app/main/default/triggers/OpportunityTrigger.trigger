/*
* Opportunity trigger should do the following:
* 1. Validate that the amount is greater than 5000.
* 2. Prevent the deletion of a closed won opportunity for a banking account.
* 3. Set the primary contact on the opportunity to the contact with the title of CEO.
*/
trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after update){
    if(Trigger.isUpdate){
        for (Opportunity opp : Trigger.new) {
            if (opp.Amount <= 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }
    if(Trigger.isBefore && Trigger.isDelete){
        Set<Id> accountIds = new Set<Id>(); 
        for (Opportunity opp : Trigger.old){
            accountIds.add(opp.AccountId);
        }
        Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN :accountIds]);
        for (Opportunity opp : Trigger.old){
            Account a = accountsMap.get(opp.AccountId);
            if (opp.StageName == 'Closed Won' && a.Industry == 'Banking'){
                opp.addError('Cannot delete closed opportunity for a banking account that is won');
                }
        }
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
    Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.new) {
            accountIds.add(opp.AccountId);
        }
    Map<Id, Contact> accountCEOContacts = new Map<Id, Contact>();
        for (Contact contact : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO']) {
            accountCEOContacts.put(contact.AccountId, contact);
        }
        for (Opportunity opp : Trigger.new) {
            Contact CEOContact = accountCEOContacts.get(opp.AccountId);
            if (CEOContact != null) {
                opp.Primary_Contact__c = CEOContact.Id;
            }
        }
    }
}