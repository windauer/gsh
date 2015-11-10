<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <title>GSH Locale Rules</title>
    <let name="locale-ids" value="collection('locales/?select=*.xml;recurse=no')/locale/id"/>
    <let name="territory-ids" value="collection('territories/?select=*.xml;recurse=no')/territory/id"/>
    <pattern id="locale-id-check">
        <rule context="/locale/predecessors/predecessor[. ne '']|/locale/successors/successor[. ne '']">
            <assert test=". ne '' and . = $locale-ids">
                <value-of select="name(.)"/> of <value-of select="."/> is not an existing locale
                id. </assert>
        </rule>
    </pattern>
    <pattern id="filename-id-check">
        <rule context="/locale">
            <let name="basename" value="replace(base-uri(.), '^.*/(.*?)$', '$1')"/>
            <assert test="$basename = concat(id, '.xml')">locale id <value-of select="id"/> does
                not match filename <value-of select="$basename"/>
            </assert>
        </rule>
    </pattern>
    <pattern id="territory-id-check">
        <rule context="/locale/current-territory[. ne '']">
            <assert test=". ne '' and . = $territory-ids">
                <value-of select="name(.)"/> of <value-of select="."/> is not an existing territory
                id. </assert>
        </rule>
    </pattern>
</schema>