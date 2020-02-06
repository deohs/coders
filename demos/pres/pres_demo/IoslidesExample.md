---
title: "Ioslides Example"
author: "Brian High"
date: "05 February, 2020"
output:
  ioslides_presentation:
    fig_caption: yes
    fig_retina: 1
    fig_width: 5
    fig_height: 3
    keep_md: true
    smaller: false
    incremental: false
    logo: img/logo_128.png
    css: inc/deohs-ioslides-theme.css
    template: inc/deohs-default-ioslides.html
---



<!-- Note: Custom CSS changes title font and removes footer gradient. -->
<!-- Note: Custom HTML template replaces logo with banner on title page.-->

## R Markdown

This is an R Markdown presentation. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document.

## Slide with Bullets

- Bullet 1
- Bullet 2
- Bullet 3

## Slide with R Output


```r
summary(cars)
```

```
##      speed           dist       
##  Min.   : 4.0   Min.   :  2.00  
##  1st Qu.:12.0   1st Qu.: 26.00  
##  Median :15.0   Median : 36.00  
##  Mean   :15.4   Mean   : 42.98  
##  3rd Qu.:19.0   3rd Qu.: 56.00  
##  Max.   :25.0   Max.   :120.00
```

## Slide with Table


```r
library(kableExtra)
knitr::kable(head(iris)) %>% kable_styling(font_size = 18)
```

<table class="table" style="font-size: 18px; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> Sepal.Length </th>
   <th style="text-align:right;"> Sepal.Width </th>
   <th style="text-align:right;"> Petal.Length </th>
   <th style="text-align:right;"> Petal.Width </th>
   <th style="text-align:left;"> Species </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 5.1 </td>
   <td style="text-align:right;"> 3.5 </td>
   <td style="text-align:right;"> 1.4 </td>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:left;"> setosa </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4.9 </td>
   <td style="text-align:right;"> 3.0 </td>
   <td style="text-align:right;"> 1.4 </td>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:left;"> setosa </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4.7 </td>
   <td style="text-align:right;"> 3.2 </td>
   <td style="text-align:right;"> 1.3 </td>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:left;"> setosa </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4.6 </td>
   <td style="text-align:right;"> 3.1 </td>
   <td style="text-align:right;"> 1.5 </td>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:left;"> setosa </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5.0 </td>
   <td style="text-align:right;"> 3.6 </td>
   <td style="text-align:right;"> 1.4 </td>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:left;"> setosa </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5.4 </td>
   <td style="text-align:right;"> 3.9 </td>
   <td style="text-align:right;"> 1.7 </td>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:left;"> setosa </td>
  </tr>
</tbody>
</table>

## Slide with Plot


```r
plot(pressure)
```

![](IoslidesExample_files/figure-html/pressure-1.png)<!-- -->

## Slide with Crosstalk Elements {.smaller}

### Fiji Earthquakes

<!--html_preserve--><div class="form-group crosstalk-input crosstalk-input-slider js-range-slider" id="mag" style="width: 400px;">
<label class="control-label" for="mag">Magnitude</label>
<input data-type="double" data-min="4" data-max="6" data-from="4" data-to="6" data-step="0.1" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-keyboard="true" data-keyboard-step="5" data-drag-interval="true" data-data-type="number"/>
<script type="application/json" data-for="mag">{
  "values": [4, 4, 4, 4, 4.1, 4.1, 4.1, 4.1, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.3, 4.3, 4.3, 4.3, 4.3, 4.3, 4.3, 4.3, 4.3, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.8, 4.8, 4.8, 4.8, 4.8, 4.8, 4.9, 4.9, 4.9, 4.9, 4.9, 4.9, 4.9, 5, 5, 5, 5, 5, 5, 5.1, 5.1, 5.1, 5.1, 5.1, 5.1, 5.1, 5.3, 5.3, 5.3, 5.3, 5.4, 5.5, 5.5, 5.6, 5.7, 5.7, 5.7, 6, 6],
  "keys": ["816", "150", "34", "772", "353", "687", "174", "423", "986", "845", "112", "120", "650", "220", "132", "210", "939", "995", "196", "701", "140", "452", "206", "171", "761", "550", "941", "187", "441", "215", "747", "59", "768", "633", "219", "971", "796", "569", "131", "72", "762", "959", "802", "642", "677", "527", "456", "656", "603", "589", "366", "748", "12", "300", "613", "118", "782", "600", "769", "711", "92", "717", "240", "468", "555", "162", "865", "159", "272", "873", "260", "617", "903", "254", "398", "549", "574", "788", "143", "981", "448", "381", "50", "312", "371", "615", "374", "80", "675", "243", "191", "214", "496", "531", "649", "176", "151", "399", "870", "1000"],
  "group": ["SharedDatab75e0c6f"]
}</script>
</div><!--/html_preserve--><!--html_preserve--><div class="container-fluid crosstalk-bscols">
<div class="fluid-row">
<div class="col-xs-6">
<div id="htmlwidget-e0baa7930097712099d0" style="width:400px;height:300px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-e0baa7930097712099d0">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addSelect","args":["SharedDatab75e0c6f"]},{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[[-20.85,-15.97,-24.09,-15.44,-30.51,-22.12,-28.98,-12.37,-17.9,-15.03,-15.87,-22.87,-21.22,-12.23,-26.06,-20.9,-22.54,-16.85,-22.09,-24.96,-20.47,-31.8,-23.55,-19.6,-15.77,-18.96,-21.24,-17.8,-16.24,-17.99,-17.43,-16.03,-23.44,-20.95,-20.48,-21.97,-19.86,-21.18,-26.78,-18.31,-17.82,-22.55,-32.22,-24.34,-23.34,-15.61,-17.84,-20.7,-17.46,-21.16,-11.02,-17.05,-23.79,-15.34,-18.89,-20.2,-18.97,-16.4,-12.93,-22.04,-19.85,-20.83,-15.2,-20.41,-12.26,-23.61,-22.3,-20.77,-28.56,-13.47,-17.7,-20.36,-18.64,-33.09,-14.7,-20.97,-20.21,-12.66,-22.33,-23.73,-23.42,-20.02,-22.5,-16.23,-12.01,-23.07,-13.23,-11.37,-21.59,-15.65,-19.77,-37.03,-20.82,-17.04,-15.45,-13.36,-13.9,-25.79,-18.84,-23.55],[181.59,186.08,179.68,167.18,181.3,180.49,181.11,166.93,181.5,167.32,188.13,171.72,181.51,167.02,180.05,169.84,172.91,182.31,180.38,180.22,185.68,180.6,180.8,183.84,167.01,169.48,180.81,181.35,167.95,168.98,185.43,185.43,184.6,181.42,181.38,182.32,184.35,180.92,183.61,182.39,181.83,183.34,180.2,179.52,184.5,187.15,181.3,184.3,181.32,181.41,167.01,181.22,179.89,167.1,181.24,182.3,185.25,182.73,169.63,184.91,184.51,181.01,184.68,186.51,167,180.27,181.9,181.16,183.59,172.29,188.1,181.19,169.32,180.94,166,181.2,183.83,166.37,171.46,179.99,180.21,184.09,170.4,167.91,166.66,184.03,167.1,166.55,170.56,186.26,181.4,177.52,181.67,186.8,186.73,167.06,167.18,182.38,184.16,180.27],null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},null,null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},{"ctKey":["448","677","452","527","747","816","80","986","150","456","398","656","717","870","845","159","496","112","272","240","214","796","34","569","531","120","603","59","381","613","131","468","555","589","650","206","72","762","366","220","171","748","176","162","151","549","399","761","353","550","873","132","260","675","687","210","50","772","312","617","768","941","174","574","12","788","187","939","633","118","995","196","300","903","243","959","219","441","782","371","802","191","254","642","865","600","143","769","1000","615","374","649","981","423","711","92","701","971","140","215"],"ctGroup":"SharedDatab75e0c6f"}]}],"limits":{"lat":[-37.03,-11.02],"lng":[166,188.13]}},"evals":[],"jsHooks":[]}</script>
</div>
<div class="col-xs-6">
<div id="htmlwidget-8a62ec8bfe1b96319351" style="width:100%;height:30%;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-8a62ec8bfe1b96319351">{"x":{"crosstalkOptions":{"key":["448","677","452","527","747","816","80","986","150","456","398","656","717","870","845","159","496","112","272","240","214","796","34","569","531","120","603","59","381","613","131","468","555","589","650","206","72","762","366","220","171","748","176","162","151","549","399","761","353","550","873","132","260","675","687","210","50","772","312","617","768","941","174","574","12","788","187","939","633","118","995","196","300","903","243","959","219","441","782","371","802","191","254","642","865","600","143","769","1000","615","374","649","981","423","711","92","701","971","140","215"],"group":"SharedDatab75e0c6f"},"style":"bootstrap","filter":"none","extensions":["Scroller"],"data":[["448","677","452","527","747","816","80","986","150","456","398","656","717","870","845","159","496","112","272","240","214","796","34","569","531","120","603","59","381","613","131","468","555","589","650","206","72","762","366","220","171","748","176","162","151","549","399","761","353","550","873","132","260","675","687","210","50","772","312","617","768","941","174","574","12","788","187","939","633","118","995","196","300","903","243","959","219","441","782","371","802","191","254","642","865","600","143","769","1000","615","374","649","981","423","711","92","701","971","140","215"],[-20.85,-15.97,-24.09,-15.44,-30.51,-22.12,-28.98,-12.37,-17.9,-15.03,-15.87,-22.87,-21.22,-12.23,-26.06,-20.9,-22.54,-16.85,-22.09,-24.96,-20.47,-31.8,-23.55,-19.6,-15.77,-18.96,-21.24,-17.8,-16.24,-17.99,-17.43,-16.03,-23.44,-20.95,-20.48,-21.97,-19.86,-21.18,-26.78,-18.31,-17.82,-22.55,-32.22,-24.34,-23.34,-15.61,-17.84,-20.7,-17.46,-21.16,-11.02,-17.05,-23.79,-15.34,-18.89,-20.2,-18.97,-16.4,-12.93,-22.04,-19.85,-20.83,-15.2,-20.41,-12.26,-23.61,-22.3,-20.77,-28.56,-13.47,-17.7,-20.36,-18.64,-33.09,-14.7,-20.97,-20.21,-12.66,-22.33,-23.73,-23.42,-20.02,-22.5,-16.23,-12.01,-23.07,-13.23,-11.37,-21.59,-15.65,-19.77,-37.03,-20.82,-17.04,-15.45,-13.36,-13.9,-25.79,-18.84,-23.55],[181.59,186.08,179.68,167.18,181.3,180.49,181.11,166.93,181.5,167.32,188.13,171.72,181.51,167.02,180.05,169.84,172.91,182.31,180.38,180.22,185.68,180.6,180.8,183.84,167.01,169.48,180.81,181.35,167.95,168.98,185.43,185.43,184.6,181.42,181.38,182.32,184.35,180.92,183.61,182.39,181.83,183.34,180.2,179.52,184.5,187.15,181.3,184.3,181.32,181.41,167.01,181.22,179.89,167.1,181.24,182.3,185.25,182.73,169.63,184.91,184.51,181.01,184.68,186.51,167,180.27,181.9,181.16,183.59,172.29,188.1,181.19,169.32,180.94,166,181.2,183.83,166.37,171.46,179.99,180.21,184.09,170.4,167.91,166.66,184.03,167.1,166.55,170.56,186.26,181.4,177.52,181.67,186.8,186.73,167.06,167.18,182.38,184.16,180.27],[499,143,538,140,203,532,304,291,573,136,52,47,524,242,432,93,54,388,590,470,93,178,349,309,64,248,605,535,188,234,189,297,63,559,556,261,201,619,40,342,640,66,216,504,56,49,535,182,573,543,62,527,526,128,655,533,129,391,641,47,184,622,99,63,249,537,309,568,53,64,45,637,260,47,48,605,242,165,119,527,510,234,106,182,99,89,220,188,165,64,630,153,577,70,83,236,221,172,210,535],[5.1,4.6,4.3,4.6,4.4,4,5.3,4.2,4,4.6,5,4.6,4.8,6,4.2,4.9,5.5,4.2,4.9,4.8,5.4,4.5,4,4.5,5.5,4.2,4.6,4.4,5.1,4.7,4.5,4.8,4.8,4.6,4.2,4.3,4.5,4.5,4.6,4.2,4.3,4.6,5.7,4.8,5.7,5,5.7,4.3,4.1,4.3,4.9,4.2,4.9,5.3,4.1,4.2,5.1,4,5.1,4.9,4.4,4.3,4.1,5,4.6,5,4.3,4.2,4.4,4.7,4.2,4.2,4.6,4.9,5.3,4.5,4.4,4.3,4.7,5.1,4.5,5.3,4.9,4.5,4.8,4.7,5,4.7,6,5.1,5.1,5.6,5,4.1,4.7,4.7,4.2,4.4,4.2,4.3],[91,41,21,44,20,14,60,16,19,20,30,27,49,132,19,31,71,14,35,41,85,19,10,23,73,13,34,23,68,28,22,25,27,27,13,13,30,18,22,14,24,18,90,34,106,30,112,17,17,17,36,24,43,18,14,11,73,16,57,47,26,15,14,28,16,63,11,12,20,14,10,23,23,47,16,31,29,18,32,49,37,71,38,28,36,32,46,24,119,54,54,87,67,22,37,22,21,14,17,22]],"container":"<table class=\"table table-condensed\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>lat<\/th>\n      <th>long<\/th>\n      <th>depth<\/th>\n      <th>mag<\/th>\n      <th>stations<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"deferRender":true,"scrollY":200,"scroller":true,"columnDefs":[{"className":"dt-right","targets":[1,2,3,4,5]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false},"selection":{"mode":"multiple","selected":null,"target":"row"}},"evals":[],"jsHooks":[]}</script>
</div>
</div>
</div><!--/html_preserve-->

