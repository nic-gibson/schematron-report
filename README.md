# Schematron Reporter

This stylesheet generates a HTML report from schematron (SVRL) output by
converting the SVRL to a stylsheet which operatores on the original document.

The final stylesheet relies on the [XHTML Verbatim stylesheet](https://github.com/Corbas/verbatim).

## Using the reporter

1. Process the input document using Schematron with SVRL output
2. Apply the `create-svrl-html-reporter.xsl` stylesheet to the SRVL
3. Apply the resulting styleshee to the original XML document.



