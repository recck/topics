#!/usr/bin/gawk -f
# Authors: Marcus Recck & Louis Shropshire
# Parse a file to search for a form
BEGIN {
    # initialize some variables
    form_count = 0
    inForm = 0
}

# if the line contains the opening of an HTML
# execute the following
$0 ~ /<form/ {
    inForm = 1
    cur_field = 0

    # find the method="..." portion of the form
    match($0, /method=['"]([a-zA-Z]+)['"]/, method)
    # find the action="..." portion of the form
    match($0, /action=['"]([^'"]+)['"]/, action)

    # if the method is empty we default to `get`, else use the method found
    form_info[form_count, "method"] = length(method[1]) > 0 ? tolower(method[1]) : "get"
    # if the action is empty we default to `default`, else use the action found
    # default is used in the bash script and knows to use the inputted file name
    form_info[form_count, "action"] = length(action[1]) > 0 ? tolower(action[1]) : "default"
}

# if we are in the middle of a form look for input fields
# containing name="..."
inForm == 1 && match($0, /name=['"]([a-zA-Z0-9_-]+)['"]/, pieces) {
    # store the name of the input field
    forms[form_count,cur_field] = pieces[1]
    cur_field++
}

# if we are the end of a form execute the following
$0 ~ /<\/form/ {
    # record the number of input fields in the form
    form_info[form_count, "values"] = cur_field;

    form_count++
    inForm = 0
}

END {
    # loop over the number of forms found
    for(i = 0; i < form_count; i++){
        # print the form action
        print form_info[i, "action"]
        # print the form method
        print form_info[i, "method"]

        # loop over the input fields
        for(j = 0; j < form_info[i, "values"]; j++){
            printf("%s", forms[i, j])
            if(j < form_info[i, "values"] - 1){
                printf("^~^")
            }
        }
        printf("\n")
    }
}