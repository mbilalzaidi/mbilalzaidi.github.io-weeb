# Quick Reference Card - VPS Setup

## 🔧 Essential Commands

### System Management
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Check service status
sudo systemctl status [service]

# Restart service
sudo systemctl restart [service]

# Enable service on boot
sudo systemctl enable [service]

# View service logs
sudo journalctl -u [service] -f
```

### Firewall (UFW)
```bash
# Check status
sudo ufw status

# Allow port
sudo ufw allow [port]/tcp

# Enable firewall
sudo ufw enable

# Disable firewall
sudo ufw disable
```

### Nginx
```bash
# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# View access logs
sudo tail -f /var/log/nginx/access.log

# View error logs
sudo tail -f /var/log/nginx/error.log
```

### Ollama
```bash
# List installed models
ollama list

# Pull a model
ollama pull [model-name]

# Remove a model
ollama rm [model-name]

# Run a model interactively
ollama run [model-name]

# Show running models
ollama ps

# Check Ollama service
sudo systemctl status ollama
```

### SSL/Certbot
```bash
# Get certificate
sudo certbot --nginx -d yourdomain.com

# Renew certificates
sudo certbot renew

# Test renewal
sudo certbot renew --dry-run

# List certificates
sudo certbot certificates
```

### System Monitoring
```bash
# Disk usage
df -h

# Memory usage
free -h

# CPU and process info
htop

# Network connections
sudo netstat -tulpn

# Check open ports
sudo ss -tulpn
```

### SSH
```bash
# Generate SSH key (local machine)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Copy key to server (local machine)
ssh-copy-id user@server-ip

# Connect to server
ssh user@server-ip

# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Restart SSH
sudo systemctl restart ssh
```

## 📝 Configuration Files

### Nginx Site Config
```
/etc/nginx/sites-available/your-domain.com
/etc/nginx/sites-enabled/your-domain.com
```

### Ollama Service
```
/etc/systemd/system/ollama.service
```

### Firewall
```
/etc/ufw/
```

### SSL Certificates
```
/etc/letsencrypt/live/your-domain.com/
```

## 🔍 Troubleshooting Checklist

### Website Not Loading
- [ ] Check if Nginx is running: `sudo systemctl status nginx`
- [ ] Check Nginx error logs: `sudo tail -f /var/log/nginx/error.log`
- [ ] Verify firewall allows port 80/443: `sudo ufw status`
- [ ] Test DNS resolution: `nslookup your-domain.com`
- [ ] Check Nginx configuration: `sudo nginx -t`

### Ollama Not Responding
- [ ] Check if Ollama is running: `sudo systemctl status ollama`
- [ ] Check Ollama logs: `sudo journalctl -u ollama -f`
- [ ] Test locally: `curl http://localhost:11434/api/tags`
- [ ] Verify port 11434 is open: `sudo ufw status`
- [ ] Restart Ollama: `sudo systemctl restart ollama`

### SSL Certificate Issues
- [ ] Check certificate status: `sudo certbot certificates`
- [ ] Verify DNS points to server: `nslookup your-domain.com`
- [ ] Check certificate expiry: `sudo certbot certificates`
- [ ] Renew certificate: `sudo certbot renew`
- [ ] Check Nginx config includes SSL: `sudo nginx -t`

### Flutter App Connection Issues
- [ ] Verify HTTPS works in browser
- [ ] Check correct API URL is used
- [ ] Verify internet permission in AndroidManifest.xml
- [ ] Check network connectivity on device
- [ ] Add error logging in Flutter app
- [ ] Test API with curl/Postman first

## 🌐 Important URLs

### Local Testing
```
http://localhost - Nginx default page
http://localhost:11434/api/tags - Ollama API
```

### Production
```
https://your-domain.com - Your website
https://your-domain.com/api/generate - Ollama API endpoint
```

## 📱 Flutter API Endpoints

### Generate Response
```dart
POST https://your-domain.com/api/generate
{
  "model": "llama2",
  "prompt": "Your question here",
  "stream": false
}
```

### List Models
```dart
GET https://your-domain.com/api/tags
```

### List Running Models
```dart
GET https://your-domain.com/api/ps
```

## 🔐 Security Best Practices

1. ✅ Use SSH keys instead of passwords
2. ✅ Disable root login via SSH
3. ✅ Keep system updated regularly
4. ✅ Use strong passwords
5. ✅ Enable firewall (UFW)
6. ✅ Use SSL certificates (HTTPS)
7. ✅ Regular backups
8. ✅ Monitor logs regularly
9. ✅ Limit sudo access
10. ✅ Use fail2ban for intrusion prevention

## 📊 Resource Usage

### Typical Resource Requirements
- **RAM**: Minimum 4GB (8GB recommended for Ollama)
- **CPU**: 2+ cores
- **Storage**: 20GB+ (models can be large)
- **Bandwidth**: Unlimited or high limit

## 🆘 Emergency Commands

### Service Not Starting
```bash
# Check what's using the port
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :11434

# Kill process on port
sudo kill -9 [PID]
```

### Out of Disk Space
```bash
# Check disk usage
df -h

# Find large files
du -ah / | sort -rh | head -20

# Clean apt cache
sudo apt clean

# Remove old logs
sudo journalctl --vacuum-time=7d
```

### Server Unresponsive
```bash
# Reboot server (from VPS control panel)
# Or via SSH if accessible
sudo reboot

# Check system load
uptime
top
```

---

**💡 Pro Tip**: Always test changes on a staging environment first, and keep backups before making major changes!
