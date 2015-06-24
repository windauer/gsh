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

declare function local:immediate-successor($territory) {
    let $successor-ids := $territory//successor
    let $successors := gsh:order-territories-chronologically(gsh:territories($successor-ids))
    let $immediate-successor := $successors[1]
    return
        $immediate-successor
};

declare function local:crawl-predecessors($territory) {
    $territory,
    let $immediate-predecessor := local:immediate-predecessor($territory)
    return
        if (not($immediate-predecessor)) then 
            ()
        else 
            local:crawl-predecessors($immediate-predecessor)
};

declare function local:crawl-successors($territory) {
    $territory,
    let $immediate-successor := local:immediate-successor($territory)
    return
        if (not($immediate-successor)) then 
            ()
        else 
            local:crawl-successors($immediate-successor)
};

declare function local:territory-sequence-to-tree($sequence) {
    let $head := head($sequence)
    return
        element ul {
            element li { 
                element a { 
                    attribute href { gsh:link-to-territory($head/id) }, 
                    gsh:territory-id-to-short-name-with-years-valid($head/id)
                    
                },
                if (not($sequence[2])) then 
                    ()
                else 
                    local:territory-sequence-to-tree(tail($sequence))
            }
        }
};

declare function local:predecessor-tree($territory) {
    element div {
        attribute class {'row tree'},
        element h3 { gsh:territory-id-to-short-name($territory/id) },
            try { 
                let $predecessors := local:crawl-predecessors($territory)
                let $successors := local:crawl-successors($territory)
                let $sequence := (reverse($predecessors), subsequence($successors, 2))
                return
                    local:territory-sequence-to-tree($sequence)
                } 
            catch * { 
                'Error generating tree' 
            }
    }
};

let $title := 'Predecessors'
let $content :=
    element div {
        for $territory in $gsh:territories[exists-on-todays-map = 'true']
        order by $territory/short-form-name
        return 
            local:predecessor-tree($territory)
    }
return
    gsh:wrap-html($content, $title)