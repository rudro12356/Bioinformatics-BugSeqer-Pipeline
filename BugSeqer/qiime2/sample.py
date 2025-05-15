import requests
import xml.etree.ElementTree as ET

def fetch_metadata(accession):
    # NCBI E-utilities URL
    url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
    
    # Parameters to send to the server
    params = {
        'db': 'sra',
        'id': accession,  # Accession number
        'rettype': 'docsum',  # Document summary format
        'retmode': 'xml',  # Return result in XML format
    }

    # Send request to NCBI server
    response = requests.get(url, params=params)

    if response.status_code == 200:
        # Print the raw XML to inspect the structure
        print("Raw XML Response:")
        print(response.text)

        # Parse the XML response
        root = ET.fromstring(response.text)

        # Prepare output
        metadata = []
        
        # Check the XML structure to find appropriate fields
        for docsum in root.findall(".//DocSum"):
            sample_id = None
            sample_type = None
            sub_type = None
            
            # Extract relevant metadata
            for item in docsum.findall(".//Item"):
                name = item.attrib['Name']
                print(f"Found item: {name}, Value: {item.text}")  # Debugging line to inspect fields

                if name == "SampleName":  # Modify based on exact field name
                    sample_id = item.text
                if name == "SampleType":  # Modify based on actual metadata name
                    sample_type = item.text
                if name == "SubType":  # Modify based on actual metadata name
                    sub_type = item.text

            # Collect the sample's metadata
            if sample_id and sample_type and sub_type:
                metadata.append([sample_id, sample_type, sub_type])

        # Print metadata in desired format
        if metadata:
            print("#q2:types\tcategorical\tcategorical")
            for row in metadata:
                print("\t".join(row))
        else:
            print("No relevant metadata found.")
    else:
        print(f"Failed to fetch data. HTTP status code: {response.status_code}")

# Example usage
accession = "ERR3928931"  # Replace with your accession number
fetch_metadata(accession)

