xquery version "3.1";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace th="http://history.state.gov/ns/xquery/territories-html" at "/db/apps/gsh/modules/territories-html.xqm";

declare function local:lineages-landing-page() {
    let $lineages := doc('/db/apps/gsh/data/lineages.xml')//lineage
    let $content := 
        element div {
            element p { count($lineages) || " lineages ", element a { attribute href { "?show-all=true" }, "(Show full table.)" }},
            element ol {
                for $lineage in $lineages
                let $current-territory-id := $lineage/current-territory/territory-id
                return
                    element li {
                        element a {
                            attribute href { "?lineage-id=" || $current-territory-id },
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
    let $lineage :=  doc('/db/apps/gsh/data/lineages.xml')//lineage[current-territory/territory-id = $lineage-id]
    let $current-territory := $lineage/current-territory
    let $content := 
        element div {
            element table {
                attribute class { "table table-bordered" },
                element tr {
                    element th { "Current territory &amp; ancestors" },
                    element th { "Other territories that mention these" }
                },
                element tr {
                    element td {
                        let $all := ($lineage/current-territory, $lineage/predecessor)
                        return
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
                                            }
                                        }
                                }
                            else 
                                element a {
                                    attribute href { $gsh:territories-home || "/" || $lineage/other-mention/territory-id },
                                    gsh:territory-id-to-short-name-with-years-valid($lineage/other-mention/territory-id)
                                }
                        else 
                            <em>-</em>
                    }
                }
            },
            let $all := ($lineage/current-territory/territory-id, $lineage/predecessor/territory-id)
            let $territories := reverse(gsh:order-territories-chronologically(gsh:territories($all)))
            return
                gsh:territories-to-list($territories, $lineage/current-territory/territory-id || "-issue", true())
        }
    let $title := $current-territory/display-name/string()
    return
        gsh:wrap-html($content, $title)
};

declare function local:show-all-lineages() {
    let $lineages :=  doc('/db/apps/gsh/data/lineages.xml')//lineage
    let $content := 
        element div {
            element p { count($lineages) || " lineages ", element a { attribute href { "?" }, "(Just show a list.)" }},
            element table {
                attribute class { "table table-bordered" },
                element tr {
                    element th { "Territory" },
                    element th { "Current territory &amp; ancestors" },
                    element th { "Other territories that mention these" }
                },
                for $lineage in $lineages
                let $current-territory := $lineage/current-territory
                order by $current-territory/display-name
                return
                    element tr {
                        element td { 
                            element strong { 
                                element a {
                                    attribute href { "?lineage-id=" || $current-territory/territory-id },
                                    gsh:territory-id-to-short-name-with-years-valid($current-territory/territory-id)
                                }
                            }
                        },
                        element td {
                            let $all := ($lineage/current-territory, $lineage/predecessor)
                            return
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
                                                }
                                            }
                                    }
                                else 
                                    element a {
                                        attribute href { $gsh:territories-home || "/" || $lineage/other-mention/territory-id },
                                        gsh:territory-id-to-short-name-with-years-valid($lineage/other-mention/territory-id)
                                    }
                            else 
                                <em>-</em>
                        }
                    }
            }
        }
    let $title := "Lineages"
    return
        gsh:wrap-html($content, $title)
};

let $lineage-id := request:get-parameter("lineage-id", ())
let $show-all := request:get-parameter("show-all", ())
return
    if ($lineage-id) then
        local:show-lineage($lineage-id)
    else if ($show-all) then
        local:show-all-lineages()
    else
        local:lineages-landing-page()