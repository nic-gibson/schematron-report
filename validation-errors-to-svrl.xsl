<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns="http://purl.oclc.org/dsdl/svrl" exclude-result-prefixes="xs xd" version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Oct 1, 2013</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>Given XML validation data where the XPath to the error has been synthesised (by
					<xd:a href="insert-error-markers.xsl">insert-error-markers.xsl</xd:a> create a
				dummy SVRL output to use as the validation output.</xd:p>
		</xd:desc>
	</xd:doc>

	<xd:doc>
		<xd:desc>
			<xd:p>The id of the dummy schematron pattern that we output.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="pattern-id" select="'xsd-validation'"/>

	<xd:doc>
		<xd:desc>
			<xd:p>The id of the dummy schematron rule that we output.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="rule-id" select="'validate-document'"/>

	<xd:doc>
		<xd:desc>
			<xd:p>The id of the dummy assertion that we output</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="assertion-id" select="'validate-node'"/>

	<xd:doc>
		<xd:desc>
			<xd:p>The role of the dummy assertion that we output</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="assertion-role" select="'validation-error'"/>

	<xd:doc>
		<xd:desc>
			<xd:p>The test attribute on the dummy assertion that we output</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="assertion-test" select="'validate()'"/>

	<xd:doc>
		<xd:desc>
			<xd:p>Generate the SVRL document. This is a very simple document as we only have one
				pattern and one rule.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="c:errors">
		<svrl:schematron-output>
			<xsl:call-template name="generate-pattern"/>
			<xsl:call-template name="generate-rule"/>
			<xsl:apply-templates/>
		</svrl:schematron-output>
	</xsl:template>

	<xd:doc>
		<xd:desc>
			<xd:p>The SVRL pattern is generated using the id value in the param above.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template name="generate-pattern">
		<svrl:active-pattern id="{$assertion-id}"/>
	</xsl:template>

	<xd:doc>
		<xd:desc>
			<xd:p>The SVRL rule is generated using the id value in the param above.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template name="generate-rule">
		<svrl:fired-rule id="{$rule-id}" context="/"/>
	</xsl:template>

	<xd:doc>
		<xd:desc>
			<xd:p>Process each c:error element and generate the appropriate svrl assertion
				element.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="c:error[not(@column)]">
		<svrl:failed-assert location="{@select}" id="{$assertion-id}" role="{$assertion-role}"
			test="{$assertion-test}">
			<svrl:text>
				<xsl:value-of select="text()"/>
			</svrl:text>
		</svrl:failed-assert>
	</xsl:template>

</xsl:stylesheet>
