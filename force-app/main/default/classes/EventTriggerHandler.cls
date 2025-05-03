public class EventTriggerHandler extends TriggerHandler{
    // Variables to store new and old versions of Event records and their maps by ID.
    private List<Event> newEvents;
    private Map<Id, Event> newEventMap;
    private List<Event> oldEvents;
    private Map<Id, Event> oldEventMap;

    // Initialize the new and old record lists and maps using Trigger.new, Trigger.old, and their corresponding maps.
    public EventTriggerHandler() {
        this.newEvents = (List<Event>) Trigger.new;
        this.newEventMap = (Map<Id, Event>) Trigger.newMap;
        this.oldEvents = (List<Event>) Trigger.old;
        this.oldEventMap = (Map<Id, Event>) Trigger.oldMap;
    }
    
    
    public override void beforeInsert() {
        EventValidationHelper.validateNoOverlappingEvents(this.newEvents, true);
    }

    public override void beforeUpdate() {
        EventValidationHelper.validateNoOverlappingEvents(this.newEvents, false);
    }

    
}