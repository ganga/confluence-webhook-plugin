public with sharing class ConfluenceEventController {
    @AuraEnabled(cacheable=true)
    public static Confluence_Event__c getEvent(Id recordId) {
        return [
            SELECT Page_Title__c, Event_Type__c, Space_Key__c, Page_Content__c
            FROM Confluence_Event__c
            WHERE Id = :recordId
            LIMIT 1
        ];
    }
}
