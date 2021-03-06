\name{spLayer.SpatialPoints}
\alias{spLayer.SpatialPoints}
\title{Define a Vector Data Layer}
\usage{
\method{spLayer}{SpatialPoints}(x, name = NULL, png = NULL, size = 1,
  png.width = 15, png.height = 15, stroke = T, stroke.col = 1,
  stroke.lwd = 1, stroke.lty = 1, stroke.alpha = 1, fill = T,
  fill.col = 2, fill.alpha = 0.5, label = NULL, popup = "")
}
\arguments{
  \item{x}{a spatial object (see Details).}

  \item{name}{a character string to name the layer.}

  \item{size}{a numerical vector giving the size of points
  (radius in pixels).}

  \item{png.width,png.height}{numerical vectors giving the
  PNG icons dimensions on the map (in pixels).}

  \item{stroke}{logical. Should a stroke be drawn along
  lines and polygons?}

  \item{stroke.col}{a vector of any of the three kinds of
  \R color specifications to set strokes color.}

  \item{stroke.lwd}{a numerical vector to set strokes
  width.}

  \item{stroke.lty}{a character vector that defines the
  strokes dash patterns (See Details).}

  \item{stroke.alpha}{a vector of numeric values in
  \eqn{[0, 1]} setting strokes opacity.}

  \item{fill}{logical. Should points and polygons be
  filled?}

  \item{fill.col}{a vector of any of the three kinds of \R
  color specifications to set fill colors.}

  \item{fill.alpha}{a vector of numeric values in \eqn{[0,
  1]} setting fill opacity.}

  \item{label}{a reserved argument (in development).}

  \item{popup}{a character vector giving contents for
  popups. HTML tags are accepted.}
}
\description{
\itemize{ \item \code{spLayer.SpatialPoints} defines a new
data layer from an object \code{SpatialPoints} or
\code{SpatialPointsDataFrame} \item
\code{spLayer.SpatialLines} defines a new data layer from
an object \code{SpatialLines} or
\code{SpatialLinesDataFrame} \item
\code{spLayer.SpatialPolygons} defines a new data layer
from an object \code{SpatialPolygons} or
\code{SpatialPolygonsDataFrame} }
}

