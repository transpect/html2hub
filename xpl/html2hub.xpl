<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xhtml = "http://www.w3.org/1999/xhtml"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:html2hub="http://www.le-tex.de/namespace/html2hub" 
  xmlns:letex="http://www.le-tex.de/namespace" 
  exclude-inline-prefixes="#all"
  version="1.0"
  name="html2hub"
  type="html2hub:convert"
  >

  <p:documentation>IMPORTANT: If you are already invoking this step without a paths
  port, your pipeline probably won’t work any more. Please add the following connection
  to the invocation:
    &lt;p:input port="paths"&gt;&lt;p:empty/&gt;&lt;/p:input&gt;
  </p:documentation>

  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>

  <p:input port="source" primary="true"/>
  <p:input port="paths" sequence="true">
    <p:documentation>If you don’t want to use the bc:load-cascaded mechanism but 
    rather use the default XSLT, you can submit <p:empty/> to this port.</p:documentation>
  </p:input>
  <p:input port="other-params" sequence="true" kind="parameter" primary="true"/>
    
  <p:output port="result" primary="true"/>
  
  <p:import href="http://transpect.le-tex.de/css-expand/xpl/css.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/simple-progress-msg.xpl"/>
  
  <p:variable name="status-dir-uri" select="concat($debug-dir-uri, '/status')"/>
  
  <letex:simple-progress-msg name="start-msg" file="hub2html-start.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Starting conversion from HTML to Hub XML</c:message>
          <c:message xml:lang="de">Beginne Konvertierung von HTML nach Hub XML</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </letex:simple-progress-msg>
  
  <p:sink/>
  
  <p:parameters name="params">
    <p:input port="parameters">
      <p:pipe step="html2hub" port="paths"/>
      <p:pipe step="html2hub" port="other-params"/>
    </p:input>
  </p:parameters>
  
  <css:expand name="add-css-attributes">
    <p:with-option name="debug" select="$debug" />
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
    <p:input port="source">
      <p:pipe port="source" step="html2hub"/>
    </p:input>
  </css:expand>

  <bc:load-cascaded name="lc" required="no" filename="html2hub/html2hub.xsl" fallback="http://transpect.le-tex.de/html2hub/xsl/html2hub.xsl">
    <p:input port="paths">
      <p:pipe port="paths" step="html2hub"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </bc:load-cascaded>

  <p:sink/>

  <p:xslt name="default" template-name="html2hub">
    <p:input port="parameters"><p:pipe step="params" port="result"/></p:input>
    <p:input port="stylesheet">
      <p:pipe step="lc" port="result"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="result" step="add-css-attributes"/>
    </p:input>
  </p:xslt>

  <letex:store-debug pipeline-step="html2hub/result" extension="xml">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </letex:store-debug>

  <letex:simple-progress-msg name="success-msg" file="hub2html-success.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Successfully converted HTML to Hub XML</c:message>
          <c:message xml:lang="de">Konvertierung von HTML nach Hub XML erfolgreich abgeschlossen</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </letex:simple-progress-msg>
  
</p:declare-step>