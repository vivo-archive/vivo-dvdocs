package edu.pitt.dbmi.digitalvita.docs;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Reader;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.Map;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.fop.apps.FOPException;
import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;

/**
 *  DVDocs is an API to a document generation facility.  DVDocs supports
 *  generating both native documents and custom documents via provided document
 *  templates.  The native types supported are Curriculum Vitae and NIH biosketch.
 *  Additionally documents can be generated with a user provided XSL-FO template.
 *  Documents can be generated from XML in the format used by DVDocs (defined by
 *  the schema in schema/dv-docs.xsd) or by RDF/XML provided from a VIVO profile.
 *  RDF/XML data is converted to straight XML using the XSPARQL language.
 *  
 *  <br/><br/>
 *  Documents can be generated in Adobe PDF format (pdf) or in Rich Text Format (rtf).
 *  <br/><br/>
 *  @see <a href="http://xmlgraphics.apache.org/fop/">Apache FOP</a>
 *  @see <a href="http://xsparql.deri.org/">XSPARQL</a>
 *  
 */
public class DVDocs
{
	
	private static Log log = LogFactory.getLog(DVDocs.class);
	
	private VivoRDF2DvXML rdfConverter = new VivoRDF2DvXML();
	
	/**
	 * Generate a document based on one of the natively available document templates from XML which 
	 * conforms to the DVDocs document schema.
	 * 
	 * @param documentXML The document data, in XML format, conforming to the schema dv-docs.xsd.   
	 * @param docType The type of document to generate.  Valid values are {@link DocumentTemplateType#CURRICULUM_VITAE CURRICULUM_VITA}
	 *                and {@link DocumentTemplateType#NIH_BIOSKETCH NIH_BIOSKETCH}.  If a null value is provided for this parameter the 
	 *                document type will default to {@link DocumentTemplateType#CURRICULUM_VITAE CURRICULUM_VITA}. 
	 * @param fileType The type of file to generate.  Valid values are {@link OutputFileType#PDF PDF} and {@link OutputFileType#RTF RTF}.
	 *                 If a null value is provided for this parameter the file type will default to {@link OutputFileType#PDF PDF}. 
	 * @param citationFormat The format that will be used for publication citations in the generated document.  Valid values are
	 *                       {@link CitationFormat#VANCOUVER VANCOUVER} or {@link CitationFormat#APA APA}.  If a null value is provided
	 *                       for this field, the format will be defaulted to {@link CitationFormat#VANCOUVER VANCOUVER}.  
	 * @param outputTarget The resulting document will be written to this target. 
	 * @throws DocGenException
	 */
	public void generateDocument(Reader documentXML, DocumentTemplateType docType, OutputFileType fileType, CitationFormat citationFormat, OutputStream outputTarget) throws DocGenException
	{
		//if a document type wasn't provided default to a CV
		if(docType == null) docType = DocumentTemplateType.CURRICULUM_VITAE;
		
		//get a handle to the template corresponding to the document type
		//the provided (native) templates are stored in the jar file as resources along with the api
		InputStream foXslTemplateInput = DVDocs.class.getResourceAsStream("/document-templates/" + docType.getTemplateFileName());
		this.generateCustomDocument(documentXML, new InputStreamReader(foXslTemplateInput), fileType, citationFormat, null, outputTarget);		
	}

	
	private Properties getProperties(CitationFormat citationFormat, OutputFileType outputFileType, Properties existingProperties)
	{
		//set up the properties required by the native XSLT
		
		Properties properties = null;
		if(existingProperties == null)
			properties = new Properties();
		else
			properties = existingProperties;

		properties.put("documentFontType", "Times");
		properties.put("documentFontSize", "12px");

		CitationFormat citeFormat = citationFormat;
		if(citeFormat == null)
			citeFormat = CitationFormat.VANCOUVER;
		properties.put("citationFormat", citationFormat.getName()); 

		OutputFileType fileType = outputFileType;
		if(fileType == null)
			fileType = OutputFileType.PDF;
		properties.put("targetFormat", fileType.getExtension());
		
		return(properties);
	}
	/**
	 * Generate a document based on one of the natively available document templates from an RDF/XML representation 
	 * of a person's VIVO profile.
	 * 
	 * @param inputRDFURI A URI to the RDF/XML data for a VIVO profile.
	 * @param vivoPersonId The VIVO person identifier of the person who the document is being generated for.  Currently vivoPersonId
	 *                     matches the end of a person identifier from the IU VIVO repository.
	 * @param docType The type of document to generate.  Valid values are {@link DocumentTemplateType#CURRICULUM_VITAE CURRICULUM_VITA}
	 *                and {@link DocumentTemplateType#NIH_BIOSKETCH NIH_BIOSKETCH}.  If a null value is provided for this parameter the 
	 *                document type will default to {@link DocumentTemplateType#CURRICULUM_VITAE CURRICULUM_VITA}. 
	 * @param fileType The type of file to generate.  Valid values are {@link OutputFileType#PDF PDF} and {@link OutputFileType#RTF RTF}.
	 *                 If a null value is provided for this parameter the file type will default to {@link OutputFileType#PDF PDF}. 
	 * @param citationFormat The format that will be used for publication citations in the generated document.  Valid values are
	 *                       {@link CitationFormat#VANCOUVER VANCOUVER} or {@link CitationFormat#APA APA}.  If a null value is provided
	 *                       for this field, the format will be defaulted to {@link CitationFormat#VANCOUVER VANCOUVER}.  
	 * @param outputTarget The resulting document will be written to this target. 
	 *                        
	 * @throws DocGenException
	 */
	public void generateDocumentFromVIVO(String inputRDFURI, String vivoPersonId, DocumentTemplateType docType, OutputFileType fileType, CitationFormat citationFormat, OutputStream outputTarget) throws DocGenException
	{
		
		//if a document type wasn't provided default to a CV
		if(docType == null) docType = DocumentTemplateType.CURRICULUM_VITAE;
		
		//get a handle to the template corresponding to the document type
		//the provided (native) templates are stored in the jar file as resources along with the api
		InputStream foXslTemplateInput = DVDocs.class.getResourceAsStream("/document-templates/" + docType.getTemplateFileName());
		
		this.generateCustomDocumentFromVIVO(inputRDFURI, vivoPersonId, new InputStreamReader(foXslTemplateInput), fileType, citationFormat, outputTarget, null);
	}	


	/**
	 * Generate a document based on a document template defined outside of DVDocs from an XML representation 
	 * of a person's VIVO profile.
	 * 
	 * @param inputRDFURI A URI to the RDF/XML data for a VIVO profile.
	 * @param vivoPersonId The VIVO person identifier of the person who the document is being generated for.  Currently vivoPersonId
	 *                     matches the end of a person identifier from the IU VIVO repository.
	 * @param foXSLReader A Reader object which references the XSL-FO template which will be used to generate a document.
	 * @param fileType The type of file to generate.  Valid values are {@link OutputFileType#PDF PDF} and {@link OutputFileType#RTF RTF}.
	 *                 If a null value is provided for this parameter the file type will default to {@link OutputFileType#PDF PDF}. 
	 * @param citationFormat The format that will be used for publication citations in the generated document.  Valid values are
	 *                       {@link CitationFormat#VANCOUVER VANCOUVER} or {@link CitationFormat#APA APA}.  If a null value is provided
	 *                       for this field, the format will be defaulted to {@link CitationFormat#VANCOUVER VANCOUVER}.  
	 * @param outputTarget The resulting document will be written to this target.
	 * @param properties An optional set of properties (can be null) that will be passed to the FOP engine (and therefore can be referenced
	 *                   in the provided XSL-FO file) as XSLT parameters when the document is generated.
	 *                        
	 * @throws DocGenException
	 */
	public void generateCustomDocumentFromVIVO(String inputRDFURI, String vivoPersonId, Reader foXSLReader, OutputFileType fileType, CitationFormat citationFormat, OutputStream outputTarget, Properties properties) throws DocGenException
	{
		if(inputRDFURI == null || vivoPersonId == null)
			throw new DocGenException("null URI or person id received.", "A document could not be generated. The required VIVO profile information was not provided.");
		
		ByteArrayOutputStream xmlOut = new ByteArrayOutputStream();
		
		try{rdfConverter.convert(inputRDFURI, vivoPersonId , xmlOut, null);}
		catch(Exception e)
		{
			String message = "An exception occured while converting RDF to XML from " + inputRDFURI + " for person with id " + vivoPersonId +".";
			log.error(message, e);
			throw new DocGenException(message, "A document could not be generated.  The provided VIVO profile could not be converted to the format needed to generate a document.  Further information about the error is available in the server log files.");
		}
		
		if(xmlOut.size() == 0)
			throw new DocGenException("empty xml output, VIVO XML was not transfromed.", "A document could not be generated.  The VIVO profile information was not be converted correctly to information that can be used to generate a document.");
		
		Reader documentXML = new InputStreamReader(new ByteArrayInputStream(xmlOut.toByteArray()));
		
		this.generateCustomDocument(documentXML, foXSLReader, fileType, citationFormat, properties, outputTarget);
	}
	
	/**
	 * Generate a document using Apache FOP.  The document will be generated based on a provided Apache FOP (XSL-FO) XSLT and corresponding XML data.
	 *   
	 * @param documentXML The data, in XML conforming to what is required by the FOP XSLT.
	 * @param foXSLReader The Apache FOP (XSL-FO) XSLT description of the document to be generated.
	 * @param fileType The type of file to generate.  Valid values are {@link OutputFileType#PDF PDF} and {@link OutputFileType#RTF RTF}.
	 *                 If a null value is provided for this parameter the file type will default to {@link OutputFileType#PDF PDF}.
	 * @param citationFormat The format that will be used for publication citations in the generated document.  Valid values are
	 *                       {@link CitationFormat#VANCOUVER VANCOUVER} or {@link CitationFormat#APA APA}.  If a null value is provided
	 *                       for this field, the format will be defaulted to {@link CitationFormat#VANCOUVER VANCOUVER}.                  
	 * @param properties  {@link Properties Properties} which will be passed to the document template as XSLT parameters.
	 * @param outputTarget The resulting document will be written to this target. 
	 * @throws DocGenException
	 */
	public void generateCustomDocument(Reader documentXML, Reader foXSLReader, OutputFileType fileType, CitationFormat citationFormat, Properties properties, OutputStream outputTarget) throws DocGenException
	{
		if(documentXML == null)
			throw new DocGenException("null documentXML found.", "A document could not be generated.  The required data to construct the document wasn't found.");
		
		if(foXSLReader == null)
			throw new DocGenException("null foXSLReader found.", "A document could not be generated.  The required template used to construct your document wasn't found.");
		
		if(outputTarget == null)
			throw new DocGenException("null outputTarget found.", "A document could not be generated.  A required target to write the document to was not found.");
		
		Properties props = this.getProperties(citationFormat, fileType, properties);
		//create the document
		try{processFopXmlFile(documentXML, foXSLReader, props, outputTarget, fileType.getMimeType());}
		catch(FOPException e) {throw new DocGenException("FOPException caused a document generation abort.", "A document could not be generated.  An unexpected error occured while processing the document.", e);}
		catch(TransformerException e){throw new DocGenException("TransformerException caused a document generation abort.", "A document could not be generated.  An unexpected error occured while transforming the document.", e);}		
	}	

	/**
	 * Generate a document using Apache FOP XSL-FO processor.
	 * 
	 * @param xmlReader  A Reader pointing to XML data for the document.
	 * @param xsltReader  A Reader pointing to the Apache FOP (XSL-FO) compatible xslt file.
	 * @param xsltParams  A map of named string values that will be passed to the document processor as XSLT parameters. 
	 * @param outputStream  An OutputStream where the resulting document will be written.
	 * @param outputFormat  The format of the resulting document.  Valid values are pdf or rtf.
	 * @throws FOPException
	 * @throws TransformerException
	 */
	private void processFopXmlFile(Reader xmlReader, Reader xsltReader, Map<String, String> xsltParams, OutputStream outputStream, String outputFormat) throws FOPException, TransformerException {

		// Setup factory and user agent
		FopFactory fopFactory = FopFactory.newInstance();
		FOUserAgent foUserAgent = fopFactory.newFOUserAgent();

		// Construct FOP with desired output format
		Fop fop = fopFactory.newFop(outputFormat, foUserAgent, outputStream);

		// Setup JAXP using XSLT as transformer
		TransformerFactory factory = TransformerFactory.newInstance();
		Transformer transformer = factory.newTransformer(new StreamSource(xsltReader));
		
		Iterator< Map.Entry<String, String> > i = xsltParams.entrySet().iterator();
		
		while(i.hasNext())
		{
			Map.Entry<String, String> kv = i.next();
			transformer.setParameter(kv.getKey(), kv.getValue());
		}
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
		String currentDate = formatter.format(new Date());
		transformer.setParameter("currentDate", currentDate);
		// Start XSLT transformation and FOP processing
		transformer.transform(new StreamSource(xmlReader), new SAXResult(fop.getDefaultHandler()));
	}	
}
