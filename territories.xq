xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xql";

let $title := 'Territories'
let $content := 
    element div {
        element p {
            count($gsh:territories), ' territories. View ', 
            <a href="all-territories.xq">all territories data</a>, ' on one page.'
        },
        element ul {
            for $territory in $gsh:territories
            order by $territory/id
            return
                element li {
                    element a {
                        attribute href {
                            "territory.xq?territory=" || $territory/id
                        },
                        gsh:territory-id-to-short-name-with-years-valid($territory/id)
                    }
                }
        }
    }
return
    gsh:wrap-html($content, $title)