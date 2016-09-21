xquery version "3.1";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace th="http://history.state.gov/ns/xquery/territories-html" at "/db/apps/gsh/modules/territories-html.xqm";

let $territory-id := 'russia'
let $territory := gsh:territories($territory-id)
return th:get-ancestors($territory)