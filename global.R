# A note on UI and backend terminology: 
# The synoptic app implements what is essentially a two-stage selection process. 
# Users have the option to 'filter' the data, which has the effect of removing 
# any elements from the dataset that aren't included in the filter.
# Users also have the option to 'highlight' specific CUs and/or populations 
# for the purpose of comparing/contrasting these with the CUs/populations not
# highlighted.  
# In line with terminology used in Shiny widgets and software development more generally,
# in the code, the term 'selection' is used in conjunction with the data structures and
# algorithms used to implement the 'highlighting' process,
# (e.g., data.currentSelection() holds the currently highlighted CUs and populations etc)
# whereas the term 'highlighting' is used to refer to styling of graphical elements
# to emphasize them visually. Often, visual highlighting signals that the element is
# part of data.currentSelection(), but visual highlighting can be expressed through
# multiple styles, and also serves purposes other than communicating the contents of the
# data.currentSelection() to the user, such as showing the user which UI element they 
# are currently hovering over.

# ----- explanatory information for the different metrics ---------
library(xfun)
library(rgdal)

MetricInfo <- list(
  CU_ID = "Conservation Unit",
  Species = "Species",
  RelAbd = "Spawner abundance relative to ?",
  AbsAbd = "Spawner Abundance",
  LongTrend = "Long-term trend",
  PercChange = "Percent change over ??",
  ProbDeclBelowLBM = "Probability of decline below lower benchmark",
  FAZ = "Freshwater Adaptive Zone"
)

# add labels here for any names or categories that should be shown with pretty labels
Labels <- list(Species = 'Species',
               AvGen = 'Average Generation Length',
               RunTiming = 'Run Timing',
               LifeHistory = 'Life History Traits',
               Sk = "Sockeye",
               Ck = "Chinook",
               Co = 'Coho',
               FAZ="Freshwater Adaptive Zone",
               Estu="Early Stuart", 
               Early_Summer="Early Summer", 
               Summer="Summer", 
               Late="Late",
               CU_ID='Conservation Unit',
               RelAbd = "RelAbd",
               AbsAbd = "AbsAbd",
               LongTrend = "LongTrend",
               PercChange = "PercChange",
               ProbDeclBelowLBM = "ProbDeclBelowLBM"
               )
  
# Specify order in which values for various attributes should appear in the graphs and tables
AttribLevels <- list(
  Species = c('Sk', 'Ck', 'Co'),
  FAZ = c('LFR', 'FRCany', 'LILL', 'MFR', 'UFR', 'LTh', 'STh', 'NTh'),
  Area = c('Fraser_Lower', 'Fraser_Canyon', 'Fraser_Mid','Fraser_Upper', 'Fraser_Thompson_Lower', 'Fraser_Thompson'),
  RunTiming = c('Estu', 'Spring', 'Early_Summer', 'Summer', 'Late', 'Fall', 'NA'),
  LifeHistory = c('Ocean', 'Stream', 'River', 'Lake', 'NA'),
  AvGen = c('3', '4', '5', '?')
)

# ------------------------ UI customization -----------------

# ------------------ Common Styles ---------
BoxHeaderStatus = 'primary'
WellPanelStyle <- "background: white"
PickerOptsSingleSelect <- list(`show-tick`=TRUE)
PickerOptsMultiSelect <- list(`show-tick`=TRUE, `actions-box`=TRUE, `selected-text-format`='count')
ButtonStyle <- "color: #fff; background-color: #337ab7; border-color: #2e6da4, height:70px; font-size: 100%"

# ------------ Data Filtering UI --------------
# attribute filter customization
# the names of the attributes users may filter by, shown in this order
FilterAttributes <- c('DataType', 'Species', 'FAZ', 'Area', 'RunTiming', 'LifeHistory', 'AvGen', 'CU_ID')

# allow only a single choice for these attributes:
SingleChoice <- c('DataType') 

# metric selector customization
# the names of the metrics users may choose from
#FilterMFMetrics <- unique(data.CU.MetricSeries$Metric)

# the names of the attributes users may choose from
FilterMFAttributes <- c("Species", "FAZ", "Area", "RunTiming", "LifeHistory", "AvGen")

# attributes for which it doesn't make sense to let the user select whether they should be shown
FilterMFhiddenAttributes <- c("CU_ID", "DataType")

# ---------------- Data Selector UI ------------------

SelectAttributes <- c('Species',
                      'CU_ID',
                      'FAZ',
                      'Area',
                      'RunTiming',
                      'LifeHistory',
                      'AvGen',
                      'Status')


# ---------------- Parcoords UI ------------------
# show the following axes in parcoords, in the order specified here
ParcoordsMetricOrder <- c("FAZ",
                          "RelAbd", "RelAbd.Status", 
                          "AbsAbd", "AbsAbd.Status",
                          "LongTrend", "LongTrend.Status",
                          "PercChange", "PercChange.Satus",
                          "ProbDeclBelowLBM", "ProbDeclBelowLBM.Status",
                          "Species",
                          "RunTiming",
                          "LifeHistory",
                          "CU_ID")

ParcoordsHideOnInit <- c('CU_ID')

# sort CUs on y-axis by these attributes
ParcoordsCUOrder <- c("Species", "FAZ", "AbsAbd")

# rotation of axis labels for metric axes (in degrees from horizontal)
ParcoordsLabelRotation <- -15 

# ---------------- Historgram Summaries UI ------------------
# histogram summaries will be generated for these metrics/attributes in the order specified
HistoSummaryAttribs <- c("Area", "FAZ", "RelAbd.Status", "AbsAbd.Status", "LongTrend.Status", "PercChange.Status")

# the number of CUs afte which display switches to bars by default
HistoMaxDots <- 40

# this list specifies the information necessary to construct a histogram from a numeric metric 
HistoCustomInfo <- list(
  Annual = list( 
    Recent.ER = list(
      breaks = c( 0,10,20,30,40,50,60,70,80,90,100),
      names = c("Below 10%","10-20%","20-30%","30%-40%","40-50%", "50%-60%","60-70%","70%-80%","80-90%","Above 90%")
    )
  ),
  Change = list(
    Recent.ER = list(
      breaks = c(-100, -10, -5, -1, 1, 5, 10, 100),
      names = c(">10% decr", "5%-10% decr", "0-5% decr","No Change", "0-5% incr", "5-10% incr",">10% incr")
    )
  ))

# --------------- Radar Plot UI ----------------

# the metrics offered as choices for the radar plot
RadarMetricOpts <- c("RelAbd.Status", "AbsAbd.Status", "LongTrend", "PercChange", "ProbDeclBelowLBM")

# -------------------- Map UI ______________________

# attributes from CU lookup table to pull into spatial data frame
MapAttribs <- c('Lat', 'Lon', 'Species', 'HasMetricsData', 'HasTimeSeriesData', "RunTiming",
                "LifeHistory")


# the metrics to include in the map labels (i.e., the popups shown on hover)
MapLabelMetrics <-  c("RelAbd", "LongTrend", "PercChange", "ProbDeclBelowLBM")

# palettes to use for the different color theme options
ColorPalette <- list(
                    Species = c(Sk = '#8c1aff', Co = '#ff9900', Ck = '#009999'),
                    Status = c(Red = '#ff0000', Amber = '#ffa500', Green = '#00ff00', 'NA' = '#eae2e3'),
                    HasMetricsData = c(Yes = '#222222', No = '#999999'),
                    HasTimeSeriesData = c(Yes = '#222222', No = '#999999'),
                    RunTiming = c(Estu = '#fd5c71', Spring = '#cb3f51', Early_Summer = '#b01f32', Summer = '#8c0e0e', Late='#76353e', Fall='#6b464b', 'NA' = '#eae2e3'),
                    LifeHistory = c(Ocean = '#5fd2bb', Stream = '#347266', River = '#d25587', Lake = '#9b1349', 'NA' = '#eae2e3')
)

CUPolyStyle.normal <- list(
  fill = TRUE,
  fillOpacity = 0.3,
  stroke = TRUE,
  weight = 2,
  opacity = 0.6
)

CUPolyStyle.highlighted <- list(
  fill = TRUE,
  fillOpacity = 0.3,
  stroke = TRUE,
  weight = 3,
  opacity = 0.9
)

CUPolyStyle.mouseover <- list(
  fill = FALSE,
  fillOpacity = 0.3,
  stroke = TRUE,
  weight = 3,
  opacity = 0.9,
  color = 'red'
)

CUMarkerStyle.normal <- list(
  radius = 6,
  stroke = FALSE,
  weight = 3,
  opacity = 0.5,
  fill = TRUE,
  fillOpacity = 0.5
)

CUMarkerStyle.highlighted <- list(
  radius = 10,
  stroke = FALSE,
  weight = 2,
  opacity = 0.9,
  fill = TRUE,
  fillOpacity = 0.9
)

CUMarkerStyle.mouseover <- list(
  radius = 10,
  stroke = TRUE,
  weight = 2,
  opacity = 0.9,
  fill = FALSE,
  fillOpacity = 0.9,
  color = 'red'
)

PopMarkerStyle.normal <- list(
  radius = 4,
  stroke = TRUE,
  weight = 1,
  opacity = 0.5,
  fill = TRUE,
  fillOpacity = 0.5
)

PopMarkerStyle.highlighted <- list(
  radius = 5,
  stroke = TRUE,
  weight = 1,
  opacity = 0.9,
  fill = TRUE,
  fillOpacity = 0.8
)

PopMarkerStyle.mouseover <- list(
  radius = 4,
  stroke = TRUE,
  weight = 1,
  opacity = 0.9,
  fill = FALSE,
  fillOpacity = 0.8,
  color = 'red'
)

# CU boundaries and markers will be shown overlaid in this order, i.e., the species listed first will be on bottom
zPaneOrder <- c("Co", "Ck", "Sk")

# --------------------- Helper functions for data display and restructuring ---------

# get full name of a CU, given the CU's ID
getCUname <- function(CU_ID) {paste0(data.CU.Lookup[data.CU.Lookup$CU_ID == CU_ID, 'CU_Name'][1], ' (', CU_ID, ')')}

# get full name of a population, given the population Pop_UID
getPopName <- function(Pop_UID) {paste0(data.Pop.Lookup[Pop_UID, 'CU_ID'], ': ', data.Pop.Lookup[Pop_UID, 'Pop_Name'], ' (', data.Pop.Lookup[Pop_UID, 'Pop_ID'], ')')}

# get name of a population, given the population Pop_UID
getPopNameShort <- function(Pop_UID) {data.Pop.Lookup[Pop_UID, 'Pop_Name']}

# get list of populations associated with the given CUs
getPopsForCUs <- function(CUs) {data.Pop.Lookup[data.Pop.Lookup$CU_ID %in% CUs, 'Pop_UID']}

# unpack a comma-separated list of items
unpack <- function(itemList) {
  if (is.null(itemList) || length(itemList) == 0 || itemList == '') {
    c()
  } else {
    strsplit(itemList, ',')[[1]]
  }
} 

# pass through a CU metrics table and add a 'labels' column
# CUlabels should be a named vector that specified the label for each CU
# if CUnames is given, uses the labels from CUnames
# otherwise assumes that the ds row names are to be used as the labels 
WithLabels <- function(ds, CUnames = NULL) {
  if (is.null(CUnames)) {
    ds$labels <- row.names(ds)
  } else {
    ds$labels <- CUnames[row.names(ds)]
  }
  return(ds)
}

# get the label for pretty printing, given the name of a metric, attribute, or attribute category
GetLabel <- function(m) {
  if (m %in% names(Labels)) {
    Labels[[m]]
  } else
  {
    m
  }
}

# get named choices for a metric or attribute, given the name of the metric 
# and a data frame with a column of values for that metric
GetNamedChoices  <- function(m, df) {
  if (!(m %in% names(df))) {
    NULL
  } else {
    if (all(is.na(df[, m]))) {
      list('NA' = 'NA')
    } else {
      if (is.factor(df[, m])) {
        choices <- levels(df[, m]) 
        choices <- choices[choices %in% df[, m]]
      } else {
        choices <- unique(as.character(df[, m]))
      }
      names(choices) <- sapply(choices, GetLabel)
      choices
    }
  }
}

# Given a lookup table, the name of the 'outdated' field and the name of the new field in the table, and a vector
# with outated values, returns a vector where old values are replaced with the updated ones.
# Use this to make fields like CU_ID, Pop_ID etc consistent across files
SubstituteValues <- function(old, new, lookup, oldVals) {
  lookup <- lookup[!is.na(lookup[, old]) & lookup[, old] != "", ]
  lookup <- unique(lookup[, c(old, new)])
  if (any(duplicated(lookup[,old]))) {
    cat("Warning: found duplicate values in column ", old, " of table ", lookup, " while translating from ", old, "to ", new, ":")
    print(lookup[lookup[, old] %in% duplicated(lookup[,old]), ])
    cat("using first occurrence ... \n")
    lookup <- lookup[!duplicated(lookup[,old]), ]
  }
  row.names(lookup) <- as.character(lookup[, old])
  lookup[as.character(oldVals), new]
}


# ------------------- put together initial data set -------------------

# Get the metrics and time series data for CUs and populations
data.CU.MetricsSeries <- read.csv("data/METRICS_FILE_BY_CU.csv", stringsAsFactors = F)
data.CU.Metrics.Years <- sort(unique(data.CU.MetricsSeries$Year))
data.CU.TimeSeries <- read.csv("data/MERGED_FLAT_FILE_BY_CU.csv", stringsAsFactors = F)
data.Pop.TimeSeries <- read.csv("data/MERGED_FLAT_FILE_BY_POP.csv", stringsAsFactors = F)

# spatial location of populations
data.Pop.Spatial <- read.csv("data/All_Species_Sites_with_FWA_watershed_key_Fraser.csv", stringsAsFactors = F)
# CU boundary polygons
# note: gpkg is the preferred format for transferring files with spatial data in and out of qGIS, since attribute names will come
# across truncated when exported from QGIS as part of a shape file. 
# However, the current version of R gdal doesn't seem to handle multi-part geometries for gpkg files, so import CU boundaries 
# as an ESRI shape file here. 
data.CU.Spatial <- readOGR(dsn="data/All_Species_CU_Boundaries_Fraser.shp", layer="All_Species_CU_Boundaries_Fraser", stringsAsStrings(), verbose=F)

# stream selector network data
# Don't use ESRI shp for this! The lists of CUs and populations associated with the various stream segments will end up truncated.
data.Streams <- readOGR(dsn="data/SiteSelectorNetwork_Fraser.gpkg", layer="SiteSelectorNetwork_Fraser", stringsAsFactors=F, verbose=F)

# Lookup table for joining metrics and spatial information for CUs
data.CU.Lookup <- read.csv("data/CULookup.csv", stringsAsFactors = F)

# Lookup table for joining metrics and spatial information for Populations
data.Pop.Lookup <- read.csv("data/PopLookup.csv", stringsAsFactors = F)

# ** Fix the CU_ID field in the metrics and data files, as well as the map data to make CU IDs consistent across files
data.CU.MetricsSeries$CU_ID <- SubstituteValues('CU_MetricsData_CU_ID', 'CU_ID', data.CU.Lookup, data.CU.MetricsSeries$CU_ID)
data.CU.TimeSeries$CU_ID <- SubstituteValues('CU_TimeSeriesData_CU_ID', 'CU_ID', data.CU.Lookup, data.CU.TimeSeries$CU_ID)
data.CU.Spatial$CU_ID <- SubstituteValues('MapData_CU_ID', 'CU_ID', data.CU.Lookup, data.CU.Spatial$CU_INDEX)
data.Pop.TimeSeries$CU_ID <- SubstituteValues('Pop_TimeSeriesData_CU_ID', 'CU_ID', data.CU.Lookup, data.Pop.TimeSeries$CU_ID)
data.Pop.Spatial$CU_ID <- SubstituteValues('MapData_CU_ID', 'CU_ID', data.CU.Lookup, data.Pop.Spatial$CU_INDEX)
data.Pop.Lookup$CU_ID <- SubstituteValues('MapData_CU_ID', 'CU_ID', data.CU.Lookup, data.Pop.Lookup$MapData_CU_ID)
# script that builds selector network now translates CU info into current naming scheme, so translation below no longer
# necessary here
#data.streams@data$CUs <- unlist(lapply(data.streams@data$CUs, function(CUList) {
#  CUs <- strsplit(CUList, ':')[[1]]
#  CUs <- unique(SubstituteValues('MapData_CU_ID', 'CU_ID', data.CULookup, CUs))
#  if (length(CUs) > 0) {
#    paste(CUs, collapse=",")
#  } else {
#    ""
#  } 
#}))


#** Create a unique population ID, 'Pop_UID', consisting of CU_ID and Pop_ID, to be used across files.
# add the unique pop ID to the various files containing population data
# Pop Lookup file
data.Pop.Lookup$Pop_UID <- paste(data.Pop.Lookup$CU_ID, data.Pop.Lookup$Pop_ID, sep='.')
row.names(data.Pop.Lookup) <- data.Pop.Lookup$Pop_UID
# Spatial pop locations
data.Pop.Spatial$Pop_UID <- paste(data.Pop.Spatial$CU_ID, data.Pop.Spatial$POP_ID, sep='.')
popsToUse <- unlist(lapply(1:nrow(data.Pop.Spatial), function(r) {
    # some pop UIDs are duplicated in map; use site name as secondary criterion to select the one to use here
    data.Pop.Lookup[data.Pop.Spatial[r, "Pop_UID"], "MapData_Pop_Name"] == data.Pop.Spatial[r, "SITE_NAME"]
  }
))
data.Pop.Spatial <- data.Pop.Spatial[popsToUse, ]
rm(popsToUse)
row.names(data.Pop.Spatial) <- data.Pop.Spatial$Pop_UID
data.Pop.Spatial$Lat <- data.Pop.Spatial$YLAT
data.Pop.Spatial$Lon <- data.Pop.Spatial$XLONG
data.Pop.Spatial$FAZ <- data.Pop.Spatial$FAZ_ACRO
data.Pop.Spatial$Species <- data.Pop.Lookup[row.names(data.Pop.Spatial), 'Species']

# Population time series data
# right now, pop ID is missing for Coho, so we need to do a somewhat complicated lookup here, by either pop ID or by pop name 
# hopefully this is temporary and will be fixed as part of the data assembly process evantually
# Identify first data year for each time series. This is only done to avoid printing out warnings about id or name mismatches more than once.
# Should be removed in production version since it takes some time to run.
# data.Pop.TimeSeries$FirstYear <- apply(data.Pop.TimeSeries, 1, function(data.row, popData){
#   popID  <- as.numeric(data.row[['Pop_ID']])
#   if (!is.na(popID)) 
#     popDataRows <- !is.na(popData$Pop_ID) & popData$Pop_ID == popID & popData$DataSet == data.row[['DataSet']]
#   else
#     popDataRows <- popData$Pop_Name == data.row[['Pop_Name']] & popData$DataSet == data.row[['DataSet']]
#   all(as.numeric(popData[popDataRows, 'Year']) >= as.numeric(data.row[['Year']]))
#   
# }, data.Pop.TimeSeries)

data.Pop.TimeSeries$Pop_UID <- apply(data.Pop.TimeSeries, 1, function(data.row) {
  matches <- c(F)
  popID  <- as.numeric(data.row[['Pop_ID']])
  if (!is.na(popID)) { # lookup with Pop ID and species - this is the preferred way to match 
    matches <- data.Pop.Lookup$TimeSeriesData_Species == data.row[["DataSet"]] & as.numeric(data.Pop.Lookup$Pop_ID) == popID
    # check for potential name mismatch
    # if (data.row[["FirstYear"]]) {
    #   if(any(matches) && data.Pop.Lookup[matches, 'TimeSeriesData_Pop_Name'][1] != data.row[['Pop_Name']]) 
    #     cat("Warning: name mismatch for population ", data.row[["DataSet"]], ' - ', data.row[["Pop_Name"]], ' ( Pop ID: ', popID,
    #       '). Expected ', data.Pop.Lookup[matches, 'TimeSeriesData_Pop_Name'][1], '!\n')
    # }
  }
  else if (data.row[["Pop_Name"]] != "") {  # if no Pop ID available, try lookup with Pop Name and Species - temporary fix until Coho pop IDs integrated into data
    matches <- data.Pop.Lookup$TimeSeriesData_Species == data.row[["DataSet"]] & data.Pop.Lookup$TimeSeriesData_Pop_Name == data.row[["Pop_Name"]]
  }
  if (any(matches)) return(data.Pop.Lookup[matches, 'Pop_UID'][1])
  else {
    # if(data.row[["FirstYear"]])  # show warning only for first occurence
    #   cat("Warning: no match found in lookup file for population ",
    #       data.row[["DataSet"]], ' - ', data.row[["Pop_Name"]], ' ( Pop ID: ', popID, '). This population will not be selectable.\n')
    return("")
  }
})
data.Pop.TimeSeries <- data.Pop.TimeSeries[data.Pop.TimeSeries$Pop_UID != '', ]
data.Pop.TimeSeries$TS_Name <- data.Pop.TimeSeries$Pop_Name

# there are sometimes multiple time series for one pop UID
# get the names for those and add to pop lookup table
data.Pop.Lookup$tsNames <- rep('', nrow(data.Pop.Lookup))
for (p in unique(data.Pop.TimeSeries$Pop_UID)) {
  data.Pop.Lookup[p, 'tsNames'] <- paste(unique(data.Pop.TimeSeries[data.Pop.TimeSeries$Pop_UID == p, 'TS_Name']), collapse = ':')
  for (name in strsplit(data.Pop.Lookup[p, 'tsNames'], ':')[[1]]) {
    ds <- data.Pop.TimeSeries[data.Pop.TimeSeries$Pop_UID == p & data.Pop.TimeSeries$TS_Name == name, ]
    if(any(duplicated(ds[, 'Year'])))  {
        cat("Warning: population ", p, ' (', name, ' ) has duplicate enries in time series data\n')
        yr <- ds$Year[duplicated(ds$Year)][1]
        print(ds[ds$Year == yr, ])
    }
  }
  rm(ds)
}

#** Eliminate data not selectable (out of bounds or not properly identified etc)
data.CU.TimeSeries <- data.CU.TimeSeries[!is.na(data.CU.TimeSeries$CU_ID), ]
data.CU.MetricsSeries <- data.CU.MetricsSeries[!is.na(data.CU.MetricsSeries$CU_ID), ]
data.Pop.TimeSeries$Pop_Name <- data.Pop.Lookup[data.Pop.TimeSeries$Pop_UID, 'Pop_Name']
data.CU.Spatial <- data.CU.Spatial[!is.na(data.CU.Spatial$CU_ID), ]
# For the stream data: create a new field that only contains CUs in the current database
data.Streams$CUsSelectable <- unlist(lapply(data.Streams$CUs, function(CUs) {
  CUs <- strsplit(CUs, ':')[[1]]
  CUs <- CUs[CUs %in% data.CU.Lookup$CU_ID]
  if (length(CUs) > 0) paste(sort(CUs), collapse=",")
  else ""
}))
# ditto for populations
data.Streams$PopsSelectable <- unlist(lapply(data.Streams$SITES, function(sites) {
  sites <- strsplit(sites, ':')[[1]]
  sites <- sites[sites %in% data.Pop.Lookup$Pop_UID]
  if (length(sites) > 0) paste(sort(sites), collapse=",")
  else ""
}))
# Now prune the stream network to remove any streams that don't potentially select CUs in the current CU database
data.Streams <- data.Streams[data.Streams$CUsSelectable != "", ]

# add stream order to stream network
data.Streams$StreamOrder <- unlist(lapply(data.Streams$FWA_WATERSHED_CODE, function(code) {
  code <- gsub('(-000000)*$', '', code) # eliminate trailing zero segments
  length(strsplit(code, '-')[[1]])
}))
data.Streams <- data.Streams[order(data.Streams$StreamOrder, decreasing=T), ]
# strip the stream code to the 'non-zero' portion of the code
strip <- function(code) {gsub('(-000000)*$', '', code)}
# split a stream code into individual segments
getSegments <- function(code) {strsplit(code, '-')[[1]]}
data.Streams$Name <- ifelse(data.Streams$WS_NAME == '', strip(data.Streams$FWA_WATERSHED_CODE), data.Streams$WS_NAME) 


#** Rearrange the metrics data so all metrics are in columns and create an associated 'Status' metric for each main metric (labeled <metric>.Status)
data.CU.MetricsSeries.MetricNames <- unique(data.CU.MetricsSeries$Metric)
data.CU.MetricsSeries.StatusMetricNames <- paste(data.CU.MetricsSeries.MetricNames, 'Status', sep='.')
data.CU.Metrics <- unique(data.CU.MetricsSeries[, c("CU_ID", "DataType", "Year")])
row.names(data.CU.Metrics) <- paste(data.CU.Metrics$CU_ID, data.CU.Metrics$DataType, data.CU.Metrics$Year, sep=".")
for (l in unique(data.CU.Metrics$DataType)) {
  for (m in data.CU.MetricsSeries.MetricNames) {
    data.subs <- unique(data.CU.MetricsSeries[data.CU.MetricsSeries$Metric == m & data.CU.MetricsSeries$DataType == l, c('CU_ID', 'Year', 'Value', 'Status')])
    row.names(data.subs) <- paste(data.subs$CU_ID, l, data.subs$Year, sep='.')
    data.CU.Metrics[row.names(data.subs), m] <- data.subs$Value
    data.CU.Metrics[row.names(data.subs), paste(m, "Status", sep=".")] <- factor(data.subs$Status, levels=c('Red', 'Amber', 'Green'), ordered=T)
  }
}
rm(l, m)

# Identify data years present in CU metrics data
data.CU.Metrics.Years <- as.character(sort(unique(as.numeric(data.CU.Metrics$Year))))


#** Attach attributes from CU lookup to metrics file 
data.CU.Metrics <- merge(data.CU.Metrics, unique(data.CU.Lookup[ , c("CU_ID", "Species", "FAZ", "Area", "RunTiming", "LifeHistory", "AvGen")]), by=c("CU_ID"), all.x=T, all.y=F)
for (attrib in names(data.CU.Metrics)) {
  if (attrib %in% names(AttribLevels)) { 
    # turn this attribute into a factor with the specified ordering
    data.CU.Metrics[is.na(data.CU.Metrics[, attrib]), attrib] <- 'NA'
    data.CU.Metrics[, attrib] <- factor(as.character(data.CU.Metrics[, attrib]), levels = AttribLevels[[attrib]])
  }
}
row.names(data.CU.Metrics) <- paste(data.CU.Metrics$CU_ID, data.CU.Metrics$DataType, data.CU.Metrics$Year, sep=".")

# Attach attributes to CU polygon data
#data.CU.Spatial <- sp::merge(data.CU.Spatial, unique(data.CU.Lookup[ , c('CU_Name' , 'CU_ID', MapAttribs)]), by=c("CU_ID"), all.x=T, all.y=F)

# Eliminate unnecessary columns from map data
attribsToKeep <- c('CU_NAME', 'CU_ID')
data.CU.Spatial@data[, names(data.CU.Spatial)[!(names(data.CU.Spatial) %in% attribsToKeep)]] <- NULL
attribsToKeep <- c('Pop_UID', 'CU_ID', 'POP_ID', 'SITE_NAME', 'Species', 'Lat', 'Lon', 'FAZ', 'FWA_WATERSHED_KEY')
data.Pop.Spatial[ , names(data.Pop.Spatial)[!(names(data.Pop.Spatial) %in% attribsToKeep)]] <- NULL
rm(attribsToKeep)

# identify CUs and populations in dataset
data.CUs <- unique(data.CU.Lookup$CU_ID)
data.Pops <- unique(data.Pop.Lookup$Pop_UID)
data.Watersheds <- unique(data.Streams$FWA_WATERSHED_CODE)

# add information about availability of associated metrics and time-series data to lookup tables
getMinYr <- function(df) {if (nrow(df) > 0) min(df$Year) else NA}
getMaxYr <- function(df) {if (nrow(df) > 0) max(df$Year) else NA}
data.Pop.Lookup$HasTimeSeriesData <- unlist(lapply(data.Pop.Lookup$Pop_UID, function(uid) {if(uid %in% data.Pop.TimeSeries$Pop_UID) 'Yes' else 'No'}))
data.CU.Lookup$HasMetricsData <- unlist(lapply(data.CU.Lookup$CU_ID, function(cu_id) {if(cu_id %in% data.CU.MetricsSeries$CU_ID) 'Yes' else 'No'}))  
data.CU.Lookup$HasTimeSeriesData <- unlist(lapply(data.CU.Lookup$CU_ID, function(cu_id) {if(cu_id %in% data.CU.TimeSeries$CU_ID) 'Yes' else 'No'})) 
data.Pop.Lookup$DataStartYear <- unlist(lapply(data.Pop.Lookup$Pop_UID, function(p) {getMinYr(data.Pop.TimeSeries[data.Pop.TimeSeries$Pop_UID == p, ])}))
data.Pop.Lookup$DataEndYear <- unlist(lapply(data.Pop.Lookup$Pop_UID, function(p) {getMaxYr(data.Pop.TimeSeries[data.Pop.TimeSeries$Pop_UID == p, ])}))
data.CU.Lookup$DataStartYear <- unlist(lapply(data.CU.Lookup$CU_ID, function(CU) {getMinYr(data.CU.TimeSeries[data.CU.TimeSeries$CU_ID == CU, ])}))
data.CU.Lookup$DataEndYear <- unlist(lapply(data.CU.Lookup$CU_ID, function(CU) {getMaxYr(data.CU.TimeSeries[data.CU.TimeSeries$CU_ID == CU, ])}))

