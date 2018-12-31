# a function adding the zscore column to the lsoa attribute table
# arguments: weighting values (12)
# output: an updated spatial polygon dataframe

indexcalculator <- function(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12){
  census_z$svi <- census_z[,2]*x1+census_z[,3]*x2+census_z[,4]*x3+census_z[,5]*x4+census_z[,6]*x5+census_z[,7]*x6+census_z[,8]*x7+census_z[,9]*x8+census_z[,10]*x9+census_z[,11]*x10+census_z[,12]*x11+census_z[,13]*x12
  svilist <- census_z[,c("GEO_CODE","svi")]
  lsoaboundary@data <- data.frame(lsoaboundary@data,svilist[match(lsoaboundary@data[,"LSOA11CD"],svilist[,"GEO_CODE"]),])
  return(lsoaboundary)
}