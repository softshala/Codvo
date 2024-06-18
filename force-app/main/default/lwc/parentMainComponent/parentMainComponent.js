import { LightningElement } from 'lwc';

export default class ParentMainComponent extends LightningElement {
    message1;
    message2;

    constructor(){
        console.log();
        this.hello = 'data';
    }

    connectedCallback(){
        console.log('IN connected callback');
        this.accountsData = getdata();
        
    }

    renderedCallback(){
        this.data
    }
    disconnectedCallback(){
        const toastmessage = new ShowToastEvent({
            title: 'Close!',
            message: 'Clsoing the component',
            variant: 'Error',
        });

    }

    handleChildData(event) {
        this.message1 = event.detail.message1;
        this.message2 = event.detail.message2;
    }
}
