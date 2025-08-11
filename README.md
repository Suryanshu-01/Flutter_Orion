# Orion Pay: A Teen Based Payments Application

---

## Drive Link  
Contains APK, demo video, and screenshots PDF:  
[*(Drive link)*](https://drive.google.com/drive/folders/1YMNh6KYzrfLt02lmxX_w0RTj2fhuYX52)

---

## Features Implemented

### Frontend

- **Theme:** Black and White  
- Splash Screen  
- Screen to Input Personal Details for User  
- PIN Setup for Security and Privacy  

#### In User’s Section

- **Orion Card:** Displays Balance, Personal QR Code, and different theme cards.  
- **QR Code Scanner:** Scans QR Code of other Orion Pay users.  
- **Transfer:** Transfer amount to another user using their mobile number.  
- **Transaction Verification:**  
  - Verifies if the user exists  
  - Checks Transaction PIN  
  - Allows selection of payment types (Entertainment, Food, Travel, Education, Miscellaneous)  
- **Coupons:** Claim coupons earned after transactions.  
- **Request:** Request money from the Admin.  
- **Transaction History:** View past transactions.  

#### Drawer Menu

- Home (Return to Home Screen)  
- Profile Manager (Shows Name, QR Code, Phone Number)  
- Admin/User Switch  
- Settings (Change Login & Transaction PINs)  
- About Us (Info about the Orion Pay team)  

---

### In Admin’s Section

- Security PIN for Admins only  
- Display User’s Name and Wallet Balance  
- Add Money → Add money to a user’s account  
- Block Transactions → Prevent money transfers through the app  
- Request Handling → Accept or decline user money requests  

---

### In Expense Manager

- User Summary → Displays Name and Wallet Balance  
- Monthly Expenses → Shows each month’s total expense; clicking a bar opens category breakdown (Bar Chart + Pie Chart)  
- Transaction History → Displays past transactions of the user  

---

## Backend

- Splash Screen implemented using JSON animation from Figma.  
- **Select_User Screen:** Choose User or Admin; if logged in, asks for PIN, otherwise navigates to input details.  
- **Firebase Storage:** Stores Wallet Balance, User ID, Transaction PIN, Login PIN, Phone Number, Gender, DOB, Name, Coupons (array), Theme Cards (array), Block Transaction (Boolean), Current Selected Card.  
- **Orion Card:**  
  - Displays selectable card image (updates Firebase)  
  - Generates QR Code with `qr_flutter`  
  - Shows Name and Wallet Balance from Firestore  
  - Displays unlocked cards collected via coupons  
- **QR Code Scanner:** Uses `mobile_scanner`; invalid codes show error, valid codes proceed to transfer  
- **Transfer Process:**  
  1. Recipient Identification: Input recipient’s registered phone number  
  2. Validation: Verify phone number in backend  
  3. Transaction Details: Specify amount and category  
  4. Security Authentication: Enter Transaction PIN  
  5. Processing & Completion: Confirm success to sender & recipient  
  6. Reward Allocation: 50% chance of receiving a digital coupon, added to dashboard automatically  
- **Coupon System:**  
  - Type 1: Brand coupons (random coupon code)  
  - Type 2: Theme card coupons (added to Orion Card)  
- **Request Feature:**  
  - Allowed only if no pending requests  
  - Admin can accept or reject requests  
- **Transaction History:**  
  - Fetch credits and debits  
  - Shows sender/receiver name, category, date, time, amount  
  - Expandable detail view  
- **Parent Dashboard (Admin):**  
  - Has its own security PIN  
  - Allows adding money, blocking transactions, managing requests  

---

## Expense Tracker Backend

- Stores expense data in Firestore, tagging each transaction by amount, category, date, and time  
- Logs category and amount under month-year for monthly summaries  
- **Monthly Expenses Screen:**  
  - Fetches aggregated monthly totals from Firestore  
  - Uses `fl_chart` to display totals as bar charts (one bar per month)  
- **Category Breakdown View:**  
  - Tapping month’s bar queries that month’s transactions  
  - Groups totals by category, shows bar chart and pie chart  
- **Details Screen:**  
  - Shows total monthly expense and transaction list (category, date, time, amount)  
- Real-time Firestore updates refresh charts and transaction history automatically  
- Swipe between pie chart and bar chart for category visualization  

---

## Technologies / Libraries / Packages Used

- [Lottie](https://pub.dev/packages/lottie) — For Figma-based Splash Screen  
- [Firebase](https://firebase.google.com/) — Database and Authentication  
- [Get](https://pub.dev/packages/get) — Route management  
- [Pinput](https://pub.dev/packages/pinput) — PIN verification  
- [Google Fonts](https://pub.dev/packages/google_fonts) — Font customization  
- [qr_flutter](https://pub.dev/packages/qr_flutter) — QR Code generation  
- [mobile_scanner](https://pub.dev/packages/mobile_scanner) — QR Code scanning  
- [animated_flip_counter](https://pub.dev/packages/animated_flip_counter) — Text animations  
- [fl_chart](https://pub.dev/packages/fl_chart) — Bar and Pie chart rendering  

---

## Team Members

- Kumar Suryanshu – 2024IMG-026  
- Prakhar Srivastava – 2024IMG-033  
- Aryan Singh – 2024IMT-013  

---



- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
