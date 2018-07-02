<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:oecd="urn:oecd:names:xmlns:authoring:document"
	xpath-default-namespace="urn:oecd:names:xmlns:authoring:document"
	xmlns:temp="urn:oecd:names:xmlns:transform:temp" xmlns="urn:oecd:names:xmlns:transform:temp"
	exclude-result-prefixes="xs xd oecd temp" version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Oct 29, 2013</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>Filters an xml document down to paragraph content</xd:p>
			<xd:p>
				<xd:b>WARNING - this version only handles paragraph content. Specifically, footnotes
					will be suppressed as will metadata</xd:b>
			</xd:p>
		</xd:desc>
	</xd:doc>

	<xsl:strip-space elements="*"/>
	<xsl:output indent="yes"/>

	<xsl:template match="/">
		<document>
			<xsl:variable name="phase1">
				<xsl:apply-templates/>
			</xsl:variable>
			<xsl:apply-templates select="$phase1" mode="strip-excess"/>
		</document>
	</xsl:template>

	<xsl:template match="@*|node()" mode="strip-excess">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="temp:block[temp:block]" mode="strip-excess">
		<xsl:copy>
			<xsl:apply-templates select="@*|node() except temp:block" mode="strip-excess"/>
		</xsl:copy>
		<xsl:apply-templates select="temp:block" mode="strip-excess"/>
	</xsl:template>

	<xsl:template match="temp:block[temp:block][matches(string-join(text(), ''), '^\s*$')]"
		mode="strip-excess">
		<xsl:apply-templates select="temp:block" mode="strip-excess"/>
	</xsl:template>

	<xsl:template match="metadata|footnote" priority="1"/>

	<xd:doc>
		<xd:desc>The highest level nodes which actually directly contain text should be converted to
			blocks of text.</xd:desc>
	</xd:doc>
	<xsl:template match="*[text()][not(ancestor::*[text()])][not(normalize-space(text()) = '')]">
		<block element="{local-name()}">
			<xsl:apply-templates/>
		</block>
	</xsl:template>

	<xsl:template match="para[child::*][not(normalize-space(.) = '')]">
		<block element="para">
			<xsl:apply-templates/>
		</block>
	</xsl:template>

	<!-- This is here to work around Quark's external graphic oddities -->
	<xsl:template match="external-graphic" priority="2"/>

	<xd:doc>
		<xd:desc>Just return the text of nodes which are descendants of nodes with text!</xd:desc>
	</xd:doc>
	<xsl:template
		match="*[text()][ancestor::*[text()]]|*[not(text())]|*[normalize-space(text()) = '']">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="emphasis" priority="2">
		<xsl:apply-templates/>
	</xsl:template>


	<xd:doc>
		<xd:desc>In order to handle a Quark 'foible', paragraphs which contain line breaks but no
			other element content must be broked into multiple blocks.</xd:desc>
	</xd:doc>
	<xsl:template match="para[not(*)][matches(., '&#x0A;')]" priority="2">
		<xsl:variable name="tokens" select="tokenize(., '&#x0D;?&#x0A;')"/>
		<xsl:for-each select="$tokens">
			<block element="para">
				<xsl:value-of select="normalize-space(.)"/>
			</block>
		</xsl:for-each>
	</xsl:template>


	<xd:doc>
		<xd:desc>Just normalize all text.</xd:desc>
	</xd:doc>
	<xsl:template match="text()">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>


	<xd:doc>
		<xd:desc>Suppress empty nodes that would otherwise become empty blocks</xd:desc>
	</xd:doc>
	<xsl:template match="*[text()][not(ancestor::*[text()])][normalize-space(text()) = '']"/>




</xsl:stylesheet>
