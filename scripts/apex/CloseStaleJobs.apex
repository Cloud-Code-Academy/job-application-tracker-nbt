Job_Application__c jobApp = new Job_Application__c(
    Follow_up_date__c = System.today() - 31,
    Name = 'Test Job Application',
    Status__c = 'Applied'
);

insert jobApp;

StaleJobsHelper staleJobs = new StaleJobsHelper();
staleJobs.cleanupStaleJobApplications();