<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <title>GSH Lineages Rules</title>
    
    <let name="territories-on-todays-map" value="collection('territories/?select=*.xml;recurse=no')/territory[exists-on-todays-map = 'true']"/>

    <pattern id="current-territory-check">
        <rule context="current-territory">
            <assert test="territory-id = $territories-on-todays-map/id">
                <value-of select="display-name"/> is not on today's map
            </assert>
        </rule>
    </pattern>
    
    <pattern id="url-check">
        <rule context="url">
            <assert test=". eq concat('http://localhost:8080/exist/apps/gsh/territories/', preceding-sibling::territory-id)">
                URL should match territory ID
            </assert>
        </rule>
    </pattern>

</schema>