xquery version "3.1";

for $territory-id in collection('/db/apps/gsh/data/locales')//current-territory[. ne '']
let $new-id := collection('/db/apps/gsh/data/territories')//old-id[. = $territory-id]/preceding-sibling::id
(:where empty($new-id):)
return 
    update value $territory-id with $new-id/string()
(: element result { $territory-id, $new-id }:)