package edu.pitt.dbmi.digitalvita.docs.test;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;

import edu.pitt.dbmi.digitalvita.docs.CitationFormat;
import edu.pitt.dbmi.digitalvita.docs.DVDocs;
import edu.pitt.dbmi.digitalvita.docs.DocumentTemplateType;
import edu.pitt.dbmi.digitalvita.docs.OutputFileType;
import edu.pitt.dbmi.digitalvita.docs.VivoRDF2DvXML;

/**
 * GenerateFile is a command line interface to DVDocs used primarily for testing purposes.
 * Given an input XML file as the first argument it will generate a pdf or rtf document (specified 
 * in the second argument, but defaulted to pdf) with the same base name. 
 * 
 * Given an input URI pointing to VIVO rdf profile data it will transform the VIVO RDF/XML to XML 
 * then generate the a document (document type, again, based on the second argument).
 * 
 * USAGE: GenerateFile inputfile [pdf/rtf]
 *        where inputfile can be the path to an xml file in DV doc format
 *        or the URI to an RDF/XML data source containing a VIVO profile.
 * 
 * @author shirey
 *
 */
public class GenerateFile
{

	public static void main(String [] args)
	{
		if(args.length == 0 || (args.length == 1 && args[0].trim().toLowerCase().equals("-h")))
		{
			printHelp();
			System.exit(1);
		}
		
		String inputFileName = args[0].trim();
		if(! inputFileName.toLowerCase().endsWith(".xml") && !inputFileName.toLowerCase().endsWith(".rdf")
		   && !inputFileName.toLowerCase().endsWith(".rdf?include=all"))
		{
			printHelp();
			System.out.println("Must provide an xml or rdf input file.");
			System.exit(1);
		}
		
		String personId = args[1].trim();
		if(personId.equals("")){
			printHelp();
			System.out.println("Provide the person id.");
			System.exit(1);
		}
				
		OutputFileType filetype = OutputFileType.PDF;
		if(args.length > 2)
		{
			String typeArg = args[2].trim().toLowerCase();
			if(typeArg.equals("pdf"))
				filetype = OutputFileType.PDF;
			else if(typeArg.equals("rtf"))
				filetype = OutputFileType.RTF;
			else
			{
				printHelp();
				System.out.println("Invalid output file type.  Valid types are rtf and pdf.");
				System.exit(1);
			}
		}
		String xmlFileName;
		String xqFileName;
		boolean convertRDF = inputFileName.toLowerCase().endsWith(".rdf") || inputFileName.toLowerCase().endsWith(".rdf?include=all"); 		
		String baseFileName = getFileBaseName(inputFileName, convertRDF);
		String outputFileName = baseFileName + "." + filetype.getExtension();
		if(convertRDF)
		{
			xmlFileName = baseFileName + ".xml";
			xqFileName = baseFileName + ".xq";
			VivoRDF2DvXML converter = new VivoRDF2DvXML();
			try
			{
				FileOutputStream outStream = new FileOutputStream(new File(xmlFileName));
				                                     //comment back in to see the resulting xquery
				FileOutputStream xqOutStream = null; //new FileOutputStream(new File(xqFileName));
				converter.convert(inputFileName, personId, outStream, xqOutStream);
				outStream.close();
			}
			catch(Exception e)
			{
				e.printStackTrace();
				System.exit(1);
			}
		}
		else
			xmlFileName = inputFileName;
		generate(xmlFileName, outputFileName, filetype);
	}
	private static String getFileBaseName(String inputFileName, boolean convertRDF)
	{
		String baseName = null;
		
		if(inputFileName.endsWith("?include=all"))
			baseName = inputFileName.substring(0, inputFileName.length() - 16);
		else
			baseName = inputFileName.substring(0, inputFileName.length() - 4);
		
		int lastSlash = baseName.lastIndexOf("/");
		if(lastSlash >= 0)
			baseName = baseName.substring(lastSlash + 1);
		String filename = baseName;
		File f = new File(filename + ".pdf");
		File f1 = new File(filename + ".rtf");
		File f2 = new File(filename + ".xml");
		File f3 = new File(filename + ".xq");
		int counter = 1;
		while(f.exists() || f1.exists() || (convertRDF && f2.exists()) || (convertRDF && f3.exists()))
		{
			filename = baseName + "-" + (++counter);
			f = new File(filename + ".pdf");
			f1 = new File(filename + ".rtf");
			f2 = new File(filename + ".xml");
			f3 = new File(filename + ".xq");
		}
		return(filename);
	}
	
	private static void printHelp()
	{
		System.out.println("USAGE: GenerateFile inputfile [pdf/rtf]");
		System.out.println("       where inputfile can be the path to an xml file in DV doc format");
		System.out.println("       or the URI to an rdf data source containing a VIVO profile.");
	}
	private static void generate(String inputFileName, String outputFileName, OutputFileType filetype)
	{
		try
		{
			DVDocs docs = new DVDocs();
			File inFile = new File(inputFileName);
			File outFile = new File(outputFileName);
			FileReader in = new FileReader(inFile);
			FileOutputStream out = new FileOutputStream(outFile);
			docs.generateDocument(in, DocumentTemplateType.CURRICULUM_VITAE, filetype, CitationFormat.VANCOUVER, out);
			in.close();
			out.close();
		}
		catch(Exception e)
		{
			System.err.print("An exception occured during the document generation.\n");
			e.printStackTrace();
			System.exit(1);
		}
	}
}
