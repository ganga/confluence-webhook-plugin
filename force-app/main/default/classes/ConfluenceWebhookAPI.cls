@RestResource(urlMapping='/confluence/webhook')
global with sharing class ConfluenceWebhookAPI {

    @HttpPost
    global static void handleWebhook() {
        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();

        try {
            Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(body);
            String eventType = (String) data.get('event');
            Map<String, Object> content = (Map<String, Object>) data.get('content');
            String title = (String) content.get('title');
            String pageId = (String) content.get('id');
            String spaceKey = (String) ((Map<String, Object>) content.get('space')).get('key');
            String compositeKey = spaceKey + ':' + pageId;
            System.debug('Page ID: ' + pageId);
            System.debug('Space Key: ' + spaceKey);
            List<Confluence_Event__c> existingRecords = [
                SELECT Id FROM Confluence_Event__c 
                WHERE External_Confluence_Key__c = :compositeKey
                LIMIT 1
            ];

            if (!existingRecords.isEmpty()) {
                System.debug('existing record id: ' + existingRecords[0].Id);
                Confluence_Event__c eventRecord = existingRecords[0];
                eventRecord.Event_Type__c = eventType;
                eventRecord.Page_Title__c = title;
                eventRecord.Raw_JSON__c = body;
                update eventRecord;
            } else {
                eventRecord = new Confluence_Event__c();
                eventRecord.Confluence_Page_ID__c = pageId;
                eventRecord.Space_Key__c = spaceKey;
                eventRecord.External_Confluence_Key__c = compositeKey;
                eventRecord.Event_Type__c = eventType;
                eventRecord.Page_Title__c = title;
                eventRecord.Raw_JSON__c = body;
                insert eventRecord;
            }
        } catch (Exception e) {
            System.debug('Webhook error: ' + e.getMessage());
            RestContext.response.statusCode = 400;
        }
    }
}
