trigger ConfluenceEventTrigger on Confluence_Event__c (after insert, after update) {
    for (Confluence_Event__c e : Trigger.new) {
        System.debug('Page ID: ' + e.Confluence_Page_ID__c);
        System.debug('Trigger fired at ' + DateTime.now());
        Boolean isNew = Trigger.isInsert;
        Boolean isUpdated = Trigger.isUpdate && 
            (e.Modified_Date__c != Trigger.oldMap.get(e.Id).Modified_Date__c);
        if ((isNew || isUpdated) && e.Confluence_Page_ID__c != null) {
            System.debug('Trigger calling cllout ' +e.Id + ' ' + e.Confluence_Page_ID__c);
            ConfluenceCallout.fetchHTMLAsync(e.Id, e.Confluence_Page_ID__c);
        }
    }
}
