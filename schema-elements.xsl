<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	exclude-result-prefixes="xs xd" xpath-default-namespace="http://www.w3.org/2001/XMLSchema"
	xmlns="urn:oecd:names:xmlns:transform:temp"
	version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Jan 7, 2014</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>Extract all the locally namespaced elements and top level imported elements from a
				flattened schema</xd:p>
		</xd:desc>
	</xd:doc>
	
	<xsl:output indent="yes"></xsl:output>

	<xsl:variable name="top-namespace" select="/xs:schema/@targetNamespace"/>
	<xsl:variable name="top-prefix"
		select="for $ns in in-scope-prefixes(/xs:schema) 
			return if  (namespace-uri-for-prefix($ns, /xs:schema) = $top-namespace) 
			then $ns else ()"
		as="xs:string"/>

	<!-- generate the element list -->
	<xsl:template match="xs:schema">
		

		<element-list namespace="{@targetNamespace}">
			<xsl:for-each-group select="descendant::xs:element|descendant::xs:any" group-by="(@name, @ref, @namespace)[1]">
				<xsl:apply-templates select="." />				
			</xsl:for-each-group>
		</element-list>

	</xsl:template>
	
	<xsl:template match="xs:any">
		<element name="*" local-name="*" namespace="{@namespace}"/>
	</xsl:template>
	
	<xsl:template match="xs:any[starts-with(@namespace, '#')]"/>
	
	<xsl:template match="xs:element[@ref][not(contains(@ref, ':'))]" priority="1">
		<element name="{@ref}" local-name="{@ref}" namespace="{$top-namespace}"/>
	</xsl:template>
	
	<xsl:template match="xs:element[@ref][starts-with(@ref, concat($top-prefix, ':'))]" priority="1">
		<element local-name="{substring-after(@ref, concat($top-prefix, ':'))}"
			namespace="{$top-namespace}"/>
	</xsl:template>
	
	<!-- never going to be used -->
	<xsl:template match="xs:element[@abstract='true']"  priority="2"/> 
	
	<xsl:template match="xs:element[@ref]">
		<element local-name="{substring-after(@ref, ':')}" name="{@ref}"
			namespace="{namespace-uri-for-prefix(substring-before(@ref, ':'), .)}"/>
	</xsl:template>
	

	<xsl:template match="xs:element[@name][not(contains(@name, ':'))]"  priority="1">
		<element name="{@name}" local-name="{@name}" namespace="{$top-namespace}"/>
	</xsl:template>

	<xsl:template match="xs:element[@name][starts-with(@name, concat($top-prefix, ':'))]" priority="1">
		<element local-name="{substring-after(@name, concat($top-prefix, ':'))}"
			namespace="{$top-namespace}"/>
	</xsl:template>

	<xsl:template match="xs:element[@name]">
		<element local-name="{substring-after(@name, ':')}" name="{@name}"
			namespace="{namespace-uri-for-prefix(substring-before(@name, ':'), .)}"/>
	</xsl:template>




</xsl:stylesheet>
