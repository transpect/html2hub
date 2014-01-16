<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet 
    version="2.0"
    xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
    xmlns:saxon = "http://saxon.sf.net/"
    xmlns:xs = "http://www.w3.org/2001/XMLSchema"
    xmlns:aid5 = "http://ns.adobe.com/AdobeInDesign/5.0/"
    xmlns:aid = "http://ns.adobe.com/AdobeInDesign/4.0/"
    xmlns:idPkg = "http://ns.adobe.com/AdobeInDesign/idml/1.0/packaging"
    xmlns:idml2xml = "http://www.le-tex.de/namespace/idml2xml"
    xmlns:xhtml = "http://www.w3.org/1999/xhtml"
    xmlns:css = "http://www.w3.org/1996/css"
    xmlns:hub = "http://www.le-tex.de/namespace/hub"
    xmlns:xlink = "http://www.w3.org/1999/xlink"
    xmlns:dbk = "http://docbook.org/ns/docbook"
    xmlns:html2hub = "http://www.le-tex.de/namespace/html2hub"
    xmlns:docx2hub = "http://www.le-tex.de/namespace/docx2hub"
    xmlns:letex = "http://www.le-tex.de/namespace"
    xmlns="http://docbook.org/ns/docbook"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    >

  <!-- PARAMS -->

  <xsl:param name="debug" select="'no'"/>
  <xsl:param name="debugdir" select="'debug'"/>
  <xsl:param name="hierarchy-by-h-elements" select="'1'"/>
  
  <!-- VARIABLES -->
  
  <xsl:variable 
    name="html2hub-basename" 
    select="replace(tokenize(base-uri(/),'/')[last()],'.hub.xml','')" 
    as="xs:string"/>


  <!-- OUTPUT -->
 
  <xsl:output 
    method="xml" 
    indent="no"
    exclude-result-prefixes="#all"
  />

  <xsl:output 
    method="xml" 
    indent="yes"
    name="debug"
    exclude-result-prefixes="#all" 
  />


  <!-- INITIAL TEMPLATE -->

  <xsl:template name="html2hub">
    <xsl:if test="//style[@type eq 'text/css']">
      <xsl:message select="'HTML2HUB WARNING: extract of css style informations not supported yet.'"/>
    </xsl:if>
    <xsl:apply-templates select="/" mode="html2hub:default"/>
  </xsl:template>


  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- mode: html2hub:default -->
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

  <xsl:template match="html" mode="html2hub:default">
    <chapter>
      <xsl:apply-templates mode="#current"/>
    </chapter>
  </xsl:template>

  <xsl:template match="head" mode="html2hub:default" />

  <xsl:template match="body" mode="html2hub:default">
    <xsl:choose>
      <xsl:when test="$hierarchy-by-h-elements = ('1','true','yes')">
	<xsl:call-template name="build-sections">
	  <xsl:with-param name="h-level" select="1" as="xs:integer" />
	  <xsl:with-param name="nodes" select="node()"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="node()" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-sections">
    <xsl:param name="h-level" as="xs:integer" />
    <xsl:param name="nodes" as="node()*" />
    <xsl:variable name="current-level-elementname-regex" as="xs:string"
      select="concat('^h', $h-level, '$')"/>
    <xsl:choose>
      <xsl:when test="$nodes/self::*[matches(local-name(), $current-level-elementname-regex)]">
	<xsl:for-each-group select="$nodes" group-starting-with="node()[matches(local-name(), $current-level-elementname-regex)]">
	  <xsl:choose>
	    <!-- first node in current-group is the correct heading-element, actually -->
	    <xsl:when test="self::*[matches(local-name(), $current-level-elementname-regex)]">
	      <section>
		<title>
		  <xsl:apply-templates select="./@*" mode="#current" />
		  <xsl:apply-templates select="./node()" mode="#current" />
		</title>
		<xsl:call-template name="build-sections">
		  <xsl:with-param name="h-level" select="$h-level + 1"/>
		  <xsl:with-param name="nodes" select="current-group()[position() gt 1]"/>
		</xsl:call-template>
	      </section>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:call-template name="build-sections">
		<xsl:with-param name="h-level" select="$h-level + 1"/>
		<xsl:with-param name="nodes" select="current-group()"/>
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:for-each-group>
      </xsl:when>
      <!-- hierarchic step -->
      <xsl:when test="not(*[matches(local-name(), $current-level-elementname-regex)]) and
		      *[matches(local-name(), concat('^h[', $h-level, '-9]'))]">
	<xsl:call-template name="build-sections">
	  <xsl:with-param name="h-level" select="$h-level + 1"/>
	  <xsl:with-param name="nodes" select="$nodes"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="$nodes" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="div" mode="html2hub:default">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="p" mode="html2hub:default">
    <para>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </para>
  </xsl:template>

  <xsl:template match="img" mode="html2hub:default">
    <xsl:element name="{if(parent::p) then 'inlinemediaobject' else 'mediaobject'}">
      <imageobject>
	<imagedata fileref="{@href}" />
      </imageobject>
    </xsl:element>
  </xsl:template>

  <xsl:template match="dl" mode="html2hub:default">
    <variablelist>
      <xsl:apply-templates select="@*" mode="#current" />
      <xsl:for-each select="dt">
	<varlistentry>
	  <term>
	    <xsl:apply-templates select="@*" mode="#current" />
	    <xsl:apply-templates mode="#current"/>
	  </term>
	  <listitem>
	    <xsl:apply-templates select="following-sibling::dd[1]/@*" mode="#current" />
	    <xsl:apply-templates select="following-sibling::dd[1]" mode="#current"/>
	  </listitem>
	</varlistentry>
      </xsl:for-each>
    </variablelist>
  </xsl:template>

  <xsl:template match="dd" mode="html2hub:default">
    <xsl:choose>
      <xsl:when test="p">
	<xsl:apply-templates mode="#current" />
      </xsl:when>
      <xsl:otherwise>
	<para>
	  <xsl:apply-templates mode="#current" />
	</para>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="span" mode="html2hub:default">
    <phrase>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </phrase>
  </xsl:template>

  <xsl:template match="br" mode="html2hub:default">
    <phrase role="br"/>
  </xsl:template>

  <xsl:template match="a[@*]" mode="html2hub:default">
    <xsl:choose>
      <xsl:when test="not(.//text())">
	<anchor id="{(@xml:id, @id)}"/>
      </xsl:when>
      <xsl:when test="matches(@href, '^(www\.|http://)')">
	<ulink>
	  <xsl:attribute name="url" select="@href"/>
	  <xsl:apply-templates mode="#current"/>
	</ulink>
      </xsl:when>
      <xsl:when test="matches(@href, '^#')">
	<xref linkend="{substring(@href, 2)}">
	  <xsl:apply-templates select="@* except @href, node()" mode="#current"/>
	</xref>
      </xsl:when>
      <xsl:when test="@href">
	<ulink url="{@href}">
	  <xsl:apply-templates select="@* except @href, node()" mode="#current"/>
	</ulink>
      </xsl:when>
      <xsl:otherwise>
	<xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="a/@shape" mode="html2hub:default" />

  <xsl:template match="hr" mode="html2hub:default">
    <hr>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </hr>
  </xsl:template>

  <xsl:template match="sub[not(ancestor::math)]" mode="html2hub:default">
    <subscript>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </subscript>
  </xsl:template>

  <xsl:template match="sup[not(ancestor::math)]" mode="html2hub:default">
    <superscript>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </superscript>
  </xsl:template>

  <xsl:template match="table" mode="html2hub:default">
    <table>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </table>
  </xsl:template>

  <xsl:template match="tr" mode="html2hub:default">
    <tr>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </tr>
  </xsl:template>

  <xsl:template match="td" mode="html2hub:default">
    <td>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </td>
  </xsl:template>

  <xsl:template match="@class" mode="html2hub:default">
    <xsl:attribute name="role" select="."/>
  </xsl:template>



  <!-- catch all -->
  <xsl:template match="@* | node()" mode="#all" priority="-3">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:*" mode="html2hub:default">
    <xsl:element name="{local-name()}" namespace="http://docbook.org/ns/docbook">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
    <xsl:message select="'WRN HTML2HUB: Unprocessed html element', local-name(), 
                         if(@class ne '') then concat('with class=&quot;', @class, '&quot;') else 'without class',
                         'now moved to hub namespace; content:', if(string-join(.//text(),'') eq '') then '[none]' else string-join(.//text(),'')"/>
  </xsl:template>

</xsl:stylesheet>
