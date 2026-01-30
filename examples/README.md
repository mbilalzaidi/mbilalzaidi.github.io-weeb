# Example Configuration Files

This directory contains ready-to-use configuration files and code examples for your VPS setup.

## 📁 Files Included

### Server Configuration

#### `nginx-config.conf`
Complete Nginx configuration with:
- HTTP to HTTPS redirect
- SSL certificate setup
- Reverse proxy for Ollama API
- Security headers
- Proper timeouts for AI requests

**Usage:**
```bash
sudo cp nginx-config.conf /etc/nginx/sites-available/learnwithus.cloud
sudo ln -s /etc/nginx/sites-available/learnwithus.cloud /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### `ollama.service`
Systemd service file for running Ollama as a background service.

**Usage:**
```bash
sudo cp ollama.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama
sudo systemctl status ollama
```

### Flutter Code

#### `ollama_service.dart`
A complete Flutter service class for communicating with your Ollama API. Features include:
- Generate AI responses
- List available models
- Health check endpoint
- Error handling
- Context-aware conversations

**Usage:**
1. Copy this file to your Flutter project: `lib/services/ollama_service.dart`
2. Update the `baseUrl` with your domain
3. Add the `http` package to your `pubspec.yaml`:
   ```yaml
   dependencies:
     http: ^1.1.0
   ```
4. Run `flutter pub get`

#### `chat_screen.dart`
A fully functional chat interface for Flutter with:
- Message bubbles (user and AI)
- Model selection
- Loading indicators
- Connection status
- Error handling
- Clear chat functionality
- Responsive design

**Usage:**
1. Copy this file to your Flutter project: `lib/screens/chat_screen.dart`
2. Make sure `ollama_service.dart` is in `lib/services/`
3. Import and use in your app:
   ```dart
   import 'screens/chat_screen.dart';
   
   // In your MaterialApp or Navigator:
   home: const ChatScreen(),
   ```

## 🚀 Quick Start

### Setting Up the Server

1. **Deploy Nginx configuration:**
   ```bash
   # Download the config
   wget https://raw.githubusercontent.com/mbilalzaidi/mbilalzaidi.github.io-weeb/main/examples/nginx-config.conf
   
   # Replace YOUR_DOMAIN with your actual domain
   sed -i 's/learnwithus.cloud/YOUR_DOMAIN/g' nginx-config.conf
   
   # Copy to Nginx
   sudo cp nginx-config.conf /etc/nginx/sites-available/YOUR_DOMAIN
   sudo ln -s /etc/nginx/sites-available/YOUR_DOMAIN /etc/nginx/sites-enabled/
   sudo nginx -t && sudo systemctl reload nginx
   ```

2. **Deploy Ollama service:**
   ```bash
   # Download the service file
   wget https://raw.githubusercontent.com/mbilalzaidi/mbilalzaidi.github.io-weeb/main/examples/ollama.service
   
   # Copy to systemd
   sudo cp ollama.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable ollama
   sudo systemctl start ollama
   ```

### Setting Up Flutter

1. **Create a new Flutter project (or use existing):**
   ```bash
   flutter create my_ollama_app
   cd my_ollama_app
   ```

2. **Add required dependencies:**
   ```bash
   # Add http package
   flutter pub add http
   ```

3. **Download the example files:**
   ```bash
   # Create directories
   mkdir -p lib/services lib/screens
   
   # Download service
   curl -o lib/services/ollama_service.dart \
     https://raw.githubusercontent.com/mbilalzaidi/mbilalzaidi.github.io-weeb/main/examples/ollama_service.dart
   
   # Download chat screen
   curl -o lib/screens/chat_screen.dart \
     https://raw.githubusercontent.com/mbilalzaidi/mbilalzaidi.github.io-weeb/main/examples/chat_screen.dart
   ```

4. **Update your domain in `ollama_service.dart`:**
   ```dart
   final String baseUrl = 'https://YOUR_DOMAIN/api';
   ```

5. **Update `lib/main.dart`:**
   ```dart
   import 'package:flutter/material.dart';
   import 'screens/chat_screen.dart';

   void main() {
     runApp(const MyApp());
   }

   class MyApp extends StatelessWidget {
     const MyApp({Key? key}) : super(key: key);

     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         title: 'Ollama Chat',
         theme: ThemeData(
           primarySwatch: Colors.deepPurple,
           useMaterial3: true,
         ),
         home: const ChatScreen(),
       );
     }
   }
   ```

6. **Add internet permission for Android:**
   Edit `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android">
       <uses-permission android:name="android.permission.INTERNET"/>
       <!-- ... rest of your manifest ... -->
   </manifest>
   ```

7. **Run your app:**
   ```bash
   flutter run
   ```

## 🔧 Customization

### Changing Colors
In `chat_screen.dart`, update the color scheme:
```dart
appBar: AppBar(
  backgroundColor: Colors.teal, // Change this
),
```

### Adding More Models
Models are automatically detected from your Ollama server. To add a new model on your server:
```bash
ssh user@your-server
ollama pull mistral  # or any other model
```

### Adjusting Timeouts
If your AI responses are slow, increase timeouts in `ollama_service.dart`:
```dart
final Duration timeout = const Duration(seconds: 300); // 5 minutes
```

And in `nginx-config.conf`:
```nginx
proxy_read_timeout 600;
proxy_connect_timeout 600;
proxy_send_timeout 600;
```

## 🐛 Troubleshooting

### "Cannot connect to Ollama service"
- Verify your server is running: `ssh user@server "sudo systemctl status ollama"`
- Check firewall allows HTTPS: `sudo ufw status`
- Test API manually: `curl https://your-domain.com/api/tags`

### "No models available"
- Pull a model on your server: `ollama pull llama2`
- Restart Ollama: `sudo systemctl restart ollama`

### SSL/Certificate errors
- Ensure SSL is set up: `sudo certbot certificates`
- Check certificate validity: `openssl s_client -connect your-domain.com:443`

### Flutter build errors
- Clean build: `flutter clean && flutter pub get`
- Check dependencies: `flutter doctor`
- Verify internet permission in AndroidManifest.xml

## 📚 Additional Resources

- [Ollama Documentation](https://github.com/ollama/ollama)
- [Flutter HTTP Package](https://pub.dev/packages/http)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)
- [Main Tutorial](../index.html)

## 💡 Tips

1. **Testing locally**: Use `http://localhost:11434/api` instead of your domain for local testing
2. **Debugging**: Add print statements in Flutter to see API responses
3. **Performance**: Consider using streaming responses for better UX with long outputs
4. **Security**: Always use HTTPS in production

---

Need help? Check the [main guide](../index.html) or open an issue!
