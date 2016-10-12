xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

$gsh:territories/territory[exists-on-todays-map = 'true'][matches(id, '\d')]