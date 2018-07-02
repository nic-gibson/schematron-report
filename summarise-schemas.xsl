<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:ofn="urn:oecd:names:xmlns:transform:functions"
	xmlns:tmp="urn:oecd:names:xmlns:transform:temp"
	xpath-default-namespace="urn:oecd:names:xmlns:transform:temp"
	xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xs xd ofn" version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Jan 9, 2014</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p/>
		</xd:desc>
	</xd:doc>


	<xsl:output method="html" version="5.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

	<xd:doc>
		<xd:desc> Set this to 'insert' to load the stylesheet and any other value to reference
			it.</xd:desc>
	</xd:doc>
	<xsl:param name="css-mode" select="'insert'"/>

	<xd:doc>
		<xd:desc>Change this to the URL for the stylesheet.</xd:desc>
	</xd:doc>
	<xsl:param name="css-url" select="'../css/schema-report.css'"/>

	<!-- set to false to stop the output of rule, etc ids where present -->
	<xsl:param name="output-schematron-id" select="'true'"/>

	<!-- set this to override the default title -->
	<xsl:param name="report-title" select="'Schema Coverage Report'"/>

	<!-- use this to set the location of the import files in the output stylesheet -->
	<xsl:param name="where-am-i" select="base-uri(document(''))"/>

	<!-- dummy result for ensure three cells in a row -->
	<xsl:variable name="dummy-result" as="element()*">
		<tmp:result dummy="true"/>
	</xsl:variable>

	<xsl:template match="documents">
		<html>
			<head>
				<title>
					<xsl:value-of select="$report-title"/>
				</title>
				<meta charset="utf-8"/>
				<xsl:choose>
					<xsl:when test="$css-mode != 'insert'">
						<link href="{resolve-uri($css-url, $where-am-i)}" type="text/css" rel="stylesheet"/>
					</xsl:when>
					<xsl:otherwise>
						<style type="text/css">
							<xsl:value-of select="unparsed-text($css-url)"/>
						</style>
					</xsl:otherwise>
				</xsl:choose>
			</head>
			<body>
				<h1>
					<xsl:value-of select="$report-title"/>
				</h1>

				<xsl:apply-templates select="document-results[1]" mode="generate-element-summary"/>
				<xsl:apply-templates select="document-results"/>
				<xsl:apply-templates select="document-results[1]" mode="generate-element-detail"/>

			</body>
		</html>

	</xsl:template>


	<!-- generate a list of all the elements and total number of times each was used. Each element
	 needs to be a link to the detaile usage info -->
	<xsl:template match="document-results" mode="generate-element-summary">
		
		<xsl:variable name="used-elements" as="element()*">
			<xsl:apply-templates select="result" mode="summarise"/>
		</xsl:variable>
		
		<xsl:variable name="used-count" select="count($used-elements)"/>
		
		<xsl:variable name="cells" select="($used-elements, 
			if ($used-count mod 3) then $dummy-result else (),
			if ($used-count mod 3 = 1) then $dummy-result else ())"/>
		
		<table class="element-summary">
			<caption>Element Usage Summary</caption>
			<xsl:call-template name="build-rows">
				<xsl:with-param name="cells" select="$cells"/>
			</xsl:call-template>
		</table>
	</xsl:template>


	<!-- normal processing for a document -->
	<xsl:template match="document-results">
		
		<xsl:variable name="used-elements" select="result[not(@count = 0)]"/>
		<xsl:variable name="used-count" select="count($used-elements)"/>
		
		<xsl:variable name="cells" select="($used-elements, 
			if ($used-count mod 3) then $dummy-result else (),
			if ($used-count mod 3 = 2) then $dummy-result else ())"/>


		<section class="document">
			<h2>
				<xsl:value-of select="@href"/>
			</h2>
			<div class="summary">
				<table>
					<tr>
						<th>Elements used:</th>
						<td>
							<xsl:value-of select="count(result[xs:integer(@count) gt 0])"/>
						</td>
					</tr>
					<tr>
						<th>Elements not used:</th>
						<td>
							<xsl:value-of select="count(result[xs:integer(@count) eq 0])"/>
						</td>
					</tr>
				</table>
			</div>

			<table class="element-summary">
				<caption>Element Usage Summary</caption>
				<xsl:call-template name="build-rows">
					<xsl:with-param name="cells" select="$cells"/>
				</xsl:call-template>
			</table>

		</section>
	</xsl:template>

	
	<xsl:template name="build-rows">
		<xsl:param name="cells" as="item()*"/>
		<xsl:variable name="offset" select="xs:integer(count($cells) div 3)"/>
		<xsl:for-each select="1 to $offset">
			<xsl:variable name="c1" select="xs:integer(.)"/>
			<xsl:variable name="c2" select="$c1 + $offset"/>
			<xsl:variable name="c3" select="$c2 + $offset"/>
			<tr>
				<xsl:apply-templates select="($cells[$c1], $cells[$c2], $cells[$c3])"/>
			</tr>
		</xsl:for-each>
	</xsl:template>


	<xsl:template match="result[@mode='dummy']" mode="#all">
		<td>&#160;</td><td>&#160;</td>
	</xsl:template>

	<xsl:template match="result" mode="summarise">
		<xsl:copy>
			<xsl:copy-of select="@* except count"/>
			<xsl:attribute name="count" select="sum(//result[@name = current()/@name][@namespace = current()/@namespace]/@count)"/>
			<xsl:copy-of select="node()"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="result">
		<td>
			
				<xsl:value-of select="@caption"/>
			
		</td>
		<td class="numeric {if (@count = 0) then 'unused' else ''}" >
			<xsl:value-of select="@count"/>
		</td>
	</xsl:template>



</xsl:stylesheet>
