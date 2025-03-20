# Prime Number Finder

A sleek iOS app that helps you identify prime numbers and find prime factorizations. Built with SwiftUI, Cursor, and help from Claude and ChatGPT, Prime Number Finder combines mathematical utility with a modern, user-friendly interface.

## Features

- 🔢 Prime number checking
- ⚡️ Instant prime factorization
- 📱 Clean, modern UI
- 📖 History tracking of previous calculations
- 🎯 Input validation and filtering
- 💫 Smooth animations and transitions
- 📱 Haptic feedback for better user experience
- ♿️ Accessibility support

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+

## Installation

1. Clone the repository
```bash
git clone https://github.com/ahl-gram/PrimeFinderApp.git
```

2. Open the project in Xcode
```bash
cd PrimeFinderApp
open PrimeFinderApp.xcodeproj
```

3. Build and run the project in Xcode

## Usage

1. Enter any positive integer in the input field
2. Tap the "Check" button
3. The app will tell you if the number is prime
4. For composite numbers, it will show the prime factorization
5. Tap the chevron on composite numbers to see all factors.
6. View your calculation history by tapping the clock icon

## Features in Detail

### Prime Number Checking
- Efficiently determines if a number is prime
- Handles numbers up to 999,999,999,999,999,999
- Special handling for edge cases like 1

### Prime Factorization
- Quickly factorizes composite numbers
- Displays factors in a clear, readable format
- Uses the × symbol for better mathematical presentation

### History Tracking
- Keeps track of all calculations
- Displays results with timestamps
- Easy to clear history when needed

## Test Suite

The app includes a comprehensive test suite that ensures reliability and correctness:

### Unit Tests
- **Prime Number Validation**: Tests for correctly identifying prime and composite numbers
- **Prime Factorization**: Verifies accurate factorization of various numbers
- **Large Number Processing**: Tests performance with numbers up to 999,999,999,999,999,999

The test suite is continuously maintained and expanded.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/) 
