# Var2Param

Discover hidden URL parameters from JavaScript variables for security testing.

## 🛠️ How It Works

- **Fetches** each URL from the input file
- **Extracts** JavaScript variable names
- **Filters** out invalid parameter names
- **Generates** URLs with XSS payloads
- **Saves** results to organized output file

## 🎯 Features

- **Smart Detection**: Extract parameters from `var`, `let`, `const`, and object properties
- **Multiple Payloads**: Generate XSS test payloads automatically  
- **Filtering**: Skip JavaScript built-in keywords and invalid parameter names
- **Beautiful Output**: Colored terminal output with progress indicators
- **Results Export**: Save findings to timestamped files

## 🚀 Usage

```bash
chmod +x js_param_extractor.sh
./js_param_extractor.sh urls.txt
```
## 🌟 Why this code is special:
- **Innovative idea** not many tools use this approach
- **Simple yet effective** does not rely on complex dependencies
- **Expandable** More styles can be added
- **Practical** Produces results that can be used immediately


