@isTest
private class EventValidationHelperTest {

    @isTest
    private static void validateNoOverlappingEvents_overlappingEventsNeedErrorMessage_expectErrorMessage() {
    // Create and insert initial event
    Event initialEvent = new Event(
        Subject = 'Initial Event',
        StartDateTime = DateTime.newInstance(2025, 5, 25, 11, 0, 0), 
        EndDateTime = DateTime.newInstance(2025, 5, 25, 12, 0, 0),
        OwnerId = UserInfo.getUserId()
        
    );
    insert initialEvent;

    // Attempt to create new overlapping events
    List<Event> newEvents = new List<Event> ();
        
        Event newEvent = new Event();
            newEvent.Subject = 'Overlap Event';
            newEvent.StartDateTime = DateTime.newInstance(2025, 5, 25, 11, 30, 0);
            newEvent.EndDateTime = DateTime.newInstance(2025, 5, 25, 12, 30, 0);
            newEvent.OwnerId = UserInfo.getUserId();
            newEvents.add(newEvent);
        
        Event newEvent2 = new Event();
            newEvent2.Subject = 'Another Overlap Event';
            newEvent2.StartDateTime = DateTime.newInstance(2025, 5, 25, 11, 45, 0);
            newEvent2.EndDateTime = DateTime.newInstance(2025, 5, 25, 13, 0, 0);
            newEvent2.OwnerId = UserInfo.getUserId();
            newEvents.add(newEvent2);
        
    
    Test.startTest();
    EventValidationHelper.validateNoOverlappingEvents(newEvents, true);
    Test.stopTest();

    System.AssertEquals(true, newEvents[0].hasErrors(), 'Expected validation error due to overlap');
    System.AssertEquals(true, newEvents[1].hasErrors(), 'Expected validation error due to overlap');
}

    @isTest
    private static void validateNoOverlappingEvents_noOverlappingEventsNeedErrorMessage_expectSuccess() {
    // Create and insert initial event
    Event initialEvent = new Event(
        Subject = 'Initial Event',
        StartDateTime = DateTime.newInstance(2025, 5, 25, 11, 0, 0), 
        EndDateTime = DateTime.newInstance(2025, 5, 25, 12, 0, 0),
        OwnerId = UserInfo.getUserId()
        
    );
    insert initialEvent;

    // Create new non-overlapping events
    List<Event> newEvents = new List<Event> ();
        
        Event newEvent = new Event();
            newEvent.Subject = 'Non-Overlap Event';
            newEvent.StartDateTime = DateTime.newInstance(2025, 5, 26, 11, 30, 0);
            newEvent.EndDateTime = DateTime.newInstance(2025, 5, 26, 12, 30, 0);
            newEvent.OwnerId = UserInfo.getUserId();
            newEvents.add(newEvent);
        
        Event newEvent2 = new Event();
            newEvent2.Subject = 'Another Non-Overlap Event';
            newEvent2.StartDateTime = DateTime.newInstance(2025, 5, 27, 11, 45, 0);
            newEvent2.EndDateTime = DateTime.newInstance(2025, 5, 27, 13, 0, 0);
            newEvent2.OwnerId = UserInfo.getUserId();
            newEvents.add(newEvent2);
        

    Test.startTest();
    EventValidationHelper.validateNoOverlappingEvents(newEvents, true);
    Test.stopTest();

    System.AssertEquals(true, !newEvents[0].hasErrors(), 'Expected no validation error due to overlap');
    System.AssertEquals(true, !newEvents[1].hasErrors(), 'Expected no validation error due to overlap');
    }

    @isTest
    private static void validateNoOverlappingEvents_oneOverlappingEventOtherOneNot_SplitOneErrorOneSuccess() {
    // Create and insert initial event
    Event initialEvent = new Event(
        Subject = 'Initial Event',
        StartDateTime = DateTime.newInstance(2025, 5, 25, 11, 0, 0), 
        EndDateTime = DateTime.newInstance(2025, 5, 25, 12, 0, 0),
        OwnerId = UserInfo.getUserId()
        
    );
    insert initialEvent;

    // Attempt to create new overlapping events
    List<Event> newEvents = new List<Event> ();
        
        Event newEvent = new Event();
            newEvent.Subject = 'Non-Overlap Event';
            newEvent.StartDateTime = DateTime.newInstance(2025, 5, 25, 11, 30, 0);
            newEvent.EndDateTime = DateTime.newInstance(2025, 5, 25, 12, 30, 0);
            newEvent.OwnerId = UserInfo.getUserId();
            newEvents.add(newEvent);
        
        Event newEvent2 = new Event();
            newEvent2.Subject = 'Another Non-Overlap Event';
            newEvent2.StartDateTime = DateTime.newInstance(2025, 5, 27, 11, 45, 0);
            newEvent2.EndDateTime = DateTime.newInstance(2025, 5, 27, 13, 0, 0);
            newEvent2.OwnerId = UserInfo.getUserId();
            newEvents.add(newEvent2);
        

    Test.startTest();
    EventValidationHelper.validateNoOverlappingEvents(newEvents, true);
    Test.stopTest();

    System.AssertEquals(true, newEvents[0].hasErrors(), 'Expected validation error due to overlap');
    System.AssertEquals(true, !newEvents[1].hasErrors(), 'Expected no validation error due to overlap');
   
    }

    @isTest
    private static void validateNoOverlappingEvents_noStartDateTime_expectSuccess() {
    // Create and insert initial event
    Event initialEvent = new Event(
        Subject = 'Initial Event',
        StartDateTime = DateTime.newInstance(2025, 5, 25, 11, 0, 0), 
        EndDateTime = DateTime.newInstance(2025, 5, 25, 12, 0, 0),
        OwnerId = UserInfo.getUserId()
        
    );
    insert initialEvent;

    // Attempt to create new overlapping events
    List<Event> newEvents = new List<Event> ();
        
        Event newEvent = new Event();
            newEvent.Subject = 'Non-Overlap Event';
            newEvent.EndDateTime = DateTime.newInstance(2025, 5, 25, 12, 0, 0);
            newEvent.OwnerId = UserInfo.getUserId();
            newEvents.add(newEvent);
        
        Event newEvent2 = new Event();
            newEvent2.Subject = 'Another Non-Overlap Event';
            newEvent2.EndDateTime = DateTime.newInstance(2025, 5, 27, 13, 0, 0);
            newEvent2.OwnerId = UserInfo.getUserId();
            newEvents.add(newEvent2);
        

    Test.startTest();
    EventValidationHelper.validateNoOverlappingEvents(newEvents, true);
    Test.stopTest();

    System.AssertEquals(true, !newEvents[0].hasErrors(), 'Expected no validation error due to overlap');
    System.AssertEquals(true, !newEvents[1].hasErrors(), 'Expected no validation error due to overlap');
   
    }
}