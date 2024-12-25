import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-icon-change-v2' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const DynamicIconManager = NativeModules.DynamicIconManager
  ? NativeModules.DynamicIconManager
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function setIcon(icon: string | null): Promise<void> {
  return DynamicIconManager.setIcon(icon);
}
export function getAllAlternativeIcons(): Promise<string[]> {
  return DynamicIconManager.getAllAlternativeIcons();
}
export function resetIcon(): Promise<string> {
  return DynamicIconManager.resetIcon();
}
export function getActiveIcon(): Promise<string> {
  return DynamicIconManager.getActiveIcon();
}
