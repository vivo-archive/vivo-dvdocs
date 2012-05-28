package edu.pitt.dbmi.digitalvita.docs;

import java.io.*;
import java.util.HashMap;

import org.deri.xsparql.evaluator.XSPARQLEvaluator;
import org.deri.xsparql.rewriter.Helper;
import org.deri.xsparql.rewriter.XSPARQLProcessor;

/**
 * A class to convert VIVO profiles provided in RDF/XML format to the Digital Vita XML
 * format (defined in /schema/dv-docs.xsd).
 * 
 * This file uses a copy of the method rewriteQuery found in org.deri.xsparql.Main.
 */

public class VivoRDF2DvXML {


 /**
  * True if parse errors occurred
  */
 private boolean parseErrors = false;
 private int numOfSyntaxErrors;
 private final XSPARQLProcessor proc = new XSPARQLProcessor();
 private final XSPARQLEvaluator xe = new XSPARQLEvaluator();

/**
 * main for unit testing purposes only.
 * @param args
 * @throws IOException
 */
public static void main(final String[] args) throws IOException, Exception
{
	//VivoRDF2DvXML main = new VivoRDF2DvXML();
	//OutputStream outStream = new FileOutputStream(new File("c:\\dvout.xml"));
	//FileReader reader = new FileReader(new File("U:\\dv-2.5\\digital-vitaDOCS\\xsparql\\sample-data\\xsparql-samples\\queries\\test.xs"));
	//main.convert("file:///projects/dv-2.5/digital-vitaDOCS/xsparql/sample-data/xsparql-samples/data/personProfile.rdf", reader, outStream);
	//main.convert("file:///projects/dv-2.5/digital-vitaDOCS/xsparql/sample-data/xsparql-samples/data/personProfile.rdf", "individual8773", outStream, null);
	//main.convert("file:///projects/dv-2.5/digital-vitaDOCS/xsparql/sample-data/xsparql-samples/data/personProfile.rdf",outStream);
}

 /**
  * Given some rdf data and an XSPARQL query file, convert the rdf data to XML data which will be placed in an output file.
  * 
  * @param inputRDFURI A URI to the rdf data which will be converted. 
  * @param xsQueryInput A Reader where the XSPARQL query which will be used to convert the data will be read from. 
  * @param output An OutputStream handle to write the resulting xml to.
  * 
  * @return true if the conversion was successful, false otherwise.
  */
public boolean convert(String inputRDFURI, String personId, Reader xsQueryInput, OutputStream output, OutputStream xqOutputStream) throws IOException, Exception
{
	HashMap<String, String> extVars = new HashMap<String, String>();
	extVars.put("graph", inputRDFURI);
	
	String person;
	person = personId;
	extVars.put("personId", person);
	
	xe.setXqueryExternalVars(extVars);
	String xquery = rewriteQuery(xsQueryInput, "UNKNOWN");
	parseErrors = parseErrors || numOfSyntaxErrors > 0;
	if(xqOutputStream != null)
		Helper.outputString(xquery, xqOutputStream);
	String result = xe.evaluateRewrittenQuery(xquery);
	Helper.outputString(result, output);
	
	if(parseErrors)
		return(false);
	
	return(true);
}

/**
 * Given VIVO profile data in rdf convert it to xml that can be consumed by the Digital Vita
 * document generator.
 * 
 * This method calls the above convert method with the xsQueryInput being set to the 
 * XSPARQL query provided in this package to convert VIVO data to DV xml.
 * 
 * @param inputRDFURI A URI to the rdf data which will be converted. 
 * @param output An OutputStream handle to write the resulting xml to.
 * 
 * @throws IOException
 * @throws Exception
 */
public boolean convert(String inputRDFURI, String personId, OutputStream output, OutputStream xqOutputStream) throws IOException, Exception
{
	Reader xsInputQuery = new InputStreamReader(DVDocs.class.getResourceAsStream("/document-templates/vivo2dv.xs"));
	return(convert(inputRDFURI, personId, xsInputQuery, output, xqOutputStream));
}
 
 /**
  * Actual query rewriting.
  * 
  * This method was copied from org.deri.xsparql.Main.  The exception handling was removed 
  * in favor of throwing exceptions up the stack.
  * 
  * @param is
  *          XSPARQL query
  * @param filename
  *          Filename of the XSPARQL query
  */
private String rewriteQuery(Reader is, String filename) throws Exception
{
	String xquery = null;
	proc.setQueryFilename(filename);
	xquery = proc.process(is);
	numOfSyntaxErrors = proc.getNumberOfSyntaxErrors();
	return xquery;
 }

}
