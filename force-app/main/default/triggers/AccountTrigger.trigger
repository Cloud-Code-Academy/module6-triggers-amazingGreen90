/*
* Account trigger should do the following:
* 1. Set the account type to prospect.
* 2. Copy the shipping address to the billing address.
* 3. Set the account rating to hot.
* 4. Create a contact for each account inserted.
*/ 
trigger AccountTrigger on Account (before insert, after insert) {
    if(Trigger.isBefore & Trigger.isInsert){
        for(Account a : Trigger.new){
            if(a.Type == null){
                a.Type = 'Prospect';
            }
            if(a.ShippingStreet != null || a.ShippingCity != null || a.ShippingCountry != null || a.ShippingState != null || a.ShippingPostalCode != null){
                a.BillingCity = a.ShippingCity;
                a.BillingCountry = a.ShippingCountry;
                a.BillingState = a.ShippingState;
                a.BillingStreet = a.ShippingStreet;
                a.BillingPostalCode = a.ShippingPostalCode;
            }
            if(a.Phone != null & a.Website != null & a.Fax != null){
                a.Rating = 'Hot';
            }
        }
    }
List<Contact> contacts = new List<Contact>();
    if(Trigger.isAfter & Trigger.isInsert){
        for(Account acct : Trigger.new){
            Contact nCon = new Contact(
                LastName = 'DefaultContact',
                Email = 'default@email.com',
                AccountId = acct.Id
            );
            contacts.add(nCon);
        }
    }
    insert contacts;
}