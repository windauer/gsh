xquery version "3.1";


import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

declare function local:crawl-predecessors($territory-ids as xs:string*, $accumulated-predecessors as xs:string*) {
    let $territories := collection('/db/apps/gsh/data/territories')/territory[id = $territory-ids]
    let $predecessors := distinct-values($territories//predecessor[not(. = $accumulated-predecessors)])
    let $log := console:log("get-predecessors: territory-ids:" || string-join($territory-ids, '; ') || " looking up predecessors: " || string-join($predecessors, '; ') || " skipping accumulated-predecessors: " || string-join($accumulated-predecessors, '; ') )
    return
        (
            if (exists($predecessors)) then
                let $seen-ps := distinct-values(($accumulated-predecessors, $territory-ids))
                return 
                    local:crawl-predecessors($predecessors, $seen-ps)
            else
                distinct-values(($accumulated-predecessors, $territory-ids))
        )
};

declare function local:get-predecessors($territory-id) {
    let $territory := collection('/db/apps/gsh/data/territories')/territory[id = $territory-id]
    return
        local:crawl-predecessors($territory//predecessor, ())[. ne $territory-id]
};

element lineages {
    for $t in collection('/db/apps/gsh/data/territories')/territory[exists-on-todays-map eq 'true']
    order by $t/short-form-name
    return
        element lineage {
            element current-territory {
                element display-name { gsh:territory-id-to-short-name-with-years-valid($t/id) },
                element territory-id { $t/id/string() },
                element url { "http://localhost:8080/exist/apps/gsh/territories/" || $t/id }
            },
            try 
                {
                    let $predecessor-ids := local:get-predecessors($t/id)
                    let $predecessors := gsh:territories($predecessor-ids)
                    let $reverse-chron := reverse(gsh:order-territories-chronologically($predecessors))
                    let $ids-for-other-mentions := ($t/id, $predecessor-ids)
                    let $other-mentions := collection('/db/apps/gsh/data/territories')//territory[.//predecessor = $ids-for-other-mentions or .//successor = $ids-for-other-mentions][not(id = $ids-for-other-mentions)]
                    return
                        (
                        for $p in $reverse-chron
                        return
                            element predecessor {
                                element display-name { gsh:territory-id-to-short-name-with-years-valid($p/id) },
                                element territory-id { $p/id/string() },
                                element url { "http://localhost:8080/exist/apps/gsh/territories/" || $p/id }
                            }
                        ,
                        for $o in $other-mentions
                        return
                            element other-mention {
                                element display-name { gsh:territory-id-to-short-name-with-years-valid($o/id) },
                                element territory-id { $o/id/string() },
                                element url { "http://localhost:8080/exist/apps/gsh/territories/" || $o/id }
                            }
                        )
                } 
            catch *
                {
                    <error>Problem crawling ancestor tree: {$err:description}</error>
                }
        }
}