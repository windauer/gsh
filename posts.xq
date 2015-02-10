xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xql";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

let $show-all-posts := request:get-parameter('show-all-posts', ())
let $territory-id := request:get-parameter('territory', ())
return
    if ($territory-id = '' or empty($territory-id)) then
        let $title := 'Posts By Territory'
        let $content :=
            <div>
                <p>Select a territory from the list below { if ($show-all-posts) then <a href="?">(Show only territory names)</a> else <a href="?show-all-posts=true">(Show all posts)</a>}:</p>
                <ul>{
                    for $territory in $gsh:territories[exists-on-todays-map = 'true']
                    let $locales := $gsh:locales[current-territory = $territory/id]
                    let $posts := $gsh:posts[locale = $locales/id]
                    let $ordered-posts := 
                        for $post in $posts 
                        order by $post/locale
                        return
                            $post
                    return
                        <li><a href="?territory={$territory/id}">{$territory/short-form-name}</a> {if ($show-all-posts and count($posts) ge 1) then gsh:posts-to-table($ordered-posts) else concat(' (', count($posts), ' posts)')}</li>
                }</ul>
            </div>
        return
            gsh:wrap-html($content, $title)
    else
        let $territory := $gsh:territories[id = $territory-id]
        let $locales := $gsh:locales[current-territory = $territory-id]
        let $posts := $gsh:posts[locale = $locales/id]
        let $ordered-posts := 
            for $post in $posts 
            order by $post/locale
            return
                $post
        let $table := gsh:posts-to-table($ordered-posts)
        let $content := 
            <div>
                <p>Return to list of <a href="?">Posts by Territory</a></p>
                <p>{count($posts)} in {$territory/short-form-name/string()}:</p>
                {$table}
            </div>
        let $title := concat('Posts in ', $territory/short-form-name)
        return
            gsh:wrap-html($content, $title)