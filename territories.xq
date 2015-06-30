xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace th="http://history.state.gov/ns/xquery/territories-html" at "/db/apps/gsh/modules/territories-html.xqm";

let $territory-id := request:get-parameter('territory', ())
let $mentions := request:get-parameter('mentions', ())
let $contains := request:get-parameter('contains', ())
return  
    if ($territory-id) then 
        th:show-territory($territory-id)
    else if ($mentions) then
        th:mentions($mentions)
    else if ($contains) then
        th:contains($contains)
    else
        th:territories-landing-page()