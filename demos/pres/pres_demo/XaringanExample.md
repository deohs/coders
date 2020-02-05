




class: title-slide

<div style="text-align:left; padding-bottom: 125px;">
    <img src="img/DEOHS-Logo-Line-Purple-Print-Transparency.png">
    <hr class="title-slide"/>
</div>

# Xaringan (Remark.js) Demo 

## Brian High

### 05 February, 2020

---
layout: true
<!-- Note: Footer interferes with heading rendering on the Crosstalk slide. -->
<div class="my-footer">
  <img src="img/W-47x35.png" width="33px" height="23px">
</div>
---

# Xaringan and Remark.js

[Remark.js](https://remarkjs.com/) is a Javascript library used for making 
slide presentations like this one. 

[xaringan](https://github.com/yihui/xaringan) ("Presentation Nina") is an R 
package for using Remark.js with R Markdown.

You can install the `xaringan` package like this:


```r
remotes::install_github('yihui/xaringan')
```

---

# R Markdown

This is an R Markdown presentation. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document.

---

# Slide with Bullets

- Bullet 1
- Bullet 2
- Bullet 3

<aside class="notes">
Here are some notes.
</aside>

---

# Slide with Image and Link

![triple image](https://deohs.washington.edu/sites/default/files/triple-image.png)

- [DEOHS Website](https://deohs.washington.edu)

---

# Slide with R Output


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

---

# Slide with Table


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

---

# Slide with Plot


```r
plot(pressure)
```

![](data:image/png;base64,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)<!-- -->

---
layout: true
<!-- Removing the footer because it interferes with heading of next slide. -->
---

# Slide with Crosstalk Elements

## Fiji Earthquakes

<div class="smaller-font">


Magnitude
{
  "values": [4, 4, 4, 4, 4, 4.1, 4.1, 4.1, 4.1, 4.1, 4.1, 4.1, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.2, 4.3, 4.3, 4.3, 4.3, 4.3, 4.3, 4.3, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.4, 4.5, 4.5, 4.5, 4.5, 4.5, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.6, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.7, 4.8, 4.8, 4.8, 4.8, 4.8, 4.9, 4.9, 4.9, 4.9, 4.9, 5, 5, 5, 5, 5, 5, 5.1, 5.1, 5.1, 5.1, 5.1, 5.1, 5.1, 5.2, 5.2, 5.2, 5.2, 5.3, 5.3, 5.5, 5.5, 5.5, 5.5, 5.5, 5.5, 5.7],
  "keys": ["58", "861", "994", "202", "834", "175", "858", "213", "863", "194", "760", "317", "112", "396", "566", "51", "196", "146", "2", "831", "86", "774", "582", "90", "201", "859", "909", "285", "696", "797", "115", "19", "682", "219", "405", "461", "75", "56", "339", "479", "926", "252", "82", "540", "603", "309", "517", "934", "246", "739", "269", "929", "982", "470", "408", "32", "940", "822", "950", "513", "118", "644", "66", "744", "930", "129", "33", "891", "165", "188", "821", "723", "617", "489", "889", "697", "549", "356", "398", "840", "357", "371", "448", "910", "381", "839", "618", "972", "908", "938", "28", "623", "681", "531", "70", "449", "893", "354", "496", "275"],
  "group": ["SharedDataa01f4cfa"]
}



{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addSelect","args":["SharedDataa01f4cfa"]},{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[[-15.03,-17.95,-25.81,-23.9,-15.77,-22.82,-18.07,-19.85,-15.65,-17.56,-16.85,-14.1,-22.95,-28.25,-22.06,-31.94,-22.19,-21.24,-18.91,-15.46,-27.27,-24.97,-23.7,-23.75,-19.92,-24.18,-23.73,-17.93,-15.36,-26.53,-16.32,-15.61,-17.95,-21.38,-19.36,-26.2,-21.11,-27.72,-22.04,-21.07,-20.85,-23.73,-11.67,-23.56,-21.03,-20.88,-17.95,-18.75,-19.66,-15.55,-13.8,-21.53,-18.11,-17.79,-16.99,-12.57,-21.63,-20.57,-23.5,-20.36,-20.16,-28.05,-15.41,-20.1,-20.99,-19.67,-14.85,-18.92,-20.21,-20.3,-30.17,-20.62,-35.48,-15.7,-24.08,-15.87,-13.47,-18.97,-30.01,-20.21,-20.81,-15.66,-22.41,-17.1,-30.63,-17.7,-16.24,-20.89,-22.54,-17.7,-19.17,-19.85,-16.43,-38.59,-22.13,-19.7,-17.32,-16.46,-23.84,-20.06],[182.29,184.68,182.54,179.9,167.01,184.52,181.58,181.85,185.17,181.59,182.31,166.01,170.56,181.71,180.6,180.57,171.4,180.81,169.46,187.81,182.38,179.54,179.6,184.5,183.91,179.02,179.99,181.89,167.51,178.3,166.74,187.15,181.73,181.39,186.36,178.35,181.5,181.7,184.91,181.13,181.59,184.49,166.02,180.23,180.78,185.18,181.37,182.35,184.31,185.05,166.53,170.52,181.67,181.32,187,167.11,180.77,181.33,179.78,181.19,184.27,182.39,186.44,184.4,181.02,182.18,167.24,169.37,183.83,181.4,182.02,181.03,179.9,184.5,179.5,188.13,172.29,169.44,181.15,182.37,185.01,186.8,183.99,184.93,180.9,182.2,167.95,185.26,172.91,181.23,169.53,182.13,186.73,175.7,180.38,182.44,181.03,180.79,180.99,168.69],null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},null,null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},{"ctKey":["175","285","929","696","531","889","697","188","858","540","112","930","982","213","58","470","357","603","797","70","339","821","396","972","566","623","371","863","408","723","32","549","940","309","822","115","449","129","617","489","448","950","517","479","861","934","994","51","86","33","893","908","246","356","513","891","774","582","19","196","682","910","90","146","926","201","252","681","219","739","354","2","165","405","194","398","118","840","859","269","644","461","938","66","831","202","381","839","496","75","909","56","760","744","275","834","317","28","82","618"],"ctGroup":"SharedDataa01f4cfa"}]}],"limits":{"lat":[-38.59,-11.67],"lng":[166.01,188.13]}},"evals":[],"jsHooks":[]}


{"x":{"crosstalkOptions":{"key":["175","285","929","696","531","889","697","188","858","540","112","930","982","213","58","470","357","603","797","70","339","821","396","972","566","623","371","863","408","723","32","549","940","309","822","115","449","129","617","489","448","950","517","479","861","934","994","51","86","33","893","908","246","356","513","891","774","582","19","196","682","910","90","146","926","201","252","681","219","739","354","2","165","405","194","398","118","840","859","269","644","461","938","66","831","202","381","839","496","75","909","56","760","744","275","834","317","28","82","618"],"group":"SharedDataa01f4cfa"},"style":"bootstrap","filter":"none","extensions":["Scroller"],"data":[["175","285","929","696","531","889","697","188","858","540","112","930","982","213","58","470","357","603","797","70","339","821","396","972","566","623","371","863","408","723","32","549","940","309","822","115","449","129","617","489","448","950","517","479","861","934","994","51","86","33","893","908","246","356","513","891","774","582","19","196","682","910","90","146","926","201","252","681","219","739","354","2","165","405","194","398","118","840","859","269","644","461","938","66","831","202","381","839","496","75","909","56","760","744","275","834","317","28","82","618"],[-15.03,-17.95,-25.81,-23.9,-15.77,-22.82,-18.07,-19.85,-15.65,-17.56,-16.85,-14.1,-22.95,-28.25,-22.06,-31.94,-22.19,-21.24,-18.91,-15.46,-27.27,-24.97,-23.7,-23.75,-19.92,-24.18,-23.73,-17.93,-15.36,-26.53,-16.32,-15.61,-17.95,-21.38,-19.36,-26.2,-21.11,-27.72,-22.04,-21.07,-20.85,-23.73,-11.67,-23.56,-21.03,-20.88,-17.95,-18.75,-19.66,-15.55,-13.8,-21.53,-18.11,-17.79,-16.99,-12.57,-21.63,-20.57,-23.5,-20.36,-20.16,-28.05,-15.41,-20.1,-20.99,-19.67,-14.85,-18.92,-20.21,-20.3,-30.17,-20.62,-35.48,-15.7,-24.08,-15.87,-13.47,-18.97,-30.01,-20.21,-20.81,-15.66,-22.41,-17.1,-30.63,-17.7,-16.24,-20.89,-22.54,-17.7,-19.17,-19.85,-16.43,-38.59,-22.13,-19.7,-17.32,-16.46,-23.84,-20.06],[182.29,184.68,182.54,179.9,167.01,184.52,181.58,181.85,185.17,181.59,182.31,166.01,170.56,181.71,180.6,180.57,171.4,180.81,169.46,187.81,182.38,179.54,179.6,184.5,183.91,179.02,179.99,181.89,167.51,178.3,166.74,187.15,181.73,181.39,186.36,178.35,181.5,181.7,184.91,181.13,181.59,184.49,166.02,180.23,180.78,185.18,181.37,182.35,184.31,185.05,166.53,170.52,181.67,181.32,187,167.11,180.77,181.33,179.78,181.19,184.27,182.39,186.44,184.4,181.02,182.18,167.24,169.37,183.83,181.4,182.02,181.03,179.9,184.5,179.5,188.13,172.29,169.44,181.15,182.37,185.01,186.8,183.99,184.93,180.9,182.2,167.95,185.26,172.91,181.23,169.53,182.13,186.73,175.7,180.38,182.44,181.03,180.79,180.99,168.69],[399,260,201,579,64,49,603,576,315,543,388,69,42,226,584,168,150,605,248,40,45,505,646,54,264,550,527,567,123,605,50,49,583,501,100,606,538,94,47,594,499,60,102,474,638,51,642,554,170,292,42,129,597,587,70,231,592,605,570,637,210,117,69,186,626,360,97,248,242,608,56,650,59,118,605,52,64,242,210,482,79,45,128,286,334,445,188,54,54,546,268,562,75,162,577,397,497,498,367,49],[4.1,4.4,4.7,4.4,5.5,5,5,4.9,4.1,4.6,4.2,4.8,4.7,4.1,4,4.7,5.1,4.6,4.4,5.5,4.5,4.9,4.2,5.2,4.2,5.3,5.1,4.1,4.7,4.9,4.7,5,4.7,4.6,4.7,4.4,5.5,4.8,4.9,4.9,5.1,4.7,4.6,4.5,4,4.6,4,4.2,4.3,4.8,5.5,5.2,4.6,5,4.7,4.8,4.3,4.3,4.4,4.2,4.4,5.1,4.3,4.2,4.5,4.3,4.5,5.3,4.4,4.6,5.5,4.2,4.8,4.4,4.1,5,4.7,5,4.3,4.6,4.7,4.4,5.2,4.7,4.2,4,5.1,5.1,5.5,4.4,4.3,4.4,4.1,4.7,5.7,4,4.1,5.2,4.5,5.1],[10,21,40,16,73,52,65,54,15,34,14,29,21,19,11,39,49,34,33,91,16,50,21,74,23,86,49,27,28,43,30,30,57,36,40,21,104,59,47,43,91,35,21,13,14,28,17,13,15,42,70,30,28,49,30,28,21,18,13,23,27,43,42,10,36,23,26,60,29,13,68,15,35,30,21,30,14,41,17,37,42,11,72,25,28,12,68,44,71,35,21,31,20,36,104,12,13,79,27,49]],"container":"<table class=\"table table-condensed\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>lat<\/th>\n      <th>long<\/th>\n      <th>depth<\/th>\n      <th>mag<\/th>\n      <th>stations<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"deferRender":true,"scrollY":250,"scroller":true,"columnDefs":[{"className":"dt-right","targets":[1,2,3,4,5]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false},"selection":{"mode":"multiple","selected":null,"target":"row"}},"evals":[],"jsHooks":[]}



</div>
    
