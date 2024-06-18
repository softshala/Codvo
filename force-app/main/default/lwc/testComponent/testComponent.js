import { LightningElement, track, api } from 'lwc';
import contactMethod from '@salesforce/apex/DataComponentController.contactMethod';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getdata from '@salesforce/apex/DataComponentController.getdata';
export default class TestComponent extends LightningElement {

    @api hello;
    accountsData;

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
    
    @track data = {
        Firstname: '',
        Lastname: '',
        Email: '',
        DOB: '',       // this.data[DOB] = event.target.value; // t@t.com
        Phone: ''
    };
    Firstname;

    handleChange(event) {  
        console.log('label is',event.target.label);
        const field = event.target.label; // field =  DOB
        this.data[field] = event.target.value; // this.data[DOB] = 2024-05-14
        console.log(`${field} =>`, this.data[field]);
        console.log(this.data);
    }

    async handleSubmit() {
        try {
            const result = await contactMethod({ contactData: this.data });
            console.log('Contact created:', result);
            if(result.Id != null){ // contact is created
                const toastmessage = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Contact is created & Id is:'+ result.Id,
                    variant: 'success',
                });
                this.dispatchEvent(toastmessage);
            }
            else{
                const toastmessage = new ShowToastEvent({
                    title: 'Error Is there!',
                    message: 'Contact is not created  ',
                    variant: 'error',
                });
                this.dispatchEvent(toastmessage);
            }

            
            
        } catch (error) {
            console.error('Error creating contact:', error);
        }
    }


    
}
