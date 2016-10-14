xquery version "3.1";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

declare function local:assignments-landing-page() {
    let $title := 'Assignments'
(:    let $breadcrumbs := th:landing-page-breadcrumbs():)
    let $lineages := doc('/db/apps/gsh/data/lineages.xml')//lineage
    let $assignments := doc('/db/apps/gsh/data/assignments.xml')//assignment
    let $unassigned-lineages := $lineages[not(current-territory/territory-id = $assignments//territory-id)]
    let $content := 
        element div {
(:            gsh:breadcrumbs($breadcrumbs),:)
            element table {
                attribute class { "table table-bordered" },
                element tr {
                    element th { "Reviewer" },
                    element th { "Territories" }
                },
                for $assignment in $assignments
                let $reviewer := $assignment/reviewer
                let $territory-ids := $assignment//territory-id
                return
                    element tr {
                        element td { $reviewer/string() },
                        element td {
                            element ol {
                                for $territory-id in $territory-ids
                                let $lineage := $lineages[current-territory/territory-id = $territory-id] 
                                let $predecessors := $lineage/predecessor
                                let $other-mentions := $lineage/other-mention
                                return
                                    element li {
                                        element a {
                                            attribute href { $gsh:app-home || "/lineages.xq?lineage-id=" || $territory-id },
                                            gsh:territory-id-to-short-name-with-years-valid($territory-id)
                                        },
                                        if ($predecessors or $other-mentions) then
                                            " (+ " || 
                                            string-join(
                                                (
                                                    if ($predecessors) then 
                                                        (count($predecessors) || " predecessors")
                                                    else 
                                                        (),
                                                    if ($other-mentions) then
                                                        (count($other-mentions) || " other territories")
                                                    else 
                                                        ()
                                                ),
                                                " &amp; "
                                            )
                                            || ")"
                                        else 
                                            ()
                                    }
                            }
                        }
                    }
            },
            element div {
                element h3 { "Unassigned Lineages" },
                element ol {
                    for $lineage in $unassigned-lineages
                    let $predecessors := $lineage/predecessor
                    let $other-mentions := $lineage/other-mention
                    let $lineage-id := $lineage/current-territory/territory-id
                    return
                        element li {
                            element a {
                                attribute href { $gsh:app-home || "/lineages.xq?lineage-id=" || $lineage-id },
                                gsh:territory-id-to-short-name-with-years-valid($lineage-id)
                            },
                            if ($predecessors or $other-mentions) then
                                " (+ " || 
                                string-join(
                                    (
                                        if ($predecessors) then 
                                            (count($predecessors) || " predecessors")
                                        else 
                                            (),
                                        if ($other-mentions) then
                                            (count($other-mentions) || " other territories")
                                        else 
                                            ()
                                    ),
                                    " &amp; "
                                )
                                || ")"
                            else 
                                ()
                        }
                }
            },
            let $all-territories := collection('/db/apps/gsh/data/territories')/territory
            let $assigned-territories := doc('/db/apps/gsh/data/lineages.xml')//territory-id
            (: assignments are for current territories; 
                old territories should all be captured by these as predecessors/other-mentions, 
                as tested via import/check-for-territories-missing-from-lineages.xq :)
            let $unassigned-territories := $all-territories[not(id = $assigned-territories)]
            return
                element div {
                    element h3 { "Territories Not Part of any Lineage" },
                    if (exists($unassigned-territories)) then
                        element ol {
                            for $t in $unassigned-territories
                            let $territory-id := $t/id
                            order by $t/short-form-name
                            return
                                element li {
                                    element a {
                                        attribute href { $gsh:app-home || "/lineages.xq?lineage-id=" || $territory-id },
                                        gsh:territory-id-to-short-name-with-years-valid($territory-id)
                                    }
                                }
                        }
                    else
                        element p { "None. Good job!" }
                }
        }
    return
        gsh:wrap-html($content, $title)
};

local:assignments-landing-page()