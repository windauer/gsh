xquery version "3.0";

let $territories := doc('/db/territories.xml')//territory
for $territory in $territories
let $url-style-name := 
    replace(
        replace(
            replace(
                translate(lower-case(replace(
                    $territory/short-form-name, "The|['’]", '')), 'çô', 'co'),
                '[\s,\(\)\.]+', '-'), 
            '-+', '-'), 
        '-+$', '')
let $id := 
    if ($territory/valid-until ne '9999') then 
        concat($url-style-name, '-', if ($territory/valid-until eq '') then 'TBD' else $territory/valid-until)
    else 
        $url-style-name
order by $id
return
(:    update value $territory/id with $id:)
    $id