xquery version "3.1";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

for $ref in $gsh:territories//(predecessor | successor)[. ne '']
let $new-id := $gsh:territories/territory[id = $ref]/new-id
(:where empty($new-id):)
return
(:    element test { element ref {$ref/string()}, element new-id {$new-id/string()} }:)
    update value $ref with $new-id/string()