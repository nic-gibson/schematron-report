<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	exclude-result-prefixes="xs xd"
	version="2.0">
	
	<xd:doc>
		<xd:desc>Simple stylesheet to strip out those elements and attributes
		added by QXA that will never be valid in the OECD models and should
		never be validated. These should eventually vanish or be handled
		in the save/load transformations.</xd:desc>
	</xd:doc>
	
	
	<!-- remove meaningless whitespace -->
	<xsl:strip-space elements="*"/>
	
	<!-- identity for the masses -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select='@*|node()'/>
		</xsl:copy>
	</xsl:template>
	
	<!-- remove any text nodes that are direct children of the root. This removes
		the CDATA section that Quark use to store the cover page content -->
	<xsl:template match="*:document/text()|*:publication/text()"/>
	
	
	<!-- attributes to suppress because we don't care to validate them but they
	are basically required by QXA -->
	<xsl:template match="@keep-with-next|@widow-control"/>
	
	
	<!-- For some reason the submission processing wraps the  document in another
		element. Strip it out -->
	<xsl:template match="NormalNode">
		<xsl:apply-templates/>
	</xsl:template>
	
	
</xsl:stylesheet>