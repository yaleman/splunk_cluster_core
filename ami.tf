data aws_ami splunk {
	most_recent = true
  filter {
    name = "state"
    values = ["available"]
  }
   # aws ec2 describe-images --filter "Name=owner-alias,Values=aws-marketplace" "Name=name,Values=splunk*" "Name=state,Values=available"
  filter {
    name = "name"
    values = [
      local.aws_ami_filter
      ]
  }
	owners = [ "aws-marketplace" ]  # aws-marketplace
}

data aws_ami splunk_8_1_1 {
	most_recent = true
  filter {
    name = "state"
    values = ["available"]
  }
   # aws ec2 describe-images --filter "Name=owner-alias,Values=aws-marketplace" "Name=name,Values=splunk*" "Name=state,Values=available"
  filter {
    name = "name"
    values = [
      local.aws_ami_filter_8_1_1
      ]
  }
	owners = [ "aws-marketplace" ]  # aws-marketplace
}
