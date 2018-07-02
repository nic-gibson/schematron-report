<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" exclude-result-prefixes="xd">
	
	<!--	This program and accompanying files are copyright 2008, 2009, 20011, 2012, 2013 Corbas Consulting Ltd.
	
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


	<!-- Use the shared stylesheet -->
    <xsl:import href="svrl-reporter-shared.xsl"/>

	<xd:doc>
		<xd:desc>
			<xd:p>This template generates the output for a node which matches a failed
			assertion or a successful report. It generates a table containing the SVRL
			data (message, type, etc) and a small snippet of the offending XML converted
			to escaped output format (by verbatim.xsl)</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="*">

        <xsl:param name="role" select="'error'"/>
        <xsl:param name="message"/>
        <xsl:param name="icon"/>
        <xsl:param name="schematron-id"/>
        <xsl:param name="type"/>
        <xsl:param name="see"/>
        
        <!-- for the top two levels only stop down 1 level because otherwise we get too much output -->
        <xsl:variable name="depth" select="if (count(ancestor-or-self::*) lt 2) then 1 else 3"/>

        <div xmlns="http://www.w3.org/1999/xhtml">
            <xsl:call-template name="output-label">
                <xsl:with-param name="role" select="$role"/>
                <xsl:with-param name="id" select="$schematron-id"/>
            </xsl:call-template>
            <xsl:call-template name="output-style">
                <xsl:with-param name="base-class">
                    <xsl:value-of select="$type"/>
                </xsl:with-param>
                <xsl:with-param name="role" select="$role"/>
            </xsl:call-template>
            <xsl:call-template name="output-icon">
                <xsl:with-param name="icon">
                    <xsl:value-of select="$icon"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="output-title">
                <xsl:with-param name="level">3</xsl:with-param>
                <xsl:with-param name="role" select="$role"/>
                <xsl:with-param name="id" select="$schematron-id"/>
            </xsl:call-template>
            <table class="header">
                <tbody>
                    <xsl:call-template name="header-line">
                        <xsl:with-param name="caption">Role</xsl:with-param>
                        <xsl:with-param name="value" select="$role"/>
                    </xsl:call-template>
                    <xsl:if test="$output-schematron-id = 'true'">
                        <xsl:call-template name="header-line">
                            <xsl:with-param name="caption">ID</xsl:with-param>
                            <xsl:with-param name="value" select="$schematron-id"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:call-template name="header-line">
                        <xsl:with-param name="caption">Type</xsl:with-param>
                        <xsl:with-param name="value" select="$type"/>
                    </xsl:call-template>
                    <xsl:call-template name="header-line">
                        <xsl:with-param name="caption">Message</xsl:with-param>
                        <xsl:with-param name="value" select="$message"/>
                    </xsl:call-template>
                    <xsl:call-template name="header-line">
                        <xsl:with-param name="caption">See</xsl:with-param>
                        <xsl:with-param name="value" select="$see"/>
                    </xsl:call-template>
                </tbody>
            </table>

            <div class="element">
                <!-- output a title attribute -->
                <xsl:call-template name="output-label"/>
                <xsl:apply-templates select="." mode="verbatim">
                    <xsl:with-param name="indent-elements" select="true()"/>
                    <xsl:with-param name="depth" select='$depth'/>
                </xsl:apply-templates>
            </div>
        </div>

    </xsl:template>


</xsl:stylesheet>
