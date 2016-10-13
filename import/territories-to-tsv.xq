xquery version "3.1";

declare function local:tsv($column-headings, $rows as array(*)*) {
    let $cell-separator := '&#09;' (: tab :)
    let $row-separator := '&#10;' (: newline :)
    let $heading-row := string-join($column-headings, $cell-separator)
    let $body-rows := 
        for $row in $rows
        return
            string-join($row?*, $cell-separator)
    let $all-rows := ($heading-row, $body-rows)
    let $tsv := string-join($all-rows, $row-separator)
    return 
        $tsv
};

let $rows := 
    for $territory in collection('/db/apps/gsh/data/territories')/territory
    let $id := $territory/id
    let $short-form-name := $territory/short-form-name
    let $long-form-name := $territory/long-form-name
    let $type := $territory/type-of-territory
    let $valid-since := $territory/valid-since
    let $valid-until := $territory/valid-until
    let $exists-on-todays-map := $territory/exists-on-todays-map
    let $predecessors := string-join($territory//predecessor[. ne ''], '; ')
    let $successors := string-join($territory//successor[. ne ''], '; ')
    let $notes := $territory/notes
    let $sources := string-join($territory//source ! normalize-space(.), '; ')
    order by $territory/id cast as xs:integer
    return
        array { $id, $short-form-name/string(), $long-form-name/string(), $type/string(), $valid-since/string(), $valid-until/string(), $exists-on-todays-map/string(), $predecessors, $successors, normalize-space($notes), $sources  }
let $column-labels := ('id', 'short-form-name', 'long-form-name', 'type-of-territory', 'valid-since', 'valid-until', 'exists-on-todays-map', 'predecessors', 'successors', 'notes', 'sources')
let $tsv := local:tsv($column-labels, $rows)
return
    xmldb:store('/db', 'territories.tsv', $tsv)