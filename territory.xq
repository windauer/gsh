xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xql";

let $territory-id := request:get-parameter('territory', ())
return  
    if (not($territory-id)) then 
        gsh:wrap-html(<div><p class="bg-warning">Missing territory parameter. <a href="territories.xq">Back to territories</a></p></div>, 'Territory')
    else
        
let $territory := gsh:territories($territory-id)
let $title := gsh:territory-id-to-short-name($territory-id)
let $counter-name := concat($territory-id, '-issue')
let $content :=
    <div>
        { gsh:territories-to-list($territory, $counter-name, true()) }
    </div>
return
    gsh:wrap-html($content, $title)