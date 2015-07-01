xquery version "3.0";

module namespace p8n="http://history.state.gov/ns/xquery/pagination";

declare function p8n:summarize($start as xs:integer, $per-page as xs:integer, $how-many as xs:integer) {
    concat('Results ', $start, '–', min(($start + $per-page - 1, $how-many)), ' of ', $how-many, '.')
};

(:~ Paginate results, Google-style
 : @see http://getbootstrap.com/components/#pagination 
 : @param href a function taking two parameters ($start and $per-page, both integers) and returning a URL :)
declare function p8n:paginate($start as xs:integer, $per-page as xs:integer, $how-many as xs:integer, $href as function) {
    let $total-pages := xs:integer(ceiling($how-many div $per-page))
    let $current-page := xs:integer(($start - 1) div $per-page + 1)
    let $max-window-size := 10 (: match Google :)
    let $keep-stable-until := $max-window-size - 3
    let $start-page := if ($current-page lt $keep-stable-until) then 1 else (max(($current-page - floor($max-window-size div 2), 1)) cast as xs:integer)
    let $end-page := if ($total-pages lt $max-window-size) then $total-pages else if ($current-page lt $keep-stable-until) then $max-window-size else $current-page + ceiling($max-window-size div 2 - 1) cast as xs:integer
    let $pages-to-show := $start-page to $end-page
    let $is-first-page := $current-page eq 1
    let $is-last-page := $current-page eq $total-pages
    let $prev-start := if ($is-first-page) then 1 else $start - $per-page
    let $next-start := if ($is-last-page) then $start else $start + $per-page
    return
        if ($total-pages le 1) then ()
        else
        element nav {
            element ul {
                attribute class { "pagination" },
                element li {
                    if ($is-first-page) then attribute class {"disabled"} else (),
                    element a {
                        attribute href { if ($is-first-page) then '#' else $href($prev-start, $per-page) },
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
                    if ($is-last-page) then attribute class {"disabled"} else (),
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

declare function p8n:strip-parameters($query-string, $names) {
    let $original-parameters := tokenize($query-string, '&amp;')
    let $trimmed := $original-parameters[not(tokenize(., '=')[1] = $names)]
    return 
        string-join($trimmed, '&amp;')
};