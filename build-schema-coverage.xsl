<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
	xmlns:tmp="urn:oecd:names:xmlns:transform:temp"
	xmlns:ofn="urn:oecd:names:xmlns:transform:functions"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns="urn:oecd:names:xmlns:transform:temp"
	xpath-default-namespace="urn:oecd:names:xmlns:transform:temp"
	exclude-result-prefixes="xs xd" version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Jan 8, 2014</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>Take the elements of a schema and build a stylesheet that counts the occurrences
				of each one within a given document.</xd:p>
		</xd:desc>
	</xd:doc>

	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

	<xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
	
	<xsl:variable name="squo"><xsl:text>'</xsl:text></xsl:variable>


	<xsl:template match="element-list">
		<axsl:stylesheet version="2.0" xmlns="urn:oecd:names:xmlns:transform:temp">
			<axsl:output method="xml" encoding="utf-8"/>
			
			<axsl:param name="document-uri" select="'Unknown Document'"/>

			<axsl:template match="/">
				<document-results href="{{$document-uri}}">
					<xsl:apply-templates>
						<xsl:sort data-type="text" order="ascending" select="@namespace"/>
						<xsl:sort data-type="text" order="ascending" select="@local-name"/>
					</xsl:apply-templates>
				</document-results>
			</axsl:template>
			
		</axsl:stylesheet>

	</xsl:template>
	
	<xsl:template match="element">
		<xsl:variable name="count" select="ofn:build-count(.)"/>
		<result caption="{if (not(@name eq '*')) then @name else concat(@namespace, ':*')}" count="{concat('{', $count, '}')}">
			<xsl:copy-of select="@*"/>
		</result>
	</xsl:template>


	<xsl:function name="ofn:build-count" as="xs:string">
		<xsl:param name="the-node" as="element()"/>
		<xsl:variable name="predicate1" select="if ($the-node/@name eq '*') then '' else concat('[local-name(.) eq ', $squo, $the-node/@local-name, $squo, ']')"/>
		<xsl:variable name="predicate2" select="concat('[namespace-uri(.) eq ', $squo, $the-node/@namespace, $squo,']')"/>
		<xsl:sequence select="concat('count(//*', $predicate1, $predicate2, ')')"/>
	</xsl:function>
	

</xsl:stylesheet>
