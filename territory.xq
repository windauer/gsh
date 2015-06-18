xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xql";

let $territory-id := request:get-parameter('territory', ())
let $territory := gsh:territories($territory-id)
let $title := gsh:territory-id-to-short-name($territory-id)
let $predecessors := gsh:territories($territory//predecessor)
let $counter-name := concat($territory-id, '-issue')
let $counter := (counter:destroy($counter-name), counter:create($counter-name, 100))
let $content :=
    <div>
        { gsh:territories-to-list(($territory, reverse(gsh:order-territories-chronologically($predecessors))), $counter-name) }
    </div>
return
    gsh:wrap-html($content, $title)