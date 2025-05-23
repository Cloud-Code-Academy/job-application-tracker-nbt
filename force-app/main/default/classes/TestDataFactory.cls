public with sharing class TestDataFactory {

    public static List<Job_Application__c> createJobApplications(Integer numberOfJobApplications) {
        List<Job_Application__c> jobApps = new List<Job_Application__c>();

        for (Integer i = 0; i < numberOfJobApplications; i++) {
            jobApps.add(new Job_Application__c(
                Name = 'Null Salary + Stale ' + i,
                Salary__c = null,
                Status__c = 'Saved',
                Application_Date__c = Date.today().addDays(-40),
                Follow_up_date__c = Date.today().addDays(-30)
            ));
            jobApps.add(new Job_Application__c(
                Name = 'Zero Salary + Fresh' + i,
                Salary__c = 0,
                Status__c = 'Saved',
                Application_Date__c = Date.today().addDays(-40),
                Follow_up_date__c = Date.today().addDays(-20)
            ));
            jobApps.add(new Job_Application__c(
                Name = '$15,000 Salary + Stale + Existing Notes' + i,
                Salary__c = 15000,
                Status__c = 'Saved',
                Application_Date__c = Date.today().addDays(-40),
                Follow_up_date__c = Date.today().addDays(-30),
                Notes__c = 'These notes better still be here after I get updated'
            ));
            jobApps.add(new Job_Application__c(
                Name = '$40,000 Salary ' + i,
                Salary__c = 40000
            ));
            jobApps.add(new Job_Application__c(
                Name = '$80,000 Salary ' + i,
                Salary__c = 80000
            ));
            jobApps.add(new Job_Application__c(
                Name = '$150,000 Salary ' + i,
                Salary__c = 150000
            ));
            jobApps.add(new Job_Application__c(
                Name = '$225,000 Salary ' + i,
                Salary__c = 225000
            ));
            jobApps.add(new Job_Application__c(
                Name = '$500,000 Salary ' + i,
                Salary__c = 500000
            ));
            jobApps.add(new Job_Application__c(
                Name = '$1,000,000 Salary ' + i,
                Salary__c = 1000000
            ));
        }
        return jobApps;
    }

    public static List<Account> createAccounts(Integer numberOfAccounts) {
        List<Account> testCompanies = new List<Account>();

        for (Integer i = 0; i < numberOfAccounts; i++) {
            testCompanies.add(new Account(
                Name = 'Vandelay Industries' + i
            ));
        }
        return testCompanies;
    }

    public static List<Event> createEvents(Integer numberOfEvents, List<Account> testAccounts) {
        List<Account> testCompanies = testAccounts;

        List<Event> interviews = new List<Event>();
        Date tomorrow = Date.today().addDays(1);
        Datetime interviewStart = Datetime.newInstance(tomorrow, Time.newInstance(8, 0, 0, 0));

        for (Integer i = 0; i < numberOfEvents; i++) {
            // Email should be created
            interviews.add(new Event(
                Subject = 'Interview',
                StartDateTime = interviewStart,
                EndDateTime = interviewStart.addHours(1),
                Company__c = testCompanies[0].Id,
                Location = 'Zoom'
            ));
            // Email shouldn't be created
            interviews.add(new Event(
                Subject = 'Interview',
                StartDateTime = interviewStart.addDays(1),
                EndDateTime = interviewStart.addDays(1).addHours(1),
                Location = 'Zoom'
            ));
            // Email shouldn't be created
            interviews.add(new Event(
                Subject = 'Meeting',
                StartDateTime = interviewStart,
                EndDateTime = interviewStart.addHours(1),
                Location = 'Zoom'
            ));
        }
        return interviews;
    }
}