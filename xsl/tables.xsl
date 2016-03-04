<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet 
    version="2.0"
    xmlns:css = "http://www.w3.org/1996/css"
    xmlns:htmltable="http://transpect.io/htmltable"
    xmlns:html2hub = "http://transpect.io/html2hub"
    xmlns:svg = "http://www.w3.org/2000/svg"
    xmlns:xhtml = "http://www.w3.org/1999/xhtml"
    xmlns:xlink = "http://www.w3.org/1999/xlink"
    xmlns:xs = "http://www.w3.org/2001/XMLSchema"
    xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
    xmlns="http://docbook.org/ns/docbook"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all"
    >

  <xsl:template match="table" mode="html2hub:default">
    <xsl:element name="{if (caption) then 'table' else 'informaltable'}">
      <xsl:apply-templates select="@class, caption" mode="#current"/>
      <tgroup>
        <xsl:attribute name="cols" select="descendant-or-self::*[@data-colcount][1]/@data-colcount"/>
        <xsl:apply-templates select="@* except @class" mode="#current"/>
        <xsl:apply-templates select="colgroup/col" mode="#current"/>
        <xsl:apply-templates select="node() except (colgroup | caption)" mode="#current"/>
      </tgroup>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="caption" mode="html2hub:default">
    <title>
      <xsl:apply-templates mode="#current"/>
    </title>
  </xsl:template>

  <xsl:template match="@data-colcount" mode="html2hub:default"/>

  <xsl:template match="@data-rowcount" mode="html2hub:default"/>

  <xsl:template match="@style" mode="html2hub:default"/>
  
  <xsl:template match="@*" mode="html2hub:default">
    <xsl:message select="'Will drop ', ."/>
  </xsl:template>
  
  <xsl:template match="@id" mode="html2hub:default">
    <xsl:attribute name="xml:id" select="."/>
  </xsl:template>
  
  <xsl:template match="@css:width" mode="html2hub:default"/>

  <xsl:template match="@css:vertical-align" mode="html2hub:default">
    <xsl:attribute name="valign" select="."/>
  </xsl:template>

  <xsl:template match="col" mode="html2hub:default">
    <colspec>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </colspec>
  </xsl:template>

  <xsl:template match="col/@width" mode="html2hub:default">
    <xsl:attribute name="colwidth" select="."/>
  </xsl:template>

  <xsl:template match="col/@span" mode="html2hub:default"/>

  <xsl:template match="tbody | thead | tfoot" mode="html2hub:default">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tr" mode="html2hub:default">
    <row>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </row>
  </xsl:template>

  <xsl:template match="td | th" mode="html2hub:default">
    <entry>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:choose>
        <xsl:when test="not(p)">
          <para>
            <xsl:apply-templates select="node()" mode="#current"/>
          </para>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:otherwise>
      </xsl:choose>
    </entry>
  </xsl:template>

  <xsl:template match="@data-colnum" mode="html2hub:default">
    <xsl:attribute name="{if (xs:integer(../@colspan) gt 1) then 'namest' else 'colname'}" select="."/>
  </xsl:template>

  <xsl:template match="@colspan" mode="html2hub:default">
    <xsl:if test="xs:integer(.) gt 1">
      <xsl:attribute name="nameend" select="xs:integer(../@data-colnum) + xs:integer(.) - 1"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@rowspan" mode="html2hub:default">
    <xsl:if test="xs:integer(.) gt 1">
      <xsl:attribute name="morerows" select="xs:integer(.) - 1"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@data-rownum" mode="html2hub:default"/>

</xsl:stylesheet>
