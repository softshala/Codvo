import { LightningElement } from 'lwc';

export default class DataBinding extends LightningElement {

    mapMarkers = [
        {
            location: {
                City: 'San Francisco',
                Country: 'USA',
                PostalCode: '94105',
                State: 'CA',
                Street: 'The Landmark @ One Market, Suite 300',
            },
            value: 'location001',
            title: 'The Landmark Building',
            description:
                'The Landmark is considered to be one of the city&#39;s most architecturally distinct and historic properties', //escape the apostrophe in the string using &#39;
            icon: 'standard:address',
        },
    ];

    Name;
    Email;

    handleClick(){
        console.log('Clicking on button');
    }

    handleChange(event){

        if(event.target.label == 'Name'){
            this.Name = event.target.value;
            console.log('this.Name->>', this.Name)
        }
        else if(event.target.label = 'Email'){
            this.Email = event.target.value;
            console.log('this.Email->>', this.Email)
        }

    }

}