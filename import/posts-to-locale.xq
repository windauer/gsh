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
let $locale := 
    element locale {
        element id { $id },
        $post/name,
        $post/current-territory,
        $post/latitude,
        $post/longitude,
        $post/predecessors,
        $post/successors,
        element alternate-names { element alternate-name { element label {()}, element notes {()} } }
    }
return
if (doc-available(concat('/db/apps/territories/locales/', $id, '.xml'))) then
    xmldb:store('/db/apps/territories/locales/', concat($id, '-fix', '.xml'), $locale)
else 
    xmldb:store('/db/apps/territories/locales/', concat($id, '.xml'), $locale)