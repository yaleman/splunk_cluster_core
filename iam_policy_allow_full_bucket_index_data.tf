
resource aws_iam_policy allow_full_bucket_index_data {
  name        = "s3_full_${var.data_bucket}"
  description = "Allows full access to the ${aws_s3_bucket.splunk_data.bucket} bucket"

  policy = templatefile("iam_policy_allow_full_bucket_testdata.tpl", { 
    var = {
        arn = join( "", [ "arn:aws:s3:::", aws_s3_bucket.splunk_data.bucket ])
        }
    }
  )
}