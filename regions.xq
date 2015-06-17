xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xql";
import module namespace counter="http://exist-db.org/xquery/counter" at "xmldb:exist://java:org.exist.xquery.modules.counter.CounterModule";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

declare function local:countries-in-region($region as xs:string) {
    collection('/db/cms/apps/countries/data')/country[region = $region]
};

let $title := 'Regions'
let $region-id := request:get-parameter('region', ())
let $regions := doc('/db/cms/apps/countries/code-tables/region-codes.xml')//item
let $content :=
    element div {
        for $region in $regions
        let $region-id := $region/value
        let $countries-in-region := local:countries-in-region($region-id)
        let $territories-in-region := $gsh:territories[id = $countries-in-region/id]
        let $territories-missing-from-countries := $countries-in-region[not(id = $gsh:territories/id)]
        return
            <div>
                <h2>{upper-case($region/value)}: {$region/label/string()}</h2>
                <table>
                    <tr style="vertical-align: top">
                        <td>
                            <h3>Old data</h3>
                            <p>{count($countries-in-region)} entries from old "countries" data in this region</p>
                            <ol>
                                {$countries-in-region ! <li>{./label/string()}</li>}
                            </ol>
                        </td>
                        <td>
                            <h3>New data</h3>
                            <p>{count($territories-in-region)} territories corresponding to these entries</p>
                            <ol>
                                {$territories-in-region ! <li>{./short-form-name/string()}</li>}
                            </ol>
                            <p>{count($territories-missing-from-countries)} missing from old "countries" data</p>
                            <ol>
                                {$territories-missing-from-countries ! <li>{./label/string()}</li>}
                            </ol>
                        </td>
                        <td>
                            <h3>New data</h3>
                            <p>{count($territories-in-region)} territories corresponding to these entries</p>
                            <ol>
                                {
                                    for $territory in $territories-in-region
                                    let $predecessors := gsh:territories($territory//predecessor)
                                    return
                                        <li>{
                                            gsh:territory-id-to-short-name-with-years-valid($territory/id)
                                            ,
                                            if ($predecessors) then
                                                <ol>{
                                                    for $predecessor in gsh:order-territories-chronologically($predecessors)
                                                    return
                                                        <li>{gsh:territory-id-to-short-name-with-years-valid($predecessor/id)}</li>
                                                }</ol>
                                            else ()
                                            }
                                        </li>
                                }
                            </ol>
                        </td>
                    </tr>
                </table>
            </div>
    }
return
    gsh:wrap-html($content, $title)