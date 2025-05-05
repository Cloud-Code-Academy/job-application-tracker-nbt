Job_Application__c ja = new Job_Application__c(
    follow_up_date__c = System.today() - 31,
    Name = 'Test Job Application',
    status__c = 'applied'
);

insert ja;

StaleJobsHelper s = new StaleJobsHelper();
s.cleanupStaleJobApplications();