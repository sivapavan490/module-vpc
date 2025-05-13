    
# getting the data of how many availability zones are avilable in our region
data "aws_availability_zones" "available" {
  state = "available"
}