xquery version "3.0";

module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory";

declare variable $gsh:posts := collection('/db/apps/gsh/data/posts')/post;
declare variable $gsh:locales := collection('/db/apps/gsh/data/locales')/locale;
declare variable $gsh:territories := collection('/db/apps/gsh/data/territories')/territory;

declare function gsh:post-type-id-to-label($type-id) {
    let $post-types := doc('/db/apps/gsh/data/code-tables/post-types.xml')
    return
        $post-types//item[value = $type-id]/label/string()
};

declare function gsh:territory-type-id-to-label($type-id) {
    let $territory-types := doc('/db/apps/gsh/data/code-tables/territory-types.xml')
    return
        $territory-types//item[value = $type-id]/label/string()
};

declare function gsh:territory-id-to-short-name($territory-id) {
    $gsh:territories[id = $territory-id]/short-form-name
};

declare function gsh:territory-id-to-short-name-with-years-valid($territory-id) {
    let $territory := $gsh:territories[id = $territory-id]
    return
        concat(
            $territory/short-form-name, 
            ' (', 
            if ($territory/valid-since ne '') then replace($territory/valid-since, '-', '/') else '?', 
            '-',
             if ($territory/valid-until ne '') then replace($territory/valid-until, '-', '/') else '?',
            ')'
        )
};

declare function gsh:locale-id-to-short-name($locale-id) {
    let $locale := $gsh:locales[id = $locale-id]
    return
        $locale/name/string()
};

declare function gsh:wrap-html($content as element(), $title as xs:string) {
    <html>
        <head>
            <title>{$title}</title>
            <link href="http://netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css" rel="stylesheet"/>
            <style type="text/css">
                body {{ font-family: HelveticaNeue, Helvetica, Arial, sans }}
                table {{ page-break-inside: avoid }}
            </style>
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

declare function gsh:territories-to-table($territories) {
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
            for $territory in $gsh:territories 
            order by $territory/id
            return
                element tr {
                    element td { attribute id { $territory/id }, $territory/id/string() },
                    element td { $territory/short-form-name/string() },
                    element td { 
                        if (empty($territory/long-form-name/node()) and not($territory/long-form-name/@type = 'none')) then 
                            (attribute class {'warning'}, '#')
                        else (),
                        if ($territory/long-form-name/@type="none") then 
                            '-' 
                        else
                            $territory/long-form-name/string() 
                        },
                    element td { 
                        if ($territory/type-of-territory = '') then
                            (attribute class {'warning'}, '#')
                        else (),
                        gsh:territory-type-id-to-label($territory/type-of-territory) 
                        },
                    element td { 
                        if ($territory/valid-since = '' or not(matches($territory/valid-since, '^-?\d{4}(-\d{2})?$'))) then
                            (attribute class {'warning'}, '#')
                        else (),
                        concat($territory/valid-since, if ($territory/valid-since/@precision) then concat(' (±', $territory/valid-since/@precision, ' yrs)') else ())
                        },
                    element td { 
                        if ($territory/valid-until = '' or not(matches($territory/valid-until, '^-?\d{4}(-\d{2})?$'))) then
                            (attribute class {'warning'}, '#')
                        else (),
                        concat(if ($territory/valid-until = '9999') then 'present' else $territory/valid-until, if ($territory/valid-until/@precision) then concat(' (±', $territory/valid-until/@precision, ' yrs)') else ())
                    },
                    element td { 
                        let $predecessors := $territory/predecessors/predecessor 
                        return
                            (
                                if (empty($predecessors) and $territory/valid-since[. eq '' or . gt '1776']) then
                                    (attribute class {'warning'}, '#')
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
                                    (attribute class {'warning'}, '#')
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

declare function gsh:posts-to-table($posts) {
    element table {
        attribute class {'table table-bordered'},
        element thead {
            element tr {
                (:
                element th {
                    'ID'
                },
                :)
                element th {
                    'Name'
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
            let $locale := $gsh:locales[id = $post/locale]
            return
                element tr {
                    element td { $locale/name/string() },
                    element td { $gsh:territories[id = $locale/current-territory]/short-form-name/string() },
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
                    element td { $locale/name/string() },
                    element td { <a href="territories.xq?territory={$locale/current-territory}">{ $gsh:territories[id = $locale/current-territory]/short-form-name/string() }</a> },
                    element td { string-join(tokenize($locale/predecessors, ', '),'; ') },
                    element td { string-join(tokenize($locale/successors, ', '),'; ')},
                    element td { string-join(($locale/latitude, $locale/longitude), ', ') }
                }
        }
    }
};