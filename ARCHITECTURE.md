<!--- This file contains the architecture planned for each stage of the project. -->
# Faith and Grow - Flutter Mobile App Architecture

## Overview
Faith and Grow is a mobile application designed for Christian business entrepreneurs. The app provides a community platform, learning resources, and business networking opportunities in a spiritually uplifting environment. The design will incorporate the brand colors from the logo: black, gold, and green.

## Core Features (MVP)
1. User Authentication (Login/Registration screens)
2. Community Feed (post creation, viewing, and interaction)
3. Learning Module Access (courses, modules, lessons)
4. Business Directory (view and search business listings)
5. User Profile Management

## Technical Constraints
- Maximum 10-12 files total
- Use shared_preferences for local storage of user data and app state
- Material Design UI components with custom branding
- Offline capability for viewed content

## File Structure

### 1. `lib/main.dart`
Entry point of the application that sets up the theme and routing.

### 2. `lib/theme.dart` (existing)
Contains the app's theme configuration, which will be updated to match the Faith and Grow branding.

### 3. `lib/models/user_model.dart`
Defines the User class and related functionality:
- User properties (name, email, profile image, business info)
- Authentication state management
- Local storage of user data

### 4. `lib/models/content_model.dart`
Defines data models for:
- Community posts
- Courses and learning modules
- Business directory listings

### 5. `lib/services/data_service.dart`
Handles all data operations:
- Fetching and storing community posts
- Managing learning content
- Accessing business directory data
- Includes mock data generation for MVP

### 6. `lib/screens/home_screen.dart`
Implements the app's main navigation hub with:
- Bottom navigation bar for accessing main features
- Dashboard overview with quick access to recent activity
- Widgets for stats and featured content

### 7. `lib/screens/community_screen.dart`
Implements the community feed:
- Post listing with engagement metrics
- Post creation functionality
- Comment viewing and interaction

### 8. `lib/screens/learning_screen.dart`
Displays available courses and learning content:
- Course listings with progress tracking
- Module and lesson navigation
- Content viewing (text, embedded video links)

### 9. `lib/screens/directory_screen.dart`
Implements the business directory:
- Business listing cards with key information
- Search and filter functionality
- Detailed business profile view

### 10. `lib/screens/profile_screen.dart`
Manages user profile:
- Profile information display and editing
- Account settings
- Progress tracking across learning modules

### 11. `lib/screens/auth_screen.dart`
Handles user authentication:
- Login form
- Registration form
- Password reset functionality

### 12. `lib/widgets/common_widgets.dart`
Contains reusable UI components used across the app:
- Custom buttons and cards
- Post and comment widgets
- Course and business listing cards
- Loading indicators and error messages

## Implementation Plan

### Phase 1: Foundation Setup
1. Update theme.dart with Faith and Grow branding colors
2. Implement models for user and content data
3. Create the data service with mock data
4. Set up the main app structure and navigation

### Phase 2: Core Screens
1. Implement authentication screen
2. Build the home screen dashboard
3. Create the community feed screen
4. Develop the learning modules screen
5. Implement the business directory screen
6. Build the user profile screen

### Phase 3: Finishing Touches
1. Ensure consistent styling across all screens
2. Implement data persistence using shared_preferences
3. Add loading states and error handling
4. Test the app for usability and performance
5. Debug any issues with app compilation

## Debugging
After completion, we'll compile the project and fix any issues that arise.

## Future Enhancements (Beyond MVP)
1. Backend integration for real-time data
2. Push notifications for community engagement
3. Advanced filtering and search capabilities
4. Analytics for user engagement and learning progress
5. CRM integration features

Total Files: 12 (meeting the constraint)
-------------------------------------------------------------------
# Faith and Grow App Enhancement: Community Creation & Monetization

## Overview
We will enhance the existing "Faith and Grow" Flutter app by adding community creation and monetization features. This will allow users to not only participate in the main community but also create their own sub-communities with tiered membership plans. This functionality is inspired by Skool.com and will give Christian business entrepreneurs the ability to monetize their expertise while building specialized communities.

## Core Features to Implement
1. Community Discovery - Browse and search for user-created communities
2. Community Creation Flow - Create communities with basic info and 3-tier pricing
3. Community Joining & Payment - Join communities by selecting a membership tier
4. Community Management - For creators to manage their communities and content
5. Tiered Access Control - Restrict content based on membership tiers

## Technical Constraints
- Maximum 10-12 files total
- Use shared_preferences for local storage of community and membership data
- Material Design with Faith and Grow branding (green, gold, black)
- Mock payment processing (no actual payment gateway integration)

## File Structure

### 1. `lib/models/community_model.dart`
Defines data models for:
- Community (name, description, cover image, creator, tiers)
- CommunityTier (name, price, features)
- CommunityMembership (links users to communities and their subscribed tier)

### 2. `lib/services/community_service.dart`
Handles all community-related data operations:
- Creating and storing communities
- Managing community memberships
- Fetching communities and filtering
- Mock payment processing for joining communities

### 3. `lib/screens/community_discovery_screen.dart`
Implements discovery of user-created communities:
- Browse communities with search and filter functionality
- Display communities as cards with basic info and lowest tier price
- Navigation to community details

### 4. `lib/screens/community_creation_screen.dart`
Implements the community creation flow:
- Step 1: Basic community info (name, description, image)
- Step 2: Three-tier pricing setup
- Step 3: Confirmation and launch

### 5. `lib/screens/community_detail_screen.dart`
Shows details of a specific community to non-members:
- Community info (cover image, name, description)
- Membership tiers with pricing
- Join/Subscribe buttons for each tier

### 6. `lib/screens/community_dashboard_screen.dart`
The main screen for a joined community:
- Community-specific posts and content
- Access to learning modules based on tier
- Community management features for creators

### 7. `lib/widgets/community_widgets.dart`
Reusable UI components for the community features:
- Community cards for discovery
- Tier selection and display widgets
- Community management interface components

### 8. Update existing files:
- `lib/models/user_model.dart` - Add fields for owned communities and memberships
- `lib/screens/home_screen.dart` - Add navigation to new community features
- `lib/screens/profile_screen.dart` - Show communities the user owns or has joined

## Implementation Plan

### Phase 1: Data Models and Services
1. Create community_model.dart with required data structures
2. Update user_model.dart to include community-related fields
3. Implement community_service.dart with CRUD operations and mock data

### Phase 2: Community Discovery and Detail
1. Create community_discovery_screen.dart for browsing communities
2. Implement community_detail_screen.dart to view community info and tiers
3. Create community widgets for consistent UI

### Phase 3: Community Creation and Management
1. Implement community_creation_screen.dart with step flow
2. Create community_dashboard_screen.dart for members and creators
3. Add tier-based access control to community content

### Phase 4: Integration with Existing App
1. Update home_screen.dart to include community discovery and creation
2. Enhance profile_screen.dart to show community memberships and ownership
3. Ensure navigation flows seamlessly between existing and new features

### Phase 5: Testing and Refinement
1. Test the complete flow from discovery to creation to joining
2. Verify tier-based access controls work correctly
3. Debug any issues with the app compilation

## Template Files Needed
- image_upload (for community cover images)

Total Files: 11 (within the constraint of 10-12 files)
-------------------------------------------------------------------
# Faith and Grow - Community Discovery Enhancement

## Overview
This implementation will enhance the Faith and Grow app by ensuring specific communities are visible in the public browse section. We'll focus on updating the community service to properly fetch, display, and manage these predefined communities.

## Core Features
1. Add featured communities to the app's local storage
2. Ensure these communities appear in the Community Discovery screen
3. Mark these communities as published for proper visibility
4. Update the community service to properly handle community status

## Technical Constraints
- Maximum 10-12 files total (will modify existing files)
- Use shared_preferences for local data persistence
- Follow Faith and Grow branding (green, gold, black)

## Implementation Plan

### 1. Update Community Service
Modify the community service to:
- Ensure the predefined communities are added to local storage upon first app launch
- Add proper handling to filter for published communities
- Update methods to check for community visibility status

### 2. Update Community Model
Ensure the Community model handles the `isPublished` flag correctly so communities can be properly filtered in the discovery screen.

### 3. Update Community Discovery Screen
Enhance the community discovery screen to properly display the published communities and filter them accordingly.

### 4. Community Data Initialization
Create a service or method to initialize the community data with the provided JSON.

## File Modifications

### 1. `lib/services/community_service.dart`
Update this file to handle the initial data loading of communities and ensure proper publishing status checks.

### 2. `lib/models/community_model.dart`
Ensure proper handling of the `isPublished` flag.

### 3. `lib/screens/community_discovery_screen.dart`
Update to properly display published communities.

### 4. `lib/main.dart`
Add initialization of featured communities data when the app starts.

### 5. `lib/services/data_initializer.dart` (new file)
Create this file to handle the initialization of predefined community data.

## Implementation Steps

1. Create `data_initializer.dart` to handle loading the predefined communities into local storage
2. Update `community_service.dart` to ensure published communities are properly handled
3. Update `main.dart` to call the data initializer at app startup
4. Update `community_discovery_screen.dart` to ensure it displays published communities
5. Test the community discovery flow to ensure predefined communities appear

## Debugging
After implementation, compile the project and verify:
- Predefined communities appear in the discovery screen
- Communities can be viewed and joined
- Filter and search functionality works with the predefined communities

Total files to modify: 5 (within the constraint of 10-12 files)
Template files needed: None
-------------------------------------------------------------------
# Firebase Integration for Faith and Grow App

Based on the current architecture of the Faith and Grow app, I'll provide a plan to connect it to Firebase backend services. This integration will replace the current local storage solutions with cloud-based Firebase services.

## Core Features to Implement

1. Firebase Authentication - Replace the mock auth with real Firebase Authentication
2. Cloud Firestore - Store users, communities, posts, and other data
3. Firebase Storage - Store images and other media files
4. Firebase initialization and configuration

## Technical Constraints

- Maximum 10-12 files total (we'll modify existing files when possible)
- Follow Faith and Grow branding (green, gold, black)
- Keep the overall user flow and UI the same
- Use proper error handling for network operations

## File Structure

### 1. `lib/services/firebase_service.dart` (new)
Core service for initializing and managing Firebase connections:
- Initialize Firebase app
- Configure Firebase services
- Provide helper methods for common Firebase operations

### 2. `lib/services/auth_service.dart` (modify existing or create)
Handle Firebase Authentication operations:
- Sign up with email/password
- Login with email/password
- Sign out
- Get current user
- Password reset

### 3. `lib/services/firestore_service.dart` (new)
Handle Firestore database operations:
- CRUD operations for users
- CRUD operations for communities
- CRUD operations for posts and comments
- CRUD operations for courses and businesses

### 4. `lib/services/storage_service.dart` (new)
Handle Firebase Storage operations:
- Upload images (profile, community covers)
- Get image download URLs
- Delete images

### 5. `lib/models/user_model.dart` (update)
Update the User model to work with Firebase:
- Add fromFirestore and toFirestore methods
- Update UserService to use Firebase Auth and Firestore

### 6. `lib/models/community_model.dart` (update)
Update Community model to work with Firestore:
- Add fromFirestore and toFirestore methods
- Update related methods to work with Firebase

### 7. `lib/models/content_model.dart` (update)
Update Content models to work with Firestore:
- Add fromFirestore and toFirestore methods for Post, Comment, Course, etc.

### 8. `android/app/build.gradle` (update)
Update the Android configuration for Firebase.

### 9. `ios/Podfile` and `ios/Runner.xcodeproj` (update)
Update iOS configuration for Firebase.

### 10. `lib/main.dart` (update)
Update the main entry point to initialize Firebase.

## Implementation Plan

### Phase 1: Firebase Setup
1. Add Firebase dependencies to pubspec.yaml
2. Initialize Firebase in main.dart
3. Create the core firebase_service.dart file

### Phase 2: Authentication Migration
1. Create/update auth_service.dart to use Firebase Authentication
2. Update User model and UserService to work with Firebase
3. Update auth screens to use new authentication service

### Phase 3: Data Storage Migration
1. Create firestore_service.dart for database operations
2. Create storage_service.dart for file storage
3. Update models to work with Firestore

### Phase 4: Migrate Existing Services
1. Update all data service calls throughout the app
2. Ensure proper error handling for network operations
3. Implement offline capability with Firestore caching

### Phase 5: Testing and Refinement
1. Test all Firebase operations
2. Verify authentication flow
3. Verify data persistence and retrieval
4. Debug any issues with the app compilation

## Template Files Needed
- image_upload (for uploading images to Firebase Storage)

Total Files: 10 (within the constraint of 10-12 files)
-------------------------------------------------------------------
# Payment Page for Community Creation - Faith and Grow App

## Overview
I'll create a payment page that showcases the benefits of creating and monetizing a community within the Faith and Grow app. This page will present payment tiers for community creation and connect to the existing community creation flow.

## Core Features
1. Benefits showcase - Highlight the value of creating a community
2. Payment tier selection - Different pricing options for community creation
3. Payment processing (mock) - Handle the payment transaction
4. Seamless navigation to community creation

## Technical Constraints
- Maximum 10-12 files (we'll primarily modify existing files)
- Use Firebase for payment data storage
- Follow Faith and Grow branding (green, gold, black)

## Implementation Plan

### New Files:
1. `lib/screens/community_payment_screen.dart` - The main payment page showing benefits and payment options

### Modifications to Existing Files:
1. `lib/screens/dashboard_tab.dart` - Add navigation to the payment page
2. `lib/screens/home_screen.dart` - Update to include the payment page in navigation
3. `lib/services/community_service.dart` - Add methods for processing community creation payments

## Detailed Implementation

### 1. `lib/screens/community_payment_screen.dart`
This will be the main payment page with the following sections:
- Hero section with compelling headline
- Benefits of creating a community (with visuals)
- Pricing tiers for community creation
- Payment form (card information)
- Action button to process payment and continue to community creation

The page will use animations for a modern feel and include testimonials if space permits.

### 2. `lib/screens/dashboard_tab.dart`
Add a new action button or card to navigate to the community payment page.

### 3. `lib/screens/home_screen.dart`
Ensure the payment page is accessible from the main navigation.

### 4. `lib/services/community_service.dart`
Add functionality to process payments for community creation.

## User Flow
1. User navigates to the community payment page from dashboard or home screen
2. User reviews benefits and pricing options
3. User selects a pricing tier and enters payment information
4. User submits payment
5. Upon successful payment, user is redirected to community creation screen

## Implementation Details

### Payment Tiers
The payment page will offer three tiers:
- Basic Creator ($49/month) - Basic community creation features
- Pro Creator ($99/month) - Enhanced features and customization
- Premium Creator ($199/month) - All features, priority support, analytics

### Firebase Integration
We'll store payment records in Firestore with the following structure:
- Collection: 'community_payments'
- Document fields: userId, amount, plan, status, createdAt

## Debugging
After completion, we'll test the payment flow and ensure proper navigation to the community creation process.

## Template Files Needed
- None (we'll use existing UI components)

Total Files: 4 (1 new + 3 modifications) - well within the constraint of 10-12 files
-------------------------------------------------------------------
# Faith and Grow - Community Payment Screen Enhancement

## Overview
I'll create a compelling payment screen that showcases the benefits of creating a community within the Faith and Grow app. This screen will highlight three subscription tiers (Community, Growth, and Mastermind) that align with the provided requirements. The screen will emphasize the value proposition for each tier and connect users to the community creation flow when they select a plan.

## Core Features
1. **Tier Comparison Section** - Display the three subscription tiers with features and pricing
2. **Value Proposition** - Highlight the benefits of creating a community
3. **Seamless Integration** - Connect to the existing community creation flow
4. **Visual Appeal** - Use animations and clean design to enhance the user experience

## Technical Constraints
- Adhere to the 10-12 file maximum (by updating existing files)
- Use Firebase for authentication and Firestore for database
- Follow Faith and Grow branding (green, gold, black)
- Support dark/light mode through the existing theme system

## File Structure

### Existing Files to Modify:

1. **`lib/screens/community_payment_screen.dart`**
   - Complete redesign of this file to match the new subscription model
   - Implement three pricing tiers: Community ($47/month), Growth ($97/month), and Mastermind ($297/month)
   - Show features for each tier as specified
   - Add visual indicators for the "Most Popular" tier
   - Connect payment buttons to appropriate actions

2. **`lib/services/community_service.dart`**
   - Update payment processing methods to handle the new tier structure
   - Add logic to check eligibility for community creation based on subscription tier

3. **`lib/screens/dashboard_tab.dart`**
   - Ensure proper navigation to the payment screen
   - Update UI to reflect user's current subscription tier

4. **`lib/main.dart`**
   - Update app title to reflect the app's purpose

### Template Files Required:
- None - will use existing UI components

## Implementation Plan

### 1. Community Payment Screen
The central piece of this implementation will be updating the community_payment_screen.dart file to display:

- **Header Section**: Title, subtitle, and compelling introduction
- **Pricing Tier Grid**: Three columns for different subscription levels
  - Community Tier ($47/month) - Basic access without community creation
  - Growth Tier ($97/month) - Full access with ability to create ONE community
  - Mastermind Tier ($297/month) - Elite access with ability to create MULTIPLE communities
- **Feature Comparison**: Checkmarks showing which features are available in each tier
- **Subscription Buttons**: "Get Started" for Community and Growth, "Apply Now" for Mastermind
- **FAQ Section**: Address common questions about community creation

The design will follow Material Design guidelines with Faith and Grow branding colors (green, gold, black) and support both light and dark modes using the existing theme system.

### 2. Community Service Updates
I'll update the community_service.dart file to:

- Add logic to verify a user's subscription tier before allowing community creation
- Process payments for the different tiers
- Store subscription information in Firestore

### 3. Dashboard Integration
Update dashboard_tab.dart to:

- Show subscription status
- Provide clear navigation to the payment screen
- Conditionally display community creation options based on subscription status

### 4. Main App Updates
Update main.dart to reflect the app's purpose and ensure proper theme application.

## User Flow
1. User navigates to the payment screen from dashboard
2. User views the different subscription tiers and their benefits
3. User selects a tier and clicks the corresponding button
4. For Community and Growth tiers: User enters payment information
5. For Mastermind tier: User is directed to an application form
6. After successful payment or application, user receives confirmation
7. Growth and Mastermind subscribers can proceed to community creation

## Debugging
After implementation, we'll compile the project and verify:
- All tier features are correctly displayed
- Proper navigation between screens
- Conditional display of community creation options based on subscription
- Theme consistency in both light and dark modes

Total files to modify: 4 (within the constraint of 10-12 files)
-------------------------------------------------------------------
# Admin Portal for Faith and Grow App

## Overview
This implementation will add an admin portal to the Faith and Grow app, providing administrators with comprehensive control over users, communities, content, and platform settings. The admin portal will be accessible only to users with admin privileges and will provide tools for community management, user administration, content moderation, and analytics.

## Core Features
1. Admin Authentication & Authorization
2. Admin Dashboard with Overview Metrics
3. User Management (view, add, edit, delete users)
4. Community Management (approve, edit, delete communities)
5. Content Moderation (review, approve, remove posts)
6. Subscription Management

## Technical Constraints
- Maximum 10-12 files total (will modify existing files when possible)
- Use Firebase Authentication and Firestore for data storage
- Follow Faith and Grow branding (green, gold, black)
- Implement proper role-based access control

## File Structure

### New Files:

1. `lib/screens/admin/admin_dashboard_screen.dart`
   - Main admin dashboard with overview stats
   - Navigation to various admin functions
   - Quick action buttons for common tasks
   - Real-time metrics display

2. `lib/screens/admin/user_management_screen.dart`
   - List, search, and filter users
   - View user details including membership status
   - Edit user information and subscription tier
   - Delete or suspend user accounts
   - Assign admin privileges

3. `lib/screens/admin/community_management_screen.dart`
   - List, search, and filter communities
   - Approve or reject new communities
   - Edit community details and settings
   - Delete or suspend communities
   - View community metrics and activity

4. `lib/services/admin_service.dart`
   - Admin-specific operations and data access
   - Role verification and permission checking
   - Admin action auditing
   - Batch operations for admin tasks

### Modifications to Existing Files:

1. `lib/models/user_model.dart`
   - Add admin role field and admin-specific properties
   - Add methods for admin permission checks

2. `lib/services/firebase_service.dart`
   - Add admin-specific security rules and queries
   - Implement admin-level data access

3. `lib/services/auth_service.dart`
   - Add admin authentication and verification
   - Implement role-based access control

4. `lib/services/firestore_service.dart`
   - Add admin-specific database operations
   - Implement data validation and sanitization

5. `lib/screens/home_screen.dart`
   - Add admin portal access for admin users
   - Create navigation path to admin screens

6. `firestore.rules`
   - Update security rules to include admin permissions
   - Create role-based access controls

## Implementation Plan

### Phase 1: Admin Authentication and Role Management
1. Update user model to include admin role
2. Modify authentication service to check for admin privileges
3. Update Firestore security rules for admin access
4. Create basic admin detection in the home screen

### Phase 2: Admin Dashboard
1. Create the admin dashboard screen with metrics overview
2. Implement navigation to admin features
3. Add real-time statistics tracking

### Phase 3: User Management
1. Create user management screen
2. Implement user listing, searching, and filtering
3. Add user detail view with edit capabilities
4. Implement user role management

### Phase 4: Community Management
1. Create community management screen
2. Implement community approval workflow
3. Add community editing and moderation tools
4. Implement community metrics display

### Phase 5: Integration and Testing
1. Connect all admin screens to the main app
2. Test all admin functions with various permission levels
3. Verify security rules are properly enforced
4. Debug and optimize admin operations

## Data Schema Enhancements

### User Collection
- Add `isAdmin` boolean field
- Add `adminLevel` field for tiered admin permissions
- Add `lastAdminAction` timestamp

### Admin Actions Collection (new)
- Store audit trail of admin activities
- Fields: actionType, adminId, targetId, timestamp, details

### Application Settings Collection (new)
- Store global application settings
- Allow admins to configure app-wide parameters

## Security Considerations
- Implement strict admin role verification on all admin endpoints
- Create detailed audit trail of all admin actions
- Apply principle of least privilege for different admin levels
- Validate all admin operations server-side

## Template Files Needed
None - we will build on existing UI components.

Total Files: 10 (4 new + 6 modifications) - within the constraint of 10-12 files
-------------------------------------------------------------------
# Error Notification and Typography Redesign for Community Platform

## Overview
This project will redesign the error notification system and typography for the "Review & Launch" page of a community platform. The current implementation shows intrusive error messages and inconsistent typography that hampers user experience. We'll create a more user-friendly notification system and establish a clear typographic hierarchy.

## Core Features
1. Non-intrusive error notifications with improved messaging
2. Consistent typography system with clear hierarchy
3. Improved button styling and readability
4. Accessibility improvements throughout

## Technical Constraints
- Maximum of 10-12 files total
- Follow Material Design principles
- Maintain compatibility with both light and dark themes
- Ensure all text is accessible and meets WCAG guidelines

## File Structure

### 1. `lib/theme.dart` (update existing)
Update the typography theme to establish a clear hierarchy with consistent sizes, weights, and spacing.

### 2. `lib/widgets/error_notification.dart` (new)
Implement three error notification styles:
- Toast notifications
- Dismissible banners
- Inline error messages

### 3. `lib/screens/community_review_launch_screen.dart` (update existing)
Update the screen to implement the new error handling and typography.

### 4. `lib/widgets/common_widgets.dart` (update existing)
Update any shared components that need typography improvements.

### 5. `lib/utils/error_messages.dart` (new)
Create user-friendly error messages with actionable suggestions.

## Implementation Plan

### Phase 1: Typography System Update
1. Define a clear typographic scale in theme.dart
2. Apply consistent text styles across headers, body text, and buttons
3. Ensure proper contrast and readability for all text elements

### Phase 2: Error Notification System
1. Implement the ErrorNotification widget with multiple display options
2. Create user-friendly error message templates
3. Add animation for smooth appearance/disappearance
4. Ensure notifications are properly announced by screen readers

### Phase 3: Screen Updates
1. Update the Review & Launch screen to use the new typography system
2. Implement the new error notification system
3. Improve button styling and text readability

### Phase 4: Testing and Refinement
1. Test error notifications in various scenarios
2. Verify typography consistency across different screen sizes
3. Ensure all components meet accessibility standards
4. Debug any issues with the implementation

## Specific Implementation Details

### Typography System
The updated typography system will include:
- Clear heading hierarchy (H1, H2, H3)
- Consistent body text sizing
- Improved button text legibility
- Proper line-height and spacing for readability

### Error Notification Options
1. **Toast Notification**:
   - Appears in the bottom center of the screen
   - Auto-dismisses after 5 seconds
   - Can be manually dismissed
   - Non-blocking of UI elements

2. **Dismissible Banner**:
   - Appears at the top of the content area
   - Includes a dismissal button
   - Remains visible until dismissed
   - Does not block interaction with the page

3. **Inline Error**:
   - Appears near the action that triggered the error
   - Provides specific guidance for resolution
   - Visually connected to the relevant action

### User-Friendly Error Messages
Rewrite technical error messages to be:
- Clear and concise
- Action-oriented
- Free of technical jargon
- Helpful for resolution

## Template Files Needed
- None - we'll update existing files and create new ones

This implementation will significantly improve the user experience by making error messages less intrusive and more helpful, while establishing a clear and consistent typographic hierarchy throughout the application.