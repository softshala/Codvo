import { LightningElement, api, track } from 'lwc';
import findDuplicates from '@salesforce/apex/MergeDuplicatesController.findDuplicates';
import mergeRecords from '@salesforce/apex/MergeDuplicatesController.mergeRecords';
import getFieldMetadata from '@salesforce/apex/MergeDuplicatesController.getFieldMetadata';

export default class DuplicateComponent extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track duplicates = [];
    @track duplicateOptions = [];
    @track selectedMasterId;
    @track selectedMergeId;
    @track mergeValues = {};
    @track fields = [];

    connectedCallback() {
        this.loadFieldMetadata();
        this.loadDuplicates();
    }

    loadFieldMetadata() {
        getFieldMetadata({ objectName: this.objectApiName })
            .then(result => {
                this.fields = result;
                result.forEach(field => {
                    this.mergeValues[field.apiName] = '';
                });
            })
            .catch(error => {
                console.error('Error fetching field metadata:', error);
            });
    }

    loadDuplicates() {
        findDuplicates({ currentRecordId: this.recordId, objectName: this.objectApiName })
            .then(result => {
                this.duplicates = result;
                this.updateDuplicateOptions();
            })
            .catch(error => {
                console.error('Error fetching duplicates:', error);
            });
    }

    updateDuplicateOptions() {
        this.duplicateOptions = this.duplicates.map(dup => ({
            label: `${dup.Name} (${dup.Email})`,
            value: dup.Id
        }));
    }

    handleMasterSelection(event) {
        this.selectedMasterId = event.detail.value;
        this.prepareMergeValues();
    }

    handleMergeSelection(event) {
        this.selectedMergeId = event.detail.value;
        this.prepareMergeValues();
    }

    prepareMergeValues() {
        const masterRecord = this.duplicates.find(rec => rec.Id === this.selectedMasterId);
        const mergeRecord = this.duplicates.find(rec => rec.Id === this.selectedMergeId);

        this.fields.forEach(field => {
            this.mergeValues[field.apiName] = masterRecord ? masterRecord[field.apiName] : '';
        });
    }

    handleFieldChange(event) {
        const { name, value } = event.target;
        this.mergeValues[name] = value;
    }

    handleMerge() {
        if (this.selectedMasterId && this.selectedMergeId) {
            mergeRecords({
                baseRecordId: this.selectedMasterId,
                mergeRecordId: this.selectedMergeId,
                mergeValues: JSON.stringify(this.mergeValues),
                objectName: this.objectApiName
            })
            .then(() => {
                this.dispatchEvent(new CustomEvent('recordsmerged'));
                this.loadDuplicates();  // Reload duplicates to reflect changes
            })
            .catch(error => {
                console.error('Error merging records:', error);
            });
        } else {
            alert('Please select both a master and a merge record.');
        }
    }
}
