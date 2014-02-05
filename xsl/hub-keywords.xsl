<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet 
    version="2.0"
    xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
    xmlns="http://docbook.org/ns/docbook"
    >

  <xsl:output 
      method="xml" 
      indent="no"
      exclude-result-prefixes="#all"
      />

  <xsl:param name="archive-dir-uri" select="''"/>
  <xsl:param name="base-dir-uri" select="replace(base-uri(), '^(.+?)([^/\\]+)\.x?html$', '$1')"/>
  <xsl:param name="base-name" select="replace(base-uri(), '^(.+?)(([^/\\]+)\.x?html)$', '$2')"/>
  <xsl:param name="src-type" select="''"/>

  <xsl:template match="/">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="*:info"/>
      <xsl:copy-of select="node() except *:info"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:info">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <keywordset role="hub">
        <keyword role="hierarchized">false</keyword>
        <keyword role="formatting-deviations-only">false</keyword>
        <keyword role="marked-identifiers">false</keyword>
        <keyword role="processed-lists">true</keyword>
        <keyword role="titles-associated-with-floats">false</keyword>
        <keyword role="layout-attributes-permitted-on-phrase">false</keyword>
        <keyword role="used-rules-only">false</keyword>
        <keyword role="source-paths">false</keyword>
        <keyword role="archive-dir-uri">
          <xsl:value-of select="$archive-dir-uri"/>
        </keyword>
        <keyword role="source-type">
          <xsl:value-of select="$src-type"/>
        </keyword>
        <keyword role="source-basename">
          <xsl:value-of select="$base-name"/>
        </keyword>
        <keyword role="source-dir-uri">
          <xsl:value-of select="$base-dir-uri"/>
        </keyword>
        <keyword role="toc-title"></keyword>
      </keywordset>
      <xsl:copy-of select="node()"/>
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>