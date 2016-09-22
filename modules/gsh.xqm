xquery version "3.0";

module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory";

import module namespace counter="http://exist-db.org/xquery/counter" at "xmldb:exist://java:org.exist.xquery.modules.counter.CounterModule";


(: core data access api :)

declare variable $gsh:locales := collection('/db/apps/gsh/data/locales')/locale;
declare variable $gsh:posts := collection('/db/apps/gsh/data/posts')/post;
declare variable $gsh:regions := collection('/db/apps/gsh/data/regions')/region;
declare variable $gsh:territories := collection('/db/apps/gsh/data/territories');

declare variable $gsh:post-types := doc('/db/apps/gsh/data/code-tables/post-types.xml');
declare variable $gsh:territory-types := doc('/db/apps/gsh/data/code-tables/territory-types.xml');


(: functions for creating links :)

declare variable $gsh:app-home := '/exist/apps/gsh';

declare variable $gsh:locales-home := $gsh:app-home || '/locales';
declare variable $gsh:posts-home := $gsh:app-home || '/posts';
declare variable $gsh:regions-home := $gsh:app-home || '/regions';
declare variable $gsh:territories-home := $gsh:app-home || '/territories';

declare function gsh:link-to-locale($locale-id) {
    $gsh:locales-home || '/' || $locale-id
};
declare function gsh:link-to-territory($territory-id) {
    $gsh:territories-home || '/' || $territory-id
};
declare function gsh:link-to-post($post-id) {
    $gsh:posts-home || '/' || $post-id
};
declare function gsh:link-to-region($region-id) {
    $gsh:regions-home || '/' || $region-id
};


(: main html wrapper :)

declare function gsh:wrap-html($content as element(), $title as xs:string) {
    <html>
        <head>
            <title>{$title}</title>
            <!-- Latest compiled and minified CSS -->
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous" />

            <!-- Optional theme -->
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous" />

            <!-- Latest compiled and minified JavaScript -->
            <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
            <style type="text/css">
                body {{ font-family: HelveticaNeue, Helvetica, Arial, sans }}
                table {{ page-break-inside: avoid }}
                dl {{ margin-above: 1em }}
                dt {{ font-weight: normal }}
            </style>
            <link href="{$gsh:app-home}/family-tree.css" rel="stylesheet"/>
            <style type="text/css" media="print">
                a, a:visited {{ text-decoration: underline; color: #428bca; }}
                a[href]:after {{ content: "" }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>{$title}</h1>
                {$content}
            </div>
        </body>
    </html>    
};

declare function gsh:breadcrumbs($links as element(li)*) {
    <ol class="breadcrumb">
        {
        let $all-links := (<li><a href="{$gsh:app-home}">Home</a></li>, $links)
        let $link-count := count($all-links)
        for $link at $n in $all-links
        return
            if ($n = $link-count) then
                <li class="active">{$link/string()}</li>
            else 
                $link
        }
    </ol>
};

(: functions for accessing territories :)

declare function gsh:territories($territory-ids as xs:string*) {
    $gsh:territories/territory[id = $territory-ids]
};

declare function gsh:post-type-id-to-label($type-id) {
    $gsh:post-types//item[value = $type-id]/label/string()
};

declare function gsh:territory-type-id-to-label($type-id) {
    $gsh:territory-types//item[value = $type-id]/label/string()
};

declare function gsh:territory-id-to-short-name($territory-id as xs:string) {
    gsh:territories($territory-id)/short-form-name
};

declare function gsh:territory-id-to-short-name-with-years-valid($territory-id as xs:string) {
    let $territory := gsh:territories($territory-id)
    return
        concat(
            $territory/short-form-name, 
            ' (', 
            if ($territory/valid-since ne '') then if (starts-with($territory/valid-since, '-')) then $territory/valid-since/string() else replace($territory/valid-since, '-', '/') else '?', 
            '–',
             if ($territory/valid-until ne '') then if ($territory/valid-until = '9999') then 'present' else replace($territory/valid-until, '-', '/') else '?',
            ')'
        )
};

declare function gsh:order-territories-chronologically($territories as element(territory)*) {
    for $territory in $territories
    order by $territory/valid-since, $territory/id
    return
        $territory
};

declare function gsh:locale-id-to-short-name($locale-id) {
    let $locale := $gsh:locales[id = $locale-id]
    return
        $locale/name/string()
};

declare function gsh:territories-to-table($territories, $counter-name) {
    element table {
        attribute class {'table table-bordered'},
        element thead {
            element tr {
                element th {
                    'ID'
                },
                element th {
                    'Short Form Name'
                },
                element th {
                    'Long Form Name'
                },
                element th {
                    'Type of Territory'
                },
                element th {
                    'Valid Since'
                },
                element th {
                    'Valid Until'
                },
                element th {
                    'Predecessors'
                },
                element th {
                    'Successors'
                },
                element th {
                    'Notes'
                },
                element th {
                    'Sources'
                }
            }
        },
        element tbody {
            for $territory in $territories 
            (:order by $territory/id:)
            return
                element tr {
                    element td { attribute id { $territory/id }, $territory/id/string() },
                    element td { $territory/short-form-name/string() },
                    element td { 
                        if (empty($territory/long-form-name/node()) and not($territory/long-form-name/@type = 'none')) then 
                            (attribute class {'warning'}, concat('[#', counter:next-value($counter-name), ']'))
                        else (),
                        if ($territory/long-form-name/@type="none") then 
                            '-' 
                        else
                            $territory/long-form-name/string() 
                        },
                    element td { 
                        if ($territory/type-of-territory = '') then
                            (attribute class {'warning'}, concat('[#', counter:next-value($counter-name), ']'))
                        else (),
                        gsh:territory-type-id-to-label($territory/type-of-territory) 
                        },
                    element td { 
                        if ($territory/valid-since = '' or not(matches($territory/valid-since, '^-?\d{4}(-\d{2})?$'))) then
                            (attribute class {'warning'}, concat('[#', counter:next-value($counter-name), ']'))
                        else (),
                        concat($territory/valid-since, if ($territory/valid-since/@precision) then concat(' (±', $territory/valid-since/@precision, ' yrs)') else ())
                        },
                    element td { 
                        if ($territory/valid-until = '' or not(matches($territory/valid-until, '^-?\d{4}(-\d{2})?$'))) then
                            (attribute class {'warning'}, concat('[#', counter:next-value($counter-name), ']'))
                        else (),
                        concat(if ($territory/valid-until = '9999') then 'present' else $territory/valid-until, if ($territory/valid-until/@precision) then concat(' (±', $territory/valid-until/@precision, ' yrs)') else ())
                    },
                    element td { 
                        let $predecessors := $territory/predecessors/predecessor 
                        return
                            (
                                if (empty($predecessors) and $territory/valid-since[. eq '' or . gt '1776']) then
                                    (attribute class {'warning'}, concat('[#', counter:next-value($counter-name), ']'))
                                else (),
                                if ($predecessors) then
                                    if (count($predecessors) gt 1) then
                                        <ol style="padding-left: 1.5em">{
                                            for $predecessor at $n in $predecessors 
                                            return 
                                                element li { 
                                                    element a { 
                                                        attribute href { concat('#', $predecessor) }, 
                                                        gsh:territory-id-to-short-name-with-years-valid($predecessor) 
                                                        }
                                                }
                                        }</ol>
                                    else
                                        element a { 
                                            attribute href { concat('#', $predecessors) }, 
                                            gsh:territory-id-to-short-name-with-years-valid($predecessors) 
                                            }
                                else ()
                            )
                        },
                    element td { 
                        let $successors := $territory/successors/successor 
                        return
                            (
                                if (empty($successors) and $territory/valid-until ne '9999') then
                                    (attribute class {'warning'}, concat('[#', counter:next-value($counter-name), ']'))
                                else (),
                                if ($successors) then
                                    if (count($successors) gt 1) then 
                                        <ol style="padding-left: 1.5em">{
                                            for $successor at $n in $successors
                                            return 
                                                element li { 
                                                    element a { 
                                                        attribute href { concat('#', $successor) }, 
                                                        gsh:territory-id-to-short-name-with-years-valid($successor) 
                                                        }
                                                }
                                        }</ol>
                                    else
                                        element a { 
                                            attribute href { concat('#', $successors) }, 
                                            gsh:territory-id-to-short-name-with-years-valid($successors) 
                                            }
                                else ()
                            )
                        },
                    element td { $territory/notes/string() },
                    element td { 
                        let $sources := $territory/sources/source 
                        for $source at $n in $sources
                        return 
                            if (starts-with($source, 'http')) then 
                                let $strip-scheme := substring-before(substring-after($source, '//'), '/')
                                let $strip-www := if (starts-with($strip-scheme, 'www.')) then substring-after($strip-scheme, 'www.') else $strip-scheme
                                return
                                    (
                                    <a href="{$source}">{$strip-www}</a>, 
                                    if ($n lt count($sources)) then <br/> else ()
                                    ) 
                            else 
                                $source 
                        }
                }
        }
    }
};

declare function gsh:generate-warning($counter-name, $message) {
    <span style="background-color: yellow">{concat('&#9744; ', if ($counter-name) then concat('#', counter:next-value($counter-name), ': ') else (), $message)}</span>
};

declare function gsh:territories-to-list($territories, $counter-name, $enable-link-territories as xs:boolean) {
    for $territory in $territories 
    (:order by $territory/id:)
    return
        element dl {
            attribute class {'dl-horizontal'},
            (:attribute style {'border-top: 1px black solid'},:)
            (
            element dt {
                'Short Form Name'
            },
            element dd { 
                attribute style {'font-weight: bold'},
                gsh:territory-id-to-short-name-with-years-valid($territory/id) 
            },
            element dt {
                'Long Form Name'
            },
            element dd { 
                let $warning := (empty($territory/long-form-name/node()) and not($territory/long-form-name/@type = 'none'))
                return
                    (
                    if ($warning) then gsh:generate-warning($counter-name, 'expected a long form name; if none, please note it') else ()
                    ,
                    if ($territory/long-form-name/@type="none") then 
                        '-' 
                    else
                        $territory/long-form-name/string() 
                    )
            },
            element dt {
                'Type of Territory'
            },
            element dd { 
                let $warning := $territory/type-of-territory = ''
                return
                    (
                    if ($warning) then gsh:generate-warning($counter-name, 'independent or dependent/special') else ()
                    ,
                    gsh:territory-type-id-to-label($territory/type-of-territory)
                    )
                },
            element dt {
                'Valid Since'
                },
            element dd { 
                let $warning := ($territory/valid-since = '' or not(matches($territory/valid-since, '^-?\d{3,4}(-\d{2})?$')))
                return
                    (
                    if ($warning) then gsh:generate-warning($counter-name, 'expected a valid since date') else ()
                    ,
                    concat($territory/valid-since, if ($territory/valid-since/@precision) then concat(' (±', $territory/valid-since/@precision, ' yrs)') else ())
                    )
            },
            element dt {
                'Valid Until'
            },
            element dd { 
                let $warning := ($territory/valid-until = '' or not(matches($territory/valid-until, '^-?\d{4}(-\d{2})?$'))) 
                return
                    (
                    if ($warning) then gsh:generate-warning($counter-name, 'expected a valid until date') else ()
                    ,
                    concat(if ($territory/valid-until = '9999') then 'present' else $territory/valid-until, if ($territory/valid-until/@precision) then concat(' (±', $territory/valid-until/@precision, ' yrs)') else ())
                    )
            },
            element dt {
                'Predecessors'
            },
            element dd { 
                let $predecessors := $territory/predecessors/predecessor 
                let $warning := (empty($predecessors) and $territory/valid-since[. eq '' or xs:integer(.) gt 1776])
                return
                    (
                    if ($warning) then gsh:generate-warning($counter-name, 'expected a predecessor') else ()
                    ,
                    if ($predecessors) then
                        if (count($predecessors) gt 1) then
                            <ol style="padding-left: 1.5em">{
                                for $predecessor at $n in $predecessors 
                                let $display := gsh:territory-id-to-short-name-with-years-valid($predecessor)
                                let $warning := 
                                    if (gsh:territories($predecessor)/valid-until = '') then 
                                        gsh:generate-warning($counter-name, 'Expected a valid until date')                                    
                                    else if (substring(gsh:territories($predecessor)/valid-until, 1, 4) lt substring($territory/valid-since, 1, 4)) then 
                                        gsh:generate-warning($counter-name, concat('Based on valid-until date of ', gsh:territories($predecessor)/valid-until, ', this is not a direct predecessor and should be removed'))
                                    else 
                                        ()
                                return 
                                    element li { 
                                        if ($enable-link-territories) then
                                            element a { 
                                                attribute href { gsh:link-to-territory($predecessor) },
                                            $display
                                            }
                                        else 
                                            $display
                                        ,
                                        $warning
                                    }
                            }</ol>
                        else
                            let $display := gsh:territory-id-to-short-name-with-years-valid($predecessors) 
                            let $warning := 
                                if (gsh:territories($predecessors)/valid-until = '') then 
                                        gsh:generate-warning($counter-name, 'Expected valid dates')                                                else if (substring(gsh:territories($predecessors)/valid-until, 1, 4) lt substring($territory/valid-since, 1, 4)) then
                                    gsh:generate-warning($counter-name, concat('Based on valid-until date of ', gsh:territories($predecessors)/valid-until, ', this is not a direct predecessor and should be removed'))
                                else 
                                    ()
                            return
                                (
                                if ($enable-link-territories) then
                                    element a { 
                                        attribute href { gsh:link-to-territory($predecessors) },
                                        $display
                                    }
                                else 
                                    $display
                                ,
                                $warning
                                )
                    else if ($warning) then 
                        ()
                    else
                        '-'
                    )
                },
            element dt {
                'Successors'
            },
            element dd { 
                let $successors := $territory/successors/successor 
                let $warning := (empty($successors) and $territory/valid-until ne '9999')
                return
                    (
                    if ($warning) then gsh:generate-warning($counter-name, 'expected a successor') else ()
                    ,
                    if ($successors) then
                        if (count($successors) gt 1) then 
                            <ol style="padding-left: 1.5em">{
                                for $successor at $n in $successors 
                                let $display := gsh:territory-id-to-short-name-with-years-valid($successor)
                                let $warning := 
                                    if (gsh:territories($successor)/valid-since = '') then 
                                        gsh:generate-warning($counter-name, 'Expected a valid date')                                    
                                    else if (substring(gsh:territories($successor)/valid-since, 1, 4) gt substring($territory/valid-until, 1, 4)) then
                                        gsh:generate-warning($counter-name, concat('Based on valid-since date of ', gsh:territories($successor)/valid-since, ', this is not a direct successor and should be removed'))
                                    else 
                                        ()
                                return 
                                    element li { 
                                        if ($enable-link-territories) then
                                            element a { 
                                                attribute href { gsh:link-to-territory($successor) },
                                                $display
                                            }
                                        else 
                                            $display
                                    ,
                                    $warning
                                    }
                            }</ol>
                        else
                            let $display := gsh:territory-id-to-short-name-with-years-valid($successors)
                            let $warning := 
                                if (gsh:territories($successors)/valid-since = '') then 
                                    gsh:generate-warning($counter-name, 'Expected a valid date')                                    
                                else if (substring(gsh:territories($successors)/valid-since, 1, 4) gt substring($territory/valid-until, 1, 4)) then
                                    gsh:generate-warning($counter-name, concat('Based on valid-since date of ', gsh:territories($successors)/valid-since, ', this is not a direct successor and should be removed'))
                                else 
                                    ()
                            return
                                (
                                if ($enable-link-territories) then
                                    element a { 
                                        attribute href { gsh:link-to-territory($successors) },
                                        $display
                                    }
                                else
                                    $display
                                ,
                                $warning
                                )
                    else if ($warning) then 
                        ()
                    else 
                        '-'
                    )
                },
            element dt {
                'Notes'
            },
            element dd { 
                if ($territory/notes ne '') then $territory/notes/string() else '-' 
            },
            element dt {
                'Sources'
            },
            element dd { 
                let $sources := $territory/sources/source 
                for $source at $n in $sources
                return 
                    if (starts-with($source, 'http')) then 
                        let $strip-scheme := substring-after($source, '//')
                        let $strip-www := if (starts-with($strip-scheme, 'www.')) then substring-after($strip-scheme, 'www.') else $strip-scheme
                        return
                            (
                            <a href="{$source}">{(:$strip-www:)$strip-scheme}</a>, 
                            if ($n lt count($sources)) then <br/> else ()
                            ) 
                    else 
                        $source 
                },
            element dt {
                'ID'
            },
            element dd { 
                attribute id { $territory/id }, 
                $territory/id/string() 
            }
            )
        }
};


(: functions for accessing posts :)

declare function gsh:posts-to-table($posts) {
    element table {
        attribute class {'table table-bordered'},
        element thead {
            element tr {
                element th {
                    'Locale ID'
                },
                element th {
                    'Locale Name'
                },
                element th {
                    'Current Territory'
                },
                element th {
                    'Valid Since'
                },
                element th {
                    'Valid Until'
                },
                element th {
                    'Predecessors'
                },
                element th {
                    'Successors'
                },
                element th {
                    'Type of Post'
                },
                element th {
                    'Notes'
                },
                element th {
                    'Sources'
                },
                element th {
                    'Geocoordinates'
                }
            }
        },
        element tbody {
            for $post in $posts
            let $locale := $gsh:locales[id = $post/locale-id][1] (: TODO eliminate duplicate locale-ids, e.g., sydney - australia and canada :)
            (: NOTE we look up territory info from the locale record, not from the item here :)
            let $territory := gsh:territories($locale/current-territory)
            return
                element tr {
                    element td { $locale/id/string() },
                    element td { 
                        element a {
                            attribute href { gsh:link-to-locale($locale/id) },
                            $locale/name/string() 
                        }
                    },
                    element td { 
                        element a {
                            attribute href { gsh:link-to-territory($territory/id)  },
                            gsh:territory-id-to-short-name-with-years-valid($territory/id) 
                        }
                    },
                    element td { $post/valid-since/string() },
                    element td { if ($post/valid-until = '9999') then 'present' else $post/valid-until/string() },
                    element td { string-join(tokenize($locale/predecessors, ', '),'; ') },
                    element td { string-join(tokenize($locale/successors, ', '),'; ')},
                    element td { gsh:post-type-id-to-label($post/post-type) },
                    element td { $post/notes/string() },
                    element td { 
                        let $sources := $post/sources/source 
                        for $source at $n in $sources
                        return 
                            if (starts-with($source, 'http')) then 
                                let $strip-scheme := substring-after($source, '//')
                                let $strip-www := if (starts-with($strip-scheme, 'www.')) then substring-after($strip-scheme, 'www.') else $strip-scheme
                                return
                                    (
                                    <a href="{$source}">{xmldb:decode-uri($strip-www)}</a>, 
                                    if ($n lt count($sources)) then <br/> else ()
                                    ) 
                            else 
                                $source 
                        },
                    element td { string-join(($locale/latitude, $locale/longitude), ', ') }
                }
        }
    }
};


(: functions for accessing locales :)

declare function gsh:locales-to-table($locales) {
    element table {
        attribute class {'table table-bordered'},
        element thead {
            element tr {
                element th {
                    'ID'
                },
                element th {
                    'Name'
                },
                element th {
                    'Current Territory'
                },
                element th {
                    'Predecessors'
                },
                element th {
                    'Successors'
                },
                element th {
                    'Geocoordinates'
                }
            }
        },
        element tbody {
            for $locale in $locales 
            return
                element tr {
                    element td { $locale/id/string() },
                    element td { <a href="{gsh:link-to-locale($locale/id)}">{$locale/name/string()}</a> },
                    element td { <a href="{gsh:link-to-territory($locale/current-territory)}">{ $gsh:territories/territory[id = $locale/current-territory]/short-form-name/string() }</a> },
                    element td { string-join(tokenize($locale/predecessors, ', '),'; ') },
                    element td { string-join(tokenize($locale/successors, ', '),'; ')},
                    element td { string-join(($locale/latitude, $locale/longitude), ', ') }
                }
        }
    }
};

(: functions for accessing regions :)

declare function gsh:regions($region-ids) {
    $gsh:regions[id = $region-ids]
};

declare function gsh:region-id-to-label($region-id) {
    let $region := gsh:regions($region-id)
    return
        $region/label/string()
};