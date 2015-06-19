xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xql";

declare function local:countries-in-region($region as xs:string) {
    collection('/db/cms/apps/countries/data')/country[region = $region]
};

(: doc('/db/apps/gsh/import/country-territory-mapping')//entry :)

let $regions := doc('/db/cms/apps/countries/code-tables/region-codes.xml')//item
for $region in $regions
let $region-id := $region/value
let $countries-in-region := local:countries-in-region($region-id)
let $territories-in-region := 
    (
    $gsh:territories[id = $countries-in-region/id]
    ,
    doc('/db/apps/gsh/import/country-territory-mapping')//territory-id[parent::entry/country-id = $countries-in-region/id] ! <id>{.}</id>
    )
let $data :=
    <region>
        <id>{$region-id/string()}</id>
        {
        for $territory in $territories-in-region
        order by $territory/id
        return
            <territory-id>{$territory/id/string()}</territory-id>}
    </region>
return
    xmldb:store('/db/apps/gsh/data/regions', concat($region-id, '.xml'), $data)