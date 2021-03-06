#'Define a Data Layer
#'
#'Define a new data layer from an object sp.
#'
#'@param x a spatial object as defined in the package \pkg{sp}.
#'@param name a character string to name the layer.
#'@param label a reserved argument (in development).
#'@param popup a character vector giving contents for popups. HTML tags are accepted.
#'
#'@examples \dontrun{
#'  #POINTS
#'  data(velov)
#'  vv <- spLayer(velov, stroke=F, popup=velov$NAME)
#'
#'  #POLYGONS
#'  data(campsites)
#'  gcol <- rev(heat.colors(5))
#'  gcut <- cut(mapdep$N.CAMPSITES, breaks=c(-1, 20, 40, 60, 80, 1000))
#'  cs <- spLayer(campsites, fill.col=as.numeric(gcut))
#'  bm1 <- basemap("mapquest.map")
#'  
#'  writeMap(bm1, cs, vv)
#'}
#'@export
spLayer <- function(x, name=NULL, label, popup, ...){
  UseMethod("spLayer", x)
}

#'Define a Vector Data Layer
#'@export
spLayer.default <- function(x, ...){
  print("Error: x not recognized as Spatial* object")
}



#'Define a Vector Data Layer
#'
#'\itemize{
#'\item \code{spLayer.SpatialPoints} defines a new data layer from an object \code{SpatialPoints} or \code{SpatialPointsDataFrame}
#'\item \code{spLayer.SpatialLines} defines a new data layer from an object \code{SpatialLines} or \code{SpatialLinesDataFrame}
#'\item \code{spLayer.SpatialPolygons} defines a new data layer from an object \code{SpatialPolygons} or \code{SpatialPolygonsDataFrame}
#'}
#'
#'@param x a spatial object (see Details).
#'@param name a character string to name the layer.
#'@param size a numerical vector giving the size of points (radius in pixels).
#'@param png character vector giving the paths for the PNG icons.
#'If \code{NULL} (default), circles are drawn.
#'@param png.width,png.height numerical vectors giving the PNG icons dimensions on the map (in pixels).
#'@param stroke logical. Should a stroke be drawn along lines and polygons?
#'@param stroke.col a vector of any of the three kinds of \R color specifications to set strokes color.
#'@param stroke.lwd a numerical vector to set strokes width.
#'@param stroke.lty a character vector that defines the strokes dash patterns (See Details).
#'@param stroke.alpha a vector of numeric values in \eqn{[0, 1]} setting strokes opacity.
#'@param fill logical. Should points and polygons be filled?
#'@param fill.col a vector of any of the three kinds of \R color specifications to set fill colors.
#'@param fill.alpha a vector of numeric values in \eqn{[0, 1]} setting fill opacity.
#'@param label a reserved argument (in development).
#'@param popup a character vector giving contents for popups. HTML tags are accepted.
#'
#'@rdname splayer_methods
#'@export
spLayer.SpatialPoints <- function(x, name=NULL, png=NULL, size=5, png.width=15, png.height=15,
                                  stroke=T, stroke.col=1, stroke.lwd=1, stroke.lty=1, stroke.alpha=1,
                                  fill=T, fill.col=2, fill.alpha=0.5,
                                  label=NULL, popup="", popup.rmd = FALSE, ...){
    if(is.null(png)){
      
      if(!inherits(x, "SpatialPoints"))
        stop("x must be an object of class SpatialPoints or SpatialPointsDataFrame")
      
      spLayerControl(name=name, size=size,
                      stroke=stroke, stroke.col=stroke.col, stroke.lwd=stroke.lwd, stroke.lty=stroke.lty, stroke.alpha=stroke.alpha,
                      fill=fill, fill.col=fill.col, fill.alpha=fill.alpha)
      tested.index <- !sapply(list(size, stroke, stroke.col, stroke.lwd, stroke.lty, stroke.alpha,
                                   fill, fill.col, fill.alpha, label, popup), is.null)
      
      stroke.logical <- stroke
      fill.logical <- fill
      stroke <- paste("\"", tolower(as.character(stroke)), "\"", sep="")
      fill <- paste("\"", tolower(as.character(fill)), "\"", sep="")
      stroke.lty <- paste("\"", as.character(stroke.lty), "\"", sep="")
      
      tab.max <- length(x)
      tab <- list(size,
                  stroke, stroke.col, stroke.lwd, stroke.lty, stroke.alpha,
                  fill, fill.col, fill.alpha, label, popup)[tested.index]
      tab <- lapply(tab, rep, length.out=tab.max)
      
      tested.names <- c("size", "stroke", "strokeCol", "strokeLwd", "strokeLty", "strokeAlpha",
                        "fill", "fillCol", "fillAlpha", "label", "popup")[tested.index]
      names(tab) <- tested.names
      
      tab$name <- name
      tab$coords <- coordinates(x)
      
      tab$strokeCol[!stroke.logical] <- tab$strokeLwd[!stroke.logical] <- tab$strokeLty[!stroke.logical] <- 1
      tab$strokeAlpha[!stroke.logical] <- 0
      tab$strokeCol <- col2hexa(tab$strokeCol)
      
      tab$fillCol[!fill.logical] <- 1
      tab$fillAlpha[!fill.logical] <- 0
      tab$fillCol <- col2hexa(tab$fillCol)
      
      
      if (any(as.numeric(tab$strokeAlpha)<0) || any(as.numeric(tab$strokeAlpha)>1))
        stop("stroke.alpha must be comprise between 0 and 1")
      if (any(as.numeric(tab$strokeLwd)<0))
        stop("stroke.lwd must be positive")
      if (any(as.numeric(tab$fillAlpha)<0) || any(as.numeric(tab$fillAlpha)>1))
        stop("fill.alpha must be comprise between 0 and 1")
      
      if("label" %in% tested.names)
        tab$label <- paste("\"", as.character(tab$label), "\"", sep="")
      if("popup" %in% tested.names){
        if(popup.rmd){
          tab$popup <- sapply(as.vector(tab$popup), function(x) knit2html(output = NULL, text = x,
                                                    options = c('fragment_only', 'base64_images')))
          tab$popup <- gsub("\\n", "<br>", tab$popup)
          tab$popup <- gsub("\"", "\\\\\"", tab$popup)
        }
        tab$popup <- paste("\"", as.character(tab$popup), "\"", sep="")
      }
      class(tab) <- c("splpoints")
      return(tab)
      
    } else {
      
      if(!inherits(x, "SpatialPoints"))
        stop("x must be an object of class SpatialPoints or SpatialPointsDataFrame")
      
      spLayerControl(name=name)
      size <- paste("[", png.width, ",", png.height, "]", sep="")  
      tested.index <- !sapply(list(png, size, label, popup), is.null)
      
      tab.max <- length(x)
      tab <- list(png, size, label, popup)[tested.index]
      tab <- lapply(tab, rep, length.out=tab.max)
      
      tested.names <- c("png", "size", "label", "popup")[tested.index]
      names(tab) <- tested.names
      
      tab$name <- name
      tab$coords <- coordinates(x)
      
      if("label" %in% tested.names)
        tab$label <- paste("\"", as.character(tab$label), "\"", sep="")
      if("popup" %in% tested.names)
        tab$popup <- paste("\"", as.character(tab$popup), "\"", sep="")
      
      class(tab) <- c("splicons")
      return(tab)
    }
}

#'@rdname splayer_methods
#'@export
spLayer.SpatialLines <- function(x, name=NULL,
                                 stroke=T, stroke.col=1, stroke.lwd=1, stroke.lty=1, stroke.alpha=1,
                                 fill=T, fill.col=2, fill.alpha=0.5,
                                 label=NULL, popup="", ...){
  
  if(!inherits(x, "SpatialLines"))
    stop("x must be an object of class SpatialLines or SpatialLinesDataFrame")
  
  spLayerControl(name=name,
                  stroke=stroke, stroke.col=stroke.col, stroke.lwd=stroke.lwd, stroke.lty=stroke.lty, stroke.alpha=stroke.alpha)
  
  tested.index <- !sapply(list(stroke, stroke.col, stroke.lwd, stroke.lty, stroke.alpha,
                               label, popup), is.null)
  
  stroke.logical <- stroke
  stroke <- paste("\"", tolower(as.character(stroke)), "\"", sep="")
  stroke.lty <- paste("\"", as.character(stroke.lty), "\"", sep="")
  
  tab <- list(stroke, stroke.col, stroke.lwd, stroke.lty, stroke.alpha,
              label, popup)[tested.index]
  tab.max <- length(x)
  tab <- lapply(tab, rep, length.out=tab.max)
  
  tested.names <- c("stroke", "strokeCol", "strokeLwd", "strokeLty", "strokeAlpha",
                    "label", "popup")[tested.index]
  names(tab) <- tested.names
  
  tab$strokeCol[!stroke.logical] <- tab$strokeLwd[!stroke.logical] <- tab$strokeLty[!stroke.logical] <- 1
  tab$strokeAlpha[!stroke.logical] <- 0
  tab$strokeCol <- col2hexa(tab$strokeCol)
  
  tab$name <- name
  tab$coords <- coordinates(x)
  
  if (any(as.numeric(tab$strokeAlpha)<0) || any(as.numeric(tab$strokeAlpha)>1))
    stop("stroke.alpha must be comprise between 0 and 1")  
  if (any(as.numeric(tab$strokeLwd)<0))
    stop("stroke.lwd must be positive")
  
  if("label" %in% tested.names)
    tab$label <- paste("\"", as.character(tab$label), "\"", sep="")
  if("popup" %in% tested.names)
    tab$popup <- paste("\"", as.character(tab$popup), "\"", sep="")
  
  class(tab) <- c("spllines")
  return(tab)
}

#'@rdname splayer_methods
#'@export
spLayer.SpatialPolygons <- function(x, name=NULL,
                                    stroke=T, stroke.col=1, stroke.lwd=1, stroke.lty=1, stroke.alpha=1,
                                    fill=T, fill.col=2, fill.alpha=0.5,
                                    label=NULL, popup="", holes=FALSE){
  if(!inherits(x, "SpatialPolygons"))
    stop("x must be an object of class SpatialPolygons or SpatialPolygonsDataFrame")
  
  spLayerControl(name=name,
                  stroke=stroke, stroke.col=stroke.col, stroke.lwd=stroke.lwd, stroke.lty=stroke.lty, stroke.alpha=stroke.alpha,
                  fill=fill, fill.col=fill.col, fill.alpha=fill.alpha)
  
  tested.index <- !sapply(list(stroke, stroke.col, stroke.lwd, stroke.lty, stroke.alpha,
                               fill, fill.col, fill.alpha, label, popup), is.null)
  
  stroke.logical <- stroke
  fill.logical <- fill
  stroke <- paste("\"", tolower(as.character(stroke)), "\"", sep="")
  fill <- paste("\"", tolower(as.character(fill)), "\"", sep="")
  stroke.lty <- paste("\"", as.character(stroke.lty), "\"", sep="")
  
  tab <- list(stroke, stroke.col, stroke.lwd, stroke.lty, stroke.alpha,
              fill, fill.col, fill.alpha, label, popup)[tested.index]
  tab.max <- length(x)
  tab <- lapply(tab, rep, length.out=tab.max)
  
  tested.names <- c("stroke", "strokeCol", "strokeLwd", "strokeLty", "strokeAlpha",
                    "fill", "fillCol", "fillAlpha", "label", "popup")[tested.index]
  names(tab) <- tested.names
  
  tab$strokeCol[!stroke.logical] <- tab$strokeLwd[!stroke.logical] <- tab$strokeLty[!stroke.logical] <- 1
  tab$strokeAlpha[!stroke.logical] <- 0
  tab$strokeCol <- col2hexa(tab$strokeCol)
  
  tab$fillCol[!fill.logical] <- 1
  tab$fillAlpha[!fill.logical] <- 0
  tab$fillCol <- col2hexa(tab$fillCol)
  
  tab$name <- name
  tab$coords <- polycoords(x)
  if (holes){
    tab$holes <- polyholes(x)
    tab$order <- polyorder(x)
  } else {
    tab$holes <- tab$order <- NULL
  }
  
  if (any(as.numeric(tab$strokeAlpha)<0) || any(as.numeric(tab$strokeAlpha)>1))
    stop("stroke.alpha must be comprise between 0 and 1")  
  if (any(as.numeric(tab$strokeLwd)<0))
    stop("stroke.lwd must be positive")
  if (any(as.numeric(tab$fillAlpha)<0) || any(as.numeric(tab$fillAlpha)>1))
    stop("fill.alpha must be comprise between 0 and 1")
  
  if("label" %in% tested.names)
    tab$label <- paste("\"", as.character(tab$label), "\"", sep="")
  if("popup" %in% tested.names)
    tab$popup <- paste("\"", as.character(tab$popup), "\"", sep="")
  
  class(tab) <- c("splpolygons")
  return(tab)
  
}

#'Define a Raster Data Layer
#'
#'\code{spLayer.SpatialGridDataFrame} defines a new data layer from an object \code{SpatialGridDataFrame}.
#'
#'@param name a character string to name the layer.
#'@param x a spatial object (see Details).
#'@param layer which layer to select?
#'@param cells.col a vector of any of the three kinds of \R color specifications giving a gradient to color the grid.
#'@param cells.alpha a vector of numeric values in \eqn{[0, 1]} setting grid opacity.
#'@export
spLayer.SpatialGridDataFrame <- function(x, name=NULL,
                                         layer, cells.col=heat.colors(12), cells.alpha=1, ...){
  if(!inherits(x, "SpatialGridDataFrame"))
    stop("x must be an object of class SpatialGridDataFrame")
  spLayerControl(name=name)
  
  x <- x[layer]
  
  cells.col <- col2hexa(cells.col, alpha.channel=T, alpha=cells.alpha, charstring=FALSE)
  tab <- list(x=x, name=name, cells.col=cells.col)
  
  class(tab) <- c("splgrid")
  return(tab)
}
  

#' Testing user inputs
#'
#' This function tests arguments validity for the function \code{\link{spLayer}}.
#' 
spLayerControl <- function(name, size=1,
                            stroke=T, stroke.col=1, stroke.lwd=1, stroke.lty=1, stroke.alpha=1,
                            fill=T, fill.col=1, fill.alpha=1, label="", popup="", holes=F){
  if(!is.null(name)){
    if(is.vector(name) && length(name)==1){
      name <- as.character(name)
    }else{
      stop("name must be a single value character vector")
    }
  }
  if(!is.numeric(size)){
    stop("size must be numeric")
  }else{
    if(any(is.na(size)))
      stop(("Missing value for size not allowed"))
    if(any(size<0))
      stop("size must be positive")
  }
  if(!is.logical(stroke))
    stop("stroke must be set on TRUE or FALSE")
  
  if(!is.logical(fill))
    stop("fill must be set on TRUE or FALSE")
  
  if(!is.logical(holes))
    stop("holes must be set on TRUE or FALSE")
}


