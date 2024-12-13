## 3.0.1

- docs: Update README.md.
- chore: Update Package to support latest dependencies

## 3.0.0

- feat: Added detection for slow internet connections. For detailed usage, refer to the example folder. ([#32](https://github.com/RounakTadvi/internet_connection_checker/issues/32))
- feat: Introduced the `requireAllAddressesToRespond` configuration to control the connectivity status determination. When enabled, InternetConnectionStatus.connected is emitted only if all specified addresses are reachable. If disabled, the status is emitted if any of the addresses is reachable.
- chore: Added an example demonstrating automatic page refresh when the internet connection becomes available.
- chore: Implemented a `dispose` method to prevent memory leaks.
- test: Achieved 100% code coverage, thereby improving the overall code quality.
- chore: Enhanced exception handling in the isHostReachable method for more robust error management.
- chore: Updated the validation criteria for internet availability to use HTTP status code range 100–599, ensuring server responses are properly handled.
- docs: Updated README snippets for better clarity and usage examples.
- fix: Ensured connectivity updates are emitted correctly when hasConnection is invoked. ([#43](https://github.com/RounakTadvi/internet_connection_checker/issues/43))
- fix: emit connection status only once in a scenario where the newly detected status is the same as the previous one. ([#35](https://github.com/RounakTadvi/internet_connection_checker/issues/35))

## 2.0.0

- Supports Android, iOS, MacOS, Web, Linux & Windows
- Added best usage example with bloc/cubit, check README.md to know more.
- Updated Documentation.
- Update dependencies to the latest release.
- Added Web Support. Implementation inspired by work from [OutdatedGuy](https://github.com/OutdatedGuy).

## 1.0.0+1

- Updated Documentation (README.md)

## 1.0.0

- **Breaking change**: Ability to provide a host name instead of IP address. Thanks [gampixi](https://github.com/gampixi)!. Update the AddressCheckOptions constructor if custom addresses are being used since the positional argument address is now a named, optional argument.
- Update dependencies to the latest release
  
## 0.0.1+4

- Add option to customize the interval, timeout, and network addresses. Thanks [Jop Middelkamp](https://github.com/jopmiddelkamp)!

## 0.0.1+3

- Add IPv6 hosts to the default addresses. Thanks [MrCsabaToth](https://github.com/MrCsabaToth)!
- Update dependencies to the latest release
- Documentation (minor documentation updates). Thanks [AleksandarSavic95](https://github.com/AleksandarSavic95)!
- Code refactor

## 0.0.1+2

- Reports that an internet connection is available as soon as one request succeeds instead of potentially waiting for the last to time out.
- Removed universal_io dependency

## 0.0.1+1

- Updated Documentation
- Update a dependency to the latest release.

## 0.0.1

- Initial Release (non-breaking change which adds functionality)
- Documentation (minor documentation updates)
- Code refactor
