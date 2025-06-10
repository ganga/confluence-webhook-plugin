public class ConfluenceAPI {
    public static String getPageHTML(String pageId) {
        String endpoint = '/rest/api/content/' + pageId + '?expand=body.storage';

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Confluence_Auth' + endpoint); // Named Credential required
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> body = (Map<String, Object>) result.get('body');
            Map<String, Object> storage = (Map<String, Object>) body.get('storage');
            return (String) storage.get('value');
        } else {
            System.debug('Confluence error: ' + res.getBody());
            return null;
        }
    }
}
