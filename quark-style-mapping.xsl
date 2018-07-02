<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:xpress="urn:xpressauthor:xpressschema"
	xmlns="urn:oecd:names:xmlns:transform:temp"
	xpath-default-namespace="urn:xpressauthor:xpressschema" exclude-result-prefixes="xs xd xpress	"
	version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Oct 29, 2013</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>This stylesheet extracts element definitions from the express schema and builds a
				map of element name (OECD) to potential Word style names for that element. We can't
				be truly accurate here because a single element name may map to multiple style
				names. It may be possible to handle this later if required by counting the
				occurrences of the word 'sub' in the QXA element names!</xd:p>
		</xd:desc>
	</xd:doc>

	<xsl:output indent="yes"/>

	<xd:doc>
		<xd:desc>Generate a mapping in an OECD namespace for later use as a lookup in content
			comparisons. Since there are multiple element definitions for style names, we'll build a
			list via grouping. Only those elements with </xd:desc>
	</xd:doc>
	<xsl:template match="XpressSchema">
		<mapping>
			<xsl:for-each-group select="Elements/ElementDef[@style]"
				group-by="@xmlname">
				<element-def name="{@xmlname}">
				<xsl:for-each select="distinct-values(current-group()/@style)">
					<style><xsl:value-of select="."/></style>
				</xsl:for-each>
				</element-def>
			</xsl:for-each-group>
		</mapping>
	</xsl:template>
	
	
	
</xsl:stylesheet>
