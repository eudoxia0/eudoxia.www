<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" indent="yes"/>
  <xsl:preserve-space elements="code"/>
  <xsl:strip-space elements="*"/>

  <xsl:template name="template-head">
    <xsl:param name="title"/>
    <head>
      <meta charset="utf-8"/>
      <title><xsl:value-of select="$title"/></title>
      <link rel="stylesheet" href="/static/style.css"/>
    </head>
  </xsl:template>

  <xsl:template name="after-body">
    <script src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
    <script type="text/x-mathjax-config">
      MathJax.Hub.Config({
        tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}
      });
    </script>
  </xsl:template>

  <!-- Page templates -->
  <xsl:template match="page">
    <!-- Generic page -->
    <xsl:variable name="title" select="@title"/>
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
    <html lang="en">
      <xsl:call-template name="template-head">
        <xsl:with-param name="title" select="$title"/>
      </xsl:call-template>
      <body>
        <div id="main">
          <xsl:apply-templates/>
        </div>
        <xsl:call-template name="after-body"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="post">
    <!-- Generic page -->
    <xsl:variable name="title" select="@title"/>
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
    <html lang="en">
      <xsl:call-template name="template-head">
        <xsl:with-param name="title" select="$title"/>
      </xsl:call-template>
      <body>
        <h1><xsl:value-of select="$title"/></h1>
        <article>
          <xsl:apply-templates/>
        </article>
        <xsl:call-template name="after-body"/>
      </body>
    </html>
  </xsl:template>

  <!-- Paragraph splitting.
       Credit: http://stackoverflow.com/questions/3733411/xslt-convert-carriage-returns-to-paragraphs-in-mixed-node-while-preserving-html -->
  <xsl:variable name="delim" select="'&#10;&#10;'"/>

  <xsl:template match="//p">
    <div class="p-block">
      <xsl:apply-templates select="node()[1]"/>
    </div>
  </xsl:template>

  <xsl:template match="node()" mode="open" name="open">
    <xsl:copy-of select="."/>
    <xsl:apply-templates select="following-sibling::node()[1]" 
                         mode="open"/>
  </xsl:template>

  <xsl:template match="//p/node()">
    <xsl:param name="pTail" select="''"/>
    <p>
      <xsl:value-of select="$pTail"/>
      <xsl:call-template name="open"/>
    </p>
    <xsl:variable name="vNext" 
                  select="following-sibling::text()[contains(., $delim)][1]"/>
    <xsl:apply-templates select="$vNext">
      <xsl:with-param name="pString" 
                      select="substring-after($vNext, $delim)"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="text()[contains(., $delim)]" 
                mode="open" priority="1">
    <xsl:value-of select="substring-before(., $delim)"/>
  </xsl:template>

  <xsl:template match="//p/text()[contains(., $delim)]"
                priority="1" name="text">
    <xsl:param name="pString" select="."/>
    <xsl:choose>
      <xsl:when test="contains($pString, $delim)">
        <xsl:variable name="vOutput" 
                      select="normalize-space(substring-before($pString, $delim))"/>
        <xsl:if test="$vOutput">
          <p>
            <xsl:value-of select="$vOutput"/>
          </p>
        </xsl:if>
        <xsl:call-template name="text">
          <xsl:with-param name="pString"
                          select="substring-after($pString, $delim)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="following-sibling::node()[1]">
          <xsl:with-param name="pTail" select="$pString" />
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@* | node()">
    <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>