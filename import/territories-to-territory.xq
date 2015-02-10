xquery version "3.0";

for $territory in doc('/db/apps/territories/territories.xml')//territory
return
    xmldb:store('/db/apps/territories/data/territories', $territory/id || '.xml', $territory)