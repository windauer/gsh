xquery version "3.0";

(:~
    controller.xql for URL rewriting.
:)

(: Standard controller.xql variables passed in from the URL Rewriting framework :)

declare variable $exist:root external;
declare variable $exist:prefix external;
declare variable $exist:controller external;
declare variable $exist:path external;
declare variable $exist:resource external;

(: Log all URL Rewriting requests? :)
declare variable $local:log := true();

(: Cache all URL Rewriting paths? :)
declare variable $local:cache-control := 'no';

(: ---------------------------------------------------------------------------------- :)
(: Functions for handling the main URL Rewriting verbs: forward, redirect, and ignore :)
(: ---------------------------------------------------------------------------------- :)

declare function local:forward($controller, $relative-path as xs:string) {
    local:forward($controller, $relative-path, ())
};

declare function local:forward($controller as xs:string, $relative-path as xs:string, $attribs as element(exist:add-parameter)*) {
    let $absolute-path-from-controller := concat($controller, '/', $relative-path)
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$absolute-path-from-controller}">
                {$attribs}
            </forward>
            <cache-control cache="{$local:cache-control}"/>
        </dispatch>
};

declare function local:redirect($absolute-path as xs:string) {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$absolute-path}"/>
        <cache-control cache="{$local:cache-control}"/>
    </dispatch>
};

declare function local:add-parameter($name as xs:string, $value as xs:string) as element(exist:add-parameter) {
    <add-parameter xmlns="http://exist.sourceforge.net/NS/exist" name="{$name}" value="{$value}"/>
};

declare function local:ignore() {
    <ignore xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="{$local:cache-control}"/>
    </ignore>
};

declare function local:log-variables($params as element(params)) {
    for $param in $params/param
    let $name := string($param/@name)
    let $value := $param/text()
    return
        util:log("DEBUG", concat("URL Rewriter: ", $name, ":          ", $value))
};

(: Main routine :)

let $uri :=         request:get-uri()
let $context :=     request:get-context-path()
let $root :=        $exist:root
let $prefix :=      $exist:prefix
let $controller :=  $exist:controller
let $path :=        $exist:path
let $resource :=    $exist:resource

(: parse path fragments for gsh-specific-pages below :)
let $path-fragments := tokenize($path, '/')

return

    (: Handle initial requests to the app :)
    if ($path = '/') then
        local:redirect(concat($context, $prefix, $controller))
    else if ($path = '') then
        local:forward($controller, 'index.xq')

    (: gsh-specific pages :)
    else if ($path-fragments[2] = ('locales', 'posts', 'regions', 'territories', 'resources')) then
        if ($path-fragments[3]) then 
            let $param-name := switch ($path-fragments[2])
                case "locales" return "locale"
                case "posts" return "post"
                case "regions" return "region"
                case "territories" return "territory"
                case "resources" return "resources"
                default return ()
            let $param := local:add-parameter($param-name, $path-fragments[3])
            return
                local:forward($controller, concat($path-fragments[2], '.xq'), $param)
        else
            local:forward($controller, concat($path-fragments[2], '.xq'))

    (: everything else is passed through :)
    else
        local:ignore()