package com.appiconchanger

import android.app.Activity
import android.app.Application
import android.content.ComponentName
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.annotation.NonNull
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.WritableArray
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = AppIconChangerModule.NAME)
class AppIconChangerModule(
    reactContext: ReactApplicationContext,
    private val packageName: String
) : ReactContextBaseJavaModule(reactContext), Application.ActivityLifecycleCallbacks {

    companion object {
        const val NAME = "DynamicIconManager"
        private const val MAIN_ACTIVITY_BASE_NAME = ".MainActivity"
    }

    private val classesToKill: MutableSet<String> = mutableSetOf()
    private var componentClass: String = ""

    override fun getName(): String {
        return NAME
    }

    @ReactMethod
    fun getActiveIcon(promise: Promise) {
        val activity: Activity? = currentActivity
        if (activity == null) {
            promise.reject("ACTIVITY_NOT_FOUND", "Activity was not found")
            return
        }

        val activityName = activity.componentName.className

        if (activityName.endsWith(MAIN_ACTIVITY_BASE_NAME)) {
            promise.resolve("Default")
            return
        }

        val activityNameSplit = activityName.split("MainActivity").toTypedArray()
        if (activityNameSplit.size != 2) {
            promise.reject("ANDROID:UNEXPECTED_COMPONENT_CLASS", componentClass)
            return
        }
        promise.resolve(activityNameSplit[1])
    }

    @ReactMethod
    fun getAllAlternativeIcons(promise: Promise) {
        try {
            val packageManager = reactApplicationContext.packageManager
            val packageInfo = packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_ACTIVITIES or PackageManager.GET_META_DATA or PackageManager.GET_DISABLED_COMPONENTS
            )

            val aliasList: WritableArray = Arguments.createArray()

            packageInfo.activities?.forEach { activityInfo ->
                if (activityInfo.targetActivity != null) {
                    aliasList.pushString(activityInfo.name.replace("$packageName$MAIN_ACTIVITY_BASE_NAME", ""))
                }
            }

            promise.resolve(aliasList)
        } catch (e: Exception) {
            promise.reject("ERROR", e)
        }
    }

    private fun completeIconChange() {
        val activity = currentActivity ?: return

        for (className in classesToKill) {
            activity.packageManager.setComponentEnabledSetting(
                ComponentName(packageName, className),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
        }
        classesToKill.clear()
    }

    @ReactMethod
    fun setIcon(iconName: String?, promise: Promise) {
        val activity = currentActivity
        if (activity == null) {
            promise.reject("ACTIVITY_NOT_FOUND", "The activity is null. Check if the app is running properly.")
            return
        }

        if (iconName.isNullOrEmpty()) {
            promise.reject("EMPTY_ICON_STRING", "Icon name is missing i.e. setIcon('YOUR_ICON_NAME_HERE')")
            return
        }

        if (componentClass.isEmpty()) {
            componentClass = activity.componentName.className
        }

        val newIconName = if (iconName.isEmpty()) "Default" else iconName
        val activeClass = "$packageName$MAIN_ACTIVITY_BASE_NAME$newIconName"

        if (componentClass == activeClass) {
            promise.reject("ICON_ALREADY_USED", "This icon is the current active icon. $componentClass")
            return
        }

        try {
            val pm = activity.packageManager

            // --- Disable ALL aliases first ---
            val packageInfo = pm.getPackageInfo(
                packageName,
                PackageManager.GET_ACTIVITIES or PackageManager.GET_META_DATA or PackageManager.GET_DISABLED_COMPONENTS
            )

            packageInfo.activities?.forEach { activityInfo ->
                if (activityInfo.targetActivity != null) { // it's an alias
                    pm.setComponentEnabledSetting(
                        ComponentName(packageName, activityInfo.name),
                        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP
                    )
                }
            }

            // --- Enable the chosen one ---
            pm.setComponentEnabledSetting(
                ComponentName(packageName, activeClass),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )

            promise.resolve("Your icon changed to $iconName")
        } catch (e: Exception) {
            promise.reject("ICON_INVALID", e.localizedMessage)
            return
        }

        componentClass = activeClass
    }


    @ReactMethod
    fun resetIcon(promise: Promise) {
        setIcon("Default", promise)
    }

    override fun onActivityPaused(activity: Activity) {}

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}

    override fun onActivityStarted(activity: Activity) {}

    override fun onActivityResumed(activity: Activity) {}

    override fun onActivityStopped(activity: Activity) {
        completeIconChange()
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}

    override fun onActivityDestroyed(activity: Activity) {
        completeIconChange()
    }
}
