xquery version "3.0";

declare variable $local:posts := doc('/db/apps/territories/posts.xml')//post;
declare variable $local:territories := doc('/db/apps/territories/territories.xml')//territory;

for $post in $local:posts
let $id := 
    replace(
        replace(
            replace(
                translate(lower-case(replace(
                    $post/name, "['’]", '')), 'ãçôü', 'acou'),
                '[\s,\(\)\.]+', '-'), 
            '-+', '-'), 
        '-+$', '')
let $post := 
    element post {
        element locale { $id },
        element territory { $post/current-territory/string() },
        $post/post-type,
        $post/valid-since,
        $post/valid-until,
        element events { element event { element type {'opened'}, element date { $post/valid-since/string() } }, if ($post/valid-until lt '9999') then element event { element type {'closed'}, element date { $post/valid-until/string() } } else () }, 
        $post/sources,
        $post/notes
    }
return
if (doc-available(concat('/db/apps/territories/posts/', $id, '.xml'))) then
    xmldb:store('/db/apps/territories/posts/', concat($id, '-fix', '.xml'), $post)
else 
    xmldb:store('/db/apps/territories/posts/', concat($id, '.xml'), $post)