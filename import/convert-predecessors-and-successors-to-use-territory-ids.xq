xquery version "3.0";

let $territories := doc('/db/territories.xml')//territory
for $pred-succ in $territories//(predecessor|successor)
return
    if ($pred-succ = $territories/short-form-name) then
        update value $pred-succ with $territories[short-form-name = $pred-succ]/id/string()
    else ()