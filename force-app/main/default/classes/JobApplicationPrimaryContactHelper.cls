public with sharing class JobApplicationPrimaryContactHelper {
    // Method to set Primary Contact
public static void setPrimaryContacts(List<Job_Application__c> jobApps) {
    Set<Id> jobAppIds = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();
    
    // If Primary contact is null, add job app Id's to the jobAppIds set
    for (Job_Application__c ja : jobApps) {
        if (ja.Primary_Contact__c == null) {
            jobAppIds.add(ja.Id);
            // If there is an account associated with the job app, add the account Id to the accountIds set
            if (ja.Company_Account__c != null) {
                accountIds.add(ja.Company_Account__c);
            }
        }
    }
    
    // Do nothing if the set of job app Id's is empty
    if (jobAppIds.isEmpty()) {
        return;
    }
    
    // Map to hold the Job application ID and list of contacts from the job application contacts junction object
    Map<Id, List<Contact>> jobAppContactsMap = new Map<Id, List<Contact>>();
    // Get the Job App Ids and the related contact ids from junction object for any job app Id in the set and loop through each one
    for (Job_Application_Contact__c jac : [
        SELECT Job_Application__c, Contact__c
        FROM Job_Application_Contact__c
        WHERE Job_Application__c IN :jobAppIds
        ORDER BY CreatedDate ASC
    ]) {
        // If the jobAppContactsMap doesn't have the current looped job app listed, then add it and a blank list of contacts to the map
        if (!jobAppContactsMap.containsKey(jac.Job_Application__c)) {
            jobAppContactsMap.put(jac.Job_Application__c, new List<Contact>());
        }
        // Add the Contact related to this record into the list for the matching Job Application in the map
        jobAppContactsMap.get(jac.Job_Application__c).add(jac.Contact__r);
    }
    
    // Map to hold account Id's and List of related contacts
    Map<Id, List<Contact>> accountContactsMap = new Map<Id, List<Contact>>();
    // If the set of accountIds is not empty, query the related contacts
    if (!accountIds.isEmpty()) {
        for (Contact c : [
            SELECT Id, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds
            ORDER BY CreatedDate ASC
        ]) {
            // If the account ID is not already in the map, add it to the map with a list of empty contacts
            if (!accountContactsMap.containsKey(c.AccountId)) {
                accountContactsMap.put(c.AccountId, new List<Contact>());
            }
            // Add the current contact to the list for its Account in the map
            accountContactsMap.get(c.AccountId).add(c);
        }
    }
    
    // Loop through each Job Application in the list. If the primary contact is empty then see if this Job App has any related contacts from the junction object.  If so, set the Primary Contact to first one on the list
    for (Job_Application__c ja : jobApps) {
        if (ja.Primary_Contact__c == null) {
            if (jobAppContactsMap.containsKey(ja.Id) && !jobAppContactsMap.get(ja.Id).isEmpty()) {
                ja.Primary_Contact__c = jobAppContactsMap.get(ja.Id).get(0).Id;
            }
            // Otherwise, if the Job Application has a related Account and that Account has any Contacts then set the primary contact to the first contact from that account
            else if (ja.Company_Account__c != null &&
                     accountContactsMap.containsKey(ja.Company_Account__c) &&
                     !accountContactsMap.get(ja.Company_Account__c).isEmpty()) {
                ja.Primary_Contact__c = accountContactsMap.get(ja.Company_Account__c).get(0).Id;
            }
        }
    }
}
}