xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xql";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

let $table := gsh:locales-to-table($gsh:locales)
let $content := 
    <div>
        <p>All locales</p>
        { $table }
    </div>
let $title := 'Locales'
return
    gsh:wrap-html($content, $title)