xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function local:get-term-entry($item) {
    let $term := $item
    let $vol-id := substring-before(util:document-name($term), '.xml')
    let $name-entry-nodes := $term/node()[not(self::tei:pb)]
    let $name := subsequence($name-entry-nodes, 1, 1)/node()[1]
    let $desc := subsequence($name-entry-nodes, 2)
    let $coverage := doc(concat('/db/cms/apps/volumes/data/', $vol-id, '.xml'))/volume/coverage
    let $source := concat($vol-id, '#', $name/@xml:id)
    return
        <term>
            <name>{normalize-space($name)}</name>
            <remarks>{
                for $remark at $n in tokenize(string-join($desc), ';')
                return
                    <remark source="{$source}" n="{$n}" not-before="{$coverage[1]}" not-after="{$coverage[2]}">{normalize-space($remark)}</remark>}</remarks>
        </term>
};

let $vols := collection('/db/cms/apps/tei-content/data/frus-volumes')
let $terms-divs := $vols/id('terms')
let $terms := $terms-divs//tei:item
let $term-entries := 
    for $term in $terms
    return 
        local:get-term-entry($term)
let $consolidated := 
    <terms sources="{count($terms-divs)}">{
        for $entry in $term-entries
        group by $name := $entry/name
        order by $name
        return
            <term>
                {$name}
                <remarks sources="{count($entry)}">{
                    for $remark in $entry/remarks/remark
                    order by $remark/@not-before, $remark/@source, $remark/@n
                    return 
                        $remark
                }</remarks>
            </term>
    }</terms>
return 
    xmldb:store('/db', 'terms.xml', $consolidated)