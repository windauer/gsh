xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace th="http://history.state.gov/ns/xquery/territories-html" at "/db/apps/gsh/modules/territories-html.xqm";
import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";


let $title := 'Resources'
let $territories := $gsh:territories/territory[exists-on-todays-map = 'true'][type-of-territory = 'independent-state']
let $breadcrumbs := gsh:breadcrumbs(<li><a href="{$gsh:app-home}/resources.xq">{$title}</a></li>)
let $content :=
    element div {
        attribute class { 'row' },
        $breadcrumbs,
        element p { 'Resources for ', concat(count($territories), ' independent states on today’s map.') },
        element table {
            attribute class {'col-md-8 table table-bordered table-striped table-condensed table-hover'},
            element thead {
                element tr {
                    element th {
                        attribute class { 'col-md-2' },
                        'Territory'
                    },
                    element th {
                        attribute class { 'col-md-1' },
                        'R&amp;R'
                    },
                    element th {
                        attribute class { 'col-md-1' },
                        'P&amp;C'
                    },
                    element th {
                        attribute class { 'col-md-1' },
                        'Travels/Pres'
                    },
                    element th {
                        attribute class { 'col-md-1' },
                        'Travels/Secs'
                    },
                    element th {
                        attribute class { 'col-md-1' },
                        'Visits'
                    },
                    element th {
                        attribute class { 'col-md-1' },
                        'Tags'
                    }
                }
            },
            element tbody {
                for $territory in $territories
                let $territory-id := $territory/id
                let $name := gsh:territory-id-to-short-name($territory-id)
                order by $name
                return
                    element tr {
                        element td {
                            element a { 
                                attribute href { gsh:link-to-territory($territory-id) },
                                $name 
                            }
                        },
                        element td {
                            if (doc(concat('/db/apps/rdcr/articles/', $territory-id, '.xml'))) then
                                (
                                attribute class { 'success' },
                                <a href="/exist/apps/hsg-shell/countries/{$territory-id}">Yes</a>
                                )
                            else
                                (
                                attribute class { 'danger' },
                                'no'
                                )
                        },
                        element td {
                            if (doc(concat('/db/apps/pocom/missions-countries/', $territory-id, '.xml'))) then
                                (
                                attribute class { 'success' },
                                <a href="/exist/apps/hsg-shell/departmenthistory/people/chiefsofmission/{$territory-id}">Yes</a>
                                )
                            else
                                (
                                attribute class { 'danger' },
                                'no'
                                )
                        },
                        element td {
                            if (collection('/db/apps/travels/president-travels')//country/@id = $territory-id) then
                                (
                                attribute class { 'success' },
                                <a href="/exist/apps/hsg-shell/departmenthistory/travels/presidents/{$territory-id}">Yes</a>
                                )
                            else
                                (
                                attribute class { 'danger' },
                                'no'
                                )
                        },
                        element td {
                            if (collection('/db/apps/travels/secretary-travels')//country/@id = $territory-id) then
                                (
                                attribute class { 'success' },
                                <a href="/exist/apps/hsg-shell/departmenthistory/travels/secretaries/{$territory-id}">Yes</a>
                                )
                            else
                                (
                                attribute class { 'danger' },
                                'no'
                                )
                        },
                        element td {
                            if (collection('/db/apps/visits/data/')//from/@id = $territory-id) then
                                (
                                attribute class { 'success' },
                                <a href="/exist/apps/hsg-shell/departmenthistory/visits/{$territory-id}">Yes</a>
                                )
                            else
                                (
                                attribute class { 'danger' },
                                'no'
                                )
                        },
                        element td {
                            if (doc('/db/apps/tags/taxonomy/taxonomy.xml')//id = $territory-id) then
                                (
                                attribute class { 'success' },
                                <a href="/exist/apps/hsg-shell/tags/{$territory-id}">Yes</a>
                                )
                            else
                                (
                                attribute class { 'danger' },
                                'no'
                                )
                        }
                    }
            }
        }
    }
return
    gsh:wrap-html($content, $title)