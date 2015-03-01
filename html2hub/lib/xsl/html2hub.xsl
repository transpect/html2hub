<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet 
    version="2.0"
    xmlns:css = "http://www.w3.org/1996/css"
    xmlns:htmltable="http://www.le-tex.de/namespace/htmltable"
    xmlns:html2hub = "http://www.le-tex.de/namespace/html2hub"
    xmlns:svg = "http://www.w3.org/2000/svg"
    xmlns:xhtml = "http://www.w3.org/1999/xhtml"
    xmlns:xlink = "http://www.w3.org/1999/xlink"
    xmlns:xs = "http://www.w3.org/2001/XMLSchema"
    xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
    xmlns="http://docbook.org/ns/docbook"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    >


  <!-- PARAMS -->

  <xsl:param name="debug" select="'no'"/>
  <xsl:param name="debug-dir" select="'debug'"/>
  <xsl:param name="hierarchy-by-h-elements" select="'no'"/><!-- hierarchization should be done by evolve-hub -->
  

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

  <xsl:strip-space elements="body div dl head html ol table ul svg:svg"/>


  <!-- INITIAL TEMPLATE -->

  <xsl:template name="html2hub">
    <xsl:apply-templates select="/" mode="html2hub:default"/>
  </xsl:template>


  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- mode: html2hub:default -->
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

  <xsl:template match="html" mode="html2hub:default">
    <chapter>
      <xsl:apply-templates select="@xml:base" mode="#current" />
      <info>
        <title/>
      </info>
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

  <xsl:template match="h1 | h2 | h3 | h4 | h5 | h6" mode="html2hub:default">
    <para remap="{local-name()}">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </para>
  </xsl:template>

  <xsl:template match="@title" mode="html2hub:default">
    <xsl:attribute name="annotations" select="."/>
  </xsl:template>

  <xsl:template match="div" mode="html2hub:default">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="p" mode="html2hub:default">
    <para>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </para>
  </xsl:template>

  <xsl:template match="img" mode="html2hub:default">
    <xsl:element name="{if (parent::p) then 'inlinemediaobject' else 'mediaobject'}">
      <xsl:for-each select="@alt">
        <xsl:element name="{local-name()}">
          <xsl:value-of select="."/>
        </xsl:element>
      </xsl:for-each>
      <imageobject>
        <imagedata fileref="{@src}">
          <xsl:for-each select="@width">
            <xsl:attribute name="{local-name()}" select="."/>
          </xsl:for-each>
        </imagedata>
      </imageobject>
    </xsl:element>
  </xsl:template>

  <xsl:template match="svg:svg" mode="html2hub:default">
    <xsl:element name="{if (parent::p) then 'inlinemediaobject' else 'mediaobject'}">
      <imageobject>
        <imagedata>
          <xsl:element name="svg" xmlns="http://www.w3.org/2000/svg">
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
          </xsl:element>
        </imagedata>
      </imageobject>
    </xsl:element>
  </xsl:template>

  <xsl:template match="svg:image" mode="html2hub:default">
    <xsl:element name="{local-name()}" xmlns="http://www.w3.org/2000/svg">
      <xsl:apply-templates select="@*|node()" mode="#current" />
    </xsl:element>
  </xsl:template>

  <!-- lists -->

  <xsl:template match="ol" mode="html2hub:default">
    <orderedlist>
      <xsl:apply-templates select="@*|node()" mode="#current" />
    </orderedlist>
  </xsl:template>

  <xsl:template match="ul" mode="html2hub:default">
    <itemizedlist>
      <xsl:apply-templates select="@*|node()" mode="#current" />
    </itemizedlist>
  </xsl:template>

  <xsl:variable name="html-inline-elements" as="xs:string*" 
                select="('a','abbr','acronym','b','basefont','bdo','big','br','button','cite','code','del','dfn','em','font','i','img','ins','input','iframe','kbd','label','map','object','q','s','samp','script','select','small','span','strong','sub','sup','textarea','tt','var','u')" />

  <xsl:template match="li" mode="html2hub:default">
    <listitem>
      <xsl:apply-templates select="@*" mode="#current" />
      <xsl:choose>
        <xsl:when test="every $c in node() satisfies $c[local-name()=$html-inline-elements or self::text()]">
          <para>
            <xsl:apply-templates select="node()" mode="#current" />
          </para>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node()" mode="#current" />
        </xsl:otherwise>
      </xsl:choose>
    </listitem>
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
        <anchor xml:id="{(@xml:id, @id)}"/>
      </xsl:when>
      <xsl:when test="matches(@href, '^(www\.|http://|mailto:)')">
        <link>
          <xsl:attribute name="xlink:href" select="@href"/>
          <xsl:apply-templates mode="#current"/>
        </link>
      </xsl:when>
      <xsl:when test="matches(@href, '^#')">
        <link linkend="{substring(@href, 2)}">
          <xsl:apply-templates select="@* except @href, node()" mode="#current"/>
        </link>
      </xsl:when>
      <xsl:when test="@href">
        <link>
          <xsl:attribute name="{if (matches(@href, '#')) then 'xlink:href' else 'linkend'}" select="@href"/>
          <xsl:apply-templates select="@* except @href, node()" mode="#current"/>
        </link>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="a/@shape" mode="html2hub:default" />

  <xsl:template match="@id" mode="html2hub:default">
    <xsl:attribute name="xml:id" select="." />
  </xsl:template>

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


  <!-- tables-->

  <xsl:include href="tables.xsl"/>

  <xsl:template match="table/@border" mode="html2hub:default">
    <xsl:if test="not(parent::*/@css:border-width)">
      <xsl:attribute name="css:border-width" select="concat(., if (matches(., 'px$')) then '' else 'px')"/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@class" mode="html2hub:default">
    <xsl:attribute name="role" select="."/>
  </xsl:template>


  <!-- font properties -->

  <xsl:template match="i" mode="html2hub:default">
    <phrase remap="{local-name()}">
      <xsl:if test="not(@css:font-style)">
        <xsl:attribute name="css:font-style" select="'italic'"/>
      </xsl:if>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </phrase>
  </xsl:template>

  <xsl:template match="b | strong" mode="html2hub:default">
    <phrase remap="{local-name()}">
      <xsl:if test="not(@css:font-weight)">
        <xsl:attribute name="css:font-weight" select="'bold'"/>
      </xsl:if>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </phrase>
  </xsl:template>

  <xsl:template match="big" mode="html2hub:default">
    <phrase remap="{local-name()}">
      <xsl:if test="not(@css:font-size)">
        <xsl:attribute name="css:font-size" select="'larger'"/>
      </xsl:if>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </phrase>
  </xsl:template>

  <xsl:template match="small" mode="html2hub:default">
    <phrase remap="{local-name()}">
      <xsl:if test="not(@css:font-size)">
        <xsl:attribute name="css:font-size" select="'smaller'"/>
      </xsl:if>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </phrase>
  </xsl:template>

  <xsl:template match="tt" mode="html2hub:default">
    <phrase remap="{local-name()}">
      <xsl:if test="not(@css:font-family)">
        <xsl:attribute name="css:font-family" select="'Monospace'"/>
      </xsl:if>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </phrase>
  </xsl:template>

  <xsl:template match="u" mode="html2hub:default">
    <phrase remap="{local-name()}">
      <xsl:if test="not(@css:text-decoration)">
        <xsl:attribute name="css:text-decoration" select="'underline'"/>
      </xsl:if>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </phrase>
  </xsl:template>

  <xsl:template match="strike | s" mode="html2hub:default">
    <phrase remap="{local-name()}">
      <xsl:if test="not(@css:text-decoration)">
        <xsl:attribute name="css:text-decoration" select="'line-through'"/>
      </xsl:if>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </phrase>
  </xsl:template>

  <xsl:template match="em" mode="html2hub:default">
    <phrase remap="{local-name()}">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </phrase>
  </xsl:template>


  <!-- text replacements: breaks and multiple whitespace -->
  <xsl:template match="text()[matches(., '(\s\s+|&#xa;)')]" mode="html2hub:default">
    <xsl:value-of select="replace(replace(., '&#xa;', ' '), '(\s)\s+', '$1')"/>
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
                         if (@class ne '') then concat('with class=&quot;', @class, '&quot;') else 'without class',
                         'now moved to hub namespace; content:', if(string-join(.//text(),'') eq '') then '[none]' else string-join(.//text(),'')"/>
  </xsl:template>

</xsl:stylesheet>
