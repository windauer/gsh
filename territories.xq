xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xql";

declare function local:territories-landing-page() {
    let $title := 'Territories'
    let $content := 
        element div {
            element p {
                concat('All ', count($gsh:territories), ' territories. View '), 
                <a href="all-territories.xq">full dataset</a>, ' on one page.'
            },
            element ul {
                for $territory in $gsh:territories
                order by $territory/id
                return
                    element li {
                        element a {
                            attribute href {
                                "territories.xq?territory=" || $territory/id
                            },
                            gsh:territory-id-to-short-name-with-years-valid($territory/id)
                        }
                    }
            }
        }
    return
        gsh:wrap-html($content, $title)
};

declare function local:show-territory($territory-id as xs:string) {
    let $territory := gsh:territories($territory-id)
    let $title := gsh:territory-id-to-short-name($territory-id)
    let $counter-name := concat($territory-id, '-issue')
    let $content :=
        <div>
            { gsh:territories-to-list($territory, $counter-name, true()) }
        </div>
    return
        gsh:wrap-html($content, $title)
};

let $territory-id := request:get-parameter('territory', ())
return  
    if ($territory-id) then 
        local:show-territory($territory-id)
    else
        local:territories-landing-page()