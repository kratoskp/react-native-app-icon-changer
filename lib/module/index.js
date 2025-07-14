"use strict";

import { NativeModules, Platform } from 'react-native';
const LINKING_ERROR = `The package 'react-native-icon-change-v2' doesn't seem to be linked. Make sure: \n\n` + Platform.select({
  ios: "- You have run 'pod install'\n",
  default: ''
}) + '- You rebuilt the app after installing the package\n' + '- You are not using Expo Go\n';
const DynamicIconManager = NativeModules.DynamicIconManager ? NativeModules.DynamicIconManager : new Proxy({}, {
  get() {
    throw new Error(LINKING_ERROR);
  }
});
export function setIcon(icon) {
  return DynamicIconManager.setIcon(icon);
}
export function getAllAlternativeIcons() {
  return DynamicIconManager.getAllAlternativeIcons();
}
export function resetIcon() {
  return DynamicIconManager.resetIcon();
}
export function getActiveIcon() {
  return DynamicIconManager.getActiveIcon();
}
//# sourceMappingURL=index.js.map