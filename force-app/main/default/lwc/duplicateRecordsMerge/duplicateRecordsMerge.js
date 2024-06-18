import { LightningElement, api, track,wire } from 'lwc';
import findDuplicates from '@salesforce/apex/MergeDuplicatesController.findDuplicates';
import getFieldMetadata from '@salesforce/apex/MergeDuplicatesController.getFieldMetadata'; // Fetch field metadata
import mergeSelectedFields from '@salesforce/apex/MergeDuplicatesController.mergeSelectedFields'; // Custom method for merging selected fields
import getRecordDetails from '@salesforce/apex/MergeDuplicatesController.getRecordDetails'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class DuplicateRecordsMerge extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track duplicates = [];
    @track columns = [];
    @track selectedMaster = null;
    @track selectedMerge = null;
    @track areBothRecordsSelected = false;
    @track fieldOptions = [];
    @track selectedMasterFields = [];
    @track selectedMergeFields = [];
    _wiredDuplicateResult;  // Private variable to store wired result

    @wire(findDuplicates, { currentRecordId: '$recordId', objectName: '$objectApiName' })
    wiredDuplicates(result) {
        this._wiredDuplicateResult = result;  // Storing the response for refresh
        if (result.data) {
            this.duplicates = result.data;
        } else if (result.error) {
            console.error('Error fetching duplicates:', result.error);
            this.showToast('Error', 'Failed to load duplicate records.', 'error');
        }
    }

   @wire(getRecordDetails, { objectName: '$objectApiName', recordId: '$recordId' })
    wiredMasterRecord({ error, data }) {
        if (data) {
            this.selectedMaster = data;
        } else if (error) {
            console.error('Error fetching master record details:', error);
            this.showToast('Error', 'Failed to load master record details.', 'error');
        }
    }

    @wire(getFieldMetadata, { objectName: '$objectApiName' })
    wiredFieldMetadata({ error, data }) {
        if (data) {
            this.columns = [
                {
                    label: 'Record ID',
                    fieldName: 'Id',
                    type: 'button',
                    typeAttributes: {
                        label: { fieldName: 'Id' },
                        name: 'view_details',
                        variant: 'base',
                        title: 'View Details'
                    }
                },
                ...data.map(field => ({
                    label: field.label,
                    fieldName: field.apiName,
                    type: 'text'
                }))
            ];
            this.columns.push({
                type: 'action',
                typeAttributes: { rowActions: this.getRowActions.bind(this) }
            });
            this.fieldOptions = data.map(field => ({
                label: field.label,
                value: field.apiName
            }));
        } else if (error) {
            console.error('Error fetching field metadata:', error);
            this.showToast('Error', 'Failed to fetch field metadata.', 'error');
        }
    }

    handleNext(){
        
    }


    navigateToRecordPage(recordId) {
         const url = `/lightning/r/${this.objectApiName}/${recordId}/view`;
        window.open(url, '_blank');
    }

    handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    switch (actionName) {
        // case 'set_master':
        //     this.selectedMaster = row;
        //     break;
        case 'set_merge':
            this.selectedMerge = row;
            break;
        case 'view_details':
            this.navigateToRecordPage(row.Id);
            break;
        default:
            console.log(`Unhandled action: ${actionName}`);
            break;
    }

    // After handling the action, update any reactive properties or UI elements
    this.updateSelectionState();
}
    updateSelectionState() {
        this.areBothRecordsSelected = this.selectedMaster && this.selectedMerge;
    }
    handleFieldChange(event) {
        this.selectedMergeFields = event.detail.value;  // Update the list of fields to be merged
    }
    

    handleMerge() {
        if (this.areBothRecordsSelected) {
            let fieldSelection = {};
            this.selectedMergeFields.forEach(field => {
                fieldSelection[field] = field;  // Mapping each merge field to itself
            });
    
            mergeSelectedFields({
                baseRecordId: this.selectedMaster.Id,
                mergeRecordId: this.selectedMerge.Id,
                objectName: this.objectApiName,
                fieldSelection: fieldSelection
            })
            .then(() => {
                this.dispatchEvent(new CustomEvent('recordsmerged'));
                this.resetSelections();
              //  this.loadDuplicates();
                this.showToast('Merge Request','Record Merged successfully','success')
                refreshApex(this._wiredDuplicateResult);
                setTimeout(()=>{
                    location.reload();
                },2500)
            })
            .catch(error => {
                this.showToast('Error','Error merging selected fields:','error')
                console.error('Error merging selected fields:', error);
            });
        } else {
            this.showToast('Error','Please select both a master and a merge record and appropriate fields.','error')
        }
    }
    
    

    resetSelections() {
        this.selectedMaster = null;
        this.selectedMerge = null;
        this.areBothRecordsSelected = false;
        this.selectedMasterFields = [];
        this.selectedMergeFields = [];
    }

    getRowActions(row, doneCallback) {
        const actions = [];
        if (row['Id']) {
           // actions.push({ label: 'Set as Master', name: 'set_master' });
            actions.push({ label: 'Set as Merge', name: 'set_merge' });
        }
        doneCallback(actions);
    }

    showToast(title, message, variant) {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
    });
    this.dispatchEvent(evt);
}

}