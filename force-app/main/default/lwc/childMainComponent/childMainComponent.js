import { LightningElement , api} from 'lwc';

export default class ChildMainComponent extends LightningElement {

    @api childdata;
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
    errorCallback(event){
        this.error = event.detail;


    }

   
    sendBack(){
        console.log('In send back');
        const newEvent = new CustomEvent("sendback", { 
            detail: {
                message1: "ball",
                message2: "Emine"
            }
        });
        this.dispatchEvent(newEvent);
    }
}
