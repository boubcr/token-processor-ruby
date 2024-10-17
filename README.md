# Help Documentation for Company User Token Top-Up Processor

This Ruby project processes user and company data from JSON files to generate an output file recording token allocations and email statuses.

## Project Overview

The main objective of this application is to read user and company data from JSON files, process the data to allocate tokens based on specified conditions, and generate an output file.

### Files and Directories
- **Input Files**:
    - `users.json`: Contains user details.
    - `companies.json`: Contains company details.

- **Generated Output File**:
    - `output.txt`: File generated in the project directory after processing.

### Processing Criteria

- **Token Top-Up**: Active users receive a token increase specified in their company’s `top_up` field.
- **Email Status**:
    - If the company’s `email_status` is `true` and the user’s `email_status` is `true`, the user is marked as "emailed."
    - Users with `email_status` set to `false` are not marked as "emailed," regardless of the company’s email status.

- **Ordering**:
    - Companies are ordered by `company_id`.
    - Users are ordered alphabetically by `last_name`.

### Additional Information

- **Error Handling**: The application handles potentially malformed data and file read/write errors.
- **Code Structure**:
    - `challenge.rb`: Core file handling token allocation, sorting, and output generation.
    - **Custom Exceptions**: Handle file read/write issues.

## Requirements

- **Ruby Version**: Ruby 3.x or above
- **Dependencies**: Install any necessary dependencies with `bundle install`

## Running the Application

To run the application, navigate to the project directory and use the following command:

```bash
ruby challenge.rb
```

## Java Version
https://github.com/boubcr/token-processor-java
