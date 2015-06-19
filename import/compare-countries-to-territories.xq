xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xql";

declare function local:order($entries) {
    for $entry in $entries
    order by $entry
    return
        $entry
};
let $countries := collection('/db/cms/apps/countries/data')/country
let $territories := $gsh:territories
let $overlap := $countries[id = $territories/id]/id
let $countries-not-in-territories := $countries[not(id = $territories/id)]/id
let $territories-not-in-countries := $territories[not(id = $countries/id)]/id
return
    element results {
        element overlapping { local:order($overlap) },
        element countries-not-in-territories { local:order($countries-not-in-territories) },
        element territories-not-in-countries { local:order($territories-not-in-countries) }
    }