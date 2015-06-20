xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xql";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

let $title := 'Geospatial History of U.S. Posts'
let $content := 
    <div>
        <p>Welcome to the {$title}.</p>
        <p>The application and data are in draft form and have not been reviewed for accuracy.</p>
        <ul>
            <li><a href="locales.xq">Locales</a></li>
            <li><a href="posts.xq">Posts</a></li>
            <li><a href="regions.xq">Regions</a></li>
            <li><a href="territories.xq">Territories</a></li>
        </ul>
    </div>
return
    gsh:wrap-html($content, $title)