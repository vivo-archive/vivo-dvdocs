package edu.pitt.dbmi.digitalvita.docs.test;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;

import edu.pitt.dbmi.digitalvita.docs.CitationFormat;
import edu.pitt.dbmi.digitalvita.docs.DVDocs;
import edu.pitt.dbmi.digitalvita.docs.DocumentTemplateType;
import edu.pitt.dbmi.digitalvita.docs.OutputFileType;

public class DVDocsAPITest
{
	public static void main(String [] args)
	{
		try
		{
			DVDocs docs = new DVDocs();
			File outFile = new File("c:\\users\\shirey\\out.pdf");
			FileOutputStream out;
			out = new FileOutputStream(outFile);
			File xmlIn = new File("c:\\users\\shirey\\dv-2.5\\DVDocs\\digital-vitaDOCS\\schema\\titus.xml");
			FileReader in = new FileReader(xmlIn);
			File customTemp = new File("c:\\users\\shirey\\test-cv.fo.xsl");
			FileReader templIn = new FileReader(customTemp);
			//docs.generateDocumentFromVIVO("file:///Users/shirey/dv-2.5/DVDocs/digital-vitaDOCS/schema/katy.rdf", "person25557", DocumentTemplateType.CURRICULUM_VITAE, OutputFileType.PDF, CitationFormat.VANCOUVER, out);
			//docs.generateDocument(in, DocumentTemplateType.CURRICULUM_VITAE, OutputFileType.PDF, CitationFormat.VANCOUVER, out);
			//docs.generateCustomDocument(in, templIn, OutputFileType.PDF, CitationFormat.VANCOUVER, null, out);
			docs.generateCustomDocumentFromVIVO("file:///Users/shirey/dv-2.5/DVDocs/digital-vitaDOCS/schema/katy.rdf", "person25557", templIn, OutputFileType.PDF, CitationFormat.VANCOUVER, out, null);
		}
		catch(Exception e){e.printStackTrace();}	
	}
}