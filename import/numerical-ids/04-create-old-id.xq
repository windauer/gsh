xquery version "3.1";

for $territory in collection('/db/apps/gsh/data/territories')/territory
return
    update insert element old-id {$territory/id/string()} following $territory/new-id