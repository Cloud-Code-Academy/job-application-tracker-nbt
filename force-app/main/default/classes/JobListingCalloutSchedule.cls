public with sharing class JobListingCalloutSchedule implements Schedulable {
        public void execute (SchedulableContext sc) {
            System.enqueueJob(new JobListingsCallout()); // Call the execute method to enqueue a JobListingsCallout instance
        }
}