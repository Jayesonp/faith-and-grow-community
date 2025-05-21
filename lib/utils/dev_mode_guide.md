# Developer Mode Troubleshooting Guide

## Overview

This guide will help you understand how Developer Mode works in the Faith and Grow app and how to properly enable it for community creation.

## Issues with Developer Mode

Developer Mode is designed to bypass payment verification when creating communities for testing purposes. However, there are a few common issues that can prevent Developer Mode from working correctly:

1. **Inconsistent SharedPreferences Settings**: The app may not be properly saving your Developer Mode preferences.

2. **Firestore Security Rules Conflicts**: Even when Developer Mode is enabled locally, Firestore security rules may still block community creation.

3. **User Document Missing Dev Mode Flag**: Your user document in Firestore may not have the correct dev_mode flags set.

## How to Fix Developer Mode

Follow these steps to properly enable Developer Mode:

### Step 1: Reset All Developer Settings

1. Go to the Developer Mode Debugger screen (accessible from Settings)
2. Click the "Reset All Developer Settings" button
3. This will clear any potentially conflicting settings in SharedPreferences

### Step 2: Force Enable Developer Mode

1. Click the "Force Enable Developer Mode" button
2. This will:
   - Enable Developer Mode locally
   - Enable Bypass Payment setting
   - Update your user document in Firestore with dev_mode privileges

### Step 3: Verify Settings

1. Refresh the page by pulling down
2. Verify that both "Developer Mode" and "Bypass Payment" toggles are ON
3. Check that your User Data shows:
   - subscriptionTier: dev_mode
   - canCreateCommunity: true
   - communityLimit: -1

### Step 4: Try Creating a Community

1. Return to the app and try creating a community
2. If you still encounter errors, return to the Debugger and check the error messages

## What Developer Mode Does

When properly enabled, Developer Mode:

1. Modifies SharedPreferences to mark you as a developer
2. Updates your user document in Firestore to have special privileges
3. Allows you to bypass the normal payment flow when creating communities
4. Sets your community limit to unlimited (-1)

## Common Errors and Solutions

### "Missing or insufficient permissions"

This usually means one of the following:

1. Your user document in Firestore doesn't have the proper dev_mode flag
2. The Firestore security rules are too restrictive

Solution: Use the "Force Enable Developer Mode" button which will update both your local settings and your Firestore user document.

### "Payment required" or "Subscription required"

This usually means:

1. The Bypass Payment setting is not enabled
2. The app is not checking the Developer Mode status correctly

Solution: Make sure both toggles are ON in the Developer Mode Debugger.

## For Developers

If you're a developer working on this app, here's what's happening under the hood:

1. Developer Mode settings are stored in SharedPreferences with keys:
   - dev_mode_enabled
   - bypass_payment_verification

2. The DevModeService checks these settings when community creation is attempted

3. The Firestore security rules check for the 'dev_mode' subscription tier in the user document

The improved Developer Mode implementation ensures all these systems work together properly.