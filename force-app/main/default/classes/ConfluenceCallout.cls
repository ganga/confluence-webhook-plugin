public class ConfluenceCallout implements Queueable, Database.AllowsCallouts {
    private Id recordId;
    private String pageId;

    public ConfluenceCallout(Id recordId, String pageId) {
        this.recordId = recordId;
        this.pageId = pageId;
    }

    public void execute(QueueableContext context) {
        String html = ConfluenceAPI.getPageHTML(pageId); 

        if (html != null) {
            Confluence_Event__c updateRec = new Confluence_Event__c(Id = recordId);
            updateRec.Page_Content__c = html;
            update updateRec;
        }
    }

    public static void fetchHTMLAsync(Id recordId, String pageId) {
        System.enqueueJob(new ConfluenceCallout(recordId, pageId));
    }
}
