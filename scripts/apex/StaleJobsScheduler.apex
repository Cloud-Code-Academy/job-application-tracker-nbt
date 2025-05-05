StaleJobsSchedulable staleJobs = new StaleJobsSchedulable();

// Schedule stale job cleanup to run once daily at 7AM
String sch = '0 0 7 * * ?';
System.schedule('Stale Job Cleanup - 7:00AM', sch, staleJobs);