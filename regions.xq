xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace counter="http://exist-db.org/xquery/counter" at "xmldb:exist://java:org.exist.xquery.modules.counter.CounterModule";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

declare function local:region-landing-page() {
    let $title := 'Regions'
    let $content :=
        element div {
            for $region in $gsh:regions
            let $region-id := $region/id
            let $territories-in-region := gsh:territories($gsh:regions[id = $region-id]/territory-id)
            return
                <div>
                    <h2>{concat($region/label, ': ', $region/description)}</h2>
                    <ol>
                        {$territories-in-region ! <li>{./short-form-name/string()}</li>}
                    </ol>
                </div>
        }
    return
        gsh:wrap-html($content, $title)
};

declare function local:show-region($region-id) {
    let $region := $gsh:regions[id = $region-id]
    let $territories-in-region := gsh:territories($gsh:regions[id = $region-id]/territory-id)
    let $title := concat($region/label, ': ', $region/description)
    let $content :=
        <div>
            <ol>
                {$territories-in-region ! <li>{./short-form-name/string()}</li>}
            </ol>
        </div>
    return
        gsh:wrap-html($content, $title)
};

let $region-id := request:get-parameter('region', ())
return
    if ($region-id) then 
        local:show-region($region-id)
    else
        local:region-landing-page()