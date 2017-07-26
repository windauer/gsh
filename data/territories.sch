<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <title>GSH Territory Rules</title>
    <let name="territory-ids"
        value="collection('territories/?select=*.xml;recurse=no')/territory/id"/>
    <pattern id="territory-id-check">
        <rule
            context="/territory/predecessors/predecessor[. ne ''] | /territory/successors/successor[. ne '']">
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
    <pattern id="valid-since">
        <rule context="valid-since[not(@type = 'pre-1776')][. castable as xs:gYear]">
            <assert test="xs:integer(.) ge 1776">To express "pre-1776", the year must be 1775 and
                valid-until requires a @type="pre-1776"</assert>
        </rule>
    </pattern>
    <pattern id="valid-until">
        <rule context="valid-until[not(@type = 'present')][. castable as xs:gYear]">
            <assert test="xs:integer(.) lt year-from-date(current-date())">To express "present", the
                year must be 9999 and valid-since requires a @type="present"</assert>
        </rule>
        <rule context="valid-until[@type = 'present']">
            <assert test=". = '9999'">With @type="present", the year must be expressed as
                9999.</assert>
        </rule>
    </pattern>
    <pattern id="exists-on-todays-map">
        <rule context="exists-on-todays-map[. = 'true']">
            <assert test="../valid-until = '9999'">If the territory exists on today's map,
                valid-until must be expressed as 9999.</assert>
        </rule>
        <rule context="exists-on-todays-map[. = 'false']">
            <assert test="../valid-until ne '9999'">If the territory does not exist on today's map,
                the valid-until year must be provided.</assert>
        </rule>
    </pattern>
    <pattern id="lineages-check">
        <rule context="exists-on-todays-map[. = 'true']">
            <assert
                test="id = collection('lineages/?select=*.xml;recurse=no')/current-territory/territory-id"
                >If territory exists on today's map, it must have a lineage entry.</assert>
        </rule>
    </pattern>
</schema>
