8byte-devops-assignment/
├── .github/
│   └── workflows/
│       └── deploy.yml           # CI/CD pipeline definition for GitHub Actions
├── terraform/
│   ├── main.tf                  # Core infrastructure (VPC, EC2, RDS, ALB)
│   ├── variables.tf             # Configurable parameters for Terraform
│   ├── outputs.tf               # Defines the outputs (e.g., ALB URL, DB Endpoint)
│   └── providers.tf             # AWS provider and S3 backend configuration
├── tests/
│   ├── __init__.py              # Makes the tests directory a package
│   └── test_main.py             # Unit tests executed by the CI/CD pipeline
├── main.py                      # The Python FastAPI LLM Routing application
├── requirements.txt             # Python dependencies (FastAPI, pytest, etc.)
├── Dockerfile                   # Instructions to containerize the Python application
├── README.md                    # Setup instructions, architecture, and cost details 
├── APPROACH.md                  # Rationale for technical decisions (EC2, GHCR, etc.) 
└── CHALLENGES.md                # Documentation of roadblocks and your resolutions