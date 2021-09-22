# this policy allows access to the splunk index testbucket bucket, should be applied to the indexer which is going to pull the data and ingest it

# resource "aws_iam_policy" "allow_full_bucket_testbucket" {
#   name        = "s3_full_splunk-index-testbucket"
#   description = "Allows full access to the splunk-index-testbucket bucket"

#   policy = templatefile("iam_policy_allow_full_bucket_testbucket.tpl", { 
#     var = {
#         arn = join( "", [ "arn:aws:s3:::", aws_s3_bucket.testbucket.bucket ])
#         }
#     }
#   )
# }
