xquery version "3.0";

let $results := distinct-values(//territories//(predecessor|successor)[matches(., '^[A-Z]')])
return
    <results count="{count($results)}">{
        for $x in $results
        order by $x
        return <name>{$x}</name>
    }</results>