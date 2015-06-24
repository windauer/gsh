xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

declare function local:update-territory-id($current-id, $new-id) {
    let $all-territory-ids := $gsh:territories/id
    let $all-predecessors := $gsh:territories//predecessor
    let $all-successors := $gsh:territories//successor
    let $collision := $new-id = $all-territory-ids
    return
        if ($collision) then
            error(xs:QName('http://history.state.gov/ns/xquery/geospatialhistory/error'), concat($new-id, ' is already in use.'))
        else
            let $territory-id := gsh:territories($current-id)/id
            let $mentions := ($all-predecessors[. = $current-id], $all-successors[. = $current-id])
            return
                (
                update value $territory-id with $new-id,
                for $mention in $mentions
                return
                    update value $mention with $new-id
                )
};

local:update-territory-id('hawaii', 'hawaii-1948')