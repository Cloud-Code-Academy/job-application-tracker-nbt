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
        upsert jobsToUpsert Jooble_Id__c;//upsert using jooble id as external id


    }
    

}