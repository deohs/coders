# Filename: get_noaa_smoke.py
# Copyright (c) University of Washington
# License: MIT https://opensource.org/licenses/MIT (See LICENSE file.)
# Repository: https://github.com/deohs/coders

import re
import os.path
import urlparse
import scrapy
from scrapy.http import Request
from scrapy.crawler import CrawlerProcess

class get_hms_shapefiles(scrapy.Spider):
    name = "get_hms_shapefiles"
    domain = "satepsanone.nesdis.noaa.gov"
    allowed_domains = [domain]
    start_urls = [ "http://%s/pub/volcano/FIRE/HMS_ARCHIVE/%s/GIS/SMOKE/" %
                     (domain, year) for year in range(2008, 2017) ]

    def parse(self, response):
        start_urls = []
        for href in response.xpath('//table/tr/td/a/@href').extract():
            regexp = r'hms_smoke[0-9]{4}0[5-9]{1}[0-9]{2}\.(dbf|shp|shx)\.gz$'
            if re.match(regexp, href):
                yield Request(
                    url=response.urljoin(href),
                    callback=self.save_file
                )

    def save_file(self, response):
        path = response.url.split('/')[-1]
        if os.path.exists(path):
            self.logger.info('%s exists: skipping', path)
        else:
            self.logger.info('Saving %s', path)
            with open(path, 'wb') as f:
                f.write(response.body)

process = CrawlerProcess()
process.crawl(get_hms_shapefiles)
process.start()
