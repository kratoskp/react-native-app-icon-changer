"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.getActiveIcon = getActiveIcon;
exports.getAllAlternativeIcons = getAllAlternativeIcons;
exports.resetIcon = resetIcon;
exports.setIcon = setIcon;
var _reactNative = require("react-native");
const LINKING_ERROR = `The package 'react-native-icon-change-v2' doesn't seem to be linked. Make sure: \n\n` + _reactNative.Platform.select({
  ios: "- You have run 'pod install'\n",
  default: ''
}) + '- You rebuilt the app after installing the package\n' + '- You are not using Expo Go\n';
const DynamicIconManager = _reactNative.NativeModules.DynamicIconManager ? _reactNative.NativeModules.DynamicIconManager : new Proxy({}, {
  get() {
    throw new Error(LINKING_ERROR);
  }
});
function setIcon(icon) {
  return DynamicIconManager.setIcon(icon);
}
function getAllAlternativeIcons() {
  return DynamicIconManager.getAllAlternativeIcons();
}
function resetIcon() {
  return DynamicIconManager.resetIcon();
}
function getActiveIcon() {
  return DynamicIconManager.getActiveIcon();
}
//# sourceMappingURL=index.js.map