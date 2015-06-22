xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace p8n="http://history.state.gov/ns/xquery/pagination" at "/db/apps/gsh/modules/pagination.xqm";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

declare function local:show-locale($locale-id) {
    let $locale := $gsh:locales[id = $locale-id]
    let $title := $locale/name/string()
    let $content := 
        <div>
            <ol class="breadcrumb">
                <li><a href="{$gsh:app-home}">Home</a></li>
                <li><a href="{$gsh:locales-home}">Locales</a></li>
                <li class="active">{$title}</li>
            </ol>
            {gsh:locales-to-table($locale)}
        </div>
    return
        gsh:wrap-html($content, $title)
};

declare function local:browse-locales($q, $start, $per-page, $show-all) {
    let $all-locales := 
        if ($q) then 
            $gsh:locales[ft:query(name, $q)]
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
    let $params-for-show-all := p8n:strip-parameters(request:get-query-string(), ('per-page', 'start'))
    let $content := 
        <div>
            <ol class="breadcrumb">
                <li><a href="{$gsh:app-home}">Home</a></li>
                <li><a href="{$gsh:locales-home}">Locales</a></li>
            </ol>
            <form class="form-inline">
                <div class="input-group">
                    <input name="q" type="search" class="form-control" placeholder="Search locales..." value="{$q}"/>
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
let $q := request:get-parameter('q', ())
let $start := request:get-parameter('start', 1)
let $per-page := request:get-parameter('per-page', 10)
let $show-all := request:get-parameter('show-all', false())
return
    if ($locale-id) then
        local:show-locale($locale-id)
    else
        local:browse-locales($q, $start, $per-page, $show-all)
