<!-- Templates from this file are copied into the conversion file by make.xsl --><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:frbrizer="http://idi.ntnu.no/frbrizer/" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
    <xsl:param name="debug" as="xs:boolean" select="false()"/>
    <xsl:param name="include_MARC001_in_entityrecord" as="xs:boolean" select="false()"/>
    <xsl:param name="include_MARC001_in_controlfield" as="xs:boolean" select="false()"/>
    <xsl:param name="include_MARC001_in_subfield" as="xs:boolean" select="false()"/>
    <xsl:param name="include_labels" as="xs:boolean" select="false()"/>
    <xsl:param name="include_anchorvalues" as="xs:boolean" select="false()"/>
    <xsl:param name="include_templateinfo" as="xs:boolean" select="false()"/>
    <xsl:param name="include_sourceinfo" as="xs:boolean" select="false()"/>
    <xsl:param name="include_keyvalues" as="xs:boolean" select="false()"/>
    <xsl:param name="include_internal_key" as="xs:boolean" select="false()"/>
    <xsl:param name="include_counters" as="xs:boolean" select="false()"/>
    <xsl:param name="UUID_identifiers" as="xs:boolean" select="true()"/>
    <xsl:param name="merge" as="xs:boolean" select="true()"/>
    <xsl:param name="include_id_as_element" as="xs:boolean" select="false()"/>
    <xsl:param name="include_missing_reverse_relationships" as="xs:boolean" select="true()"/>
    <xsl:param name="include_target_entity_type" as="xs:boolean" select="false()"/>
    <xsl:param name="include_entity_labels" as="xs:boolean" select="true()"/>
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <!--Template for copying subfield content. This template is used by the entity-templates-->
    <xsl:template name="copy-content">
        <xsl:param name="type" required="no" select="''"/>
        <xsl:param name="subtype" required="no" select="''"/>
        <xsl:param name="label" required="no" select="''"/>
        <xsl:param name="select" required="no"/>
        <xsl:param name="marcid" required="no"/>
        <xsl:call-template name="copy-attributes"/>
        <xsl:if test="$type ne ''">
            <xsl:attribute name="type" select="$type"/>
        </xsl:if>
        <xsl:if test="$subtype ne ''">
            <xsl:attribute name="subtype" select="$subtype"/>
        </xsl:if>
        <xsl:if test="$include_labels and ($label ne '')">
            <xsl:if test="$label ne ''">
                <xsl:attribute name="label" select="$label"/>
            </xsl:if>
        </xsl:if>
        <xsl:value-of select="normalize-space($select)"/>
        <xsl:if test="$include_MARC001_in_controlfield">
            <xsl:if test="string($marcid) ne ''">
                <xsl:element name="frbrizer:mid">
                    <xsl:attribute name="i" select="$marcid"/>
                </xsl:element>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--Template for copying the attributes of an element -->
    <xsl:template name="copy-attributes">
        <xsl:for-each select="@*">
            <xsl:copy/>
        </xsl:for-each>
    </xsl:template>
    <!-- Template for replacing internal keys with descriptive keys -->
    <xsl:template match="*:record-set" mode="replace-keys" name="replace-keys">
        <xsl:param name="keymapping" required="yes"/>
        <xsl:copy>
            <xsl:call-template name="copy-attributes"/>
            <xsl:for-each select="*:record">
                <xsl:variable name="record_id" select="@id"/>
                <xsl:choose>
                    <xsl:when test="$keymapping//*:keyentry[@id = $record_id]">
                        <xsl:copy>
                            <xsl:for-each select="@*">
                                <xsl:choose>
                                    <xsl:when test="local-name() = 'id'">
                                        <xsl:attribute name="id" select="$keymapping//*:keyentry[@id = $record_id]/@key"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                            <xsl:if test="$include_sourceinfo">
                                <xsl:element name="frbrizer:source">
                                    <xsl:attribute name="c" select="1"/>
                                    <xsl:value-of select="$record_id"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="$include_keyvalues">
                                <xsl:element name="frbrizer:keyvalue">
                                    <xsl:if test="$include_counters">
                                        <xsl:attribute name="f.c" select="1"/>
                                    </xsl:if>
                                    <xsl:value-of select="$keymapping//*:keyentry[@id = $record_id]/@key"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="$include_id_as_element">
                                <xsl:element name="frbrizer:idvalue">
                                    <xsl:attribute name="c" select="'1'"/>
                                    <xsl:attribute name="id" select="$keymapping//*:keyentry[@id = $record_id]/@key"/>
                                    <xsl:value-of select="$keymapping//*:keyentry[@id = $record_id]/@key"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:for-each select="node()">
                                <xsl:choose>
                                    <xsl:when test="@href = $keymapping//*:keyentry/@id">
                                        <xsl:variable name="temp" select="@href"/>
                                        <xsl:copy>
                                            <xsl:for-each select="@*">
                                                <xsl:choose>
                                                  <xsl:when test="local-name() = 'href'">
                                                  <xsl:attribute name="href" select="$keymapping//*:keyentry[@id = $temp]/@key"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:copy-of select="."/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:for-each>
                                            <xsl:for-each select="node()">
                                                <xsl:copy-of select="."/>
                                            </xsl:for-each>
                                        </xsl:copy>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:when test="exists(*:relationship[@href = $keymapping//*:keyentry/@id])">
                        <xsl:copy>
                            <xsl:call-template name="copy-attributes"/>
                            <xsl:for-each select="node()">
                                <xsl:choose>
                                    <xsl:when test="local-name() = 'relationship'">
                                        <xsl:variable name="href" select="@href"/>
                                        <xsl:copy>
                                            <xsl:for-each select="@*">
                                                <xsl:choose>
                                                  <xsl:when test="local-name() = 'href' and exists($keymapping//*:keyentry[@id = $href]/@key)">
                                                  <xsl:attribute name="href" select="$keymapping//*:keyentry[@id = $href]/@key[1]"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:copy-of select="."/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:for-each>
                                            <xsl:copy-of select="frbrizer:mid"/>
                                        </xsl:copy>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    <!--<xsl:template match="*:record-set" mode="create-UUID">
        <xsl:choose>
            <xsl:when test="$UUID_identifiers">
                <xsl:call-template name="UUID"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
    <xsl:template match="*:record-set" mode="remove-record-set">
        <xsl:copy-of select="//*:record"/>
    </xsl:template>
    <!--<xsl:template match="@*|node()" mode="UUID" name="UUID">
        <xsl:copy>
            <xsl:copy-of select="@* except @id|@href"/>
            <xsl:if test="exists(@id)">
                <xsl:attribute xmlns:uuid="java:java.util.UUID" name="id" select="uuid:to-string(uuid:nameUUIDFromBytes(string-to-codepoints(@id)))"/>
            </xsl:if>
            <xsl:if test="exists(@href)">
                <xsl:attribute xmlns:uuid="java:java.util.UUID" name="href" select="uuid:to-string(uuid:nameUUIDFromBytes(string-to-codepoints(@href)))"/>
            </xsl:if>
            <xsl:apply-templates mode="UUID" select="node()"/>
        </xsl:copy>
    </xsl:template>-->
    <xsl:function xmlns:local="http://idi.ntnu.no/frbrizer/" name="local:sort-keys">
        <xsl:param name="keys"/>
        <xsl:perform-sort select="distinct-values($keys)">
            <xsl:sort select="."/>
        </xsl:perform-sort>
    </xsl:function>
    <xsl:function xmlns:local="http://idi.ntnu.no/frbrizer/" name="local:sort-relationships">
        <xsl:param name="relationships"/>
        <xsl:perform-sort select="$relationships">
            <xsl:sort select="@id"/>
        </xsl:perform-sort>
    </xsl:function>
 <!--   <xsl:function name="frbrizer:marc21rdftype" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:variable name="prefix" select="'marcrdf'"/>
        <xsl:variable name="tag" select="$node/ancestor-or-self::node()[@tag]/@tag"/>
        <xsl:variable name="code" select="$node/ancestor-or-self::node()[@code]/@code"/>
        <xsl:variable name="ind1" select="                 if (matches($node/ancestor-or-self::node()[@tag]/@ind1, '[a-zA-Z0-9]')) then                     $node/ancestor-or-self::node()[@tag]/@ind1                 else                     '_'"/>
        <xsl:variable name="ind2" select="                 if (matches($node/ancestor-or-self::node()[@tag]/@ind2, '[a-zA-Z0-9]')) then                     $node/ancestor-or-self::node()[@tag]/@ind2                 else                     '_'"/>
        <xsl:value-of select="                 if (local-name($node) eq 'controlfield') then                     concat($prefix, ':M', $tag)                 else                     concat($prefix, ':M', $tag, $ind1, $ind2, $code)"/>
    </xsl:function>-->
    <!--template for adding inverse relationships -->
    <!--uses a record-set as input and outputs a new record-set-->
    <xsl:template match="*:record-set" mode="create-inverse-relationships">
        <xsl:if test="$include_missing_reverse_relationships">
            <xsl:variable name="record-set" select="."/>
            <xsl:copy>
                <xsl:for-each select="*:record">
                    <xsl:variable name="record" select="."/>
                    <xsl:variable name="this-entity-id" select="@id"/>
                    <xsl:copy>
                        <xsl:copy-of select="@* | node()"/>
                        <xsl:for-each select="$record-set/*:record[*:relationship[(@href = $this-entity-id)]]">
                            <xsl:variable name="target-entity-type" select="@type"/>
                            <xsl:variable name="target-entity-label" select="@label"/>
                            <xsl:variable name="target-entity-id" select="@id"/>
                            <xsl:for-each select="*:relationship[(@href eq $this-entity-id) and exists(@itype)]">
                                <xsl:variable name="rel-type" select="@type"/>
                                <xsl:variable name="rel-itype" select="@itype"/>
                                <xsl:if test="not(exists($record/*:relationship[@href eq $target-entity-id and @itype = $rel-type and @type = $rel-itype]))">
                                    <xsl:copy>
                                        <xsl:if test="exists(@itype)">
                                            <xsl:attribute name="type" select="@itype"/>
                                        </xsl:if>
                                        <xsl:if test="exists(@type)">
                                            <xsl:attribute name="itype" select="@type"/>
                                        </xsl:if>
                                        <xsl:if test="exists(@isubtype)">
                                            <xsl:attribute name="subtype" select="@isubtype"/>
                                        </xsl:if>
                                        <xsl:if test="exists(@subtype)">
                                            <xsl:attribute name="isubtype" select="@subtype"/>
                                        </xsl:if>
                                        <xsl:if test="$include_target_entity_type">
                                            <xsl:attribute name="target_type" select="$target-entity-type"/>
                                        </xsl:if>
                                        <xsl:if test="$include_counters">
                                            <xsl:attribute name="c" select="'1'"/>
                                        </xsl:if>
                                        <xsl:attribute name="href" select="$target-entity-id"/>
                                        <xsl:if test="$include_labels">
                                            <xsl:if test="@ilabel ne ''">
                                                <xsl:attribute name="label" select="@ilabel"/>
                                            </xsl:if>
                                            <xsl:if test="@label ne ''">
                                                <xsl:attribute name="ilabel" select="@label"/>
                                            </xsl:if>
                                        </xsl:if>
                                        <xsl:copy-of select="node()"/>
                                    </xsl:copy>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    <xsl:template match="/*:collection" mode="merge" name="merge">
        <xsl:param name="ignore_indicators_in_merge" select="false()" required="no"/>
        <xsl:copy>
            <xsl:for-each-group select="//*:record" group-by="@id">
                <xsl:sort select="@type"/>
                <xsl:sort select="@subtype"/>
                <xsl:sort select="@id"/>
                <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                    <xsl:attribute name="id" select="current-group()[1]/@id"/>
                    <xsl:attribute name="type" select="current-group()[1]/@type"/>
                    <xsl:if test="exists(current-group()/@subtype)">
                        <xsl:attribute name="subtype">
                            <xsl:variable name="temp">
                                <xsl:perform-sort select="string-join(distinct-values(current-group()/@subtype[. ne '']), '-')">
                                    <xsl:sort select="."/>
                                </xsl:perform-sort>
                            </xsl:variable>
                            <xsl:value-of select="string-join($temp, '/')"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="current-group()[1]/@label">
                        <xsl:attribute name="label" select="current-group()[1]/@label"/>
                    </xsl:if>
                    <xsl:if test="current-group()[1]/@c">
                        <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                    </xsl:if>
                    <xsl:for-each-group select="current-group()/*:controlfield" group-by="string-join((@tag, @type, string(.)), '')">
                        <xsl:sort select="@tag"/>
                        <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                            <xsl:copy-of select="@* except @c"/>
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                            <xsl:for-each-group select="current-group()/*:mid" group-by="@i">
                                <xsl:for-each select="distinct-values(current-group()/@i)">
                                    <frbrizer:mid>
                                        <xsl:attribute name="i" select="."/>
                                    </frbrizer:mid>
                                </xsl:for-each>
                            </xsl:for-each-group>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:datafield" group-by="                             normalize-space(string-join(((@tag), @type,                             (if ($ignore_indicators_in_merge) then                                 ()                             else                                 (@ind1, @ind2)), *:subfield/@code, *:subfield/@type, *:subfield/text()), ''))">
                        <xsl:sort select="@tag"/>
                        <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                            <xsl:copy-of select="current-group()[1]/@tag"/>
                            <xsl:copy-of select="current-group()[1]/@ind1"/>
                            <xsl:copy-of select="current-group()[1]/@ind2"/>
                            <xsl:copy-of select="current-group()[1]/@type"/>
                            <xsl:copy-of select="current-group()[1]/@subtype"/>
                            <xsl:copy-of select="current-group()[1]/@label"/>
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:for-each-group select="current-group()/*:subfield" group-by="concat(@code, @type, text())">
                                <xsl:sort select="@code"/>
                                <xsl:sort select="@type"/>
                                <xsl:for-each select="distinct-values(current-group()/text())">
                                    <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                                        <xsl:copy-of select="current-group()[1]/@code"/>
                                        <xsl:copy-of select="current-group()[1]/@type"/>
                                        <xsl:copy-of select="current-group()[1]/@subtype"/>
                                        <xsl:if test="current-group()[1]/@label">
                                            <xsl:copy-of select="current-group()[1]/@label"/>
                                        </xsl:if>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:for-each-group>
                            <xsl:for-each-group select="current-group()/*:mid" group-by="@i">
                                <xsl:for-each select="distinct-values(current-group()/@i)">
                                    <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                                        <xsl:attribute name="i" select="."/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:for-each-group>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:relationship" group-by="concat(@type, @href, @subtype)">
                        <xsl:sort select="@type"/>
                        <xsl:sort select="@subtype"/>
                        <xsl:sort select="@id"/>
                        <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                            <xsl:copy-of select="@* except (@c | @ilabel | @itype | @isubtype)"/>
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:for-each-group select="current-group()/*:mid" group-by="@i">
                                <xsl:for-each select="distinct-values(current-group()/@i)">
                                    <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                                        <xsl:attribute name="i" select="."/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:for-each-group>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:template" group-by=".">
                        <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/mid" group-by="@i">
                        <xsl:for-each select="distinct-values(current-group()/@i)">
                            <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                                <xsl:attribute name="i" select="."/>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:anchorvalue" group-by=".">
                        <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:idvalue" group-by="@id">
                        <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:if test="current-group()[1]/@id">
                                <xsl:copy-of select="current-group()/@id"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:source" group-by=".">
                        <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:keyvalue" group-by=".">
                        <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:label" group-by=".">
                        <xsl:element name="{name(current-group()[1])}" namespace="{namespace-uri(current-group()[1])}">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="normalize-space(current-group()[1])"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:intkey" group-by=".">
                        <xsl:element name="intkey">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/*:collection" mode="rdfify" name="rdfify">
        <rdf:RDF xml:base="http://example.org/rda/">
            <xsl:for-each-group select="( //@type[starts-with(., 'http')])" group-by="replace(., tokenize(., '/')[last()], '')">
                <xsl:namespace name="{tokenize(., '/')[last() - 1]}" select="current-grouping-key()"/>
            </xsl:for-each-group>
            <xsl:for-each-group select="//*:record[starts-with(@type, 'http')]" group-by="@id, @type" composite="yes">
                <xsl:sort select="@type"/>
                <xsl:sort select="@id"/>
                <xsl:variable name="p" select="tokenize(@type, '/')[last() - 1]"/>
                <xsl:variable name="n" select="tokenize(@type, '/')[last()]"/>
                <xsl:element name="{concat($p, ':', $n)}" namespace="{replace(@type, tokenize(@type, '/')[last()], '')}" >
                    <xsl:attribute name="rdf:about" select="@id" />
                    <xsl:for-each-group select="current-group()//(*:subfield, *:controlfield)[starts-with(@type, 'http')]" group-by="@type, text()" composite="yes">
                        <xsl:variable name="pre" select="tokenize(@type, '/')[last() - 1]"/>
                        <xsl:variable name="nm" select="tokenize(@type, '/')[last()]"/>
                        <xsl:element name="{concat($pre, ':', $nm)}" namespace="{replace(@type, tokenize(@type, '/')[last()], '')}" >
                            <xsl:copy-of select="current-group()[1]/text()"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:relationship[starts-with(@type, 'http')]" group-by="@type, @href" composite="yes">
                        <xsl:sort select="@type"/>
                        <xsl:variable name="pre" select="tokenize(@type, '/')[last() - 1]"/>
                        <xsl:variable name="nm" select="tokenize(@type, '/')[last()]"/>
                        <xsl:element name="{concat($pre, ':', $nm)}" namespace="{replace(@type, tokenize(@type, '/')[last()], '')}" >
                            <xsl:attribute name="rdf:resource" select="current-group()[1]/@href" />
                        </xsl:element>                        
                    </xsl:for-each-group>
                </xsl:element>
            </xsl:for-each-group>
        </rdf:RDF>
    </xsl:template>
</xsl:stylesheet>