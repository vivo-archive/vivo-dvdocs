package edu.pitt.dbmi.digitalvita.docs.service;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import edu.pitt.dbmi.digitalvita.docs.CitationFormat;
import edu.pitt.dbmi.digitalvita.docs.DVDocs;
import edu.pitt.dbmi.digitalvita.docs.DocGenException;
import edu.pitt.dbmi.digitalvita.docs.DocumentTemplateType;
import edu.pitt.dbmi.digitalvita.docs.OutputFileType;
import edu.pitt.dbmi.digitalvita.docs.VivoRDF2DvXML;

/**
 * A simple web service interface to DV docs.
 */
@Path("/vivo-doc-gen/")
public class DocumentResource
{

	private static Log log = LogFactory.getLog(DocumentResource.class);
	
	/**
	 * respond to http://server/dv-docs/vivo-doc-gen/vivoServerName/personId?filetype=type
	 * 
	 * Currently personId matches the end of a person identifier from the IU VIVO repository.  This should eventually
	 * change to provide the whole identifier.
	 * 
	 * Valid values for filetype are pdf or rtf.  If nothing is provided the default is pdf.
	 * 
	 * Eventually we will add an option to specify CV or Biosketch, but currently we can't
	 * generate a Biosketch from the VIVO data because of missing personal statement and the
	 * inclusion of every item from the person's profile.
	 */
	@Produces("text/plain")
	@GET
	@Path("{vivoServer}/{vivoPersonId}")
	public Response getDocument(@PathParam("vivoServer") String vivoServer, @PathParam("vivoPersonId") String vivoPersonId, @DefaultValue("pdf") @QueryParam("fileformat") String fileformat, @DefaultValue("cv") @QueryParam("filetype") String filetype, @DefaultValue("apa") @QueryParam("citations") String citations /*, @DefaultValue("") @QueryParam("servername") String serverName */)
	{	
		File tempRDFFile = null;
		File tempXMLFile = null;
		String filePrefix = Long.toString(System.nanoTime());
		String format=null;
		OutputFileType fformat=null;
		DocumentTemplateType ftype=null;
		CitationFormat citation=null;
		
		// Default Values.
		format = "application/pdf";
		fformat = OutputFileType.PDF;
		ftype = DocumentTemplateType.CURRICULUM_VITAE;
		citation = CitationFormat.APA;
		
		if(fileformat.trim().equals("rtf"))
		{
			format = "application/rtf";
			fformat = OutputFileType.RTF;
		}
		if(filetype.trim().equals("nih"))
		{
			ftype = DocumentTemplateType.NIH_BIOSKETCH;
		}
		if(citations.trim().equals("vancouver"))
		{
			citation = CitationFormat.VANCOUVER;
		}
		
		//http://vivo-dev.dlib.indiana.edu/individual/person25557/person25557.rdf?include=all/
		//serverName previously hard coded to vivo-dev.dlib.indiana.edu
		String inputURL = "http://" + vivoServer.trim() + "/individual/" + vivoPersonId + "/" + vivoPersonId + ".rdf?include=all";
		
		VivoRDF2DvXML converter = new VivoRDF2DvXML();
		byte [] doc = null;
		try
		{
			URL url = new URL(inputURL);
			tempRDFFile = File.createTempFile(filePrefix, "vivo-doc-temp-trunc.rdf");
			tempXMLFile = File.createTempFile(filePrefix, "vivo-doc-temp.xml");

			//hack until it is fixed...
			//remove unneeded courseOffering and organizationForPosition entries from rdf/xml
			//after this problem is fixed we can probably get away with not
			//storing the rdf (or xml) in a file, but they're a bit big
			//to store in memory right now....
			removeExtraineousReferences(url, tempRDFFile);
			
			FileOutputStream xmlOutStream = new FileOutputStream(tempXMLFile);
			
			//if you want to see the resulting xquery output from xsparql provide 
			//an output stream here.
			FileOutputStream xqOut = null; //new FileOutputStream(new File("c:\\this.xq"));
			
			//convert the VIVO rdf/xml to xml, xml stored in xmlOutStream
			converter.convert(tempRDFFile.toURI().toASCIIString(), vivoPersonId, xmlOutStream, xqOut);
			xmlOutStream.close();

			//generate a CV from the resulting xml
			doc = generateDocument(tempXMLFile.getAbsolutePath(), fformat, ftype, citation);
		}
		catch(Exception e)
		{
			log.error("Error while generating a document for person with id " + vivoPersonId, e);

			//if the exception is file not found send a 404 back
			if(e instanceof FileNotFoundException)
			{
				return Response.status(404).type("text/plain").entity(inputURL + " was not found.").build();
			}
			else  //otherwise send a 500 
				return Response.status(500).type("text/plain").entity("An internal error occurred.  Please ask your system administrator to check the log files for further information.").build();
		}
		finally
		{
			removeFile(tempRDFFile);
			removeFile(tempXMLFile);			
		}
		return Response.status(200).type(format).entity(doc).build();
	 }

	//remove a temporary file
	private void removeFile(File file)
	{
		try
		{
			if(file != null && file.exists())
				file.delete();
		}
		catch(Exception e){log.error("ERROR: Error deleting " + (file == null?"null file":file.getAbsolutePath()), e);}  //if the file is locked or something else is wrong, we can't delete, just leave it.
	}

	//remove references of type courseOffering and organizationForPosition as they aren't needed
	//and increases the time the xparql conversion takes ten fold.	
	static Pattern pattern = Pattern.compile("^<j\\..:(courseoffering|organizationforposition).*/>$");
	private void removeExtraineousReferences(URL input, File output) throws IOException
	{
		BufferedReader br = new BufferedReader(new InputStreamReader(input.openStream()));
		String strLine;  
		BufferedWriter out = new BufferedWriter(new FileWriter(output));

		while ((strLine = br.readLine()) != null)
		{
			if(strLine != null)
			{
				String testLine = strLine.trim().toLowerCase();
				Matcher matcher = pattern.matcher(testLine);
				if(! matcher.matches())
				{
					out.write(strLine + "\n");
				}
			}
		}	  
		out.close();
	}
	 
	
	//generate a document
	private static byte [] generateDocument(String inputFileName, OutputFileType fileformat, DocumentTemplateType filetype, CitationFormat citations) throws DocGenException, IOException
	{
			DVDocs docs = new DVDocs();
			File inFile = new File(inputFileName);
			FileReader in = new FileReader(inFile);
			ByteArrayOutputStream out = new ByteArrayOutputStream();
			//default to generating a CV and use the Vancouver citation format
			docs.generateDocument(in, filetype, fileformat, citations, out);
			in.close();
			return(out.toByteArray());
	}	 
}