# this policy allows access to the splunk index testbucket bucket, should be applied to the indexer which is going to pull the data and ingest it


# resource aws_iam_policy allow_full_bucket_testdata {
#   name        = "s3_full_splunk-index-testdata"
#   description = "Allows full access to the splunk-index-testdata bucket"

#   policy = templatefile("iam_policy_allow_full_bucket_testdata.tpl", { 
#     var = {
#         arn = join( "", [ "arn:aws:s3:::", aws_s3_bucket.testdata.bucket ])
#         }
#     }
#   )
# }

