#!/usr/bin/gawk -f
# Authors: Marcus Recck & Louis Shropshire
# Parse a file to search for a form
BEGIN {
    form_count = 0
    inForm = 0
}

$0 ~ /<form/ {
    inForm = 1
    cur_field = 0

    match($0, /method=['"]([a-zA-Z]+)['"]/, method)
    match($0, /action=['"]([^'"]+)['"]/, action)

    form_info[form_count, "method"] = length(method[1]) > 0 ? tolower(method[1]) : "get"
    form_info[form_count, "action"] = length(action[1]) > 0 ? tolower(action[1]) : "default"
}

inForm == 1 && match($0, /name=['"]([a-zA-Z0-9_-]+)['"]/, pieces) {
    forms[form_count,cur_field] = pieces[1]
    cur_field++
}

$0 ~ /<\/form/ {
    form_info[form_count, "values"] = cur_field;

    form_count++
    inForm = 0
}

END {
    for(i = 0; i < form_count; i++){
        print form_info[i, "action"]
        print form_info[i, "method"]
        for(j = 0; j < form_info[i, "values"]; j++){
            printf("%s", forms[i, j])
            if(j < form_info[i, "values"] - 1){
                printf("^~^")
            }
        }
        printf("\n")
    }
}