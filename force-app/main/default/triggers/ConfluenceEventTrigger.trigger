trigger ConfluenceEventTrigger on Confluence_Event__c (after insert, after update) {
    for (Confluence_Event__c e : Trigger.new) {
        Boolean isNew = Trigger.isInsert;
        Boolean isUpdated = Trigger.isUpdate && 
            (e.Confluence_Page_ID__c != Trigger.oldMap.get(e.Id).Confluence_Page_ID__c || 
             e.Page_Content__c == null);

        if ((isNew || isUpdated) && e.Confluence_Page_ID__c != null) {
            ConfluenceCallout.fetchHTMLAsync(e.Id, e.Confluence_Page_ID__c);
        }
    }
}