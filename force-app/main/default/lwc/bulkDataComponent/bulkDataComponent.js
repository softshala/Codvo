import { LightningElement , wire, track } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import makeGetRequest from '@salesforce/apex/PostgridDataController.makeGetRequest';
export default class BulkDataComponent extends LightningElement {

    @track allEvents = [];  // Store all records
    @track events = [];     // Store records to display on the current page
    @track currentPage = 1;
    @track pageSize = 3;    // Records per page
    @track totalRecords = 0;
    @track totalPages = 0;
    subscription = {};
    error;

    handleExternal(){
		makeGetRequest()
		.then(result => {
			console.log('result',result);
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			console.log(error)
		})
	} 

    connectedCallback() {
        this.handleSubscribe();
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleSubscribe() {
        const messageCallback = (response) => {
            console.log('New message received: ', JSON.stringify(response));
            // Assuming data structure matches the Platform Event fields
            this.events.push(response.data.payload);
        };

        subscribe('/event/Postgrid_LWC_PE__e', -1, messageCallback).then(response => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    handleUnsubscribe() {
        unsubscribe(this.subscription, (response) => {
            console.log('Unsubscribed from: ', JSON.stringify(response.channel));
            this.subscription = {};
        });
    }
}