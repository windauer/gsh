xquery version "3.1";

for $territory in collection('/db/apps/gsh/data/territories')/territory
return
    update delete $territory/new-id