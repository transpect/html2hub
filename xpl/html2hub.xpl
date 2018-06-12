<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xhtml = "http://www.w3.org/1999/xhtml"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:htmltable="http://transpect.io/htmltable"
  xmlns:html2hub="http://transpect.io/html2hub" 
  xmlns:tr="http://transpect.io" 
  exclude-inline-prefixes="#all"
  version="1.0"
  name="html2hub"
  type="html2hub:convert"
  >

  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>

  <p:option name="prepend-hub-xml-model" required="false" select="'true'"/>
  <p:option name="hub-version" select="'1.1'"/>

  <p:option name="archive-dir-uri" required="false" select="''"/>
  <p:option name="src-type" required="false" select="'xhtml11'"/>
  
  <p:option name="shorthand-css" required="false" select="'no'"/>

  <p:input port="source" primary="true"/>
  <p:input port="stylesheet">
    <p:document href="../xsl/html2hub.xsl"/>
  </p:input>
  <p:input port="other-params" sequence="true" kind="parameter" primary="true"/>
  <p:input port="schema" primary="false">
    <p:documentation>Excepts the Hub RelaxNG XML schema</p:documentation>
    <p:document href="../../schema/Hub/hub.rng"/>
  </p:input>
    
  <p:output port="result" primary="true">
    <p:pipe port="result" step="include-hub-model"/>
  </p:output>
  
  <p:import href="http://transpect.io/css-tools/xpl/css.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xml-model/xpl/prepend-hub-xml-model.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/calabash-extensions/rng-extension/xpl/rng-validate-to-PI.xpl"/>
  <p:import href="http://transpect.io/htmltables/xpl/add-origin-atts.xpl"/>



  <p:variable name="status-dir-uri" select="concat($debug-dir-uri, '/status')"/>
  <p:variable name="basename" select="replace(base-uri(), '^(.+?)([^/\\]+)\.x?html$', '$2')"/>
    
  <tr:simple-progress-msg name="start-msg">
    <p:with-option name="file" select="concat('hub2html-start.',$basename,'.txt')"/>
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Starting conversion from HTML to Hub XML</c:message>
          <c:message xml:lang="de">Beginne Konvertierung von HTML nach Hub XML</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
  <p:sink/>
  
  <p:parameters name="params">
    <p:input port="parameters">
      <p:pipe step="html2hub" port="other-params"/>
    </p:input>
  </p:parameters>

  <p:load name="load-normalize-stylesheet" href="../xsl/namespace-normalization.xsl"/>

  <p:choose name="namespaces">
    <p:when test="/*/namespace-uri() ne 'http://www.w3.org/1999/xhtml'">
      <p:xpath-context>
        <p:pipe port="source" step="html2hub"/>
      </p:xpath-context>
      <p:xslt name="normalize-namespace">
        <p:input port="source">
          <p:pipe port="source" step="html2hub"/>
        </p:input>
        <p:input port="stylesheet">
          <p:pipe port="result" step="load-normalize-stylesheet"/>
        </p:input>
        <p:with-param name="archive-dir-uri" select="$archive-dir-uri"/>
        <p:with-param name="src-type" select="$src-type"/>
      </p:xslt>
    </p:when>
    <p:otherwise>
      <p:identity>
        <p:input port="source">
          <p:pipe port="source" step="html2hub"/>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>

  <p:identity name="normalize"/>

  <css:expand name="add-css-attributes">
    <p:with-option name="debug" select="$debug" />
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
    <p:input port="source">
      <p:pipe port="result" step="normalize"/>
    </p:input>
  </css:expand>

  <htmltable:add-origin-atts name="add-origin-atts">
    <p:documentation>Normalizes rowspans and colspans in tables.</p:documentation>
    <p:input port="source">
      <p:pipe port="result" step="add-css-attributes"/>
    </p:input>
  </htmltable:add-origin-atts>
  
  <p:xslt name="hub" initial-mode="html2hub:default">
    <p:input port="source">
      <p:pipe port="result" step="add-origin-atts"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe step="html2hub" port="stylesheet"/>
    </p:input>
    <p:with-param name="shorthand-css" select="$shorthand-css"/>
  </p:xslt>
  
  <tr:store-debug pipeline-step="html2hub/result" extension="xml">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:sink/>

  <p:load name="load-hub-keywords-stylesheet" href="../xsl/hub-keywords.xsl"/>

  <p:xslt name="hub-keywords">
    <p:input port="source">
      <p:pipe port="result" step="hub"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="result" step="load-hub-keywords-stylesheet"/>
    </p:input>
    <p:with-param name="archive-dir-uri" select="$archive-dir-uri"/>
    <p:with-param name="src-type" select="$src-type"/>
  </p:xslt>

  <p:choose>
    <p:when test="$prepend-hub-xml-model='true'">
      <tr:prepend-hub-xml-model>
        <p:with-option name="hub-version" select="$hub-version"/>
      </tr:prepend-hub-xml-model>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>

  <p:identity name="include-hub-model"/>

  <tr:validate-with-rng-PI name="rng2pi">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="schema">
      <p:pipe port="schema" step="html2hub"/>
    </p:input>
  </tr:validate-with-rng-PI>
  
  <tr:store-debug>
    <p:with-option name="pipeline-step" select="concat('rngvalid/',$basename,'.with-PIs')"/>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <tr:simple-progress-msg name="success-msg">
    <p:with-option name="file" select="concat('html2hub-success.',$basename,'.txt')"/>
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Successfully converted HTML to Hub XML</c:message>
          <c:message xml:lang="de">Konvertierung von HTML nach Hub XML erfolgreich abgeschlossen</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
  <p:sink/>

</p:declare-step>