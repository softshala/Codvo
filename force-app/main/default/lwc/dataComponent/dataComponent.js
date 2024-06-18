import { LightningElement } from 'lwc';

export default class DataComponent extends LightningElement {

    name = 'Shubham';
    data = 'Hello World';

    textChange(event){
        console.log(event.target.value);

    }

    
}