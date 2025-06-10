import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Confluence_Event__c.Page_Title__c',
    'Confluence_Event__c.Page_Content__c'
];

export default class ConfluenceEventViewer extends LightningElement {
    @api recordId;
    pageTitle;
    pageContent;
    hasError = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.pageTitle = data.fields.Page_Title__c.value;
            this.pageContent = data.fields.Page_Content__c.value;
            this.hasError = false;
        } else if (error) {
            console.error(error);
            this.hasError = true;
        }
    }

    renderedCallback() {
        if (this.pageContent) {
            const container = this.template.querySelector('.confluence-html');
            if (container && container.innerHTML !== this.pageContent) {
                container.innerHTML = this.pageContent;
            }
        }
    }
}
