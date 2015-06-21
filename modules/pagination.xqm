xquery version "3.0";

module namespace p8n="http://history.state.gov/ns/xquery/pagination";

declare function p8n:summarize($start as xs:integer, $per-page as xs:integer, $how-many as xs:integer) {
    concat('Results ', $start, '–', $start + $per-page - 1, ' of ', $how-many, '.')
};

declare function p8n:paginate($start as xs:integer, $per-page as xs:integer, $how-many as xs:integer, $href as function) {
    let $total-pages := xs:integer(ceiling($how-many div $per-page))
    let $current-page := ($start - 1) div $per-page + 1
    let $pages-to-show := distinct-values((1, xs:integer(max(($current-page - 2, 1))) to xs:integer(min(($current-page + 2, $total-pages))), $total-pages))
    let $prev-start := max(($start - $per-page, 1))
    let $next-start := $start + $per-page
    return
        element nav {
            element ul {
                attribute class { "pagination" },
                element li {
                    if ($current-page eq 1) then attribute class {"disabled"} else (),
                    element a {
                        attribute href { $href($prev-start, $per-page) },
                        attribute aria-label { "Previous" },
                        element span {
                            attribute aria-hidden { "true" },
                            "«"
                        }
                    },
                for $page in $pages-to-show
                let $new-start := ($page - 1) * $per-page + 1
                return
                    element li {
                        if ($page = $current-page) then attribute class {"active"} else (),
                        element a {
                            attribute href { $href($new-start, $per-page) },
                            $page
                        }
                    }
                },
                element li {
                    if ($current-page eq $total-pages) then attribute class {"disabled"} else (),
                    element a {
                        attribute href { $href($next-start, $per-page) },
                        attribute aria-label { "Next" },
                        element span { 
                            attribute aria-hidden { "true" },
                            "»"
                        }
                    }
                }
            }
        }
};

(: 
let $q := 'iran'
let $start := 1001
let $per-page := 10
let $how-many := 1024
let $href := function($start, $per-page) { concat('?q=', $q, '&amp;start=', $start, if ($per-page ne 10) then concat('&amp;per-page=', $per-page) else ()) }
let $summary := p8n:summarize($start, $per-page, $how-many)
let $nav := p8n:paginate($start, $per-page, $how-many, $href)
let $content :=
    element div {
        element p { $summary },
        $nav
    }
return
    gsh:wrap-html($content, 'nav test')
:)