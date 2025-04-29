public with sharing class StaleJobsSchedulable implements Schedulable {
    public void execute(SchedulableContext sc) {
        new StaleJobsHelper().cleanupStaleJobApplications();
    }
}