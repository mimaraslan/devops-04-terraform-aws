resource "aws_iam_user" "my_soruce1" {
  name = "Ragip"

  tags = {
    tag-key = "DevOps"
    tecrube = "Uzman"
  }
}
