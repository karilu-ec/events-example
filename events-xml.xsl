<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" extension-element-prefixes="exsl str set" version="1.0" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" xmlns:str="http://exslt.org/strings">
  <xsl:include href="/_cascade/formats/event-xml-builder"/>
  <xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>
  
  <!-- 
    This variable is appended onto the end of page URLs. Change the value to correspond
    with the extensions of your pages (eg .html, .php, .aspx).
  -->
  <xsl:variable name="pageExtension">.html</xsl:variable>

  <xsl:variable name="folderPrefix">/</xsl:variable>

  <xsl:template match="/">
    <xsl:variable name="currentPage" select="//system-page[@current]"/>
    <xsl:variable name="fixedPath" select="translate(substring-before($currentPage/path, $currentPage/name),'/','')"/>

    <xml>
      <xsl:choose>
        <!-- If we're within a YYYY/MM folder, grab single events from the current month. -->
        <xsl:when test="string-length($fixedPath) &gt; 4">
          <xsl:apply-templates select="//system-page[not(@current) and system-data-structure/@definition-path='Event']">
            <xsl:sort select="starts"/>
          </xsl:apply-templates>
        </xsl:when>
        <!-- If we're within a YYYY folder, grab recurring events from each month in this year. -->
        <xsl:when test="string-length($fixedPath) = 4">
          <xsl:apply-templates select="//system-page[not(@current) and name != 'index' and contains(path, $fixedPath)]">
            <xsl:sort select="starts"/>
          </xsl:apply-templates>
        </xsl:when>
        <!-- Otherwise, do nothing. -->
        <xsl:otherwise/>    
      </xsl:choose>
    </xml>
  </xsl:template>
  <xsl:template match="system-page">
      <xsl:call-template name="build-event-xml">
          <xsl:with-param name="page" select="."/>
          <xsl:with-param name="pageExtension" select="$pageExtension"/>          
      </xsl:call-template>
  </xsl:template>
  
</xsl:stylesheet>