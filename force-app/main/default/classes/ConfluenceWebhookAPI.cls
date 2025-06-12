@RestResource(urlMapping='/confluence/webhook')
global without sharing class ConfluenceWebhookAPI {

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
            DateTime modifiedDate = parseModifiedDate((String) content.get('modifiedDate'));

            System.debug('Page ID: ' + pageId);
            System.debug('Space Key: ' + spaceKey);
            System.debug('Composite Key: ' + compositeKey);
            List<Confluence_Event__c> existingRecords = [
                    SELECT Id FROM Confluence_Event__c 
                    WHERE External_Confluence_Key__c = :compositeKey
                    LIMIT 1
            ];
            if (eventType == 'page_removed') {
                if (!existingRecords.isEmpty()) {
                    delete existingRecords;
                    System.debug('Deleted Confluence page record: ' + pageId);
                } else {
                    System.debug('No matching record found to delete for Page ID: ' + pageId);
                }
                return;
            } else {
                Confluence_Event__c eventRecord;
                System.debug('existing record id: ' + existingRecords);
                if (!existingRecords.isEmpty()) {
                    System.debug('existing record id: ' + existingRecords[0].Id);
                    eventRecord = existingRecords[0];
                    eventRecord.Event_Type__c = eventType;
                    eventRecord.Page_Title__c = title;
                    eventRecord.Raw_JSON__c = body;
                    eventRecord.Modified_Date__c = modifiedDate;
                    update eventRecord;
                } else {
                    System.debug('creating new record');
                    eventRecord = new Confluence_Event__c();
                    eventRecord.Confluence_Page_ID__c = pageId;
                    eventRecord.Space_Key__c = spaceKey;
                    eventRecord.External_Confluence_Key__c = compositeKey;
                    eventRecord.Event_Type__c = eventType;
                    eventRecord.Page_Title__c = title;
                    eventRecord.Raw_JSON__c = body;
                    eventRecord.Modified_Date__c = modifiedDate;
                    insert eventRecord;
                }
            }
        } catch (Exception e) {
            System.debug('Webhook error: ' + e.getMessage());
            RestContext.response.statusCode = 400;
        }
    }

    public static DateTime parseModifiedDate(String modifiedStr) {
        try {
            // Example input: 2025-06-11T23:56:27.3+0000
    
            // Step 1: Remove timezone offset (+0000 or +05:30, etc.)
            Integer plusIndex = modifiedStr.indexOf('+');
            if (plusIndex == -1) plusIndex = modifiedStr.indexOf('-'); // handle negative offset
            if (plusIndex > -1) {
                modifiedStr = modifiedStr.substring(0, plusIndex);
            }
    
            // Step 2: Remove milliseconds (after '.')
            if (modifiedStr.contains('.')) {
                modifiedStr = modifiedStr.substring(0, modifiedStr.indexOf('.'));
            }
    
            // Step 3: Replace 'T' with space
            modifiedStr = modifiedStr.replace('T', ' ');
    
            // Final format: yyyy-MM-dd HH:mm:ss
            return DateTime.valueOf(modifiedStr);
        } catch (Exception e) {
            System.debug('Date parse error: ' + e.getMessage());
            return null;
        }
    }
}
