xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

declare function local:crawl-predecessors($territory) {
    element ul {
        element li { 
            element a { 
                attribute href {'#'}, 
                gsh:territory-id-to-short-name-with-years-valid($territory/id)
                
            },
            let $immediate-predecessor := local:immediate-predecessor($territory)
            return
                if (not($immediate-predecessor)) then 
                    ()
                else 
                    local:crawl-predecessors($immediate-predecessor)
        }
    }
};

declare function local:immediate-predecessor($territory) {
    let $predecessor-ids := $territory//predecessor
    let $predecessors := gsh:order-territories-chronologically(gsh:territories($predecessor-ids))
    let $immediate-predecessor := $predecessors[last()]
    return
        $immediate-predecessor
};

let $title := 'Predecessors'
let $content :=
    element div {
        for $territory in subsequence($gsh:territories[exists-on-todays-map = 'true'], 1, 2)
        order by $territory/short-form-name
        return 
            element div {
                attribute class {'row tree'},
                element h3 { gsh:territory-id-to-short-name-with-years-valid($territory/id) },
                local:crawl-predecessors($territory)
            }
    }
return
    gsh:wrap-html($content, $title)