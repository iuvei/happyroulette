package com.lzstudio.common.functions;

import org.cocos2dx.lib.Cocos2dxActivity;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.util.Log;

import com.lzstudio.common.ActivityBase;

public class GetVersionName {

	public static String sAppVersionName = "";
	private static Cocos2dxActivity sActivity;
	
	public static String getAppVersionName() {
		if (GetVersionName.sAppVersionName == "") {			
			try {
				sActivity = ActivityBase.getContext();
				PackageInfo info = sActivity.getPackageManager().getPackageInfo(sActivity.getPackageName(), 0);
				GetVersionName.sAppVersionName = info.versionName;
				
				Log.d("LuaJavaBridge", "getAppVersionName.........." + GetVersionName.sAppVersionName);
			} catch (NameNotFoundException e) {
				e.printStackTrace();
			}
		}
		return GetVersionName.sAppVersionName;
	}
}
