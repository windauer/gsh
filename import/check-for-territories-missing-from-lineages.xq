xquery version "3.1";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

let $territories-with-lineage := doc('/db/apps/gsh/data/lineages.xml')//territory-id
let $territories-without-lineage := $gsh:territories/territory[not(id = $territories-with-lineage)]
return $territories-without-lineage
