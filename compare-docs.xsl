<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	 xpath-default-namespace="urn:oecd:names:xmlns:transform:temp"
	 xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	 xmlns:ofn="urn:oecd:names:xmlns:transform:functions"
	xmlns:temp="urn:oecd:names:xmlns:transform:temp" exclude-result-prefixes="xs xd" version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Oct 31, 2013</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>Compare a set of pairs of elements. When both the text value of the pairs are the same and the
			styles are valid, suppress the elements. Otherwise, output the elements with additional attributes
			showing if styles match and if text matches.</xd:p>
		</xd:desc>
	</xd:doc>
	
	<xsl:key name="style-map-key" match="/*/mapping/element-def/style" use="parent::*/@name"/>

	<xsl:template match="mapping"/>
	
	<xsl:template match="paired-doc">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="block-pair[not(lower-case(normalize-space(block[1])) = lower-case(normalize-space(block[2]))) 
		or (block[1]/@style and not(block[1]/@style= key('style-map-key', block[1]/@style)))]">
		<xsl:variable name="style" select='block[1]/@style'/>
		<xsl:copy>
			<xsl:attribute name="style-match" select="if ($style and not($style = key('style-map-key', $style))) then 1 else 0"/>
			<xsl:if test="@style and not($style = key('style-map-key', $style))
				">
				<xsl:attribute name="other-style" select="string-join(key('style-map-key', $style), ' ')"/>
			</xsl:if>
			<xsl:attribute name="text-match" select="if (lower-case(normalize-space(block[1])) = lower-case(normalize-space(block[2]))) then 1 else 0"/>
			<xsl:copy-of select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="block-pair"/>
		
	
</xsl:stylesheet>
