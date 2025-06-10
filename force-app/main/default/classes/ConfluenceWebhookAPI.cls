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
            String pageContent = (String) content.get('pageContent');
            Confluence_Event__c eventRecord;

            // Try to find an existing record for this Page ID and Space Key
            List<Confluence_Event__c> existingRecords = [
                SELECT Id FROM Confluence_Event__c 
                WHERE Confluence_Page_Id__c = :pageId AND Space_Key__c = :spaceKey 
                LIMIT 1
            ];

            if (!existingRecords.isEmpty()) {
                // Update existing record
                eventRecord = existingRecords[0];
            } else {
                // Insert new record
                eventRecord = new Confluence_Event__c();
            }
            eventRecord.Event_Type__c = eventType;
            eventRecord.Confluence_Page_ID__c = pageId;
            eventRecord.Page_Title__c = title;
            eventRecord.Space_Key__c = spaceKey;
            eventRecord.Raw_JSON__c = body;
            eventRecord.Page_Content__c = pageContent;
            upsert eventRecord;
            
        } catch (Exception e) {
            System.debug('Webhook error: ' + e.getMessage());
            RestContext.response.statusCode = 400;
        }
    }
}
