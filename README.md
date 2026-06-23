# DevOps Pipeline — Terraform ile AWS

Bu depo, **Terraform** kullanarak AWS üzerinde temel kaynakları (IAM kullanıcıları, gruplar, S3 bucket) oluşturmayı öğreten bir ders çalışma alanıdır.

## CI/CD Evreni

```
CI/CD:           (Jenkins, Git, GitHub, GitOps, GitHub Actions, GitLab, GitLab CI, Bitbucket, Bamboo)
Scripting:       (Python, Bash, PowerShell)
Containers:      (Docker)
Orchestration:   (Kubernetes, Helm, ArgoCD)
Cloud:           (AWS, Azure, GCP)
Virtualization:  (VMware, VirtualBox)
IaC:             (Terraform, Ansible, CloudFormation)
Monitoring:      (Prometheus, Grafana, ELK)
```

---

![terraform-logo.png](terraform-logo.png)

## Terraform Nedir?

**Terraform**, HashiCorp tarafından geliştirilen açık kaynaklı bir **Altyapı Kodu (IaC — Infrastructure as Code)** aracıdır. Bulut sağlayıcılarındaki (AWS, Azure, GCP vb.) kaynakları `.tf` uzantılı dosyalarda tanımlar; bu tanımları okuyarak altyapıyı oluşturur, günceller veya siler.

**Temel kavramlar:**

| Kavram | Açıklama |
|--------|----------|
| **Provider** | Hangi bulut sağlayıcısıyla çalışılacağını belirler (ör. `hashicorp/aws`) |
| **Resource** | Oluşturulacak kaynak (IAM kullanıcısı, S3 bucket vb.) |
| **State** | Terraform'un oluşturduğu kaynakları takip ettiği durum dosyası (`terraform.tfstate`) |
| **Plan** | Uygulamadan önce yapılacak değişikliklerin önizlemesi |
| **Apply** | Planı AWS'e uygulama |

---

## Ön Gereksinimler

### AWS CLI

AWS hesabınıza komut satırından erişmek için AWS CLI kurulmalıdır.

- Kurulum: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Kurulum sonrası sürümü kontrol edin:

```bash
aws --version
```

### Terraform

- Kurulum (Linux): https://developer.hashicorp.com/terraform/install#linux
- Kurulum (Windows): https://developer.hashicorp.com/terraform/install#windows

Kurulum sonrası:

```bash
terraform version
```

---

## Proje Yapısı

```
devops-04-terraform-aws/
├── _02_setups.sh              # Amazon Linux üzerinde sistem güncelleme komutları
├── _03_group.tf               # IAM grubu tanımı
├── _04_user.tf                # IAM kullanıcısı tanımı
├── _05_group_membership.tf    # Kullanıcıları gruba ekleme
├── _06_s3_bucket.tf           # S3 bucket tanımı
└── my-provider.tf             # AWS provider ve bölge ayarı (oluşturulacak)
```

### Dosya Açıklamaları

| Dosya | Ne Yapar? |
|-------|-----------|
| `_04_user.tf` | AWS IAM üzerinde tek bir kullanıcı oluşturur (`Ragip`). Etiketlerle ortam bilgisi eklenir. |
| `_03_group.tf` | `developers` adında bir IAM grubu tanımlar. |
| `_05_group_membership.tf` | İki kullanıcı (`UnalBey`, `AydinBey`) oluşturur ve bunları `DevSecOps-Test-Group` grubuna ekler. |
| `_06_s3_bucket.tf` | Geliştirme ortamı için etiketli bir S3 bucket oluşturur. |
| `my-provider.tf` | Terraform'a AWS sağlayıcısını ve çalışılacak bölgeyi (`us-east-1`) bildirir. **Bu dosya olmadan Terraform AWS'e bağlanamaz.** |

---

## Kurulum — Amazon Linux (EC2)

### 1. EC2 Makinesi Oluşturma

Amazon Linux tabanlı bir EC2 örneği oluşturun. SSH bağlantısı için MobaXterm veya benzeri bir terminal istemcisi kullanabilirsiniz.

- Varsayılan kullanıcı adı: `ec2-user`

### 2. Terraform Kurulumu

```bash
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install terraform
```

Kurulumu doğrulayın:

```bash
terraform version
```

### 3. Çalışma Alanı Oluşturma

```bash
pwd                                    # Bulunduğunuz dizini gösterir
mkdir my-workspace-terraform           # Yeni klasör oluşturur
cd my-workspace-terraform              # Klasöre girer
```

---

## Terraform Temel Komutları

Aşağıdaki komutlar her Terraform projesinde sırasıyla kullanılır.

| Komut | Açıklama |
|-------|----------|
| `terraform init` | Provider'ları indirir ve çalışma alanını hazırlar. **Her projede bir kez çalıştırılır.** |
| `terraform validate` | `.tf` dosyalarının sözdizimini kontrol eder. Çalıştırmak zorunlu değildir. |
| `terraform fmt` | Dosyaların biçimini Terraform standartlarına göre düzeltir. |
| `terraform plan` | Yapılacak değişiklikleri önizler; henüz AWS'e uygulanmaz. |
| `terraform apply` | Planı onayladıktan sonra AWS'e uygular. |
| `terraform apply -auto-approve` | Onay sormadan (`yes` yazmadan) doğrudan uygular. |
| `terraform destroy` | Terraform'un oluşturduğu tüm kaynakları siler. |

**Tipik iş akışı:**

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

---

## Ders Adımları (EC2 Üzerinde)

### Adım 1 — IAM Kullanıcısı Oluşturma

Dokümantasyon: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user

```bash
nano my-user.tf
# veya
vi my-user.tf
```

`vi` editöründe yazmak için `i` tuşuna basın; kaydetmek için `ESC` ardından `:wq` yazıp Enter'a basın.

```hcl
resource "aws_iam_user" "my_resource1" {
  name = "Tolga"
  path = "/"

  tags = {
    tag-key     = "Yazilim"
    environment = "Dev"
  }
}
```

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

### Adım 2 — IAM Grubu Oluşturma

Dokümantasyon: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group

```bash
vi group.tf
```

```hcl
resource "aws_iam_group" "arge" {
  name = "arge"
}
```

```bash
terraform fmt          # Dosya biçimini düzeltir
terraform plan
terraform apply -auto-approve
```

### Adım 3 — Kullanıcıları Gruba Ekleme

Dokümantasyon: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership

```bash
vi my-group-membership.tf
```

```hcl
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
```

```bash
terraform plan
terraform apply
```

### Adım 4 — S3 Bucket Oluşturma

```bash
vi my-bucket.tf
```

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
```

> **Not:** S3 bucket adları global olarak benzersiz olmalıdır. Aynı isim başka bir hesapta kullanılıyorsa hata alırsınız.

```bash
terraform plan
terraform apply
```

### Adım 5 — AWS Provider Tanımlama

Provider, Terraform'un hangi bulut sağlayıcısı ve bölgede çalışacağını belirler.

Dokümantasyon: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

```bash
vi my-provider.tf
```

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

```bash
terraform init    # Provider değişince tekrar çalıştırın
terraform plan
terraform apply
```

### Kaynakları Temizleme

Ders sonunda oluşturulan tüm kaynakları silmek için:

```bash
terraform destroy
```

---

## Kurulum — Yerel Makine (Windows)

### 1. Gerekli Araçlar

| Araç | Açıklama |
|------|----------|
| **AWS CLI** | AWS hesabına bağlanmak için |
| **Terraform** | Altyapı kodlarını çalıştırmak için |
| **VS Code** | Kod düzenleyici; Terraform eklenti paketi önerilir |

- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Terraform (Windows): https://developer.hashicorp.com/terraform/install#windows
- VS Code eklenti paketi: https://marketplace.visualstudio.com/items?itemName=dannysteenman.aws-terraform-extension-pack

Terraform kurulumundan sonra `PATH` ortam değişkenine eklendiğinden emin olun.

### 2. Çalışma Alanı

Bu depoyu yerel makinenize klonlayın veya EC2'deki `.tf` dosyalarını şu dizine kopyalayın:

```
D:\workspace\devops\devops-04-terraform-aws
```

### 3. AWS Kimlik Bilgileri

Terminalden AWS hesabınıza bağlanın:

```bash
aws configure
```

Sırasıyla istenecek bilgiler:

| Alan | Açıklama |
|------|----------|
| AWS Access Key ID | IAM kullanıcısının erişim anahtarı |
| AWS Secret Access Key | Gizli anahtar |
| Default region name | Örn. `us-east-1` |
| Default output format | Genelde `json` |

### 4. Terraform'u Çalıştırma

```bash
cd D:\workspace\devops\devops-04-terraform-aws
terraform init
```

`my-provider.tf` dosyasını oluşturun (yukarıdaki provider kodunu kullanın):

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

```bash
terraform plan
terraform apply
```

Kaynakları silmek için:

```bash
terraform destroy
```

---

## Sık Karşılaşılan Hatalar

| Hata | Olası Çözüm |
|------|-------------|
| `Error: No valid credential sources found` | `aws configure` ile kimlik bilgilerini girin |
| `Error: creating S3 Bucket: BucketAlreadyExists` | Bucket adını benzersiz yapın |
| `Error: Provider configuration not present` | `my-provider.tf` dosyasını oluşturup `terraform init` çalıştırın |
| `Error: Required plugins are not installed` | `terraform init` komutunu çalıştırın |

---

## Faydalı Bağlantılar

- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- IAM User: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user
- IAM Group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group
- IAM Group Membership: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership
- S3 Bucket: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
