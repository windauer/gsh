xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace p8n="http://history.state.gov/ns/xquery/pagination" at "/db/apps/gsh/modules/pagination.xqm";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

declare function local:landing-page-breadcrumbs() {
    <li><a href="{$gsh:locales-home}">Locales</a></li>
};

declare function local:locale-breadcrumbs($locale-id) {
    (
    local:landing-page-breadcrumbs(),
    <li><a href="{gsh:link-to-locale($locale-id)}">{gsh:locale-id-to-short-name($locale-id)}</a></li>
    )
};

declare function local:locales-within-territory-breadcrumbs($territory-id) {
    (
    local:landing-page-breadcrumbs(),
    <li><a href="{concat($gsh:locales-home, '?territory=', $territory-id)}">Within {gsh:territory-id-to-short-name($territory-id)}</a></li>
    )
};

declare function local:show-locale($locale-id) {
    let $locale := $gsh:locales[id = $locale-id]
    let $title := $locale/name/string()
    let $breadcrumbs := local:locale-breadcrumbs($locale-id)
    let $content := 
        <div>
            {gsh:breadcrumbs($breadcrumbs)}
            {gsh:locales-to-table($locale)}
        </div>
    return
        gsh:wrap-html($content, $title)
};

declare function local:show-locales-within-territory($territory-id) {
    let $locales := $gsh:locales[current-territory = $territory-id]
    let $title := gsh:territory-id-to-short-name($territory-id)
    let $breadcrumbs := local:locales-within-territory-breadcrumbs($territory-id)
    let $content := 
        <div>
            <p>{count($locales)} within {$title}.</p>
            {gsh:breadcrumbs($breadcrumbs)}
            {gsh:locales-to-table($locales)}
        </div>
    return
        gsh:wrap-html($content, $title)
};

declare function local:browse-locales($q, $territory, $start, $per-page, $show-all) {
    let $all-locales := 
        if ($q) then 
            $gsh:locales[ft:query(name, $q)]
        else if ($territory) then
            let $territories := $gsh:territories/territory[ft:query(short-form-name, $territory) or ft:query(long-form-name, $territory)]/id
            return
                $gsh:locales[current-territory = $territories]
        else 
            $gsh:locales
    let $ordered-locales := for $locale in $all-locales order by $locale/id return $locale
    let $locales-to-show := if ($show-all) then $ordered-locales else subsequence($ordered-locales, $start, $per-page)
    let $href := function($start, $per-page) { 
        concat('?', 
            string-join(
                (
                if ($q) then concat('q=', $q) else (), 
                concat('start=', $start), 
                if ($per-page ne 10) then concat('per-page=', $per-page) else ()
                ), 
                '&amp;')
            )
        }
    let $table := gsh:locales-to-table($locales-to-show)
    let $params-sans-per-page := p8n:strip-parameters(request:get-query-string(), ('per-page', 'show-all'))
    let $params-for-show-all := p8n:strip-parameters(request:get-query-string(), ('per-page', 'start', 'show-all'))
    let $breadcrumbs := gsh:breadcrumbs((<li><a href="{$gsh:locales-home}">Locales</a></li>, if ($q) then <li>{$q}</li> else if ($territory) then <li>Within {$territory}</li> else ()))
    let $content := 
        <div>
            { $breadcrumbs }
            <form class="form-inline">
                <div class="input-group">
                    <input name="q" type="search" class="form-control" placeholder="Search locales..." value="{$q}"/>
                </div>
                <div class="input-group">
                    <input name="territory" type="search" class="form-control" placeholder="Search by territory..." value="{$territory}"/>
                </div>
                <div class="input-group">
                    <div class="dropdown">
                        <button class="btn btn-default dropdown-toggle" type="button" id="per-page" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            Results per page
                            <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu" aria-labelledby="per-page">
                            <li><a href="?{$params-sans-per-page}">10</a></li>
                            <li><a href="?{string-join(($params-sans-per-page, 'per-page=25'), '&amp;')}">25</a></li>
                            <li><a href="?{string-join(($params-sans-per-page, 'per-page=100'), '&amp;')}">100</a></li>
                            <li><a href="?{string-join(($params-for-show-all, 'show-all=true'), '&amp;')}">All</a></li>
                        </ul>
                    </div>
                </div>
                <input class="btn btn-default" type="submit" value="Submit"/>
            </form>
            <p>{if ($show-all) then concat('All ', count($all-locales), ' locales.') else p8n:summarize($start, $per-page, count($all-locales))}</p>
            { $table }
            { if ($show-all) then () else p8n:paginate($start, $per-page, count($all-locales), $href) }
        </div>
    let $title := 'Locales'
    return
        gsh:wrap-html($content, $title)
};

let $locale-id := request:get-parameter('locale', ())
let $territory := request:get-parameter('territory', ())
let $q := request:get-parameter('q', ())
let $start := request:get-parameter('start', 1)
let $per-page := request:get-parameter('per-page', 10)
let $show-all := request:get-parameter('show-all', false())
return
    if ($locale-id) then
        local:show-locale($locale-id)
    else
        local:browse-locales($q, $territory, $start, $per-page, $show-all)
