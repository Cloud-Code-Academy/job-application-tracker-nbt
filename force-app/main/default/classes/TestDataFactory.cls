public with sharing class TestDataFactory {

    public static List<Job_Application__c> createJobApplications(Integer numberOfJobApplications) {
        List<Job_Application__c> jobApps = new List<Job_Application__c>();

        for (Integer i = 0; i < numberOfJobApplications; i++) {
            jobApps.add(new Job_Application__c(
                Name = 'Null Salary ' + i,
                Salary__c = null
            ));
            jobApps.add(new Job_Application__c(
                Name = 'Zero Salary ' + i,
                Salary__c = 0
            ));
            jobApps.add(new Job_Application__c(
                Name = '$15,000 Salary ' + i,
                Salary__c = 15000
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

    public static List<Event> createEvents(Integer numberOfEvents) {
        List<Event> interviews = new List<Event>();
        Date tomorrow = Date.today().addDays(1);
        Datetime interviewStart = Datetime.newInstance(tomorrow, Time.newInstance(8, 0, 0, 0));

        for (Integer i = 0; i < numberOfEvents; i++) {
            interviews.add(new Event(
                Subject = 'Interview',
                StartDateTime = interviewStart,
                EndDateTime = interviewStart.addHours(1),
                Location = 'Zoom'
            ));
        }
        return interviews;
    }








}