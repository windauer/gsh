xquery version "3.1";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

declare function local:assignments-landing-page() {
    let $title := 'Assignments'
(:    let $breadcrumbs := th:landing-page-breadcrumbs():)
    let $content := 
        element div {
(:            gsh:breadcrumbs($breadcrumbs),:)
            element table {
                attribute class { "table table-bordered" },
                element tr {
                    element th { "Reviewer" },
                    element th { "Territories" }
                },
                for $assignment in doc('/db/apps/gsh/data/assignments.xml')//assignment
                let $reviewer := $assignment/reviewer
                let $territory-ids := $assignment//territory-id
                return
                    element tr {
                        element td { $reviewer/string() },
                        element td {
                            element ol {
                                for $territory-id in $territory-ids
                                return
                                    element li {
                                        element a {
                                            attribute href { $gsh:territories-home || "?mentions=" || $territory-id },
                                            gsh:territory-id-to-short-name-with-years-valid($territory-id)
                                        }
                                    }
                            }
                        }
                    }
            }
        }
    return
        gsh:wrap-html($content, $title)
};

local:assignments-landing-page()