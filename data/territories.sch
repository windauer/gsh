<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <title>GSH Territory Rules</title>
    <let name="territory-ids" value="collection('territories/?select=*.xml;recurse=no')/territory/id"/>
    <pattern id="territory-id-check">
        <rule context="/territory/predecessors/predecessor[. ne '']|/territory/successors/successor[. ne '']">
            <assert test=". ne '' and . = $territory-ids">
                <value-of select="name(.)"/> of <value-of select="."/> is not an existing territory
                id. </assert>
        </rule>
    </pattern>
    <pattern id="filename-id-check">
        <rule context="/territory">
            <let name="basename" value="replace(base-uri(.), '^.*/(.*?)$', '$1')"/>
            <assert test="$basename = concat(id, '.xml')">territory id <value-of select="id"/> does
                not match filename <value-of select="$basename"/>
            </assert>
        </rule>
    </pattern>
</schema>