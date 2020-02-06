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
<input data-type="double" data-min="4" data-max="5.7" data-from="4" data-to="5.7" data-step="0.1" data-grid="true" data-grid-num="8.5" data-grid-snap="false" data-prettify-separator="," data-keyboard="true" data-keyboard-step="5.88235294117647" data-drag-interval="true" data-data-type="number"/>
<script type="application/json" data-for="mag">{
  "values": [4, 4, 4, 4, 4, 4.1, 4.1, 4.1, 4.1, 4.1, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.3, 4.3, 4.3, 4.3, 4.3, 4.3, 4.3, 4.3, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.8, 4.8, 4.8, 4.8, 4.8, 4.9, 4.9, 4.9, 4.9, 4.9, 4.9, 4.9, 5, 5, 5, 5, 5, 5, 5, 5, 5.1, 5.2, 5.2, 5.2, 5.2, 5.3, 5.6, 5.7],
  "keys": ["34", "52", "834", "433", "299", "767", "431", "671", "174", "161", "106", "939", "250", "361", "995", "542", "274", "282", "917", "518", "130", "809", "403", "941", "455", "212", "344", "777", "508", "125", "285", "670", "43", "795", "829", "23", "529", "30", "497", "375", "88", "509", "314", "72", "111", "319", "573", "337", "674", "438", "694", "735", "133", "540", "819", "603", "38", "532", "180", "359", "602", "577", "218", "815", "87", "516", "918", "41", "92", "729", "940", "303", "678", "413", "969", "165", "669", "186", "272", "159", "484", "993", "311", "597", "462", "883", "643", "724", "356", "697", "230", "689", "381", "703", "692", "571", "746", "787", "297", "275"],
  "group": ["SharedDatad3a77977"]
}</script>
</div><!--/html_preserve--><!--html_preserve--><div class="container-fluid crosstalk-bscols">
<div class="fluid-row">
<div class="col-xs-6">
<div id="htmlwidget-7cb140ad50e04f22cd10" style="width:400px;height:300px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-7cb140ad50e04f22cd10">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addSelect","args":["SharedDatad3a77977"]},{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[[-23.64,-19.44,-12.08,-14.12,-21.34,-18,-17.67,-19.1,-20.77,-19.86,-22.09,-20.9,-15.75,-32.42,-26.16,-17.02,-17.56,-20.75,-12,-21.75,-22.13,-21.8,-17.98,-21.5,-19.19,-21.24,-28.15,-20.05,-23.55,-13.05,-18.4,-15.17,-26.5,-11.76,-25.8,-17.64,-23.08,-19.15,-31.24,-17.79,-15.79,-23.47,-19.34,-19.26,-17.98,-17.8,-17.7,-18.8,-20.3,-37.37,-12.84,-24.57,-20.07,-20.74,-17.95,-13.36,-15.02,-20.9,-27.18,-18.07,-15.86,-18.6,-14.57,-15.29,-24.97,-30.4,-20.16,-22.34,-16.24,-28.1,-17.74,-22.32,-18.13,-20.74,-19.7,-18.55,-20.83,-15.67,-23.3,-14.46,-15.2,-18.1,-15.26,-19.52,-30.64,-19.84,-31.03,-19.57,-20.81,-23.5,-16.17,-20.93,-17.95,-35.48,-16.44,-23.82,-15.9,-17.98,-27.54,-20.31],[179.96,183.5,165.76,166.64,181.41,180.62,187.09,184.52,181.16,184.35,180.38,169.84,185.23,181.21,179.5,182.41,181.59,184.52,166.2,180.67,180.38,183.6,181.51,170.5,183.51,180.81,183.4,183.86,180.8,169.58,183.4,187.2,178.29,165.96,182.1,181.28,183.45,169.5,180.6,181.32,166.83,180.24,182.62,184.42,181.58,181.32,188.1,182.41,182.3,176.78,166.78,178.4,169.14,181.53,184.68,167.06,184.24,182.02,182.53,181.58,166.98,184.28,167.24,166.9,179.82,181.4,181.99,171.52,167.95,182.25,181.31,180.54,181.52,180.7,182.44,182.23,181.01,185.23,180.16,167.26,184.68,181.72,183.13,168.98,181.2,182.37,181.59,184.47,184.7,180,184.1,181.54,181.73,179.9,185.74,180.09,185.3,180.5,182.5,184.06],null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},null,null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},{"ctKey":["88","106","509","787","314","462","186","767","939","72","272","159","111","484","319","573","540","518","883","819","275","777","703","87","130","603","643","993","34","311","431","516","724","508","337","38","918","250","125","356","532","678","674","52","361","671","995","692","438","41","597","297","413","694","285","92","180","809","359","697","969","670","735","542","43","403","274","230","381","602","577","282","218","795","834","433","941","829","23","571","174","815","529","133","299","30","746","917","455","729","212","689","940","165","303","669","497","161","344","375"],"ctGroup":"SharedDatad3a77977"}]}],"limits":{"lat":[-37.37,-11.76],"lng":[165.76,188.1]}},"evals":[],"jsHooks":[]}</script>
</div>
<div class="col-xs-6">
<div id="htmlwidget-b5850cecbbc1aef71064" style="width:100%;height:30%;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-b5850cecbbc1aef71064">{"x":{"crosstalkOptions":{"key":["88","106","509","787","314","462","186","767","939","72","272","159","111","484","319","573","540","518","883","819","275","777","703","87","130","603","643","993","34","311","431","516","724","508","337","38","918","250","125","356","532","678","674","52","361","671","995","692","438","41","597","297","413","694","285","92","180","809","359","697","969","670","735","542","43","403","274","230","381","602","577","282","218","795","834","433","941","829","23","571","174","815","529","133","299","30","746","917","455","729","212","689","940","165","303","669","497","161","344","375"],"group":"SharedDatad3a77977"},"style":"bootstrap","filter":"none","extensions":["Scroller"],"data":[["88","106","509","787","314","462","186","767","939","72","272","159","111","484","319","573","540","518","883","819","275","777","703","87","130","603","643","993","34","311","431","516","724","508","337","38","918","250","125","356","532","678","674","52","361","671","995","692","438","41","597","297","413","694","285","92","180","809","359","697","969","670","735","542","43","403","274","230","381","602","577","282","218","795","834","433","941","829","23","571","174","815","529","133","299","30","746","917","455","729","212","689","940","165","303","669","497","161","344","375"],[-23.64,-19.44,-12.08,-14.12,-21.34,-18,-17.67,-19.1,-20.77,-19.86,-22.09,-20.9,-15.75,-32.42,-26.16,-17.02,-17.56,-20.75,-12,-21.75,-22.13,-21.8,-17.98,-21.5,-19.19,-21.24,-28.15,-20.05,-23.55,-13.05,-18.4,-15.17,-26.5,-11.76,-25.8,-17.64,-23.08,-19.15,-31.24,-17.79,-15.79,-23.47,-19.34,-19.26,-17.98,-17.8,-17.7,-18.8,-20.3,-37.37,-12.84,-24.57,-20.07,-20.74,-17.95,-13.36,-15.02,-20.9,-27.18,-18.07,-15.86,-18.6,-14.57,-15.29,-24.97,-30.4,-20.16,-22.34,-16.24,-28.1,-17.74,-22.32,-18.13,-20.74,-19.7,-18.55,-20.83,-15.67,-23.3,-14.46,-15.2,-18.1,-15.26,-19.52,-30.64,-19.84,-31.03,-19.57,-20.81,-23.5,-16.17,-20.93,-17.95,-35.48,-16.44,-23.82,-15.9,-17.98,-27.54,-20.31],[179.96,183.5,165.76,166.64,181.41,180.62,187.09,184.52,181.16,184.35,180.38,169.84,185.23,181.21,179.5,182.41,181.59,184.52,166.2,180.67,180.38,183.6,181.51,170.5,183.51,180.81,183.4,183.86,180.8,169.58,183.4,187.2,178.29,165.96,182.1,181.28,183.45,169.5,180.6,181.32,166.83,180.24,182.62,184.42,181.58,181.32,188.1,182.41,182.3,176.78,166.78,178.4,169.14,181.53,184.68,167.06,184.24,182.02,182.53,181.58,166.98,184.28,167.24,166.9,179.82,181.4,181.99,171.52,167.95,182.25,181.31,180.54,181.52,180.7,182.44,182.23,181.01,185.23,180.16,167.26,184.68,181.72,183.13,168.98,181.2,182.37,181.59,184.47,184.7,180,184.1,181.54,181.73,179.9,185.74,180.09,185.3,180.5,182.5,184.06],[538,293,63,63,464,636,45,230,568,201,590,93,280,47,492,420,543,144,94,595,577,213,586,117,307,605,57,243,349,644,343,50,609,45,68,574,90,150,328,587,45,511,573,223,590,539,45,385,476,263,150,562,66,598,260,236,339,402,60,603,60,255,162,100,511,40,504,106,188,68,575,565,618,589,397,563,622,66,512,195,99,544,393,63,175,328,57,202,162,550,338,564,583,59,126,498,57,626,68,249],[4.5,4.2,4.5,5.3,4.5,5,4.9,4.1,4.2,4.5,4.9,4.9,4.5,4.9,4.5,4.5,4.6,4.3,5,4.6,5.7,4.4,5.2,4.7,4.3,4.6,5,4.9,4,4.9,4.1,4.7,5,4.4,4.5,4.6,4.7,4.2,4.4,5,4.6,4.8,4.5,4,4.2,4.1,4.2,5.2,4.5,4.7,4.9,5.6,4.8,4.5,4.4,4.7,4.6,4.3,4.6,5,4.8,4.4,4.5,4.2,4.4,4.3,4.2,5,5.1,4.6,4.6,4.2,4.6,4.4,4,4,4.3,4.4,4.4,5.2,4.1,4.6,4.4,4.5,4,4.4,5.2,4.2,4.3,4.7,4.3,5,4.7,4.8,4.7,4.8,4.4,4.1,4.3,4.4],[26,15,51,69,21,100,62,16,12,30,35,31,28,39,25,29,34,25,31,30,104,17,68,32,19,34,32,65,10,68,10,28,50,51,26,17,30,12,18,49,39,37,32,15,14,12,10,67,10,34,35,80,37,36,21,22,27,18,21,65,25,31,18,15,23,17,11,43,68,18,42,12,41,27,12,17,15,34,18,87,14,52,28,21,16,17,49,28,20,23,13,64,57,35,30,40,19,19,12,21]],"container":"<table class=\"table table-condensed\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>lat<\/th>\n      <th>long<\/th>\n      <th>depth<\/th>\n      <th>mag<\/th>\n      <th>stations<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"deferRender":true,"scrollY":200,"scroller":true,"columnDefs":[{"className":"dt-right","targets":[1,2,3,4,5]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false},"selection":{"mode":"multiple","selected":null,"target":"row"}},"evals":[],"jsHooks":[]}</script>
</div>
</div>
</div><!--/html_preserve-->

