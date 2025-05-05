public with sharing class StaleJobsHelper {

    public void cleanupStaleJobApplications() {
        // Query jobs that don't have a status of closed or accepted
        List<String> statuses = new List<String>{'Closed', 'Accepted'};
        // Query jobs that have a follow up date 30 days old or more
        Date thirtyDaysOld = Date.today().addDays(-30);
        List<Job_Application__c> jobApps = [SELECT Id, Status__c, Follow_up_date__c, Notes__c
                                            FROM Job_Application__c 
                                            WHERE (Status__c NOT IN :statuses)
                                            AND (Follow_up_date__c <= :thirtyDaysOld)];

        // If no stale jobs, end process
        if (jobApps.isEmpty()) {
            System.debug('No stale jobs to cleanup');
            return;
        }

        // Initialize list and string
        List<Job_Application__c> jobAppsToCleanup = new List<Job_Application__c>();
        String existingNotes = '';

        for (Job_Application__c job : jobApps) {
            job.Status__c = 'Closed';
            // If there are existing notes, add a line break after
            if (job.Notes__c != null) {
                existingNotes = job.Notes__c + '\n\n';
            }
            job.Notes__c = existingNotes + 'Job Application was closed by an automated process on ' + Datetime.now().format();
            jobAppsToCleanup.add(job);
        }
        try {
            update jobAppsToCleanup;
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}