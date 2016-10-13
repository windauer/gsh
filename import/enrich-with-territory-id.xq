xquery version "3.1";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

let $assignments := doc('/db/apps/gsh/data/assignments.xml')//assignment
let $territories := $assignments//territory
for $territory in $territories
let $match := $gsh:territories/territory[short-form-name = $territory and exists-on-todays-map eq 'true']/id
return
    element territory-id { $match/string() }
(:    if ($match) then update replace $territory with element territory-id { $match/string() } else ():)