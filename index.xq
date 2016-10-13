xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

let $title := 'Geospatial History of U.S. Foreign Relations'
let $content := 
    <div>
        <p>Welcome to the {$title}.</p>
        <p>The application and data are in draft form and have not been reviewed for accuracy.</p>
        <ul>
            <li><a href="{$gsh:locales-home}">Locales</a></li>
            <li><a href="{$gsh:posts-home}">Posts</a></li>
            <li><a href="{$gsh:regions-home}">Regions</a></li>
            <li><a href="{$gsh:territories-home}">Territories</a></li>
            <li><a href="{$gsh:app-home}/lineages.xq">Territory Lineages</a></li>
            <li><a href="{$gsh:app-home}/resources">Resources</a></li>
        </ul>
    </div>
return
    gsh:wrap-html($content, $title)