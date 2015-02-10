xquery version "3.0";

let $territories := doc('/db/territories.xml')//territory
for $territory in $territories
let $new-predecessors :=
    for $predecessor in tokenize(normalize-space($territory/predecessors), ';\s*')[. ne '']
    return
        element predecessor {$predecessor}
let $new-successors :=
    for $successor in tokenize(normalize-space($territory/successors), ';\s*')[. ne '']
    return
        element successor {$successor}
return
    (
        update replace $territory/predecessors with element predecessors {$new-predecessors},
        update replace $territory/successors with element successors {$new-successors}
    )