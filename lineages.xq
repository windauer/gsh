xquery version "3.1";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace th="http://history.state.gov/ns/xquery/territories-html" at "/db/apps/gsh/modules/territories-html.xqm";

declare function local:lineages-landing-page() {
    let $lineages := collection('/db/apps/gsh/data/lineages')//lineage
    let $content := 
        element div {
            element p { count($lineages) || " lineages ", element a { attribute href { "?show-all=true" }, "(Show full table.)" }},
            element ol {
                for $lineage in $lineages
                let $current-territory-id := $lineage/current-territory/territory-id
                return
                    element li {
                        element a {
                            attribute href { $gsh:lineages-home || "/" || $current-territory-id },
                            gsh:territory-id-to-short-name-with-years-valid($current-territory-id)
                        }
                    }
            }
        }
    let $title := "Lineages"
    return
        gsh:wrap-html($content, $title)
};

declare function local:show-lineage($lineage-id) {
    let $lineage :=  collection('/db/apps/gsh/data/lineages')//lineage[current-territory/territory-id = $lineage-id]
    let $current-territory := $lineage/current-territory
    let $all := ($lineage/current-territory, $lineage/predecessor)
    let $content := 
        element div {
            element section {
                attribute style { "column-break-inside: avoid" },
                element h3 { "Review status" },
                element table {
                    attribute class { "table table-bordered" },
                    element colgroup {
                        element col {
                            attribute class { "col-md-3" }
                        },
                        element col {
                            attribute class { "col-md-9" }
                        }
                    },
                    element tbody {
                        element tr {
                            element th { "Status" },
                            element td { $lineage/review/status/string() }
                        },
                        element tr {
                            element th { "Reviewer" },
                            element td { ($lineage/review/reviewer/string()[. ne ''], '-')[1] }
                        },
                        element tr {
                            element th { "Reviewed Date" },
                            element td { ($lineage/review/reviewed-date/string()[. ne ''], '-')[1] }
                        }
                    }
                }
            },
            element section {
                attribute style { "column-break-inside: avoid" },
                element h3 { "Overview" },
                element p { 
                    "The first column below contains a list of the " || count($all) || " " ||
                    "countries in the “lineage” of " || 
                    gsh:territory-id-to-short-name-with-years-valid($lineage/current-territory/territory-id) || 
                    "—newest to oldest. " || 
                    "Please review these to ensure they all belong in the lineage. " ||
                    "The second column contains a list of other countries that " ||
                    "list these as either a predecessor or successor. " ||
                    "If any of the entries in the second column belong in the lineage, " || 
                    "please click on their links, complete the forms, and include " ||
                    "it in your submission."
                },
                element table {
                    attribute class { "table table-bordered" },
                    element colgroup {
                        element col {
                            attribute class { "col-md-5" }
                        },
                        element col {
                            attribute class { "col-md-7" }
                        }
                    },
                    element tbody {
                        element tr {
                            element th { "Current territory &amp; ancestors" },
                            element th { "Other territories that list these as predecessors or successors" }
                        },
                        element tr {
                            element td {
                                if (count($all) gt 1) then
                                    element ol {
                                        for $t at $n in $all/territory-id
                                        return
                                            element li {
                                                element a {
                                                    attribute href { $gsh:territories-home || "/" || $t },
                                                    gsh:territory-id-to-short-name-with-years-valid($t)
                                                },
                                                if ($n gt 1) then 
                                                    element ul {
                                                        element li { gsh:review-checkbox(("Keep with relationship _____", "Move to lineage of _____ ")) }
                                                    }
                                                else 
                                                    ()
                                            }
                                    }
                                else 
                                    element a {
                                        attribute href { $gsh:territories-home || "/" || $all/territory-id },
                                        gsh:territory-id-to-short-name-with-years-valid($all/territory-id)
                                    }
                            },
                            element td {
                                if ($lineage/other-mention) then
                                    if (count($lineage/other-mention) gt 1) then
                                        element ol {
                                            for $o in $lineage/other-mention
                                            order by $o/display-name
                                            return
                                                element li {
                                                    element a {
                                                        attribute href { $gsh:territories-home || "/" || $o/territory-id },
                                                        gsh:territory-id-to-short-name-with-years-valid($o/territory-id)
                                                    },
                                                    let $territory := gsh:territories($o/territory-id)
                                                    let $matching-predecessors := $territory//predecessor[. = $all/territory-id]
                                                    let $matching-successors := $territory//successor[. = $all/territory-id]
                                                    return 
                                                        if ($matching-predecessors or $matching-successors) then
                                                            ": Lists " ||
                                                            string-join(
                                                                (
                                                                    if ($matching-predecessors) then
                                                                        string-join($matching-predecessors ! gsh:territory-id-to-short-name-with-years-valid(.), ", ")
                                                                        || 
                                                                        " as predecessor"
                                                                    else (),
                                                                    if ($matching-successors) then
                                                                        string-join($matching-successors ! gsh:territory-id-to-short-name-with-years-valid(.), ", ")
                                                                        || 
                                                                        " as successor"
                                                                    else ()
                                                                )
                                                                ,
                                                                " and "
                                                            )
                                                        else
                                                            ()
                                                    ,
                                                    element ul {
                                                        element li { gsh:review-checkbox(("Delete", "Promote to ancestor after #__ with relationship _____")) }
                                                    }
                                                }
                                        }
                                    else 
                                        (
                                            element a {
                                                attribute href { $gsh:territories-home || "/" || $lineage/other-mention/territory-id },
                                                gsh:territory-id-to-short-name-with-years-valid($lineage/other-mention/territory-id)
                                            },
                                            let $territory := gsh:territories($lineage/other-mention/territory-id)
                                            let $matching-predecessors := $territory//predecessor[. = $all/territory-id]
                                            let $matching-successors := $territory//successor[. = $all/territory-id]
                                            return 
                                                if ($matching-predecessors or $matching-successors) then
                                                    (
                                                        ": Lists " ||
                                                        string-join(
                                                            (
                                                                if ($matching-predecessors) then
                                                                    string-join($matching-predecessors ! gsh:territory-id-to-short-name-with-years-valid(.), ", ")
                                                                    || 
                                                                    " as predecessor"
                                                                else (),
                                                                if ($matching-successors) then
                                                                    string-join($matching-successors ! gsh:territory-id-to-short-name-with-years-valid(.), ", ")
                                                                    || 
                                                                    " as successor"
                                                                else ()
                                                            )
                                                            ,
                                                            " and "
                                                        ),
                                                        element br { () },
                                                        element ul { 
                                                            element li { 
                                                                gsh:review-checkbox(("Delete", "Promote to ancestor after #__ with relationship _____"))
                                                            }
                                                        }
                                                    )
                                                else
                                                    ()
                                        )
                                else 
                                    <em>-</em>
                            }
                        }
                    }
                }
            },
            element section {
                element h3 { "Full records of current territory &amp; ancestors" },
                let $all := ($lineage/current-territory/territory-id, $lineage/predecessor/territory-id)
                let $territories := for $t in $all return gsh:territories($t)
                let $counter-name := $lineage/current-territory/territory-id || "-issue"
                let $counter := (counter:destroy($counter-name), counter:create($counter-name, 100))
                return
                    gsh:territories-to-list($territories, $counter-name, true(), true())
            }
        }
    let $title := $current-territory/display-name || " &amp; its ancestors" 
    return
        gsh:wrap-html($content, $title)
};

declare function local:show-all-lineages() {
    let $lineages :=  collection('/db/apps/gsh/data/lineages')//lineage
    let $content := 
        element div {
            element p { count($lineages) || " lineages ", element a { attribute href { "?" }, "(Just show a list.)" }},
            element table {
                attribute class { "table table-bordered" },
                element colgroup {
                    element col {
                        attribute class { "col-md-3" }
                    },
                    element col {
                        attribute class { "col-md-3" }
                    },
                    element col {
                        attribute class { "col-md-6" }
                    }
                },
                element tbody {
                    element tr {
                        element th { "Territory" },
                        element th { "Current territory &amp; ancestors" },
                        element th { "Other territories that list these as predecessors or successors" }
                    },
                    for $lineage in $lineages
                    let $current-territory := $lineage/current-territory
                    let $all := ($lineage/current-territory, $lineage/predecessor)
                    order by $current-territory/display-name
                    return
                        element tr {
                            element td { 
                                element strong { 
                                    element a {
                                        attribute href { $gsh:lineages-home || "/" || $current-territory/territory-id },
                                        gsh:territory-id-to-short-name-with-years-valid($current-territory/territory-id)
                                    }
                                }
                            },
                            element td {
                                if (count($all) gt 1) then
                                    element ol {
                                        for $t in $all/territory-id
                                        return
                                            element li {
                                                element a {
                                                    attribute href { $gsh:territories-home || "/" || $t },
                                                    gsh:territory-id-to-short-name-with-years-valid($t)
                                                }
                                            }
                                    }
                                else 
                                    element a {
                                        attribute href { $gsh:territories-home || "/" || $all/territory-id },
                                        gsh:territory-id-to-short-name-with-years-valid($all/territory-id)
                                    }
                            },
                            element td {
                                if ($lineage/other-mention) then
                                    if (count($lineage/other-mention) gt 1) then
                                        element ol {
                                            for $o in $lineage/other-mention
                                            order by $o/display-name
                                            return
                                                element li {
                                                    element a {
                                                        attribute href { $gsh:territories-home || "/" || $o/territory-id },
                                                        gsh:territory-id-to-short-name-with-years-valid($o/territory-id)
                                                    },
                                                    let $territory := gsh:territories($o/territory-id)
                                                    let $matching-predecessors := $territory//predecessor[. = $all/territory-id]
                                                    let $matching-successors := $territory//successor[. = $all/territory-id]
                                                    return 
                                                        if ($matching-predecessors or $matching-successors) then
                                                            ": Lists " ||
                                                            string-join(
                                                                (
                                                                    if ($matching-predecessors) then
                                                                        string-join($matching-predecessors ! gsh:territory-id-to-short-name-with-years-valid(.), ", ")
                                                                        || 
                                                                        " as predecessor"
                                                                    else (),
                                                                    if ($matching-successors) then
                                                                        string-join($matching-successors ! gsh:territory-id-to-short-name-with-years-valid(.), ", ")
                                                                        || 
                                                                        " as successor"
                                                                    else ()
                                                                )
                                                                ,
                                                                " and "
                                                            )
                                                        else
                                                            ()
                                                }
                                        }
                                    else 
                                        (
                                        element a {
                                            attribute href { $gsh:territories-home || "/" || $lineage/other-mention/territory-id },
                                            gsh:territory-id-to-short-name-with-years-valid($lineage/other-mention/territory-id)
                                        },
                                        let $territory := gsh:territories($lineage/other-mention/territory-id)
                                        let $matching-predecessors := $territory//predecessor[. = $all/territory-id]
                                        let $matching-successors := $territory//successor[. = $all/territory-id]
                                        return 
                                            if ($matching-predecessors or $matching-successors) then
                                                ": Lists " ||
                                                string-join(
                                                    (
                                                        if ($matching-predecessors) then
                                                            string-join($matching-predecessors ! gsh:territory-id-to-short-name-with-years-valid(.), ", ")
                                                            || 
                                                            " as predecessor"
                                                        else (),
                                                        if ($matching-successors) then
                                                            string-join($matching-successors ! gsh:territory-id-to-short-name-with-years-valid(.), ", ")
                                                            || 
                                                            " as successor"
                                                        else ()
                                                    )
                                                    ,
                                                    " and "
                                                )
                                            else
                                                ()
                                        )
                                else 
                                    <em>-</em>
                            }
                        }
                }
            }
        }
    let $title := "Lineages"
    return
        gsh:wrap-html($content, $title)
};

let $lineage-id := request:get-parameter("lineage", ())
let $show-all := request:get-parameter("show-all", ())
return
    if ($lineage-id) then
        local:show-lineage($lineage-id)
    else if ($show-all) then
        local:show-all-lineages()
    else
        local:lineages-landing-page()