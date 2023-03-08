<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:date="http://exslt.org/dates-and-times">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <xsl:variable name="newLine" select="'&#xA;'" />
    <xsl:variable name="toolName" select="/ResultsSession/@toolName"/>
    <xsl:variable name="rules" select="/ResultsSession/CodingStandards/Rules/RulesList/Rule"/>
    <xsl:variable name="category" select="/ResultsSession/CodingStandards/Rules/CategoriesList//Category"/>

    <xsl:template match="/">
        <xsl:element name="pmd">
            <xsl:attribute name="version"><xsl:value-of select="$toolName"/></xsl:attribute>
            <xsl:attribute name="timestamp"><xsl:value-of select="date:date-time()"/></xsl:attribute>
            <xsl:apply-templates select="ResultsSession/CodingStandards/StdViols"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="StdViols">
        <xsl:variable name="FlowViols" select="FlowViol"/>
        <xsl:variable name="MetViols" select="MetViol" />
        <xsl:call-template name="transViolations">
            <xsl:with-param name="violations" select="$MetViols"/>
        </xsl:call-template>
        <xsl:call-template name="transViolations">
            <xsl:with-param name="violations" select="$FlowViols"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="transViolations">
        <xsl:param name="violations"/>
        <xsl:for-each select="$violations">
            <xsl:variable name="ElDesc" select="ElDescList/ElDesc"/>
            <xsl:if test="@supp != true()">
                <xsl:element name="file">
                    <xsl:attribute name="name">
                        <xsl:value-of select="@locFile"/>
                    </xsl:attribute>
                    <xsl:element name="violation">
                        <xsl:attribute name="beginline"><xsl:value-of select="@locStartln"/></xsl:attribute>
                        <xsl:attribute name="endline"><xsl:value-of select="@locEndLn"/></xsl:attribute>
                        <xsl:attribute name="begincolumn"><xsl:value-of select="@locStartPos"/></xsl:attribute>
                        <xsl:attribute name="endcolumn"><xsl:value-of select="@locEndPos"/></xsl:attribute>
                        <xsl:attribute name="rule"><xsl:value-of select="@rule"/></xsl:attribute>
                        <xsl:attribute name="priority"><xsl:value-of select="@sev"/></xsl:attribute>
                        <xsl:if test="@pkg">
                            <xsl:attribute name="package">
                                <xsl:value-of select="@pkg"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:attribute name="ruleset">
                            <xsl:call-template name="getRuleCategory">
                                <xsl:with-param name="ruleId" select="@rule"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$ElDesc">
                                <xsl:call-template name="setMessages">
                                    <xsl:with-param name="ElDesc" select="$ElDesc"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@msg"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="getRuleCategory">
        <xsl:param name="ruleId"/>
        <xsl:variable name="cat" select="$rules[@id = $ruleId]/@cat"/>
        <xsl:value-of select="$category[@name = $cat]/@desc"/>
    </xsl:template>
    
    <xsl:template name="setMessages">
        <xsl:param name="ElDesc"/>
        <xsl:for-each select="$ElDesc">
            <xsl:call-template name="getFile">
                <xsl:with-param name="srcRngFile" select="@srcRngFile"/>
            </xsl:call-template>
            <xsl:variable name="message" select="concat(':', @ln, '***', @desc)"/>
            <xsl:value-of select="$message"/>
            <xsl:variable name="anns" select="Anns/Ann"/>
            <xsl:for-each select="$anns">
                <xsl:value-of select="concat('***', @msg)"/>
            </xsl:for-each>
            <xsl:value-of select="$newLine"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="getFile">
        <xsl:param name="srcRngFile"/>
        <xsl:variable name="newsrcRngFile" select="substring-after($srcRngFile,'/')"/>
        <xsl:choose>
            <xsl:when test="contains($newsrcRngFile,'/')">
                <xsl:call-template name="getFile">
                    <xsl:with-param name="srcRngFile" select="$newsrcRngFile" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$newsrcRngFile"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>