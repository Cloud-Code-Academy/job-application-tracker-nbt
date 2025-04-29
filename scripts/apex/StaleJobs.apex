StaleJobScheduler staleJob = new StaleJobScheduler();

Schedule email reminder to run once daily at 7AM
String sch = '0 0 7 * * ?';
System.schedule('Stale Job Cleanup - 7:00AM', sch, staleJob);

// String sch = '0 5 22 * * ?';
// System.schedule('Stale Job Cleanup - 10:05PM', sch, staleJob);