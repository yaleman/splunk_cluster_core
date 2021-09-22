# place to shove bucket data
resource aws_s3_bucket splunk_data {
    bucket = var.data_bucket
    acl = "private"
    tags = merge(local.common_tags, {
        Name = "Splunk Index Data Store"
        description = "This holds all the data for Splunk. Delete it and we have bad days."
    })
}

# place to shove bucket data so it can be ingested by the indexers
# this can go away once the migration from the on premises servers has been done
# resource aws_s3_bucket migrator {
#     bucket = "splunk-index-migrator"
#     acl = "private"
#     tags = {
#         Name = "Splunk Migration Data Store"
#         Environment = "Dev"
#     }
# }


# place to shove bucket data
# resource aws_s3_bucket testbucket {
#     bucket = "${var.data_bucket}-testbucket"
#     acl = "private"
#     tags = merge(local.common_tags, {
#         Name = "Splunk Test Bucket Store"
#         environment = "dev"
#     })
# }



# which is for testing how I can just dump data onto the index tier and let it go to smart store
# resource aws_s3_bucket testdata {
#     bucket = "${var.data_bucket}-testdata"
#     acl = "private"
#     tags = merge(local.common_tags, {
#         environment = "dev"
#     })
# }
