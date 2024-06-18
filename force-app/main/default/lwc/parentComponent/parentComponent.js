import { LightningElement } from 'lwc';

export default class ParentComponent extends LightningElement {
    data;
    handledata(event){
        this.data = event.target.value;
        console.log('Data->',this.data);
    }
}