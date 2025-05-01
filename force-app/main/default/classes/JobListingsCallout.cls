public with sharing class JobListingsCallout implements Queueable, Database.AllowsCallouts{
    //queable class to call the Post Job Listings method in a scheduled class
    public void execute(QueueableContext context) {
        postJobListings('Salesforce Developer', 'Canada');
 
     }
    //Callout to Jooble.org endpoint
    public static void postJobListings(String keywords,String location) {
        
        //set up HTTP Request
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:JoobleNameCred');
        request.setMethod('POST');
        request.setBody('{"keywords":"'+keywords+'","location":"'+location+'"}');
        
        //Send HTTP
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        //Check for success response code. If successful , update the Job Listing records with the Job ID
        if (response.getStatusCode()>= 200 && response.getStatusCode() <= 299) {      
            upsertJobListings(response.getBody());
        }
    }

    public static void upsertJobListings(String responseJson){
        //parse the json response
        Map<String,Object> desResponse = (Map<String,Object>)JSON.deserializeUntyped(responseJson);
        List<Object> objectList = (List<Object>)desResponse.get('jobs');
        List<Job_Application__c> existingApplications = [Select Jooble_Id__c from Job_Application__c where Jooble_Id__c != null];
        List<String> joobleIds = new List<String>();
        for ( Job_Application__c ja : existingApplications) {
             joobleIds.add(ja.Jooble_Id__c);
        }
        List<Job_Application__c> jobsToUpsert = new List<Job_Application__c>();
        //Loop through the object list and convert each object to a map, then convert that to a Job_Application__c object
        // Then add that Job_Application__c to the jobsToUpsert list
        for (Object o : objectList) {
            Map<String, Object> listItemMap = (Map<String, Object>)o;
            Job_Application__c j = new Job_Application__c();
            j.Position_Title__c = (String) listItemMap.get('title');
            j.Location__c = (String) listItemMap.get('location');
            j.Description__c = (String) listItemMap.get('snippet');
            j.Salary_Range__c = (String) listItemMap.get('salary');            
            j.URL__c = (String) listItemMap.get('link');            
            j.Company_Name__c = (String) listItemMap.get('company');
            Long id = (Long)listItemMap.get('id'); //Jooble Id is returned as a Long, but we want it to be a String to be used as an external ID
            String joobleId = id.format(); // Call Format() to convert the Long to a String
            j.Jooble_Id__c = joobleId.replace(',', ''); //remove commas that resulted from initial long data type 
            String name = j.Position_Title__c + ' - ' + j.company_name__c;
            j.name = name.left(80);
            //skip already existing jobs for status update
            if (!joobleIds.contains(j.Jooble_Id__c)) {
                j.Status__c = 'Saved';    
            }
            jobsToUpsert.add(j); //add job application to collection

        }
        jobsToUpsert = upsertAccounts(jobsToUpsert); //call to another function to upsert accounts
        upsert jobsToUpsert Jooble_Id__c;//upsert using jooble id as external id


    }

    public static List<Job_Application__c> upsertAccounts(List<Job_Application__c> newJobApplications){
        //Gather all company names, exclude duplicates
        List<String> companyNames = new List<String>();
        for (Job_Application__c ja : newJobApplications) {
            if (!companyNames.contains(ja.Company_Name__c)) {
                companyNames.add(ja.Company_Name__c);
            }
        }
        //query accounts by Account name
        List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE Name in :companyNames];
        Map<String, Id> companyNameToId = new Map<String, Id>();//Create name to ID map to add AccountIds to Job Applications to Upsert
        List<String> existingAccountNames = new List<String>();
        //add existing account names to a list to exclude from account insert
        for (Account a : existingAccounts) {
            if (!existingAccountNames.contains(a.Name)) {
                existingAccountNames.add(a.Name);
                companyNameToId.put(a.Name, a.Id);
            }
        }
        //add accounts to be inserted
        List<Account> accountsToInsert = new List<Account>();
        for (Job_Application__c ja2 : newJobApplications) {
            if (ja2.Company_Name__c != null && !existingAccountNames.contains(ja2.Company_Name__c)) {
                Account a = new Account();
                a.Name = ja2.Company_Name__c;
                accountsToInsert.add(a);
            }
        }
        insert accountsToInsert;
        //add Ids of inserted accounts to map
        for (Account acc : accountsToInsert) {
            companyNameToId.put(acc.Name, acc.Id);
        }
        //add accountIds to Job Application records in company account field
        for (Job_Application__c ja3 : newJobApplications) {
            ja3.Company_Account__c = companyNameToId.get(ja3.Company_Name__c);
        }

    
        return newJobApplications;
    }
}