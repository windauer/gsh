xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

let $counter-name := 'issue'
let $counter := (counter:destroy($counter-name), counter:create($counter-name, 100))
let $title := 'Territories by region'
let $ordered-regions := for $region in collection('/db/apps/gsh/data/regions')/region order by $region/label return $region
let $content :=
    element div {
        for $region in $ordered-regions
        let $region-id := $region/id
        let $territories-in-region := $region//territory-id
        return
            <div style="page-break-after:always;">
                <h2>{upper-case($region/id)}: {$region/label/string()}</h2>
                <p>{count($territories-in-region)} territories on today's map</p>
                {
                    let $ordered-territories := for $t in gsh:territories($territories-in-region) order by $t/short-form-name return $t
                    for $territory at $n in $ordered-territories
                    let $predecessors := gsh:territories($territory//predecessor)
                    return
                        <div style="page-break-after:always;">
                            <h3>{$n}. {gsh:territory-id-to-short-name-with-years-valid($territory/id)}</h3>
                            { gsh:territories-to-list(($territory, reverse(gsh:order-territories-chronologically($predecessors))), $counter-name, false()) }
                        </div>
                }
            </div>
    }
return
    gsh:wrap-html($content, $title)