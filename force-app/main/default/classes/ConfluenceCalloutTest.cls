@IsTest
private class ConfluenceCalloutTest {

    // Mock response for the Confluence API
    private class MockConfluenceCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"body": {"storage": {"value": "<p>Mock Page Content</p>", "representation": "storage"}}}');
            return res;
        }
    }

    @IsTest
    static void testInsertTrigger() {
        Test.setMock(HttpCalloutMock.class, new MockConfluenceCallout());

        Confluence_Event__c evt = new Confluence_Event__c(
            Confluence_Page_ID__c = '123456',
            Event_Type__c = 'page_created',
            Page_Title__c = 'Test Page',
            Space_Key__c = 'TEST'
        );

        Test.startTest();
        insert evt;
        Test.stopTest();

        // Query back and verify HTML content is set
        Confluence_Event__c inserted = [SELECT Page_Content__c FROM Confluence_Event__c WHERE Id = :evt.Id];
        System.assert(inserted.Page_Content__c != null && inserted.Page_Content__c.contains('Mock Page Content'));
    }

    @IsTest
    static void testUpdateTrigger() {
        Test.setMock(HttpCalloutMock.class, new MockConfluenceCallout());

        Confluence_Event__c evt = new Confluence_Event__c(
            Confluence_Page_ID__c = '111111',
            Event_Type__c = 'page_created',
            Page_Title__c = 'Initial Page',
            Space_Key__c = 'INIT'
        );
        insert evt;

        // Update with new Page ID (to simulate update trigger firing)
        evt.Confluence_Page_ID__c = '999999';
        update evt;

        Test.stopTest();

        Confluence_Event__c updated = [SELECT Page_Content__c FROM Confluence_Event__c WHERE Id = :evt.Id];
        System.assert(updated.Page_Content__c != null && updated.Page_Content__c.contains('Mock Page Content'));
    }
}
