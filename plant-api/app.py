from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
from bs4 import BeautifulSoup
import urllib.parse
import re

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

@app.route("/health", methods=["GET"])
def health_check():
    """
    Health check endpoint to ensure the server is running.
    Returns:
        JSON response with status "healthy" and HTTP 200.
    """
    return jsonify({"status": "healthy"}), 200

@app.route("/plantinfo", methods=["POST"])
def plant_info_route():
    """
    API endpoint to get plant information.
    Expects a JSON payload with 'plant_name'.
    Returns:
        JSON response containing plant URL and extracted information, or an error message.
    """
    # Check if the request body is JSON
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    # Get plant_name from the JSON request body
    plant_name = request.json.get("plant_name")

    # Validate if plant_name is provided
    if not plant_name:
        return jsonify({"error": "Missing 'plant_name' in request body"}), 400

    # Call the helper function to get plant information
    info = get_plant_info(plant_name)

    # Return the result as JSON
    if "error" in info:
        return jsonify(info), 500  # Return appropriate error status
    return jsonify(info), 200

def get_plant_info(plant_name):
    """
    Fetches plant care information directly from thespruce.com's internal search.
    Args:
        plant_name (str): The name of the plant to search for.
    Returns:
        dict: A dictionary containing the URL and extracted info, or an error message.
    """
    try:
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }

        # Construct the search query for TheSpruce's internal search
        search_query = f"{plant_name} care"
        encoded_search_query = urllib.parse.quote(search_query)
        thespruce_search_url = f"https://www.thespruce.com/search?q={encoded_search_query}"

        print(f"Searching TheSpruce directly for: {thespruce_search_url}") # Debugging print

        # Fetch the search results page from TheSpruce
        search_response = requests.get(thespruce_search_url, headers=headers, timeout=15)
        search_response.raise_for_status()
        search_soup = BeautifulSoup(search_response.content, "html.parser")

        # Find the first search result link that looks like an article
        # Trying a more robust selector for article links on TheSpruce search results
        # Look for links with the specific class or a data-doc-id attribute (common for articles)
        article_links = search_soup.select("a.mntl-card-list-items__link, a[data-doc-id]")

        print(f"Found {len(article_links)} potential article links.") # Debugging print: How many links were found by the selector?

        found_article_url = None
        for link in article_links:
            href = link.get("href")
            print(f"  Considering link: {href}") # Debugging print: See each link being checked

            # Ensure the link is a full URL and belongs to thespruce.com
            # Also, prioritize links that contain "care" or the plant name (hyphenated) in their URL
            if href and "thespruce.com" in href:
                # Add a more specific check for article URLs, often containing a numerical ID or specific path
                # Example: /peace-rose-care-guide-6674376
                if re.search(r'/\d+$', href) or "care-guide" in href: # Check for common article URL patterns
                    found_article_url = href
                    break # Found a suitable article link

        if not found_article_url:
            return {"error": f"No relevant article found in TheSpruce search results for: {plant_name} care. Tried URL: {thespruce_search_url}"}

        print(f"Attempting to fetch article from: {found_article_url}") # Debugging print

        # Fetch the content of the found article
        article_response = requests.get(found_article_url, headers=headers, timeout=15)
        article_response.raise_for_status()
        article_soup = BeautifulSoup(article_response.content, "html.parser")

        # Select paragraphs within typical content blocks on TheSpruce
        paragraphs = article_soup.select("div.mntl-sc-block p, div.comp.type--article-body p")
        content = [p.get_text().strip() for p in paragraphs if len(p.get_text().strip()) > 50] # Filter short paragraphs

        if content:
            extracted_content = "\n\n".join(content[:5])
            return {
                "url": found_article_url,
                "info": extracted_content
            }
        else:
            return {"error": f"No substantial content found in the article: {found_article_url}"}

    except requests.exceptions.Timeout as e:
        return {"error": f"Request timed out: {str(e)}. The server took too long to respond."}
    except requests.RequestException as e:
        return {"error": f"Request error: {str(e)}. Could not connect to the website or received a bad response."}
    except Exception as e:
        return {"error": f"An unexpected scraping error occurred: {str(e)}"}


if __name__ == "__main__":
    # When running locally, you can test with:
    # curl -X POST -H "Content-Type: application/json" -d '{"plant_name": "Rose"}' http://127.0.0.1:3003/plantinfo
    app.run(host='0.0.0.0', port=3003, debug=True)
