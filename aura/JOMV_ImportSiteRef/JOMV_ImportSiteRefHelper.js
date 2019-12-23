({
    doInit : function(component) {        
        var action = component.get("c.getUser");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){                 
                component.set("v.user", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    getSampleJSON : function(){
        // 3. Variable declaration and assigning value to show in component.
        var jsonStr = '{"rows":[{"vals":[{"val":"Sample Therapeutic Area"},{"val":"Sample Facility Department Name"},{"val":"First Name"},{"val":"Last Name"},{"val":"Country Name"},{"val":"Sample Name"},{"val":"Sample Trial"}]}],"headers":[{"title":"Therapeutic Area"},{"title":"Facility  Department Name"},{"title":"PI First Name"},{"title":"PI Last Name"},{"title":"Country"},{"title":"Name"},{"title":"Trial"}]}';
        return jsonStr;
    },
    readCSV : function(cmp) {
        var spinner = cmp.find("csvSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var fileInput = cmp.find("file").getElement();
        var file = fileInput.files[0];
        cmp.set('v.isImportsuccess',false);
        //alert(JSON.stringify(file));
        if(JSON.stringify(file)  === '{}'){
            if(file.type === 'application/vnd.ms-excel'){
                cmp.set("v.fileTypeError", false);
                var reader = new FileReader();
                reader.readAsText(file);
                reader.onload = loadHandler;
                reader.onerror = errorHandler;
            } else {
                cmp.set("v.fileTypeError", true);
                cmp.set("v.importLabel", 'Import Site References Now');
                cmp.set("v.isDisabled",true);
                $A.util.toggleClass(spinner, "slds-hide");
            }
            
            function loadHandler(event) {
                var csv = event.target.result;
                processData(csv);
            }
            
            function processData(csv) {
                var allLines = csv.split(/\r\n|\n/);
               // var header = 'No.,'+allLines[0];
                var header = 'No.,';
                var gridDataHeaders = cmp.get('v.gridData.headers');
                for(var i = 0; i < gridDataHeaders.length; i++){         
                    header += (i === (gridDataHeaders.length - 1)) ? gridDataHeaders[i]["title"] : gridDataHeaders[i]["title"] + ','; 
                }
                //cmp.set("v.headers",header.split(','));
                //console.log(header.split(','));
                var allHeaders = header.split(',');
                var headerCount = 0;
                var headersWithoutBlank ='No.'; 
                for(var i=1; i<allHeaders.length-2; i++){
                    console.log(allHeaders[i]);
                    if(allHeaders[i] !==""){
                        headersWithoutBlank = headersWithoutBlank + ','+ allHeaders[i];
                        headerCount++; 
                    }
                }
                cmp.set("v.headers",header.split(','));
                console.log('HeaderCount'+headerCount);
                //var headerCount = cmp.get("v.headers").length-2;
                var lines = [];
                //console.log(allLines.length);
                for (var i=1; i<allLines.length-1; i++) {
                    var data = allLines[i].split(',');
                    var tarr = [];
                    //console.log(data.length);
                    for (var j=0; j<data.length; j++) {
                        if(j < header.split(',').length -1 ){
                            tarr.push(data[j]);
                        } 
                    }
                    lines.push(tarr);
                }
                cmp.set("v.data", lines);
                cmp.set("v.importLabel", 'Import '+lines.length+' Site References Now');
                cmp.set("v.isDisabled",false);
                $A.util.toggleClass(spinner, "slds-hide");
            }
            
            function errorHandler(evt) {
                if(evt.target.error.name == "NotReadableError") {
                    alert("Canno't read file !");
                    cmp.set("v.isDisabled",true);
                }
            }  
        }else{
            alert('Please select csv file.');
            cmp.set("v.fileTypeError", true);
            cmp.set("v.importLabel", 'Import Site References Now');
            $A.util.toggleClass(spinner, "slds-hide");
            cmp.set("v.isDisabled",true);
        }        
    },
    handleImport: function(cmp, evt, helper) {
        var lines = cmp.get("v.data");
        console.log(lines.length);
        var action = cmp.get("c.importSiteReferences");
        action.setParams({
            data:lines
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){ 
                cmp.set("v.isImportsuccess",true);
                cmp.set("v.isDisabled",true);
                cmp.set("v.importLabel","Import Site References Now");
                let message = 'Data Import success';
                //alert('Data Import success..!');
                //alert(message); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"success",
                    "message": message
                });
                toastEvent.fire();
            }else{
                let errors = a.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                //alert(message);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"error",
                    "message": message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }, 
    downloadSampleCSV : function(component, event, helper) {
        // 3. Getting table data to download it in CSV.
        var gridData = component.get("v.gridData");
        // 4. Spliting headers form table.
        var gridDataHeaders = gridData["headers"];
        // 5. Spliting row form table.
        var gridDataRows = gridData["rows"];
        // 6. CSV download.
        var csv = '';
        for(var i = 0; i < gridDataHeaders.length; i++){         
            csv += (i === (gridDataHeaders.length - 1)) ? gridDataHeaders[i]["title"] : gridDataHeaders[i]["title"] + ','; 
        }
        csv += "\n";
        var data = [];
        for(var i = 0; i < gridDataRows.length; i++){
            var gridRowIns = gridDataRows[i];
            var gridRowInsVals = gridRowIns["vals"];
            var tempRow = [];
            for(var j = 0; j < gridRowInsVals.length; j++){                                     
                var tempValue = gridRowInsVals[j]["val"];
                if(tempValue.includes(',')){
                    tempValue = "\"" + tempValue + "\"";
                }
                tempValue = tempValue.replace(/(\r\n|\n|\r)/gm,"");                 
                tempRow.push(tempValue);
            }
            data.push(tempRow); 
        }
        data.forEach(function(row){
            csv += row.join(',');
            csv += "\n";
        });
        // 6. To download table in CSV format.
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_blank';
        hiddenElement.download = 'SampleSiteReferenceData'+'.csv'; 
        hiddenElement.click();
    }
})