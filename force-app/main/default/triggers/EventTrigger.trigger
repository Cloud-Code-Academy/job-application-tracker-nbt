trigger EventTrigger on EVENT (before insert, before update) {
    new EventTriggerHandler().run();
}
