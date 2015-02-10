xquery version "3.0";

let $pred-succ := distinct-values(//territories//(predecessor|successor)[. ne ''])
let $ids := //territory/id
let $results := $pred-succ[not(. = $ids)]
return
    <results count="{count($results)}">{
        for $x in $results
        order by $x
        return <name>{$x}</name>
    }</results>