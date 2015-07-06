xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace dates = "http://xqdev.com/dateparser" at "/db/cms/modules/date-parser.xqm";

declare function local:get-date-candidate-field($div) {
    let $head := normalize-space(string-join($div/tei:head[1]/node()[not(./self::tei:note)]))
    let $source-note := string-join($div//tei:note[@type='source'])
    let $body := normalize-space(string-join($div/tei:head/following-sibling::node()))
    let $parsed-head := try { analyze-string($head, '[A-Z][a-z]+ \d{1,2}, \d{4}')//fn:match ! dates:parseDate(.)/string() } catch * {()}
    let $parsed-note := try { analyze-string($source-note, '[A-Z][a-z]+ \d{1,2}, \d{4}')//fn:match ! dates:parseDate(.)/string() } catch * {()}
    let $parsed-body := try { analyze-string($body, '[A-Z][a-z]+ \d{1,2}, \d{4}')//fn:match ! dates:parseDate(.)/string() } catch * {()}
    (: TODO / BUG? look into why following-sibling fails. the sibling axis would allow us to restrict search to same chapter, reduce false values from volumes with non-chronological chapters :)
    let $preceding := $div/preceding::tei:div[@type='document'][.//tei:dateline/tei:date/@when][1] ! (attribute doc-id {./@xml:id}, .//tei:dateline/tei:date/@when/string())
    let $following := $div/following::tei:div[@type='document'][.//tei:dateline/tei:date/@when][1] ! (attribute doc-id {./@xml:id}, .//tei:dateline/tei:date/@when/string())
    let $variance := 
        if (substring($preceding[2], 1, 10) castable as xs:date and substring($following[2], 1, 10) castable as xs:date) then
            days-from-duration(xs:date(substring($following[2], 1, 10)) - xs:date(substring($preceding[2], 1, 10)))
        else 
            ()
    let $best-guess := ($parsed-head, $preceding[2], $following[2], $parsed-note, $parsed-body[1])[. ne ''][1]
    return
        <div vol="{util:document-name($div) ! substring-before(., '.xml')}">
            {$div/@*}
            <head>{$head}</head>
            <source-note>{$source-note}</source-note>
            <parsed-head>{$parsed-head}</parsed-head>
            <parsed-note>{$parsed-note}</parsed-note>
            <parsed-body>{$parsed-body}</parsed-body>
            <preceding>{$preceding}</preceding>
            <following>{$following}</following>
            <variance>{$variance}</variance>
            <best-guess>{$best-guess}</best-guess>
        </div>
};

declare function local:get-date-entry($document) {
    let $date := ($document/tei:dateline/tei:date)[1]
    let $vol-id := substring-before(util:document-name($document), '.xml')
    let $source := concat($vol-id, '#', $document/@xml:id)
    let $coverage := doc(concat('/db/cms/apps/volumes/data/', $vol-id, '.xml'))/volume/coverage
    return
        if ($date/@when) then
            <document>
                <date>{substring($date/@when, 1, 10)}</date>
                <remark source="{$source}" not-before="{$coverage[1]}" not-after="{$coverage[2]}">{element date {$date/@*, $date/string()}}</remark>
            </document>
        else
            let $maybes := local:get-date-candidate-field($document)
            let $best-guess := $maybes/best-guess
            return
                <document>
                    <date>{substring($best-guess, 1, 10)}</date>
                    <remark source="{$source}" not-before="{$coverage[1]}" not-after="{$coverage[2]}">{$maybes/*}</remark>
                </document>
};


let $vols := 
(:    doc('/db/cms/apps/tei-content/data/frus-volumes/frus1969-76v03.xml'):)
    collection('/db/cms/apps/tei-content/data/frus-volumes')
let $documents := $vols//tei:div[@type='document']
let $date-entries := 
    for $document in $documents
    return 
        local:get-date-entry($document)
let $consolidated := 
    <dates sources="{count($documents)}">{
        for $entry in $date-entries
        group by $date := $entry/date
        order by $date
        return
            <documents>
                {$date}
                <document sources="{count($entry)}">{$entry/remark}</document>
            </documents>
    }</dates>
return 
(:    $consolidated:)
    xmldb:store('/db', 'dates.xml', $consolidated)