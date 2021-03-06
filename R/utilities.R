#' Internals functions
#'
#' These functions are used internally by \pkg{rleafmap}.
#'
#'@rdname internals
coords2json <- function(x, type, holes=NULL, order=NULL){   #x=coords; holes=booleans vector; type=class
  if(type=="splpoints"||type=="splicons"){
    res <- paste("[", x[,1], ", ", x[,2], "]", sep="")
  }
  if(type=="spllines"){
    res <- lapply(x, function(x) lapply(x, proclines))
    res <- lapply(res, function(x) do.call("paste", c(x, sep=", ")))
    res <- lapply(res, function(x) paste("[", x, "]", sep=""))
  }
  if(type=="splpolygons"){
    if(is.null(holes)){
      res <- lapply(x, function(x) lapply(x, procpolys))
      res <- lapply(res, function(x) do.call("paste", c(x, sep=", ")))
      res <- lapply(res, function(x) paste("[", x, "]", sep=""))
    } else {
      res <- lapply(x, function(x) lapply(x, procpolys))
      res <- mapply(function(a, b) a[b], a=res, b=order)
      holes <- mapply(function(a, b) a[b], a=holes, b=order)
      res <- mapply(holify, a=holes, b=res)
      res <- lapply(res, function(x) do.call("paste", c(x, sep=", ")))
      res <- lapply(res, function(x) paste("[", x, "]", sep=""))
    }
  }
  return(res)
}

#'@rdname internals
holify <- function(a, b){
  for(i in 1:length(a)){
    if (a[i]==T && i>1){
      b[i-1] <- substr(b[i-1], 1, nchar(b[i-1])-1)
      b[i] <- substr(b[i], 2, nchar(b[i]))
    }
  }
  return(b)
}

#'@rdname internals
polycoords <- function(x){  #Extrait les coordonnees d'un objet SpatialPolygons
  res <- x@polygons
  res <- lapply(res, function(x) x@Polygons)
  res <- lapply(res, function(x) lapply(x, coordinates))
  return(res)
}

#'@rdname internals
polyholes <- function(x){  #Extrait les slots 'hole' d'un objet SpatialPolygons
  res <- x@polygons
  res <- lapply(res, function(x) x@Polygons)
  res <- lapply(res, function(x) lapply(x, function(x) x@hole))
  return(res)
}

#'@rdname internals
polyorder <- function(x){  #Extrait les slots 'plotOrder' d'un objet SpatialPolygons
  res <- x@polygons
  res <- lapply(res, function(x) x@plotOrder)
  return(res)
}

#'@rdname internals
proclines <- function(x) {
  res <- paste("[", x[,1], ", ",x[,2], "]", sep="", collapse=", ")
  res <- paste("[", res, "]", sep="")
}

#'@rdname internals
procpolys <- function(x) {
  res <- paste("[", x[,1], ", ",x[,2], "]", sep="", collapse=", ")
  res <- paste("[[", res, "]]", sep="")
}

#'@rdname internals
pngasp <- function(x){ #x is an splgrid object
  xlim <- bbox(x$x)[1,]
  ylim <- bbox(x$x)[2,]
  asp <- (diff(ylim)/diff(xlim))/cos((mean(ylim) * pi)/180)
  names(asp) <- NULL
  return(asp)
}

#INUTILE ?
# exnames <- function(x, match.class){ #x is a list of spl objects, match.class is a vector of classes names to match
#   cl <- sapply(x, class)
#   x <- x[cl %in% match.class]
#   res <- unlist(sapply(x, function(x) x["name"]))
#   return(res)
# }

#'@rdname internals
class2var <- function(x){
  switch(x,
         "basemap"="BaseMap",
         "splpoints"="Points",
         "splicons"="Icons",
         "spllines"="Lines",
         "splpolygons"="Polygons",
         "splgrid"="Raster")
}

#'@rdname internals
xvarnames <- function(x){ #x est une liste d'objets spl
  xclass <- sapply(x, function(x) return(class(x)))
  xname <- sapply(x, function(x) return(x$name))
  xvarclass <- sapply(xclass, class2var)
  xvarname <- paste(safeVar(xname), xvarclass, sep="")
  res <- data.frame(xclass, xname, xvarname)
  return (res)
}

#'@rdname internals
safeVar <- function(x){
  x <- gsub("[^A-Za-z0-9]", "", x)
  test1 <- grepl("[0-9]", substr(x, 1, 1))
  substr(x[test1], 1, 1) <- letters[as.numeric(substr(x[test1], 1, 1))+1]

  if(any(x == "")){
    stop("Incorrect value for name")
  }
  return(x)
}

#'@rdname internals
cleanDepsub <- function(x){
  x <- paste(x, collapse="")
  x <- substr(x, 5, nchar(x))
  x <- gsub("\\(", "", x)
  x <- gsub("\\)", "", x)
  x <- gsub(" ", "", x)
  x <- strsplit(x, ",")
  return(x)
}

#' Convert colors to hexadecimal format
#'
#' This function converts any color of the \R system to hexadecimal format.
#' @param x a vector of any of the three kinds of \R color specifications.
#' @param alpha.channel logical. Sould an alpha channel included in the output?  Default is \code{FALSE}.
#' @param alpha a vector of numeric values in \eqn{[0, 1]}. Recycled if necessary.
#' @param charstring logical. Sould resulting elements be surrounded by quotation marks? Default is \code{TRUE}.
#' 
#' @return A character vector of hexadecimal values.
#' 
#' @seealso \code{\link[grDevices]{col2rgb}} for translating \R colors to RGB vectors.
#' @export
#' @keywords internal
col2hexa <- function(x, alpha.channel=FALSE, alpha=1, charstring=TRUE){
  col <- col2rgb(x)
  if(alpha.channel){
    alpha <- as.integer(alpha*255)
    col <- rgb(red=col[1,], green=col[2,], blue=col[3,], alpha=alpha, maxColorValue = 255)
  } else {
    col <- rgb(red=col[1,], green=col[2,], blue=col[3,], maxColorValue = 255)
  }
  if(charstring){
    col <- paste("\"", col, "\"", sep="")
  }
  return(col)
}


#' Basemap Tiles Servers
#' 
#' Print a list of tiles servers ready-to-use with \code{\link{basemap}}.
#' 
#' @param print.servers logical. Should the names of the servers be printed?
#' @return Returns invisibly a matrix with servers names, urls and credits.
#' @export
bmSource <- function(print.servers=TRUE){
  bm.source <- matrix(c(
                        "mapquest.map",             "http://otile1.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.jpg",
                        "mapquest.sat",             "http://otile1.mqcdn.com/tiles/1.0.0/sat/{z}/{x}/{y}.jpg",
                        "stamen.toner",             "http://tile.stamen.com/toner/{z}/{x}/{y}.jpg",
                        "stamen.toner.hybrid",      "http://tile.stamen.com/toner-hybrid/{z}/{x}/{y}.jpg",
                        "stamen.toner.labels",      "http://tile.stamen.com/toner-labels/{z}/{x}/{y}.jpg",
                        "stamen.toner.lines",       "http://tile.stamen.com/toner-lines/{z}/{x}/{y}.jpg",
                        "stamen.toner.background",  "http://tile.stamen.com/toner-background/{z}/{x}/{y}.jpg",
                        "stamen.toner.lite",        "http://tile.stamen.com/toner-lite/{z}/{x}/{y}.jpg",
                        "stamen.watercolor",        "http://tile.stamen.com/watercolor/{z}/{x}/{y}.jpg"
                      ), ncol=2, byrow=T)
  
  mapquest.tiles.cr <- "Tiles: <a href=\"http://www.mapquest.com/\" target=\"_blank\" title=\"Tiles Courtesy of MapQuest\">MapQuest</a>"
  stamen.tiles.cr <- "Tiles: <a href=\"http://stamen.com\" title=\"Map tiles by Stamen Design, under CC BY 3.0.\">Stamen Design</a>"
  osm.data.cr <- "Data: <a href=\"http://openstreetmap.org\" title=\"Data by OpenStreetMap, under CC BY SA\">OSM</a>"
  nasa.data.cr <- "Data: <a href=\"\" title=\"NASA/JPL-Caltech and U.S. Depart. of Agriculture, Farm Service Agency\">NASA...</a>"
  
  mapquest.map.cr <- paste(mapquest.tiles.cr, osm.data.cr, sep=" | ")
  mapquest.sat.cr <- paste(mapquest.tiles.cr, nasa.data.cr, sep=" | ")
  stamen.cr <- paste(stamen.tiles.cr, osm.data.cr, sep=" | ")
  vec.cr <- c(mapquest.map.cr, mapquest.sat.cr, rep(stamen.cr, 7))
  bm.source <- cbind(bm.source, vec.cr)
  if(print.servers){
    cat(paste(bm.source[,1], collapse="\n"))
  }
  invisible(bm.source)
}

#' Tiles Servers URL
#' 
#' Take a tiles server name (as returned by \code{\link{bmSource}}) and return its url.
#' 
#' @param x a character string of the name of the server.
#' @return The url of the server.
bmServer <- function(x){
  bm.source <- bmSource(print.servers=FALSE)
  res <- bm.source[bm.source[,1]==x,2]
  if(length(res) == 0L){
    res <- x
  }
  return(res)
}


#' Tiles Servers Attribution
#' 
#' Take a tiles server url and return its attribution.
#' 
#' @param x a character string of the url of the server.
#' @return The attribution of the server.
bmCredit <- function(x){
  bm.source <- bmSource(print.servers=FALSE)
  res <- bm.source[bm.source[,2]==x,3]
  if(length(res) == 0L){
    res <- NULL
  }
  return(res)
}