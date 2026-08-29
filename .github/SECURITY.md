# Security Policy

## Supported Versions

We release updates regularly. Only the latest version receives security updates.

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| < Latest| :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in Outside the Wire Character Generator, please report it responsibly:

### For Non-Critical Issues:
- Open a GitHub Issue with the "security" label
- Include steps to reproduce the vulnerability
- Provide any relevant logs or screenshots

### For Critical Security Issues:
- **DO NOT** open a public issue
- Email the maintainers directly (if private reporting is enabled)
- Include:
  - Description of the vulnerability
  - Steps to reproduce
  - Potential impact
  - Suggested fix (if any)

### What to Expect:
- **Initial Response**: Within 48 hours
- **Status Update**: Within 1 week
- **Resolution Timeline**: Depends on severity
  - Critical: Within 7 days
  - High: Within 14 days
  - Medium/Low: Within 30 days

## Security Best Practices

This application implements:
- ✅ Firebase Security Rules for data protection
- ✅ API key restrictions (platform-specific)
- ✅ Input validation and sanitization
- ✅ Automated dependency scanning via Dependabot
- ✅ Secret scanning for exposed credentials

### Firebase API Keys
Firebase API keys in this repository are **intentionally public** and safe:
- They identify the Firebase project, not authenticate users
- Security is enforced through Firebase Security Rules
- API keys are restricted to specific platforms/domains in Google Cloud Console
- See: [Firebase API Key Documentation](https://firebase.google.com/docs/projects/api-keys)

## Known Security Considerations

1. **Client-side application**: This is a Flutter app running on user devices
2. **Firebase backend**: Data security enforced via Firestore Security Rules
3. **No server-side secrets**: All authentication handled by Firebase Auth
4. **PDF generation**: Local-only, no data transmission

## Dependencies

We use Dependabot to monitor dependencies for security vulnerabilities. When alerts are detected:
1. Automated PR created to update vulnerable package
2. Review and test changes
3. Merge and release update promptly

## Contact

For security concerns, contact the repository maintainers through GitHub.
