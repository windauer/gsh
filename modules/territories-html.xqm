xquery version "3.0";

module namespace th="http://history.state.gov/ns/xquery/territories-html";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace console="http://exist-db.org/xquery/console";

declare function th:landing-page-breadcrumbs() {
    <li><a href="{$gsh:territories-home}">Territories</a></li>
};

declare function th:territory-breadcrumbs($territory-id) {
    (
    th:landing-page-breadcrumbs(),
    <li><a href="{gsh:link-to-territory($territory-id)}">{gsh:territory-id-to-short-name($territory-id)}</a></li>
    )
};

declare function th:territories-landing-page() {
    let $title := 'Territories'
    let $breadcrumbs := th:landing-page-breadcrumbs()
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
                for $territory in $gsh:territories/territory
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

declare function th:immediate-predecessors($territory) {
    let $predecessor-ids := $territory//predecessor
    let $predecessors := gsh:order-territories-chronologically(gsh:territories($predecessor-ids))
    let $closest-predecessor-valid-until := $predecessors[last()]/valid-until
    let $immediate-predecessors := $predecessors[valid-until = $closest-predecessor-valid-until]
    return
        (
        $immediate-predecessors
        ,
        console:log("immediate-predecessors for " || $territory/id || ": " || string-join($immediate-predecessors/id, ', '))
        )
};

declare function th:immediate-successors($territory) {
    let $successor-ids := $territory//successor
    let $successors := gsh:order-territories-chronologically(gsh:territories($successor-ids))
    let $closest-successor-valid-since := $successors[1]/valid-since
    let $immediate-successors := $closest-successor-valid-since[valid-since = $closest-successor-valid-since]
    return
        $immediate-successors
};

declare function th:crawl-predecessors($territory) {
    $territory,
    let $immediate-predecessors := th:immediate-predecessors($territory)
    return
        if (not($immediate-predecessors)) then 
            ()
        else 
            $immediate-predecessors ! th:crawl-predecessors(.)
};

declare function th:crawl-successors($territory) {
    $territory,
    let $immediate-successors := th:immediate-successors($territory)
    return
        if (not($immediate-successor)) then 
            ()
        else 
            $immediate-successors ! th:crawl-successors(.)
};

declare function th:territory-sequence-to-tree($sequence) {
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
                    th:territory-sequence-to-tree(tail($sequence))
            }
        }
};

declare function th:predecessor-tree($territory) {
    element div {
        attribute class {'row tree'},
        element h3 { 'Tree' },
            try { 
                let $predecessors := th:crawl-predecessors($territory)
                let $successors := th:crawl-successors($territory)
                let $sequence := (reverse($predecessors), subsequence($successors, 2))
                return
                    th:territory-sequence-to-tree($sequence)
                } 
            catch * { 
                'Error generating tree' 
            }
    }
};

declare function th:successor-tree-recurse($territory, $territory-id-to-highlight) {
    console:log("successor-tree-recurse for " || $territory/id)
    ,
    let $territory-id := $territory/id
    let $successor-ids := $territory//successor
    let $successors := gsh:territories($successor-ids)
    (:
    let $midterm-split-offs := $successors[valid-since lt $territory/valid-until]
    let $endterm-successors := $successors[valid-since = $territory/valid-until]
    let $successors-to-graph := ($midterm-split-offs, $endterm-successors)
    :)
    return
        element li {
            element a { 
                attribute href { gsh:link-to-territory($territory/id) }, 
                if ($territory-id = $territory-id-to-highlight) then attribute class {"selected"} else (),
                gsh:territory-id-to-short-name-with-years-valid($territory-id)
            },
            if ($successors) then
                element ul {
                    for $successor in gsh:order-territories-chronologically($successors)
                    return
                        th:successor-tree-recurse($successor, $territory-id-to-highlight)
                }
            else 
                ()
        }
};

declare function th:successor-tree($territory) {
    element div {
        attribute class {'row tree'},
        element h3 { gsh:territory-id-to-short-name($territory/id) },
        try 
            { <ul>{th:successor-tree-recurse($territory, $territory/id)}</ul> } 
        catch * 
            { <p class="bg-warning">Error generating tree</p> }
    }
};

declare function th:get-ancestors($territory) {
    console:log("get-ancestors for " || $territory/id)
    ,
    if (not($territory//predecessor)) then
        (
        console:log("no predecessors tagged for " || $territory/id || ", stopping get-ancestors search.")
        ,
        console:log(serialize($territory//predecessor))
        ,
        $territory
        )
    else
        (
        console:log("found predecessors for " || $territory/id || ", passing to immediate-predecessors.")
        ,
        for $predecessor in th:immediate-predecessors($territory) return th:get-ancestors($predecessor)
        )
};

declare function th:ancestor-tree($territory) {
    console:log("ancestor-tree for " || $territory/id)
    ,
    try 
        { 
            let $ancestors := th:get-ancestors($territory)
            for $ancestor in $ancestors
            return
                element div {
                    attribute class {'row tree'},
                    <ul>{th:successor-tree-recurse($ancestor, $territory/id)}</ul>
                }
        } 
    catch * 
        { <p class="bg-warning">Error generating ancestor tree</p> }
};

declare function th:show-territory($territory-id as xs:string) {
    let $territory := gsh:territories($territory-id)
    let $title := gsh:territory-id-to-short-name($territory-id)
    let $breadcrumbs := th:territory-breadcrumbs($territory-id)
    let $display-name := gsh:territory-id-to-short-name-with-years-valid($territory-id)
    let $counter-name := concat($territory-id, '-issue')
    let $content :=
        <div>
            { gsh:breadcrumbs($breadcrumbs) }
            <p>Look up territories that <a href="{$gsh:territories-home}?mentions={$territory-id}">reference {$display-name}</a>.</p>
            { gsh:territories-to-list($territory, $counter-name, true(), false()) }
            { (: th:ancestor-tree($territory) :) () }
        </div>
    return
        gsh:wrap-html($content, $display-name)
};

declare function th:mentions($territory-id as xs:string) {
    let $direct-hit := gsh:territories($territory-id)
    let $pred-succ := gsh:order-territories-chronologically($gsh:territories/territory[.//predecessor = $territory-id or .//successor = $territory-id])
    let $display-name := gsh:territory-id-to-short-name-with-years-valid($territory-id)
    let $title := concat('Mentions of ', $display-name)
    let $breadcrumbs := (th:landing-page-breadcrumbs(), <li><a href="#">{$title}</a></li>)
    let $content :=
        <div>
            { gsh:breadcrumbs($breadcrumbs) }
            <p>{count(($direct-hit, $pred-succ))} mentions of {$display-name}</p>
            { 
                if ($direct-hit) then
                    (
                        <h3><a href="{gsh:link-to-territory($territory-id)}">{$display-name}</a></h3>,
                        gsh:territories-to-list($direct-hit, (), true(), false())
                    )
                else 
                    ()
            }
            {
                if ($pred-succ) then
                    (
                        <h3>Territories with {$display-name} tagged as a direct predecessor or successor</h3>,
                        for $hit at $n in $pred-succ
                        let $hit-display-name := gsh:territory-id-to-short-name-with-years-valid($hit/id)
                        return
                            (
                                <h4><a href="{gsh:link-to-territory($hit/id)}">{$hit-display-name}</a></h4>,
                                <p>Look up <a href="{$gsh:territories-home}?mentions={$hit/id}">mentions of {$hit-display-name}</a>.</p>,
                                gsh:territories-to-list($hit, (), false(), false())
                            )
                    )
                else 
                    ()
            }
        </div>
    return
        gsh:wrap-html($content, $title)
};


declare function th:contains($territory-id as xs:string) {
    let $hits := gsh:order-territories-chronologically($gsh:territories/territory[contains(id, $territory-id)])
    let $title := concat('Territories whose id contains "', $territory-id, '"')
    let $breadcrumbs := (th:landing-page-breadcrumbs(), <li><a href="#">{$title}</a></li>)
    let $content :=
        <div>
            { gsh:breadcrumbs($breadcrumbs) }
            <p>{count($hits)} territory ids containing "{$territory-id}"</p>
            {
                for $hit in $hits
                let $hit-id := $hit/id
                return
                    (
                        <h3><a href="{gsh:link-to-territory($hit-id)}">{gsh:territory-id-to-short-name-with-years-valid($hit-id)}</a></h3>,
                        <p>Look up <a href="{$gsh:territories-home}?mentions={$hit-id}">mentions of "{$hit-id}"</a>.</p>,
                        gsh:territories-to-list($hit, (), true(), false())
                    )
            }
        </div>
    return
        gsh:wrap-html($content, $title)
};