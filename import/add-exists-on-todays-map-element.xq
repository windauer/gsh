xquery version "3.0";

let $territories := doc('/db/territories.xml')//territory
for $territory in $territories
return
    update insert element exists-on-todays-map
        {
            if ($territory/valid-until eq '9999') then 
                'true'
            else if ($territory/valid-until ne '') then
                'false'
            else 
                ''
        } following $territory/valid-until