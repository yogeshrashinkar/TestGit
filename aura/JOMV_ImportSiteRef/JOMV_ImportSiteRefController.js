({
    doInit : function(component, event, helper) {
        helper.doInit(component);
        //Creating sample file
        // 1. Calling method "getSampleJSON()" and parsing it into JSON object.
        var jsonData = JSON.parse(helper.getSampleJSON());
        // 2. Setting parsed data in attribute "gridData".
        component.set("v.gridData",jsonData);
    },
    handleUpload : function(cmp, evt, helper){
        helper.readCSV(cmp);
    },
    handleImport: function(cmp, evt, helper){
        helper.handleImport(cmp);
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    // 2. Method to download Sample CSV file.
    downloadSampleCSV : function(component, event, helper) {
        helper.downloadSampleCSV(component, event, helper);
    }
})