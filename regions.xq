xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace counter="http://exist-db.org/xquery/counter" at "xmldb:exist://java:org.exist.xquery.modules.counter.CounterModule";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

declare function local:landing-page-breadcrumbs() {
    <li><a href="{$gsh:regions-home}">Regions</a></li>
};

declare function local:region-breadcrumbs($region-id) {
    (
    local:landing-page-breadcrumbs(),
    <li><a href="{gsh:link-to-region($region-id)}">{gsh:region-id-to-label($region-id)}</a></li>
    )
};

declare function local:region-landing-page() {
    let $title := 'Regions'
    let $breadcrumbs := local:landing-page-breadcrumbs()
    let $content :=
        <div>
            { gsh:breadcrumbs($breadcrumbs) }
            <p>{count($gsh:regions)} regions.</p>
            <ol>{
                for $region in $gsh:regions
                let $region-id := $region/id
                let $territories-in-region := $gsh:regions[id = $region-id]/territory-id
                order by $region-id
                return
                    <li>
                        <a href="{gsh:link-to-region($region-id)}">{$region/label/string()}</a> ({$region/description/string()}; {count($territories-in-region)} territories.)
                    </li>
            }</ol>
        </div>
    return
        gsh:wrap-html($content, $title)
};

declare function local:show-region($region-id) {
    let $region := gsh:regions($region-id)
    let $territories-in-region := $region/territory-id
    let $title := $region/label
    let $breadcrumbs := local:region-breadcrumbs($region-id)
    let $content :=
        <div>
            { gsh:breadcrumbs($breadcrumbs) }
            <p>{$region/description/string()}; {count($territories-in-region)} territories on today's map.</p>
            <ol>
                {$territories-in-region ! <li><a href="{gsh:link-to-territory(.)}">{gsh:territory-id-to-short-name-with-years-valid(.)}</a></li>}
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