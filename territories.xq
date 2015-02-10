xquery version "3.0";

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xql";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

let $ordered-territories := 
    for $territory in $gsh:territories 
    order by $territory/id
    return
        $territory
let $table := gsh:territories-to-table($ordered-territories)
let $summary := 
    <p>{count($gsh:territories)} territories; 
        {count($gsh:territories[exists-on-todays-map = 'true'])} from today's map and 
        {count($gsh:territories[exists-on-todays-map = 'false'])} from the past 
        ({count($gsh:territories[exists-on-todays-map = ''])} not yet determined);
        {count($gsh:territories[type-of-territory = 'independent-state'])} independent states and
        {count($gsh:territories[type-of-territory = 'dependency-or-area-of-special-sovereignty'])} dependencies or area of special sovereignty
        ({count($gsh:territories[type-of-territory = ''])} not yet determined).
    </p>
let $content := 
    <div>
        <p>This table contains the data from VSFS spreadsheet submissions through May 5, 2014. 
            The submissions have been incorporated into a master XML document, with the following features:</p>
        <ol>
            <li>A unique identifier has been assigned to each territory, derived from its short form name.
                These identifiers help us distinguish territories with the same or similar short form name, 
                and especially help distinguish present-day territories from those that are no longer on today's map. 
                For example, there are two entries for "Cyprus", one for the pre-1960 dependency 
                    and one for the present-day, independent country. 
                Present-day Cyprus's identifier is "cyprus", and its predecessor, Cyprus (-1960), 
                has the identifier "cyprus-1960".
                All historical territories have had their "valid-until" year appended to the identifier.
                In cases where the dataset does not yet have a "valid-until" date, "-TBD" has been appended.  
                As the "valid-until" dates are completed, we will update these historical territories' identifiers 
                to replace "-TBD" with the "valid-since" year. 
            </li>
            <li>Valid since and valid until dates have been normalized to YYYY form, with months appended 
                as YYYY-MM where they appear. 
                B.C.E. years are expressed as -YYYY (e.g., "800 BCE" is "-0800"). 
                In cases where the precision of a date is less than 1 year, 
                the level of precision is captured with a @precision attribute; 
                for example, "early 16th century" is stored as "1625" with a precision of "25" 
                – and rendered as 1625 ± 25 years. 
                Valid until values of 9999 are rendered as "present."
            </li>
            <li>Highlighting has been applied to cells to help focus our efforts on the remaining items that appear to require completion:
                <ul>
                    <li>Long form name: If empty and not supplied as "(no long form name)" (now indicated with a dash)</li>
                    <li>Type of territory: If empty</li>
                    <li>Valid since and valid until: If empty or if doesn't match YYYY(-MM)</li>
                    <li>Predecessors: If empty and the valid since date is after 1776</li>
                    <li>Successors: If empty and the valid until date is before 9999</li>
                </ul>
            </li>
            <li>To facilitate searching for all highlighted issues that need attention, the number character ("#") appears in all highlighted cells. 
                (Of course, we can still revise any of the data; it needn't be highlighted.)
            </li>
        </ol>
        {$summary}
        {$table}
    </div>
let $title := concat('Historical Territory Names Database - ', format-date(adjust-date-to-timezone(current-date(), ()), '[MNn] [D], [Y]'))
return
    gsh:wrap-html($content, $title)