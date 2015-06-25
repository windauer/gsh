xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace console="http://exist-db.org/xquery/console";

declare function local:has-reciprocal-relationship($source-id, $target-id, $relationship) {
    let $target := gsh:territories($target-id)
    let $is-reciprocal := $target//*[name() = $relationship][. = $source-id]
    return
        exists($is-reciprocal)
};

let $problems := 
    for $item in ($gsh:territories//precedessor, $gsh:territories//successor)
    let $source := $item/ancestor::territory/id
    let $target := $item
    let $asserted-relationship := $item/name()
    let $relationship-expected-at-target := if ($asserted-relationship = 'predecessor') then 'successor' else 'predecessor'
    order by $source
    return
        if (local:has-reciprocal-relationship($source, $target, $relationship-expected-at-target)) then 
            ()
    (:        <pass source="{$source}" target="{$target}" relationship="{$relationship-expected-at-target}"/>:)
        else
            <fail source="{$source}" target="{$target}" relationship="{$asserted-relationship}"/>
return
    element results {
        attribute count { count($problems) },
        $problems
        }