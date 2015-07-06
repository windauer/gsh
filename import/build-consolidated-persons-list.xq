xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function local:get-person-entry($item) {
    let $person := $item
    let $vol-id := substring-before(util:document-name($person), '.xml')
    let $name-entry-nodes := $person/node()[not(self::tei:pb)]
    let $name := subsequence($name-entry-nodes, 1, 1)/node()[1]
    let $desc := subsequence($name-entry-nodes, 2)
    let $coverage := doc(concat('/db/cms/apps/volumes/data/', $vol-id, '.xml'))/volume/coverage
    let $source := concat($vol-id, '#', $name/@xml:id)
    return
        <person>
            <name>{normalize-space($name)}</name>
            <remarks>{
                for $remark at $n in tokenize(string-join($desc), ';')
                return
                    <remark source="{$source}" n="{$n}" not-before="{$coverage[1]}" not-after="{$coverage[2]}">{normalize-space($remark)}</remark>}</remarks>
        </person>
};

let $vols := collection('/db/cms/apps/tei-content/data/frus-volumes')
let $people-divs := $vols/id('persons')
let $people := $people-divs//tei:item
let $person-entries := 
    for $person in $people
    return 
        local:get-person-entry($person)
let $consolidated := 
    <persons sources="{count($people-divs)}">{
        for $entry in $person-entries
        group by $name := $entry/name
        order by $name
        return
            <person>
                {$name}
                <remarks sources="{count($entry)}">{
                    for $remark in $entry/remarks/remark
                    order by $remark/@not-before, $remark/@source, $remark/@n
                    return 
                        $remark
                }</remarks>
            </person>
    }</persons>
return 
    xmldb:store('/db', 'persons.xml', $consolidated)