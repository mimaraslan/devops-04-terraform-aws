resource "aws_iam_group_membership" "A_Team" {
  name = "tf-testing-group-membership"

  users = [
    aws_iam_user.user1.name,
    aws_iam_user.user2.name,
  ]

  group = aws_iam_group.group.name
}

resource "aws_iam_group" "group" {
  name = "DevSecOps-Test-Group"
}

resource "aws_iam_user" "user1" {
  name = "UnalBey"
}

resource "aws_iam_user" "user2" {
  name = "AydinBey"
}
