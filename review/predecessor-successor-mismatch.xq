xquery version "3.1";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

let $problems := 
    for $territory in $gsh:territories/territory
    let $predecessors := $territory/predecessors/predecessor ! gsh:territories(.)
    let $predecessor-problems := 
        for $t in $predecessors 
        return
            if ($territory/id = $t/successors/successor) then ()
            else $t/id
    let $successors := $territory/successors/successor ! gsh:territories(.)
    let $successor-problems := 
        for $t in $successors 
        return
            if ($territory/id = $t/predecessors/predecessor) then ()
            else $t/id
    return
        if ($predecessor-problems or $successor-problems) then
            (
                $predecessor-problems ! 
                    element problem {
                        element territory-id { ./string() },
                        element successor { $territory/id/string() },
                        element description { . || " should list " || $territory/id || " as a successor."}
                    },
                $successor-problems ! 
                    element problem {
                        element territory-id { ./string() },
                        element predecessor { $territory/id/string() },
                        element description { . || " should list " || $territory/id || " as a predecessor."}
                    }
            )
        else 
            ()
let $ordered-problems :=
    for $problem in $problems
    order by $problem/territory-id
    return $problem
return
    element problems {
        $ordered-problems
    }