xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xql";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

declare function local:posts-landing-page($show-all-posts as xs:boolean) {
    let $title := 'Posts By Territory'
    let $content :=
        <div>
            <p>Select a territory from the list below { if ($show-all-posts) then <a href="?">(Show only territory names)</a> else <a href="?show-all-posts=true">(Show all posts)</a>}:</p>
            <ul>{
                for $territory in $gsh:territories[exists-on-todays-map = 'true']
                let $locales := $gsh:locales[current-territory = $territory/id]
                let $posts := $gsh:posts[locale-id = $locales/id]
                let $ordered-posts := 
                    (: don't bother sorting unless necessary :)
                    if ($show-all-posts) then 
                        for $post in $posts 
                        order by $post/locale-id
                        return
                            $post
                    else 
                        $posts
                order by $territory/id
                return
                    <li><a href="?territory={$territory/id}">{$territory/short-form-name/string()}</a> {if ($show-all-posts and count($posts) ge 1) then gsh:posts-to-table($ordered-posts) else concat(' (', count($posts), ' posts)')}</li>
            }</ul>
        </div>
    return
        gsh:wrap-html($content, $title)
};

declare function local:show-posts-in-territory($territory-id as xs:string) {
    let $territory := $gsh:territories[id = $territory-id]
    let $locales := $gsh:locales[current-territory = $territory-id]
    let $posts := $gsh:posts[locale-id = $locales/id]
    let $ordered-posts := 
        for $post in $posts 
        order by $post/locale-id
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
};

declare function local:show-post($locale-id as xs:string) {
    let $post := $gsh:posts[locale-id = $locale-id]
    let $locale := $gsh:locales[id = $locale-id]
    let $table := gsh:posts-to-table($post)
    let $content := 
        <div>
            <p>Return to list of <a href="?">Posts by Territory</a></p>
            {$table}
        </div>
    let $title := $locale/name/string()
    return
        gsh:wrap-html($content, $title)
    
};

let $show-all-posts := xs:boolean(request:get-parameter('show-all-posts', false()))
let $territory-id := request:get-parameter('territory', ())
let $locale-id := request:get-parameter('locale', ())
return
    if ($locale-id) then
        local:show-post($locale-id)
    else if ($territory-id ne '') then
        local:show-posts-in-territory($territory-id)
    else
        local:posts-landing-page($show-all-posts)