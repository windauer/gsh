xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

declare function local:immediate-predecessor($territory) {
    let $predecessor-ids := $territory//predecessor
    let $predecessors := gsh:order-territories-chronologically(gsh:territories($predecessor-ids))
    let $immediate-predecessor := $predecessors[last()]
    return
        $immediate-predecessor
};

declare function local:predecessor-tree($territory) {
    let $predecessor := local:immediate-predecessor($territory)
    return
        (
        element territory {
            $territory/id,
            $territory/valid-since,
            $territory/valid-until,
            if ($predecessor) then 
                element immediate-predecessor {
                    $territory/valid-since = $predecessor/valid-until
                }
            else ()
        },
        if ($predecessor) then 
            local:predecessor-tree($predecessor)
        else ()
        )
};

declare function local:immediate-successor($territory) {
    let $successor-ids := $territory//successor
    let $successors := gsh:order-territories-chronologically(gsh:territories($successor-ids))
    let $immediate-successor := $successors[1]
    return
        $immediate-successor
};


declare function local:supplied-predecessors($territory) {
    let $territory-id := $territory/id
    let $predecessor-ids := $territory//predecessor
    let $ordered := gsh:order-territories-chronologically(gsh:territories(($territory-id, $predecessor-ids)))
    return $ordered !
        element territory {
            ./id,
            ./valid-since,
            ./valid-until
        }
};

let $territory-id := request:get-parameter('territory', 'korea-south')
let $territory := gsh:territories($territory-id)
return 
    local:immediate-predecessor($territory)