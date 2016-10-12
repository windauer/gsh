xquery version "3.1";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

for $territory in $gsh:territories/territory
return
    xmldb:rename(util:collection-name($territory), util:document-name($territory), $territory/id || ".xml")