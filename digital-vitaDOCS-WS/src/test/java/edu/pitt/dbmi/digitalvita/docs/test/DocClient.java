package edu.pitt.dbmi.digitalvita.docs.test;

import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.InputStream;

import javax.ws.rs.core.MediaType;

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;

public class DocClient {

	public static void main(String [] args)
	{
		try
		{
			Client client = new Client();
			WebResource resource = client.resource("http://localhost:8080/dv-docs/document/BLECH"); 
			//ClientResponse response = resource.type("application/xml").put(ClientResponse.class, "<customer>...</customer.");
			ClientResponse response = resource.type("application/xml").post(ClientResponse.class, "<tag>something</tag>");//.get(ClientResponse.class);
			if(response.getClientResponseStatus().getStatusCode() == 200)
			{
				MediaType type = response.getType();
				System.out.println(type);
				InputStream stream = response.getEntityInputStream();
				int i;
				DataOutputStream os = new DataOutputStream(new FileOutputStream("c:\\out2.bin"));
				while((i = stream.read()) != -1)
				{
					System.out.print(((char)i));
					os.writeByte(i);
				}
				os.close();
			}
			
			System.out.println("\n" + response);
		}
		catch(Exception e){e.printStackTrace();}
	}
}
