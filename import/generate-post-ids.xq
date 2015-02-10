xquery version "3.0";

let $posts := doc('/db/apps/territories/posts.xml')//post
for $post in $posts
let $url-style-name := 
    replace(
        replace(
            replace(
                translate(lower-case(replace(
                    $post/name, "['’]", '')), 'çô', 'co'),
                '[\s,\(\)\.]+', '-'), 
            '-+', '-'), 
        '-+$', '')
let $id := 
    if ($post/valid-until ne '9999') then 
        concat($url-style-name, '-', if ($post/valid-until eq '') then 'TBD' else $post/valid-until)
    else 
        $url-style-name
order by $id
return
(:    update value $territory/id with $id:)
    $id