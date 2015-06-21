xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

declare function local:countries-in-region($region as xs:string) {
    collection('/db/cms/apps/countries/data')/country[region = $region]
};

let $counter-name := 'issue'
let $counter := (counter:destroy($counter-name), counter:create($counter-name, 100))
let $title := 'Territories by region'
let $regions := doc('/db/cms/apps/countries/code-tables/region-codes.xml')//item
let $ordered-regions := for $region in $regions order by $region/value return $region
let $content :=
    element div {
        for $region in $ordered-regions
        let $region-id := $region/value
        let $countries-in-region := local:countries-in-region($region-id)
        let $territories-in-region := $gsh:territories[id = $countries-in-region/id] 
        let $territories-missing-from-countries := $countries-in-region[not(id = $gsh:territories/id)]
        return
            <div style="page-break-after:always;">
                <h2>{upper-case($region/value)}: {$region/label/string()}</h2>
                <p>{count($territories-in-region)} territories on today's map</p>
                {
                    let $ordered-territories := for $territory in $territories-in-region order by $territory/id return $territory
                    for $territory at $n in $territories-in-region
                    let $predecessors := gsh:territories($territory//predecessor)
                    order by $territory/id
                    return
                        <div style="page-break-after:always;">
                            <h3>{$n}. {gsh:territory-id-to-short-name-with-years-valid($territory/id)}</h3>
                            { gsh:territories-to-list(($territory, reverse(gsh:order-territories-chronologically($predecessors))), $counter-name) }
                        </div>
                }
            </div>
    }
return
    gsh:wrap-html($content, $title)