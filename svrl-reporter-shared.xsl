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
	
	
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p>These templates are used both by the final report generator and by the 
				report stylesheet generator. They are simple templates used to wrap
				up repeated output functionality.</xd:p>
		</xd:desc>
	</xd:doc>

    
    <xsl:template name="output-label">
        <xsl:param name="role"/>
        <xsl:param name="id"/>
        <xsl:choose>
            <xsl:when test="$role-as-label = 'true'">
                <xsl:if test="normalize-space($role) != ''">
                    <xsl:attribute name="title">
                        <xsl:value-of select="$role"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$id-as-label = 'true'">
                <xsl:if test="normalize-space($id) != ''">
                    <xsl:attribute name="title">
                        <xsl:value-of select="$id"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="output-style">
        <xsl:param name="base-class"/>
        <xsl:param name="role"/>
        <xsl:choose>
            <xsl:when test="normalize-space($role) != ''">
                <xsl:if test="$role-as-style = 'true'">
                    <xsl:attribute name="class">
                        <xsl:value-of select="concat($base-class, ' ', $role)"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:when>
            <xsl:when test="normalize-space($base-class) != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="$base-class"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="output-title">
        <xsl:param name="level" select='1'/>
        <xsl:param name="role"/>
        <xsl:param name="id"/>
        <xsl:choose>
            <xsl:when test="$role-as-title =  'true'">
                <xsl:if test="normalize-space($role) != ''">
                    <xsl:element name="{concat('h', $level)}" namespace="http://www.w3.org/1999/xhtml">
                        <xsl:value-of select="$role"/>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$id-as-title = 'true'">
                <xsl:if test="normalize-space($id) != ''">
                    <xsl:element name="{concat('h', $level)}" namespace="http://www.w3.org/1999/xhtml">
                        <xsl:value-of select="$id"/>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="output-icon">
        <xsl:param name="icon"/>
        <xsl:if test="normalize-space($icon) != ''">
            <img src="{$icon}" class="icon"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="header-line">
        <xsl:param name="caption"/>
        <xsl:param name="value"/>
        <xsl:if test="not(normalize-space($value) = '')">
            <tr>
                <th>
                    <xsl:value-of select="$caption"/>
                </th>
                <td>
                    <xsl:value-of select="$value"/>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
