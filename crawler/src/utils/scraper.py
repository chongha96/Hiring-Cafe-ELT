import json
import urllib.parse
from bs4 import BeautifulSoup
from seleniumbase import SB
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(filename="scraper.log",level=logging.INFO)

#Builds the Search URL with KVP Query Parameters, encoding the json data to work with browser search
def _build_search_url(base_url:str, locations: list,sort_by: str,days: int) -> str:
    logger.info("Building search parameters...")
    search_params = {
        "locations": locations,
        "sortBy": sort_by,
        "dateFetchedPastNDays": days,
    }

    logger.info("Building search URL...")
    encoded_params = urllib.parse.quote(
        json.dumps(search_params)
    )
    search_url = f"{base_url}?searchState={encoded_params}"
    logger.info(f"Successfully built search URL: {search_url}")
    return search_url



#Takes raw web data and extracts a json object from the Next.js framework
def _extract_next_data(html: str) -> dict:
    soup = BeautifulSoup(html, "html.parser")
    find_json = soup.find("script", id="__NEXT_DATA__")

    try:
        return json.loads(find_json.string)
    except json.JSONDecodeError as e:
        raise RuntimeError(f"Failed to parse __NEXT_DATA__: {e}")



#Primary handler that scrapes data, and returns list of jobs in json string format, and the time taken to extract the data
def scrape_site(base_url: str,locations: list,sort_by: str,days: int,reconnect_time: int,timeout: int) -> dict:
    logger.info("Scraping website: Building search URL")

    url = _build_search_url(
        base_url=base_url,
        locations=locations,
        sort_by=sort_by,
        days=days,
    )

    with SB(
        uc=True,
        xvfb=True,
    ) as sb:

        sb.set_window_size(1920, 1080)

        logger.info("Opening website")
        sb.uc_open_with_reconnect(url, reconnect_time)

        logger.info("Checking for captcha")

        try:
            sb.uc_gui_handle_captcha()
        except Exception as e:
            logger.warning(f"Captcha handling failed: {e}")

        sb.sleep(5)

        logger.info("Waiting for job listings")

        sb.wait_for_element_visible(
            "span.line-clamp-2",
            timeout=timeout
        )

        raw_data = sb.get_page_source()

        if raw_data:
            logger.info("Successfully obtained raw page source data")
        else:
            logger.warning("No page source data extracted")

    return _extract_next_data(raw_data)
