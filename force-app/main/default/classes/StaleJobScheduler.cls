public with sharing class StaleJobScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        new StaleJobHelper().cleanupStaleJobApplications();
    }
}