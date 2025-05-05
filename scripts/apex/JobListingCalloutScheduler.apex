String sch = '0 0 7 * * ?';
System.schedule('Job Listing Callout - 7:00AM', sch, new JobListingCalloutSchedule());