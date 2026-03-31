# Contributing to Gity

Thanks for your interest in contributing!

## How to Contribute

1. **Fork** the repository
2. **Clone** your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/gity.git
   cd gity
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes** — follow the code style (shell scripts, POSIX-compliant)
5. **Test** your changes:
   ```bash
   bash install.sh
   gity
   ```
6. **Commit** your changes:
   ```bash
   git add .
   git commit -m "Add: brief description of changes"
   ```
7. **Push** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
8. Open a **Pull Request**

## Guidelines

- Keep scripts **POSIX-compliant** (compatible with bash/dash)
- Test on **multiple distributions** if possible
- Update **documentation** if you add features
- Use **clear commit messages**
- Follow existing **code style**

## Reporting Issues

Open an issue with:
- Your distribution and version
- Steps to reproduce
- Expected vs actual behavior
- Any error messages

## Ideas for Contributions

- Support for custom scan directories via config file
- Themes / color customization
- Integration with other Git tools
- Better error handling
