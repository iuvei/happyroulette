package com.lzstudio.common.functions;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.provider.MediaStore;
import android.util.Log;

import com.lzstudio.common.ActivityBase;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

public class GetVersion {

    private static final String TAG = "GetVersion";
    private static int callLuaGetVersionCallbackId = -1;

    // lua调用java
    public static void getVersion(int luaFunctionId) {
        Log.d(TAG, "getVersionOnLua luaFunctionId = " + luaFunctionId);
        if (callLuaGetVersionCallbackId != -1) {
            Cocos2dxLuaJavaBridge
                    .releaseLuaFunction(callLuaGetVersionCallbackId);
            callLuaGetVersionCallbackId = -1;
        }
        callLuaGetVersionCallbackId = luaFunctionId;


        String versionName = "";
        try {
            // ---get the package info---
            PackageManager pm = ActivityBase.getContext().getPackageManager();
            PackageInfo pi = pm.getPackageInfo(ActivityBase.getContext().getPackageName(), 0);
            versionName = pi.versionName;
            if (versionName == null || versionName.length() <= 0) {
                getVersionOnLua("1.0.0");
            }
        } catch (Exception e) {
            Log.e("VersionInfo", "Exception", e);
        }
        getVersionOnLua(versionName);
    }

    // java调用lua
    public static void getVersionOnLua(final String version) {
        Log.d(TAG, "getVersionOnLua version = " + version);
        ActivityBase.getContext().runOnGLThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaGetVersionCallbackId, version);
            }
        });
    }
}