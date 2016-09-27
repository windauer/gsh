xquery version "3.1";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

let $problems := 
    for $territory in $gsh:territories/territory
    let $predecessors := $territory/predecessors/predecessor ! gsh:territories(.)
    let $predecessor-problems := 
        for $t in $predecessors
        return
            try {
                if ($territory/valid-since - $t/valid-until le 2) then ()
                else $t
            } catch * {
                $t
            }
    let $successors := $territory/successors/successor ! gsh:territories(.)
    let $successor-problems := 
        for $t in $successors
        return
            try {
                if ($t/valid-since - $territory/valid-until le 2) then ()
                else $t
            } catch * {
                $t
            }
    return
        if ($predecessor-problems or $successor-problems) then
            (
                $predecessor-problems ! 
                    element problem {
                        element predecessor { ./id/string() },
                        element successor { $territory/id/string() },
                        element description { ./id || " is valid until " || ./valid-until || ", but " || $territory/id || " is valid since " || $territory/valid-since || "." }
                    },
                $successor-problems ! 
                    element problem {
                        element predecessor { $territory/id/string() },
                        element successor { ./id/string() },
                        element description { $territory/id || " is valid until " || $territory/valid-until || ", but " || ./id || " is valid since " || ./valid-since || "." }
                    }
            )
        else 
            ()
let $ordered-problems :=
    for $problem in $problems
    order by $problem/predecessor, $problem/successor
    return $problem
return
    element problems {
        $ordered-problems
    }