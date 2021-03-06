<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no" omit-xml-declaration="no" version="1.0"/>
    <xsl:include href="https://cdn.rawgit.com/tillgrallert/xslt-calendar-conversion/master/date-function.xsl"/>
    
    <!-- this stylesheet goes through a TEI file and looks for all <tei:date> elements that have @when-custom but no @when attribute -->
    
    <xsl:param name="p_id-editor" select="'pers_TG'"/>
    
    <xsl:template match="@* |node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- convert dates date include information on single days -->
    <xsl:template match="tei:date[string-length(@when-custom)=10][not(@when)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="when">
                <xsl:choose>
                    <xsl:when test="@datingMethod='#cal_islamic'">
                        <xsl:call-template name="funcDateH2G">
                            <xsl:with-param name="pDateH" select="@when-custom"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="@datingMethod='#cal_ottomanfiscal'">
                        <xsl:call-template name="funcDateM2G">
                            <xsl:with-param name="pDateM" select="@when-custom"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="@datingMethod='#cal_julian'">
                        <xsl:call-template name="funcDateJ2G">
                            <xsl:with-param name="pDateJ" select="@when-custom"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- convert hijri years only -->
    <xsl:template match="tei:date[string-length(@when-custom)=4][@datingMethod='#cal_islamic'][not(@when)][not(@notBefore)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:variable name="v_date-h-1"
                select="concat(@when-custom,'-01-01')"/>
            <xsl:variable name="v_date-g-1">
                <xsl:call-template name="funcDateH2G">
                    <xsl:with-param name="pDateH" select="$v_date-h-1"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="v_date-h-2"
                select="concat(@when-custom,'-12-29')"/>
            <xsl:variable name="v_date-g-2">
                <xsl:call-template name="funcDateH2G">
                    <xsl:with-param name="pDateH" select="$v_date-h-2"/>
                </xsl:call-template>
            </xsl:variable>
            <!-- test if the Hijrī year spans more than one Gregorian year (this is not the case for 1295, 1329  -->
            <xsl:choose>
                <xsl:when test="substring($v_date-g-1,1,4)=substring($v_date-g-2,1,4)">
                    <xsl:attribute name="when" select="substring($v_date-g-1,1,4)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="notBefore" select="$v_date-g-1"/>
                    <xsl:attribute name="notAfter" select="$v_date-g-2"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- document changes -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:element name="change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="$p_id-editor"/>
                <xsl:text>Automatically added computed Gregorian dates to the </xsl:text>
                <xsl:element name="att">when</xsl:element>
                <xsl:text> attributes of all non-Gregorian </xsl:text>
                <xsl:element name="gi">date</xsl:element>
                <xsl:text> elements.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>