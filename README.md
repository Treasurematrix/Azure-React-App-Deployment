# Azure-React-App-Deployment
# Deploying a React Application on Microsoft Azure VM (Ubuntu + Nginx)

## Project Overview

This project demonstrates how to deploy a React Single Page Application (SPA) on a Microsoft Azure Virtual Machine running Ubuntu 20.04 LTS, using Nginx as the web server.

The deployment follows a production-style approach in which the React application is first compiled into optimised static files using `npm run build` and then served through Nginx.

The project was completed as part of **DevOps Micro Internship (DMI) – Week 8, Assignment 1**, focusing on Microsoft Azure infrastructure, Linux server administration, networking, application deployment and troubleshooting.

Rather than using the React development server (`npm start`), Nginx serves the generated production build.

## Project Objectives

The objectives of this assignment were to:

- Provision an Ubuntu Virtual Machine on Microsoft Azure.
- Create and manage Azure resources using a Resource Group.
- Configure network access using Network Security Groups (NSGs).
- Establish remote server access through SSH.
- Install Git, Node.js and npm.
- Clone and build a React application.
- Install and configure Nginx to serve the React production build.
- Configure Nginx to support Single Page Application routing.
- Verify the application through the VM's public IP address.
- Apply basic security practices.
- Troubleshoot and resolve deployment errors.

## Technologies and Tools

| Technology | Purpose |
|---|---|
| Microsoft Azure | Cloud infrastructure |
| Azure Portal | Resource provisioning and management |
| Azure Virtual Machine | Hosting environment |
| Ubuntu 20.04 LTS | Server operating system |
| Network Security Group (NSG) | Inbound network traffic control |
| SSH | Remote server administration |
| Git | Source code management |
| GitHub | Application source repository |
| Node.js | JavaScript runtime |
| npm | Dependency management and build tool |
| React | Frontend application framework |
| Nginx | Web server and static file hosting |
| Linux | Server administration and permissions |

## Architecture Overview

The deployment uses a straightforward cloud-hosted static application architecture.

```text
                 INTERNET
                    |
                    |
              User Browser
                    |
                    | HTTP (Port 80)
                    |
                    v
          Azure Public IP Address
                    |
                    v
       Network Security Group (NSG)
                    |
                    v
          Azure Virtual Machine
               Ubuntu 20.04
                    |
                    v
                  Nginx
                    |
                    v
          React Production Build
                    |
                    v
              build/index.html
                    |
                    v
             React Application
```

**Network access:**

- Port 22 – SSH access for remote administration.
- Port 80 – HTTP access for the deployed React application.

## Azure Infrastructure Configuration

The infrastructure was provisioned through the Microsoft Azure Portal.

| Configuration | Value |
|---|---|
| Resource Group | `react-app-rg` |
| Virtual Machine | `react-app-vm` |
| Operating System | Ubuntu 20.04 LTS |
| VM Size | B1s |
| Authentication | Username and password |
| VM Username | `chiomanwosu` |
| Web Server | Nginx |
| Application Port | 80 (HTTP) |
| Administration Port | 22 (SSH) |

The Azure Resource Group provides a logical container for managing the resources associated with the deployment.

### Network Security Configuration

A Network Security Group (NSG) was configured to control inbound access to the VM.

| Port | Protocol | Purpose |
|---|---|---|
| 22 | TCP | SSH remote administration |
| 80 | TCP | HTTP web traffic |

SSH access should be restricted to a trusted public IP address rather than exposed to the entire internet.

## Deployment Process

### Step 1: Create an Azure Resource Group

I created a Resource Group named:

`react-app-rg`

The Resource Group provides a logical way to organise and manage related Azure resources.

I used the Azure Portal to create and configure the resource group.

### Step 2: Provision the Ubuntu Virtual Machine

I created an Azure Virtual Machine with the following configuration:

- Ubuntu Server 20.04 LTS.
- B1s virtual machine size.
- Username: `chiomanwosu`.
- Password-based authentication.
- Public IP address enabled.

I also configured the required inbound networking rules through the VM's Network Security Group.

### Step 3: Connect to the VM Using SSH

After the VM was successfully provisioned, I connected remotely from my local terminal.

```bash
ssh chiomanwosu@<PUBLIC_IP>
```

I authenticated using the username and password configured during VM creation.

A successful SSH connection confirmed that remote administration was working.

### Step 4: Update Ubuntu and Install Dependencies

Before deploying the application, I updated the operating system packages.

```bash
sudo apt update && sudo apt upgrade -y
```

I installed Git:

```bash
sudo apt install -y git
```

Verify the installation:

```bash
git --version
```

I then installed Node.js and npm:

```bash
sudo apt install -y nodejs npm
```

Verify the installed versions:

```bash
node -v
npm -v
```

These tools are required to retrieve the source code, install project dependencies and generate the React production build.

### Step 5: Clone the React Application

I cloned the application repository from GitHub.

**Source repository:** https://github.com/pravinmishraaws/my-react-app

Commands:

```bash
cd ~

git clone https://github.com/pravinmishraaws/my-react-app.git

cd my-react-app
```

After cloning, I installed the application's dependencies.

```bash
npm install
```

This installed the packages defined in the project's `package.json` file.

### Step 6: Build the React Application

I generated the production build using:

```bash
npm run build
```

The build process compiled the React application into optimised static files.

I verified the generated files:

```bash
ls -la build
```

The output included files and directories such as:

```text
build/
├── asset-manifest.json
├── favicon.ico
├── index.html
├── logo192.png
├── logo512.png
├── manifest.json
├── robots.txt
└── static/
```

The `build/` directory contains the static assets required to serve the application.

### Step 7: Install and Configure Nginx

I installed Nginx:

```bash
sudo apt install -y nginx
```

I enabled the service to start automatically when the VM boots:

```bash
sudo systemctl enable nginx
```

I started Nginx:

```bash
sudo systemctl start nginx
```

I verified its status:

```bash
sudo systemctl status nginx --no-pager
```

### Configure Nginx

I edited the default Nginx site configuration:

```bash
sudo nano /etc/nginx/sites-available/default
```

The server configuration was updated to point to the React production build directory.

```nginx
server {
    listen 80;
    server_name _;

    root /home/chiomanwosu/my-react-app/build;
    index index.html;

    location / {
        try_files $uri /index.html;
    }
}
```

**Configuration explanation:**

- `listen 80;` – Nginx listens for incoming HTTP requests on port 80.
- `server_name _;` – Provides a default server name for requests.
- `root` – Specifies the location of the React production build.
- `index index.html;` – Defines the default page.
- `try_files $uri /index.html;` – Supports client-side routing by falling back to `index.html` when a requested file or route does not exist.

This is particularly important for React applications using client-side routing.

### Test and Reload Nginx

Before applying the configuration, I checked it for syntax errors:

```bash
sudo nginx -t
```

After successful validation, I reloaded Nginx:

```bash
sudo systemctl reload nginx
```

## Step 8: Test the Application

I accessed the application through the VM's public IP address.

```text
http://<PUBLIC_IP>
```

I verified that:

- The React homepage loaded successfully.
- The application was accessible over HTTP.
- Navigation worked as expected.
- The application was served by Nginx rather than the React development server.

## Troubleshooting: Errors Encountered and Solutions

One of the most valuable parts of this deployment was troubleshooting an Nginx permission error.

### Error 1: 500 Internal Server Error

**Observed error:**

```text
500 Internal Server Error
nginx/1.24.0 (Ubuntu)
```

The VM was accessible, and Nginx was running, but the React application was not loading in the browser.

#### Investigation

Instead of randomly changing the configuration, I inspected the Nginx error logs.

```bash
sudo tail -f /var/log/nginx/error.log
```

The logs revealed:

```text
stat() "/home/chiomanwosu/my-react-app/build/index.html"
failed (13: Permission denied)
```

Another message indicated:

```text
rewrite or internal redirection cycle while internally
redirecting to "/index.html"
```

#### Root Cause

The issue was caused by Linux filesystem permissions.

The React application files were owned by my Linux user:

```text
chiomanwosu
```

However, Nginx runs under a separate service account:

```text
www-data
```

Although the React build directory existed and contained `index.html`, Nginx could not access it because it lacked the necessary directory traversal permissions.

Linux requires execute permission on each parent directory in a file path to allow a user to traverse that directory.

#### Solution

**1. Allow directory traversal on the home directory.**

```bash
sudo chmod o+x /home/chiomanwosu
```

This allowed other users, including the Nginx service account, to traverse the home directory.

**2. Set appropriate permissions on the project directory.**

```bash
sudo chmod -R 755 /home/chiomanwosu/my-react-app
```

This provided directory traversal and file-reading permissions.

**3. Change ownership of the production build directory to Nginx.**

```bash
sudo chown -R www-data:www-data /home/chiomanwosu/my-react-app/build
```

This assigned ownership of the generated static files to the Nginx service account.

**4. Restart Nginx.**

```bash
sudo systemctl restart nginx
```

#### Outcome

After applying the permission corrections, I refreshed the browser and the React application loaded successfully through the VM's public IP address.

This troubleshooting experience helped me understand the relationship between Linux filesystem permissions, service accounts and web server access.

### Troubleshooting Commands Reference

These commands were useful during deployment and debugging:

| Command | Purpose |
|---|---|
| `sudo systemctl status nginx --no-pager` | Check Nginx service status |
| `sudo nginx -t` | Validate Nginx configuration |
| `sudo systemctl reload nginx` | Reload Nginx configuration |
| `sudo systemctl restart nginx` | Restart Nginx |
| `sudo tail -f /var/log/nginx/error.log` | Monitor Nginx error logs |
| `ls -la build` | Inspect build files and permissions |
| `ls -ld /home/chiomanwosu` | Inspect home directory permissions |
| `sudo ufw status` | Check Ubuntu firewall status |

## Security Considerations

The following security practices were considered during the deployment:

1. **Network Security Groups:** Only the required inbound ports (22 and 80) were configured for the assignment.
2. **SSH access:** Remote administration was performed through SSH. Restricting port 22 to a trusted source IP is recommended.
3. **Password authentication:** A strong, unique password should be used. SSH key-based authentication is generally preferable for production environments.
4. **Linux permissions:** File and directory permissions should follow the principle of least privilege.
5. **Firewall verification:** Ubuntu firewall status can be checked using `sudo ufw status`.

**Production improvement:** For a real production deployment, I would also consider HTTPS using TLS certificates, a dedicated web root such as `/var/www/`, automated deployment through CI/CD and stronger SSH access controls.

## Project Outcome

The deployment was completed successfully.

The React application was built on the Azure Ubuntu VM and served through Nginx. I verified public accessibility using the VM's public IP address and resolved the filesystem permission issue encountered during testing.

This project provided practical experience with:

- Microsoft Azure Virtual Machines.
- Azure Resource Groups and NSG configuration.
- Ubuntu server administration.
- SSH remote access.
- Git and Node.js.
- React production builds.
- Nginx configuration and static hosting.
- Linux permissions and ownership.
- Application troubleshooting and log analysis.

## Key Lessons Learned

This project reinforced an important lesson: successful cloud deployment involves more than provisioning infrastructure and uploading application files.

Understanding how networking, Linux permissions, service accounts and web servers interact is equally important.

The 500 Internal Server Error was particularly valuable because it required me to investigate the logs, identify the actual cause and apply a targeted solution rather than simply restarting services or changing configurations blindly.

## Acknowledgements

This project was completed as part of the **DevOps Micro Internship (DMI), Week 8 – Assignment 1**, under the guidance of Pravin Mishra.

Application source code: https://github.com/pravinmishraaws/my-react-app

## Author

**Chioma Nwosu**

Cloud Engineering | DevOps | AWS | Microsoft Azure | Linux

GitHub: https://github.com/Treasurematrix

LinkedIn: https://www.linkedin.com/in/chioma-nwosu-878788143/

---

*Learning in public, building practical cloud projects, and documenting the lessons along the way.*
