<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
	xmlns:corbas="http://www.corbas.net/ns/functions" exclude-result-prefixes="svrl corbas xd axsl "
	xmlns="http://www.w3.org/1999/xhtml" version="2.0">

	<!--	
		
	This program and accompanying files are copyright 2008, 2009, 20011, 2012, 2013 Corbas Consulting Ltd.
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see http://www.gnu.org/licenses/.
	
	If your organisation or company are a customer or client of Corbas Consulting Ltd you may
	be able to use and/or distribute this software under a different license. If you are
	not aware of any such agreement and wish to agree other license terms you must
	contact Corbas Consulting Ltd by email at corbas@corbas.co.uk. -->

	<xsl:import href="svrl-reporter-shared.xsl"/>

	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

	<xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
	
	<xd:doc>
		<xd:desc>Set to true to output schematron id</xd:desc>
	</xd:doc>
	<xsl:param name="output-schematron-id" select="'false'"/>
	
	<xd:doc>
		<xd:desc> Set to true to use the role values as classes </xd:desc>
	</xd:doc>
	<xsl:param name="role-as-style" select="'true'"/>

	<xd:doc>
		<xd:desc> Set to true to use the role values as labels </xd:desc>
	</xd:doc>
	<xsl:param name="role-as-label" select="'true'"/>

	<xd:doc>
		<xd:desc> Set to true to use the role values as titles </xd:desc>
	</xd:doc>
	<xsl:param name="role-as-title" select="'true'"/>

	<xd:doc>
		<xd:desc> Set to true to use the id values as labels </xd:desc>
	</xd:doc>
	<xsl:param name="id-as-label" select="'true'"/>

	<xd:doc>
		<xd:desc> Set to true to use the id values as titles </xd:desc>
	</xd:doc>
	<xsl:param name="id-as-title" select="'true'"/>

	<xd:doc>
		<xd:desc> Set this to 'insert' to load the stylesheet and any other value to reference
			it.</xd:desc>
	</xd:doc>
	<xsl:param name="css-mode" select="'insert'"/>

	<xd:doc>
		<xd:desc>Change this to the URL for the stylesheet.</xd:desc>
	</xd:doc>
	<xsl:param name="css-url" select="resolve-uri('../css/svrl-report.css', $where-am-i)"/>

	<!-- set this to override the default title -->
	<xsl:param name="report-title" select="'Schematron Processing Output Report'"/>

	<!-- use this to set the location of the import files in the output stylesheet -->
	<xsl:variable name="where-am-i" select="base-uri(document(''))"/>


	<xd:doc>
		<xd:desc>
			<xd:p>Match the root svrl element and use it to generate the skeleton of our output
				stylesheet.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="svrl:schematron-output">

		<xsl:variable name="context" select="."/>


		<axsl:stylesheet version="2.0" exclude-result-prefixes="">

			<!-- output all the known namespaces -->
			<xsl:for-each select="in-scope-prefixes(.)">
				<xsl:call-template name="create-ns">
					<xsl:with-param name="prefix" select="."/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:call-template>
			</xsl:for-each>

			<!-- helpers used by this script -->
			<axsl:import href="{resolve-uri('svrl-report-helpers.xsl', $where-am-i)}"/>
			<axsl:import href="{resolve-uri('verbatim.xsl', $where-am-i)}"/>
			<axsl:output media-type="xhtml"/>
			
			<!-- params for verbatim -->
			<axsl:param name="max-depth" select="5"/>
			<axsl:param name='indent-elements' select="true()"/>

			<!-- copied from params for this stylesheet -->
			<axsl:param name="role-as-style">
				<xsl:value-of select="$role-as-style"/>
			</axsl:param>
			<axsl:param name="role-as-label">
				<xsl:value-of select="$role-as-label"/>
			</axsl:param>
			<axsl:param name="role-as-title">
				<xsl:value-of select="$role-as-title"/>
			</axsl:param>
			<axsl:param name="id-as-label">
				<xsl:value-of select="$id-as-label"/>
			</axsl:param>
			<axsl:param name="id-as-title">
				<xsl:value-of select="$id-as-title"/>
			</axsl:param>
			<axsl:param name="css-mode">
				<xsl:value-of select="$css-mode"/>
			</axsl:param>
			<axsl:param name="css-url">
				<xsl:value-of select="$css-url"/>
			</axsl:param>

			<axsl:param name="output-schematron-id">
				<xsl:value-of select="$output-schematron-id"/>
			</axsl:param>
			<axsl:strip-space elements="*"/>

			<axsl:template match="/">
				<html xmlns="http://www.w3.org/1999/xhtml">
					<head>
						<title>
							<xsl:choose>
								<xsl:when test="normalize-space(svrl:schematron-output/@title)">
									<xsl:value-of select="svrl:schematron-output/@title"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$report-title"/>
								</xsl:otherwise>
							</xsl:choose>
						</title>
						<axsl:choose>
							<axsl:when test="$css-mode != 'insert'">
								<link href="{{$css-url}}" type="text/css" rel="stylesheet"/>
							</axsl:when>
							<axsl:otherwise>
								<style type="text/css">
									<axsl:value-of select="unparsed-text($css-url)"/>
								</style>
							</axsl:otherwise>
						</axsl:choose>
						<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
					</head>

					<body>
						<h1>
							<xsl:choose>
								<xsl:when test="normalize-space(svrl:schematron-output/@title)">
									<xsl:value-of select="svrl:schematron-output/@title"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$report-title"/>
								</xsl:otherwise>
							</xsl:choose>

						</h1>

						<!-- generate document structure with calls for each assert or report.-->
						<xsl:for-each-group group-starting-with="svrl:active-pattern"
							select="svrl:successful-report|svrl:failed-assert|svrl:fired-rule|svrl:active-pattern">

							<xsl:apply-templates select="." mode="generate-calls"/>

						</xsl:for-each-group>

					</body>

				</html>
			</axsl:template>

		</axsl:stylesheet>

	</xsl:template>

	<xd:doc>
		<xd:desc>
			<xd:p>Give an active-pattern element, create the calls to the templates we are going to
				generate for each assert or report. This template builds up the structure of the
				output document using the groups created above. Within the pattern we group all the
				fired-rules for output.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="svrl:active-pattern" mode="generate-calls">

		<!-- Skip the pattern unless we have output (rules/asserts/etc) -->
		<xsl:if test="count(current-group()) gt 1">
			<div id="{@id}" class="pattern">
				<xsl:apply-templates select="(@name, @id)[1]"/>
				<div class="pattern-content">
					<!-- process each group of pattern/rules/asserts/reports together -->
					<xsl:for-each-group select="current-group() except ."
						group-starting-with="svrl:fired-rule">
						<xsl:apply-templates select="." mode="generate-calls"/>
					</xsl:for-each-group>
				</div>
			</div>
		</xsl:if>
		
	</xsl:template>


	<xd:doc>
		<xd:desc>
			<xd:p>If a fired rule has associated assertion failures or rule successes, then they
				will be in the group with the rule. Output the group and the template applications
				into the div for that group. Do nothing if the group only contains the rule.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="svrl:fired-rule" mode="generate-calls">
		<xsl:if test="count(current-group()) gt 1">
			<div class="rule">
				<xsl:call-template name="output-label">
					<xsl:with-param name="role" select="@role"/>
					<xsl:with-param name="id" select="@id"/>
				</xsl:call-template>
				<xsl:call-template name="output-style">
					<xsl:with-param name="base-class" select="local-name()"/>
				</xsl:call-template>
				<xsl:call-template name="output-icon">
					<xsl:with-param name="icon">
						<xsl:value-of select="@icon"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="output-title">
					<xsl:with-param name="level">2</xsl:with-param>
					<xsl:with-param name="role" select="@role"/>
					<xsl:with-param name="id" select="@id"/>
				</xsl:call-template>

				<!-- process the asserts and reports -->
				<xsl:apply-templates select="current-group() except ." mode="generate-calls"/>
			</div>
		</xsl:if>
	</xsl:template>

	<xd:doc>
		<xd:desc>
			<xd:p>Generate the xsl:apply-templates we will use for each assert or report. Uses the
				location from the SVRL to generate the apply templates which is handled by the
				generic handler in svr-</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="svrl:successful-report|svrl:failed-assert" mode="generate-calls">
		<axsl:apply-templates select="{@location}">
			<xsl:apply-templates select="svrl:text|.|@role|@icon|@see|@id" mode="generate-params"/>
		</axsl:apply-templates>
	</xsl:template>

	<xd:doc>
		<xd:desc>Generate a namespace node from node and a prefix</xd:desc>
	</xd:doc>
	<xsl:template name="create-ns">
		<xsl:param name="context"/>
		<xsl:param name="prefix"/>
		<xsl:namespace name="{$prefix}" select="namespace-uri-for-prefix($prefix, $context)"/>
	</xsl:template>

	<xd:doc>
		<xd:desc>Turn the message into the message parameter.</xd:desc>
	</xd:doc>
	<xsl:template match="svrl:text" mode="generate-params">
		<axsl:with-param name="message">
			<xsl:value-of select="."/>
		</axsl:with-param>
	</xsl:template>

	<xd:doc>
		<xd:desc>Turn the current node into the type param</xd:desc>
	</xd:doc>
	<xsl:template match="svrl:failed-assert" mode="generate-params">
		<axsl:with-param name="type">assert</axsl:with-param>
	</xsl:template>

	<xd:doc>
		<xd:desc>Turn the current node into the type param</xd:desc>
	</xd:doc>
	<xsl:template match="svrl:successful" mode="generate-params">
		<axsl:with-param name="type">report</axsl:with-param>
	</xsl:template>

	<xd:doc>
		<xd:desc>Convert the icon, role and set attributes to parameters</xd:desc>
	</xd:doc>
	<xsl:template match="@icon|@role|@see" mode="generate-params">
		<axsl:with-param name="{local-name()}" select="{.}"/>
	</xsl:template>


	<xd:doc>
		<xd:desc>Convert the id attribute to a parameter</xd:desc>
	</xd:doc>
	<xsl:template match="@id" mode="generate-params">
		<axsl:with-param name="schematron-id" select="{.}"/>
	</xsl:template>

	<xd:doc>
		<xd:desc>Generate a heading from pattern name or id</xd:desc>
	</xd:doc>
	<xsl:template match="svrl:active-pattern/@name|svrl:active-pattern/@id">
		<h2>
			<xsl:value-of select="."/>
		</h2>
	</xsl:template>

</xsl:stylesheet>
