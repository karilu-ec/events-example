<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" extension-element-prefixes="exsl str set" version="1.0" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" xmlns:str="http://exslt.org/strings">
  <xsl:include href="/_cascade/formats/include/format-date"/>
  <xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>
  
  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
  
  <xsl:template name="build-event-xml">
    <xsl:param name="page"/>
    
    <!-- 
    This variable is appended onto the end of page URLs. Change the value to correspond
    with the extensions of your pages (eg .html, .php, .aspx).
    -->
    <xsl:param name="pageExtension"/>
    
    <xsl:variable name="pageSDS" select="$page/system-data-structure"/>

    <xsl:variable name="start-day">
      <xsl:call-template name="format-date">
        <xsl:with-param name="date" select="$pageSDS/starts"/>
        <xsl:with-param name="mask" select="'d'"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="end-day">
      <xsl:call-template name="format-date">
        <xsl:with-param name="date" select="$pageSDS/ends"/>
        <xsl:with-param name="mask" select="'d'"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="multiday">
      <xsl:choose>
        <xsl:when test="$start-day != $end-day">true</xsl:when>
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="allday">
      <xsl:choose>
        <xsl:when test="$pageSDS/all-day/value = 'Yes'">true</xsl:when>
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="recurUntil">
        <xsl:choose>
            <xsl:when test="$pageSDS/recurrence/ends != ''">
                  <xsl:call-template name="format-date">
                    <xsl:with-param name="date" select="$pageSDS/recurrence/ends"/>
                    <xsl:with-param name="mask" select="'isoUtcDateTime'"/>
                  </xsl:call-template>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="recurrence-frequency">
      <xsl:choose>
          <xsl:when test="$pageSDS/recurrence/frequency = ''">Once</xsl:when>
          <xsl:otherwise><xsl:value-of select="$pageSDS/recurrence/frequency"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
        
    <event>
      <title>
        <xsl:call-template name="replace-string">
          <xsl:with-param name="text" select="$page/title"/>
          <xsl:with-param name="replace">'</xsl:with-param>
          <xsl:with-param name="with">&apos;</xsl:with-param>                                
        </xsl:call-template>
      </title>
      <id><xsl:value-of select="$page/@id"/></id>
      <summary><xsl:value-of select="$page/summary"/></summary>
      <location><xsl:value-of select="$pageSDS/location"/></location>
      <target>[system-view:internal]true[/system-view:internal][system-view:external]false[/system-view:external]</target>
      <start>
        <xsl:call-template name="format-date">
          <xsl:with-param name="date" select="$pageSDS/starts"/>
          <xsl:with-param name="mask" select="'isoUtcDateTime'"/>
        </xsl:call-template>
      </start>
      <end>
        <xsl:call-template name="format-date">
          <xsl:with-param name="date" select="$pageSDS/ends"/>
          <xsl:with-param name="mask" select="'isoUtcDateTime'"/>
        </xsl:call-template>
      </end>
      <categories>
        <xsl:for-each select="$page/dynamic-metadata[name='categories']/value"><category><xsl:value-of select="."/></category></xsl:for-each>
      </categories>
      <path>[system-view:external]<xsl:value-of select="$page/path"/><xsl:value-of select="$pageExtension"/>[/system-view:external][system-view:internal][system-asset]<xsl:value-of select="$page/path"/>[/system-asset][/system-view:internal]</path>
      <allday>
        <xsl:choose>
          <xsl:when test="$multiday = 'true'">true</xsl:when>
          <xsl:when test="$allday = 'true'">true</xsl:when>
          <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
      </allday>
      <recurrence>
        <frequency><xsl:value-of select="$recurrence-frequency"/></frequency>
        <xsl:if test="$recurrence-frequency != 'Once'">
            <interval><xsl:value-of select="$pageSDS/recurrence/interval"/></interval>
            <byday>
            <xsl:for-each select="$pageSDS/recurrence/day/value">
              <day><xsl:value-of select="."/></day>
            </xsl:for-each>
            </byday>
            <monthly-day><xsl:value-of select="$pageSDS/recurrence/monthly-day"/></monthly-day>
            <until><xsl:value-of select="$recurUntil"/></until>
        </xsl:if>  
      </recurrence>
    </event>
  </xsl:template>
    
  <xsl:template name="replace-string">
    <xsl:param name="text"/>
    <xsl:param name="replace"/>
    <xsl:param name="with"/>
    <xsl:choose>
      <xsl:when test="contains($text,$replace)">
        <xsl:value-of select="substring-before($text,$replace)"/>
        <xsl:value-of select="$with"/>
        <xsl:call-template name="replace-string">
          <xsl:with-param name="text" select="substring-after($text,$replace)"/>
          <xsl:with-param name="replace" select="$replace"/>
          <xsl:with-param name="with" select="$with"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="stringtolower">
    <xsl:param name="string"/>
    <xsl:value-of select="translate($string, $uppercase, $lowercase)"/>
  </xsl:template>
    
</xsl:stylesheet>