xquery version "3.1";

let $documents := collection('/db/apps/gsh/data/territories')/territory
let $elements := collection('/db/apps/gsh/data/territories')//*
let $attributes := collection('/db/apps/gsh/data/territories')//@*
let $distinct-element-names := distinct-values($elements/name())
let $distinct-attribute-names := distinct-values($attributes/name())
return
    element report {
        element documents {
            element count { count($documents) }
        },
        element elements {
            for $element in $distinct-element-names
            let $count := count($elements[name() = $element])
            return
                element element { 
                    element name { $element },
                    element count { $count }
                }
        },
        element attributes {
            for $a in $distinct-attribute-names
            let $as := $attributes[name() = $a]
            let $count := count($as)
            let $parents := $as/../name()
            return
                element attribute { 
                    element name { $a },
                    element count { $count },
                    element parents { string-join(distinct-values($parents), '; ') } 
                }
        }

    }