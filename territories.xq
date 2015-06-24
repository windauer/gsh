xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

declare function local:landing-page-breadcrumbs() {
    <li><a href="{$gsh:territories-home}">Territories</a></li>
};

declare function local:territory-breadcrumbs($territory-id) {
    (
    local:landing-page-breadcrumbs(),
    <li><a href="{gsh:link-to-territory($territory-id)}">{gsh:territory-id-to-short-name($territory-id)}</a></li>
    )
};

declare function local:territories-landing-page() {
    let $title := 'Territories'
    let $breadcrumbs := local:landing-page-breadcrumbs()
    let $content := 
        element div {
            gsh:breadcrumbs($breadcrumbs),
            element p {
                concat('All ', count($gsh:territories), ' territories.')
                (:
                'View '), 
                <a href="all-territories.xq">full dataset</a>, ' on one page.'
                :)
            },
            element ul {
                for $territory in $gsh:territories
                order by $territory/short-form-name, $territory/valid-since (: alphabetical, then chronological tie breaker :)
                return
                    element li {
                        element a {
                            attribute href { gsh:link-to-territory($territory/id) },
                            gsh:territory-id-to-short-name-with-years-valid($territory/id)
                        }
                    }
            }
        }
    return
        gsh:wrap-html($content, $title)
};

declare function local:immediate-predecessor($territory) {
    let $predecessor-ids := $territory//predecessor
    let $predecessors := gsh:order-territories-chronologically(gsh:territories($predecessor-ids))
    let $immediate-predecessor := $predecessors[last()]
    return
        $immediate-predecessor
};

declare function local:immediate-successor($territory) {
    let $successor-ids := $territory//successor
    let $successors := gsh:order-territories-chronologically(gsh:territories($successor-ids))
    let $immediate-successor := $successors[1]
    return
        $immediate-successor
};

declare function local:crawl-predecessors($territory) {
    $territory,
    let $immediate-predecessor := local:immediate-predecessor($territory)
    return
        if (not($immediate-predecessor)) then 
            ()
        else 
            local:crawl-predecessors($immediate-predecessor)
};

declare function local:crawl-successors($territory) {
    $territory,
    let $immediate-successor := local:immediate-successor($territory)
    return
        if (not($immediate-successor)) then 
            ()
        else 
            local:crawl-successors($immediate-successor)
};

declare function local:territory-sequence-to-tree($sequence) {
    let $head := head($sequence)
    return
        element ul {
            element li { 
                element a { 
                    attribute href { gsh:link-to-territory($head/id) }, 
                    gsh:territory-id-to-short-name-with-years-valid($head/id)
                    
                },
                if (not($sequence[2])) then 
                    ()
                else 
                    local:territory-sequence-to-tree(tail($sequence))
            }
        }
};

declare function local:predecessor-tree($territory) {
    element div {
        attribute class {'row tree'},
        element h3 { 'Tree' },
            try { 
                let $predecessors := local:crawl-predecessors($territory)
                let $successors := local:crawl-successors($territory)
                let $sequence := (reverse($predecessors), subsequence($successors, 2))
                return
                    local:territory-sequence-to-tree($sequence)
                } 
            catch * { 
                'Error generating tree' 
            }
    }
};

declare function local:show-territory($territory-id as xs:string) {
    let $territory := gsh:territories($territory-id)
    let $title := gsh:territory-id-to-short-name($territory-id)
    let $breadcrumbs := local:territory-breadcrumbs($territory-id)
    let $counter-name := concat($territory-id, '-issue')
    let $content :=
        <div>
            { gsh:breadcrumbs($breadcrumbs) }
            <p>Lookup territories that <a href="{$gsh:territories-home}?mentions={$territory-id}">reference id "{$territory-id}"</a>.</p>
            { gsh:territories-to-list($territory, $counter-name, true()) }
            { local:predecessor-tree($territory) }
        </div>
    return
        gsh:wrap-html($content, $title)
};

declare function local:mentions($territory-id as xs:string) {
    let $direct-hit := gsh:territories($territory-id)
    let $pred-succ := gsh:order-territories-chronologically($gsh:territories[.//predecessor = $territory-id or .//successor = $territory-id])
    let $title := concat('Mentions of "', $territory-id, '"')
    let $breadcrumbs := (local:landing-page-breadcrumbs(), <li><a href="#">{$title}</a></li>)
    let $content :=
        <div>
            { gsh:breadcrumbs($breadcrumbs) }
            <p>{count(($direct-hit, $pred-succ))} mentions of "{$territory-id}"</p>
            { 
                if ($direct-hit) then
                    (
                        <h3>Territory with id "{$territory-id}"</h3>,
                        <h4><a href="{gsh:link-to-territory($territory-id)}">{gsh:territory-id-to-short-name-with-years-valid($territory-id)}</a></h4>,
                        gsh:territories-to-list($direct-hit, (), true())
                    )
                else 
                    ()
            }
            {
                if ($pred-succ) then
                    (
                        <h3>Territories with "{$territory-id}" tagged as a direct predecessor or successor</h3>,
                        for $hit at $n in $pred-succ
                        return
                            (
                                <h4><a href="{gsh:link-to-territory($hit/id)}">{gsh:territory-id-to-short-name-with-years-valid($hit/id)}</a></h4>,
                                <p>Lookup <a href="{$gsh:territories-home}?mentions={$hit/id}">mentions of "{$hit/id}"</a>.</p>,
                                gsh:territories-to-list($hit, (), true())
                            )
                    )
                else 
                    ()
            }
        </div>
    return
        gsh:wrap-html($content, $title)
};


declare function local:contains($territory-id as xs:string) {
    let $hits := $gsh:territories[contains(id, $territory-id)]
    let $title := concat('Territories whose id contains "', $territory-id, '"')
    let $breadcrumbs := (local:landing-page-breadcrumbs(), <li><a href="#">{$title}</a></li>)
    let $content :=
        <div>
            { gsh:breadcrumbs($breadcrumbs) }
            <p>{count($hits)} territory ids containing "{$territory-id}"</p>
            {
                for $hit in $hits
                return
                    (
                        <h3><a href="{gsh:link-to-territory($hit/id)}">{gsh:territory-id-to-short-name-with-years-valid($hit/id)}</a></h3>,
                        <p>Lookup <a href="{$gsh:territories-home}?mentions={$territory-id}">mentions of "{$territory-id}"</a>.</p>,
                        gsh:territories-to-list($hit, (), true())
                    )
            }
        </div>
    return
        gsh:wrap-html($content, $title)
};

let $territory-id := request:get-parameter('territory', ())
let $mentions := request:get-parameter('mentions', ())
let $contains := request:get-parameter('contains', ())
return  
    if ($territory-id) then 
        local:show-territory($territory-id)
    else if ($mentions) then
        local:mentions($mentions)
    else if ($contains) then
        local:contains($contains)
    else
        local:territories-landing-page()