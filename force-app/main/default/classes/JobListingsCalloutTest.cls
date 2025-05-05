@IsTest
public with sharing class JobListingsCalloutTest {
    @IsTest
    static void jobListingsPostTest() {
        // Register the mock callout class
		Test.setMock(HttpCalloutMock.class, new JobListingsCalloutMock());
        Datetime currentTime = System.now();
        //create a job listing with the same Jooble_Id__c as to test whether integration will skip setting status field for updated records
        Job_Application__c oldJa = new Job_Application__c(
            name = 'Test Job Application',
            Position_Title__c = 'Salesforce Developer',
            Location__c = 'Canada',
            Jooble_Id__c = '7004741214002539643',
            status__c = 'Applied'
            ); 
        insert oldJa;
		// As this is a future method, we need to enclose it in Test.startTest() and Test.stopTest() to ensure it's executed in the test context.
		Test.startTest();
		JobListingsCallout.postJobListings('Salesforce Developer', 'Canada'); // Call the method with example Keywords and Location 
		Test.stopTest();
        
        //retrieve test job application records
        List<Job_Application__c> japplications = [SELECT Name,Id FROM Job_Application__c WHERE LastModifiedDate >= :currentTime];
        List<Job_Application__c> savedJobApplications = [SELECT Name,Id 
            FROM Job_Application__c WHERE LastModifiedDate >= :currentTime AND Status__c = 'Saved'];
        
        Assert.areEqual(3, japplications.size(),'Not the expected number of job applications');
        Assert.areEqual(2, savedJobApplications.size(),'Not the expected number of job applications');


    }
    @IsTest
    Static void jobListingCalloutScheduleTest (){
        //Set callout schedule time
        String CRON_EXP = '0 0 0 15 3 ? 2026';      

        Test.startTest();
        // Register the mock callout class
        test.setMock(HttpCalloutMock.class,  new JobListingsCalloutMock());
        //create scheduled job       
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new JobListingCalloutSchedule());
        Test.stopTest();
        //retrieve scheduled job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

        Assert.areEqual(CRON_EXP, ct.CronExpression,'The Cron Expression for the scheduled job does not match what was specified.');
    }
}