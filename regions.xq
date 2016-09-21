xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace counter="http://exist-db.org/xquery/counter" at "xmldb:exist://java:org.exist.xquery.modules.counter.CounterModule";
import module namespace th="http://history.state.gov/ns/xquery/territories-html" at "/db/apps/gsh/modules/territories-html.xqm";

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
            <p>{count($gsh:regions)} regions; {count($gsh:regions//territory-id)} territories listed.</p>
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
            <p>Also:</p>
            <ol>
                <li>
                    <a href="{$gsh:regions-home}/none">Territories not included in a region</a>
                </li>
            </ol>
        </div>
    return
        gsh:wrap-html($content, $title)
};

declare function local:show-territories-not-in-regions($view-all) {
    let $region-territories := $gsh:regions//territory-id
    let $current-territories := $gsh:territories[exists-on-todays-map = 'true']/id
    let $hits := $current-territories[not(. = $region-territories)]
    let $title := 'Territories not included in a region'
    let $breadcrumbs := 
        (
        local:landing-page-breadcrumbs(),
        <li><a href="{$gsh:regions-home}/none">{$title}</a></li>
        )
    let $content :=
        <div>
            { gsh:breadcrumbs($breadcrumbs) }
            <p>{count($hits)} territories on today's map. {if ($view-all) then <a href="?">View only territory names.</a> else <a href="?view-all=true">View full dataset.</a>}</p>
            <ol>
                {
                    for $hit in $hits
                    order by $hit/../short-form-name, $hit/../valid-since
                    return
                        <li><a href="{gsh:link-to-territory($hit)}">{gsh:territory-id-to-short-name-with-years-valid($hit)}</a></li>
                }
            </ol>
        </div>
    return
        gsh:wrap-html($content, $title)
    
};

declare function local:show-region($region-id, $view-all) {
    let $region := gsh:regions($region-id)
    let $territories-in-region := $region/territory-id
    let $title := $region/label
    let $breadcrumbs := local:region-breadcrumbs($region-id)
    let $content :=
        <div>
            { gsh:breadcrumbs($breadcrumbs) }
            <p>{$region/description/string()}; {count($territories-in-region)} territories on today's map. {if ($view-all) then <a href="?">View only territory names.</a> else <a href="?view-all=true">View full dataset.</a>}</p>
            <ol>
                {$territories-in-region ! <li><a href="{gsh:link-to-territory(.)}">{gsh:territory-id-to-short-name-with-years-valid(.)}</a></li>}
            </ol>
            {
            if ($view-all) then
                for $territory in gsh:territories($territories-in-region)
                let $territory-id := $territory/id
                let $counter-name := concat($territory-id, '-issue')
                order by $territory/short-form-name, $territory/valid-since
                return
                    <div>
                        <h3>{gsh:territory-id-to-short-name-with-years-valid($territory-id)}</h3>
                        <p>Lookup territories that <a href="{$gsh:territories-home}?mentions={$territory-id}">reference id "{$territory-id}"</a>.</p>
                        { gsh:territories-to-list($territory, $counter-name, true()) }
                        { (: th:ancestor-tree($territory) :) () }
                    </div>
            else ()
            }
        </div>
    return
        gsh:wrap-html($content, $title)
};

let $region-id := request:get-parameter('region', ())
let $view := xs:boolean(request:get-parameter('view-all', false()))
return
    if ($region-id) then 
        if ($region-id = 'none') then
            local:show-territories-not-in-regions($view)
        else
            local:show-region($region-id, $view)
    else
        local:region-landing-page()