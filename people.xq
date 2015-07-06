xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace th="http://history.state.gov/ns/xquery/territories-html" at "/db/apps/gsh/modules/territories-html.xqm";
import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

declare function local:people-list($people, $show-descriptions) {
    element ul {
        for $person in $people
        let $name := $person/name
        let $remarks := $person//remark
        order by lower-case($person/name) collation "?lang=en-US"
        return 
            element li {
                $name/string()
                ,
                if ($show-descriptions and $remarks) then
                    element ul {
                        for $remark in distinct-values($remarks)
                        return
                            element li {$remark}
                    }
                else ()
            }
    }
};

let $show-descriptions := xs:boolean(request:get-parameter('show-descriptions', ()))
let $people := collection('/db/apps/gsh/data/people')/persons/person[name ne '']
let $content :=
    <div>
        <p>{count($people)} people. {if ($show-descriptions) then <a href="?">Hide descriptions.</a> else <a href="?show-descriptions=true">Show descriptions.</a> }</p>
        {local:people-list($people, $show-descriptions)}
    </div>
return
    gsh:wrap-html($content, 'People')