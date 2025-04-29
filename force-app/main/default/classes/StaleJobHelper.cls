public with sharing class StaleJobHelper {

    public void cleanupStaleJobApplications() {
        Date thirtyDaysOld = Date.today().addDays(-30);
        List<Job_Application__c> jobApps = [SELECT Id, Status__c, Follow_up_date__c 
                                            FROM Job_Application__c 
                                            WHERE (Status__c != 'Closed' OR Status__c != 'Accepted')
                                            AND (Follow_up_date__c <= :thirtyDaysOld)];
        if (jobApps.isEmpty()) {
            System.debug('No stale jobs to cleanup');
            return;
        }
        List<Job_Application__c> jobAppsToCleanup = new List<Job_Application__c>();
        for (Job_Application__c job : jobApps) {
            job.Status__c = 'Closed';
            job.Notes__c = 'Job Application was closed by an automated process on ' + Datetime.now().format();
            jobAppsToCleanup.add(job);
        }
        try {
            update jobAppsToCleanup;
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}