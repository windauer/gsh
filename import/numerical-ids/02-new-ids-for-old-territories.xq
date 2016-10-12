xquery version "3.1";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

let $max-id := max($gsh:territories/territory/new-id)
let $territories := for $t in $gsh:territories/territory[exists-on-todays-map = 'false'] order by $t/id return $t
for $territory at $n in $territories
let $new-id := $max-id + $n
return 
(:    $new-id:)
    update insert <new-id>{$new-id}</new-id> following $territory/id
(:    update value $territory/new-id with $new-id:)